//
//  PPYPlayModel.m
//  PPLiveKitDemo(WebSDK)
//
//  Created by jacksimjia on 2017/2/8.
//  Copyright © 2017年 高国栋. All rights reserved.
//

#import "PPYPlayModel.h"

@implementation PPYPlayModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"channelWebID"  : @"channel_web_id",
             @"channelType"  : @"channel_type",
             @"rtmpURL"  : @"rtmp_url",
             @"hdlURL": @"hdl_url",
             @"m3u8URL" : @"m3u8_url",
             @"rtmpsURLArray" : @"rtmps_url",
             @"m3u8sURLArray" : @"m3u8s_url"};
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"rtmpsURLArray" : [PPYPlayRTMPModel class],
             @"m3u8sURLArray" : [PPYPLayM3U8Model class]};
}

+ (NSString *)getNameForFt:(NSInteger)ft {
    NSString *name = @"原画";
    switch (ft) {
        case 0:
            name = @"原画";
            break;
        case 1:
            name = @"流畅";
            break;
        case 2:
            name = @"高清";
            break;
        case 3:
            name = @"超清";
            break;
        case 4:
            name = @"蓝光";
            break;
        default:
            name = @"原画";
            break;
    }
    return name;
}

+ (NSInteger)getFtForName:(NSString *)name {
    if (name == nil || ![name isKindOfClass:[NSString class]]) return 0;
    NSArray *data = @[@"原画",
                      @"流畅",
                      @"高清",
                      @"超清",
                      @"蓝光"];
    NSInteger index = [data indexOfObject:name];
    if (index != NSNotFound) {
        return index;
    }
    return 0;
}
@end




@implementation PPYPlayRTMPModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"rtmpURL"  : @"rtmp_url",
             @"ftCN"  : @"ft_cn"};
}
@end

@implementation PPYPLayM3U8Model

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"m3u8URL"  : @"m3u8_url"};
}
@end
