//
//  MBShareApi.h
//  MBShare
//
//  Created by Mingbao on 7/12/16.
//  Copyright © 2016 qiyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBShareMessage.h"

typedef NS_ENUM(NSUInteger, kMBShareState) {
    kMBShareStateSuccess = 0,
    kMBShareStateCancelled = -1,
    kMBShareStateFailed = -2
};

typedef void(^MBShareCompleteCallback)(kMBShareState state, NSDictionary *userInfo, NSError *error);

@interface MBShareApi : NSObject

/**
 * @brief 注册平台信息
 * @param keys 各个平台注册的Appkey
 * @description 示例
 *              @code     [MBShareApi registerAppKeys: @{@"Weibo": @"微博appkey", @"Wechat": @"微信appkey"}];
 */
+ (void) registerAppKeys: (NSDictionary *) keys;

/**
 * @brief 判断平台App是否安装(目前支持微信、微博)
 * @param platform 平台名称,支持weibo,wechat,不区分大小写
 * @description 示例
 *              @code [MBShareApi isAppInstalled: @"wechat"]
 */
+ (BOOL) isAppInstalled: (NSString *) platform;

/**
 * @brief 分享
 * @param msg 分享内容
 * @param complete分享完成之后的回调
 * @brief 示例
 *        @code MBShareMessage *message = [MBShareMessage messageWithType: kShareTypeWechatSession];
 message.title = @"永久免费的爱奇艺安全利器";
 message.desc = @"推荐你一个爱奇艺防盗神器，从此安全无忧";
 message.url = @"http://71.am/q7";
 message.image = [UIImage imageNamed: @"qis_download_qr"];
 message.thumbnailImage = message.image;
 [MBShareApi shareMessage: message complete:^(kMBShareState state, NSDictionary *userInfo, NSError *error) {
 NSLog(@"shareWeibo %@", @(state));
 }];
 
 */
+ (void) shareMessage: (MBShareMessage *) msg complete: (MBShareCompleteCallback) complete;

@end
