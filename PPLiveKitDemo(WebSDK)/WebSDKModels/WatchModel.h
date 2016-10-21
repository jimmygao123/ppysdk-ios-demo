//
//  WatchModel.h
//  PPLiveKitDemo(WebSDK)
//
//  Created by admin on 2016/10/21.
//  Copyright © 2016年 高国栋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+YYModel.h"

@interface RTMPModel : NSObject
@property (copy, nonatomic) NSString *rtmpUrl;
@property (assign, nonatomic) int ft;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *ftCn;
@end

@interface WatchModel : NSObject
@property (copy, nonatomic) NSString *channelWebId;
@property (copy, nonatomic) NSString *rtmpUrl;
@property (copy, nonatomic) NSString *hdlUrl;
@property (copy, nonatomic) NSString *m3u8Url;
@property (copy, nonatomic) NSArray *rtmpsUrl;  //<RTMPModel *>
@end
