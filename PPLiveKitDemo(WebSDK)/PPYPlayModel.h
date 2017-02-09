//
//  PPYPlayModel.h
//  PPLiveKitDemo(WebSDK)
//
//  Created by jacksimjia on 2017/2/8.
//  Copyright © 2017年 高国栋. All rights reserved.
//

#import "PPYBaseModel.h"

@class PPYPlayRTMPModel,PPYPLayM3U8Model;

@interface PPYPlayModel : PPYBaseModel
@property (nonatomic, strong) NSString *channelWebID;/**<视频webid*/

@property (nonatomic, assign) NSInteger channelType;/**<视频类型(1:点播;2:直播)*/
@property (nonatomic, strong) NSString *rtmpURL;/**<直播rtmp协议播放地址*/
@property (nonatomic, strong) NSString *hdlURL;/**<直播HDL协议播放地址*/
@property (nonatomic, strong) NSString *m3u8URL;/**<直播/点播 HLS协议播放地址*/


@property (nonatomic, strong) NSArray <PPYPlayRTMPModel *>*rtmpsURLArray;/**<直播rtmp多码流播放地址*/
@property (nonatomic, strong) NSArray <PPYPLayM3U8Model *>*m3u8sURLArray;/**<直播码率rtmp协议播放地址*/

+ (NSString *)getNameForFt:(NSInteger)ft;
+ (NSInteger)getFtForName:(NSString *)name;
@end


@interface PPYPlayRTMPModel : PPYBaseModel
@property (nonatomic, assign) NSInteger ft;/**<0:原画;[1~4]码率依次提升*/
@property (nonatomic, strong) NSString *rtmpURL;/**<直播码率唯一标*/
@property (nonatomic, strong) NSString *name;/**<直播码率唯一标*/
@property (nonatomic, strong) NSString *ftCN;/**<直播流码率中文描述(默认列表-流畅/高清/超清/蓝光/原画)*/
@end

@interface PPYPLayM3U8Model : PPYBaseModel
@property (nonatomic, assign) NSInteger ft; /**<0:原画;[1~4]码率依次提升*/
@property (nonatomic, strong) NSString *m3u8URL;/**<直播码率HLS协议播放地址*/
@end
