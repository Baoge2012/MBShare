//
//  MBShareMessage.h
//  MBShare
//
//  Created by Mingbao on 7/12/16.
//  Copyright © 2016 qiyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, kShareType) {
    kShareTypeWeibo,
    kShareTypeWechatSession,
    kShareTypeWechatTimeline
};

@interface MBShareMessage : NSObject

+ (instancetype) messageWithType: (kShareType) type;

// 不为nil其它属性会被忽略
@property (nonatomic, copy) NSString *text;

//当text为空时,以下内容有效

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, copy) NSString *url;

@property (nonatomic, assign, readonly) kShareType type;

- (void) share;
- (id) generateMessage;

@end
