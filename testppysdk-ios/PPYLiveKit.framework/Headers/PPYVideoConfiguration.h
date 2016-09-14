//
//  PPYVideoConfiguration.h
//  PPYLiveKit
//
//  Created by Jimmy on 16/8/22.
//  Copyright © 2016年 高国栋. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
typedef NS_ENUM( NSUInteger, PPYCaptureSessionPreset){
    PPYCaptureSessionPreset360x640 = 0,
    PPYCaptureSessionPreset540x960 = 1,
    PPYCaptureSessionPreset720x1280 = 2,
    PPYCaptureSessionPresetDefault = PPYCaptureSessionPreset540x960,
};

typedef NS_ENUM(NSUInteger, PPYCaptureFPS){
    PPYCaptureFPSLow = 15,
    PPYCaptureFPSMedium = 24,
    PPYCaptureFPSHigh = 30
};

typedef NS_ENUM(NSUInteger, PPYVideoQuality){
    /// 分辨率： 360 *640 帧数：15 码率：500Kps
    PPYVideoQuality_Low1 = 0,
    /// 分辨率： 360 *640 帧数：24 码率：800Kps
    PPYVideoQuality_Low2 = 1,
    /// 分辨率： 360 *640 帧数：30 码率：800Kps
    PPYVideoQuality_Low3 = 2,
    /// 分辨率： 540 *960 帧数：15 码率：800Kps
    PPYVideoQuality_Medium1 = 3,
    /// 分辨率： 540 *960 帧数：24 码率：800Kps
    PPYVideoQuality_Medium2 = 4,
    /// 分辨率： 540 *960 帧数：30 码率：800Kps
    PPYVideoQuality_Medium3 = 5,
    /// 分辨率： 720 *1280 帧数：15 码率：1000Kps
    PPYVideoQuality_High1 = 6,
    /// 分辨率： 720 *1280 帧数：24 码率：1200Kps
    PPYVideoQuality_High2 = 7,
    /// 分辨率： 720 *1280 帧数：30 码率：1200Kps
    PPYVideoQuality_High3 = 8,
    /// 默认配置
    PPYVideoQuality_Default = PPYVideoQuality_Low2
};

@interface PPYVideoConfiguration : NSObject


+(instancetype)defalutVideoConfiguration;
+(instancetype)videoConfigurationWithVideoQuality:(PPYVideoQuality)videoQuality;
+(instancetype)videoConfigurationWithPreset:(PPYCaptureSessionPreset)videoPreset andFPS:(PPYCaptureFPS)fps andBirate:(int)bitrate; //kbps

@property (nonatomic, assign) int fps;
@property (nonatomic, assign) int birate;
@property (nonatomic, assign) PPYCaptureSessionPreset capturePreset;

@property (nonatomic, assign) CGSize videoSize;
@property (nonatomic, copy, readonly) NSString *avCapturePreset;


@end
