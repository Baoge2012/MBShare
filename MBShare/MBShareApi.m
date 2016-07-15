//
//  MBShareApi.m
//  MBShare
//
//  Created by Mingbao on 7/12/16.
//  Copyright © 2016 qiyi. All rights reserved.
//

#import "MBShareApi.h"
#import "WeiboSDK.h"
#import "WXApi.h"
#import "MBShareMessage.h"
#import <objc/runtime.h>

@interface MBShareApi ()<WeiboSDKDelegate, WXApiDelegate>

+ (instancetype) shareInstance;

@property (nonatomic, strong) NSMutableDictionary *globalSettings;

@property (nonatomic, copy) MBShareCompleteCallback callback;

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;

@end

BOOL handleOpenUrl(id self, SEL cmd, UIApplication *application, NSURL *url)
{
    return [[MBShareApi shareInstance] application: application handleOpenURL: url];
}

@implementation MBShareApi

+ (instancetype) shareInstance
{
    static MBShareApi *__instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __instance = [[MBShareApi alloc] init];
    });
    return __instance;
}

+ (void) registerAppKeys: (NSDictionary *) keys
{
    [[self shareInstance] registerAppKeys: keys];
    [WeiboSDK enableDebugMode: YES];
}

+ (BOOL) isAppInstalled: (NSString *) platform
{
    return [[self shareInstance] isAppInstalled: platform];
}

+ (void) shareMessage: (MBShareMessage *) msg complete: (MBShareCompleteCallback) complete
{
    [[self shareInstance] shareMessage: msg complete: complete];
}

- (instancetype) init
{
    if (self = [super init])
    {
        _globalSettings = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void) registerAppKeys: (NSDictionary *) keys
{
    NSArray *allKeys = keys.allKeys;
    for (NSString *key in allKeys)
    {
        NSString *lowercaseKey = key.lowercaseString;
        if ([lowercaseKey isEqualToString: @"weibo"])
        {
            [WeiboSDK registerApp: [keys objectForKey: key]];
        }
        else if ([lowercaseKey isEqualToString: @"wechat"]||[lowercaseKey isEqualToString: @"weixin"])
        {
            [WXApi registerApp: [keys objectForKey: key]];
        }
    }
}

- (BOOL) isAppInstalled: (NSString *) platform
{
    BOOL installed = NO;
    NSString *lowercasePlatform = platform.lowercaseString;
    if ([lowercasePlatform isEqualToString: @"weibo"])
    {
        installed = [WeiboSDK isWeiboAppInstalled];
    }
    else if ([lowercasePlatform isEqualToString: @"wechat"] || [lowercasePlatform isEqualToString: @"weixin"])
    {
        installed = [WXApi isWXAppInstalled];
    }
    return installed;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    id delegate = [UIApplication sharedApplication].delegate;
    IMP delegateIMP = class_getMethodImplementation([delegate class], @selector(application:handleOpenURL:));
    IMP mbIMP = class_getMethodImplementation([MBShareApi class], @selector(application:handleOpenURL:));
    if (delegateIMP == mbIMP)
    {//添加方法
        return [[MBShareApi shareInstance] handleOpenURL: url];
    }
    else
    {
        [[MBShareApi shareInstance] handleOpenURL: url];
        return [[MBShareApi shareInstance] application: application handleOpenURL: url];
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation
{
    id delegate = [UIApplication sharedApplication].delegate;
    IMP delegateIMP = class_getMethodImplementation([delegate class], @selector(application:openURL:sourceApplication:annotation:));
    IMP mbIMP = class_getMethodImplementation([MBShareApi class], @selector(application:openURL:sourceApplication:annotation:));
    if (delegateIMP == mbIMP)
    {//添加方法
        return [[MBShareApi shareInstance] handleOpenURL: url];
    }
    else
    {
        [[MBShareApi shareInstance] handleOpenURL: url];
        return [[MBShareApi shareInstance] application: application openURL: url sourceApplication: sourceApplication annotation: annotation];
    }
}

- (void) hookAppDelegate: (id) delegate
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL selector = @selector(application:handleOpenURL:);
        
        Class delegateClass = [delegate class];
        Class selfClass = [self class];
        
        Method method = class_getInstanceMethod(selfClass, selector);
        BOOL didAddMethod = class_addMethod(delegateClass, selector, class_getMethodImplementation(selfClass,selector), method_getTypeEncoding(method));
        if (!didAddMethod)
        {
            Method delegateMethod = class_getInstanceMethod(delegateClass, selector);
            method_exchangeImplementations(method, delegateMethod);
        }
        
        SEL openUrlSelector = @selector(application:openURL:sourceApplication:annotation:);
        Method openUrlmethod = class_getInstanceMethod(selfClass, openUrlSelector);
        
        BOOL didAddOpenUrlMethod = class_addMethod(delegateClass, openUrlSelector, class_getMethodImplementation(selfClass, openUrlSelector), method_getTypeEncoding(openUrlmethod));
        if (!didAddOpenUrlMethod)
        {
            Method delegateOpenUrlMethod = class_getInstanceMethod(delegateClass, openUrlSelector);
            method_exchangeImplementations(openUrlmethod, delegateOpenUrlMethod);
        }
    });
}

