# MBShare
把微信分享和微博分享封装了一下，用起来很简单

举个例子
``` objc
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
```
集成请分别参考微博和微信的集成，如果有人用，如果需要支持更多的平台或者需要更多的功能请联系我

![Alt text](/MBShare/Screen Shot.png)
