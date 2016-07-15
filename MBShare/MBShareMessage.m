//
//  MBShareMessage.m
//  MBShare
//
//  Created by Mingbao on 7/12/16.
//  Copyright © 2016 qiyi. All rights reserved.
//

#import "MBShareMessage.h"
#import "WeiboSDK.h"
#import "WXApi.h"

@interface MBShareMessage ()

- (NSData *) compressImageTo32k: (UIImage *) image;

@end

@interface MBWeiboMessage : MBShareMessage

@end
@implementation MBWeiboMessage

- (void) share
{
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = @"https://api.weibo.com/oauth2/default.html";
    authRequest.scope = @"all";
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:[self generateMessage] authInfo:authRequest access_token: nil];
    request.userInfo = @{@"From": @"MBShare",
                         @"identifier": [NSString stringWithFormat:@"com.mbshare.%f", [[NSDate date] timeIntervalSince1970]]};
    [WeiboSDK sendRequest:request];
}

- (id) generateMessage
{
    WBMessageObject *message = [WBMessageObject message];
    
    message.text = self.text;
    if (self.text == nil)
    {
        if (self.url)
        {
            WBWebpageObject *webpageObj = [WBWebpageObject object];
            webpageObj.webpageUrl = self.url;
            webpageObj.title = self.title;
            webpageObj.description = self.desc;
            webpageObj.objectID = [NSUUID UUID].UUIDString;
            if (self.thumbnailImage)
            {
                webpageObj.thumbnailData = [self compressImageTo32k: self.thumbnailImage];
            }
            message.mediaObject = webpageObj;
        }
        else if (self.image)
        {
            WBImageObject *image = [WBImageObject object];
            image.imageData = UIImageJPEGRepresentation(self.image, 0.8);
            message.imageObject = image;
        }
    }
    
    if (message.text == nil && message.imageObject == nil && message.mediaObject == nil)
    {
        NSLog(@"MBShareApi:微博分享内容不能为空");
    }
    return message;
}

@end

@interface MBWechatSessionMessage : MBShareMessage


@end
@implementation MBWechatSessionMessage

- (void) share
{
    SendMessageToWXReq *msg = [self generateMessage];
    [WXApi sendReq: msg];
}

- (id) generateMessage
{
    SendMessageToWXReq *msg = [[SendMessageToWXReq alloc] init];
    msg.text = self.text;
    msg.bText = self.text.length > 0 ? YES : NO;
    msg.scene = WXSceneSession;
    if (self.image || self.url)
    {
        WXMediaMessage *media = [WXMediaMessage message];
        media.title = self.title;
        media.description = self.desc;
        if (self.thumbnailImage)
        {
            media.thumbData = [self compressImageTo32k: self.thumbnailImage];
        }
        if (self.url)
        {
            WXWebpageObject *webpageObj = [WXWebpageObject object];
            webpageObj.webpageUrl = self.url;
            media.mediaObject = webpageObj;
        }
        else if (self.image)
        {
            WXImageObject *image = [WXImageObject object];
            image.imageData = UIImageJPEGRepresentation(self.image, 0.8);
            media.mediaObject = image;
        }
        msg.message = media;
        
        if (media.mediaObject == nil)
        {
            NSLog(@"MBShareApi:微信分享内容不能为空");
        }
    }
    return msg;
}

@end


@interface MBWechatTimelineMessage : MBWechatSessionMessage

@end
@implementation MBWechatTimelineMessage

- (id) generateMessage
{
    SendMessageToWXReq *msg = [super generateMessage];
    msg.scene = WXSceneTimeline;
    return msg;
}

@end

@implementation MBShareMessage

+ (instancetype) messageWithType: (kShareType) type
{
    switch (type) {
        case kShareTypeWeibo:
            return [[MBWeiboMessage alloc] init];
            break;
        case kShareTypeWechatSession:
            return [[MBWechatSessionMessage alloc] init];
            break;
        case kShareTypeWechatTimeline:
            return [[MBWechatTimelineMessage alloc] init];
            break;
    }
}

- (kShareType) type
{
    if ([self isKindOfClass: [MBWechatTimelineMessage class]])
    {
        return kShareTypeWechatTimeline;
    } else if ([self isKindOfClass: [MBWechatSessionMessage class]])
    {
        return kShareTypeWechatSession;
    }
    return kShareTypeWeibo;
}

- (NSData *) compressImageTo32k: (UIImage *) image
{
    CGFloat fractor = 1;
    NSData *thumbnailData = UIImageJPEGRepresentation(image, fractor);
    while (thumbnailData.length > 1024*32)
    {
        fractor *= 0.8;
        thumbnailData = UIImageJPEGRepresentation(self.thumbnailImage, fractor);
    }
    return thumbnailData;
}

- (void) share
{
    NSAssert(NO, @"this method must be override");
}

- (id) generateMessage
{
    NSAssert(NO, @"this method must be override");
    return nil;
}

@end