- (BOOL) handleOpenURL: (NSURL *) url
{
    if ([WXApi handleOpenURL: url delegate: self] || [WeiboSDK handleOpenURL: url delegate: self])
    {
        return YES;
    }
    return NO;
}

- (void) shareMessage: (MBShareMessage *) msg complete: (MBShareCompleteCallback) complete
{
    if (complete)
    {
        self.callback = complete;
    }
    [msg share];
}

- (void) completeShareMessage: (MBShareMessage *) msg state: (kMBShareState) state error: (NSError *) error
{
    if (self.callback)
    {
        self.callback(state, nil, error);
    }
}

#pragma WeiboSDK Delegate

-(void) onResp:(BaseResp*)resp
{
    kMBShareState state;
    NSError *error = nil;
    switch (resp.errCode) {
        case WXSuccess:
            state = kMBShareStateSuccess;
            break;
        case WXErrCodeUserCancel:
            state = kMBShareStateCancelled;
            error = [NSError errorWithDomain: @"MBShareApi::Weibo" code: resp.errCode userInfo: @{NSLocalizedDescriptionKey: @"微博分享被取消了"}];
            break;
        case WXErrCodeCommon:
            //            state = kMBShareStateFailed;
            //            break;
        case WXErrCodeSentFail:
            //            state = kMBShareStateFailed;
            //            break;
        case WXErrCodeAuthDeny:
            //            state = kMBShareStateFailed;
            //            break;
        case WXErrCodeUnsupport:
            state = kMBShareStateFailed;
            error = [NSError errorWithDomain: @"MBShareApi::Weibo" code: resp.errCode userInfo: (resp.errStr ? @{NSLocalizedDescriptionKey: resp.errStr} : nil)];
            break;
        default:
            break;
    }
    [self completeShareMessage: nil state: state error: nil];
}

#pragma WXApi Delegate

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    NSLog(@"request = %@", request);
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    kMBShareState state;
    NSError *error = nil;
    switch (response.statusCode) {
        case WeiboSDKResponseStatusCodeSuccess:
            state = kMBShareStateSuccess;
            break;
        case WeiboSDKResponseStatusCodeUserCancel:
            state = kMBShareStateCancelled;
            error = [NSError errorWithDomain: @"MBShareApi::Wechat" code: response.statusCode userInfo: response.userInfo];
            break;
        case WeiboSDKResponseStatusCodeSentFail:
            //            state = kMBShareStateFailed;
            //            break;
        case WeiboSDKResponseStatusCodeAuthDeny:
            //            state = kMBShareStateFailed;
            //            break;
        case WeiboSDKResponseStatusCodeUserCancelInstall:
            //            state = kMBShareStateFailed;
            //            break;
        case WeiboSDKResponseStatusCodeShareInSDKFailed:
            state = kMBShareStateFailed;
            error = [NSError errorWithDomain: @"MBShareApi::Wechat" code: response.statusCode userInfo: response.userInfo];
            break;
        default:
            state = kMBShareStateFailed;
            break;
    }
    [self completeShareMessage: nil state: state error: error];
}

@end

@interface UIApplication (MBShare)

@end

@implementation UIApplication (MBShare)

+ (void) load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        SEL originalSelector = @selector(setDelegate:);
        SEL swizzledSelector = @selector(mb_setDelegate:);
        
        Method originalMethod = class_getInstanceMethod(self, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
        
        BOOL didAddMethod =
        class_addMethod(self,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(self,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        
    });
}

- (void) mb_setDelegate: (id) delegate
{
    [[MBShareApi shareInstance] hookAppDelegate: delegate];
    [self mb_setDelegate: delegate];
}

@end
