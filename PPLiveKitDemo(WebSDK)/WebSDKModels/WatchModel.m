//
//  WatchModel.m
//  PPLiveKitDemo(WebSDK)
//
//  Created by admin on 2016/10/21.
//  Copyright © 2016年 高国栋. All rights reserved.
//

#import "WatchModel.h"

@implementation RTMPModel
@end

@implementation WatchModel

+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass{
    return @{
             @"rtmpsUrl" : [RTMPModel class],
             };
}
@end
