//
//  ViewController.m
//  MBShare
//
//  Created by Mingbao on 7/12/16.
//  Copyright © 2016 qiyi. All rights reserved.
//

#import "ViewController.h"
#import "WeiboSDK.h"
#import "AppDelegate.h"
#import "WXApi.h"
#import "MBShareApi.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) shareWeibo
{
    MBShareMessage *message = [MBShareMessage messageWithType: kShareTypeWeibo];
//    message.title = @"超好用的分享组件，无需注册 @wua_wua2012";
//    message.desc = @"我正在用一个超好用的分享组件，只需要在要分享的平台注册就可以，使用起来也超级简单";
//    message.url = @"http://weibo.com/2458407017/profile";
//    message.image = [UIImage imageNamed: @"1468568782"];
//    message.thumbnailImage = message.image;
    message.text = @"超好用的分享组件，无需注册 @wua_wua2012";
    [MBShareApi shareMessage: message complete:^(kMBShareState state, NSDictionary *userInfo, NSError *error) {
        switch (state) {
            case kMBShareStateSuccess:
                NSLog(@"分享成功了");
                break;
            case kMBShareStateCancelled:
                NSLog(@"分享取消了 %@", error);
                break;
            case kMBShareStateFailed:
                NSLog(@"分享失败了 %@", error);
                break;
        }
    }];
}

- (IBAction) shareWechatSession
{
    MBShareMessage *message = [MBShareMessage messageWithType: kShareTypeWechatSession];
    message.title = @"超好用的分享组件，无需注册 wechat:MM523689";
    message.desc = @"我正在用一个超好用的分享组件，只需要在要分享的平台注册就可以，使用起来也超级简单";
    message.url = @"http://weibo.com/2458407017/profile";
    message.image = [UIImage imageNamed: @"1468568782"];
    message.thumbnailImage = message.image;
    [MBShareApi shareMessage: message complete:^(kMBShareState state, NSDictionary *userInfo, NSError *error) {
        switch (state) {
            case kMBShareStateSuccess:
                NSLog(@"分享成功了");
                break;
            case kMBShareStateCancelled:
                NSLog(@"分享取消了 %@", error);
                break;
            case kMBShareStateFailed:
                NSLog(@"分享失败了 %@", error);
                break;
        }
    }];
}

- (IBAction) shareWechatTimeline
{
    MBShareMessage *message = [MBShareMessage messageWithType: kShareTypeWechatTimeline];
    message.title = @"超好用的分享组件，无需注册 wechat:MM523689";
    message.desc = @"我正在用一个超好用的分享组件，只需要在要分享的平台注册就可以，使用起来也超级简单";
    message.url = @"http://weibo.com/2458407017/profile";
    message.image = [UIImage imageNamed: @"1468568782"];
    message.thumbnailImage = message.image;
    [MBShareApi shareMessage: message complete:^(kMBShareState state, NSDictionary *userInfo, NSError *error) {
        switch (state) {
            case kMBShareStateSuccess:
                NSLog(@"分享成功了");
                break;
            case kMBShareStateCancelled:
                NSLog(@"分享取消了 %@", error);
                break;
            case kMBShareStateFailed:
                NSLog(@"分享失败了 %@", error);
                break;
        }
    }];
}


@end
