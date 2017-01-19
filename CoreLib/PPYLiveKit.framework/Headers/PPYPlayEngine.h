//
//  PPYPlayEngine.h
//  PPYLiveKit
//
//  Created by Jimmy on 16/9/19.
//  Copyright © 2016年 高国栋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(int,PPYSourceType){
    PPYSourceType_VOD = 1,    //m3u8
    PPYSourceType_Live = 2,   //rtmp, flv-http,
};

typedef NS_ENUM (int,PPYPlayEngineErrorType)  {
    PPYPlayEngineError_InvalidSourceURL,
    PPYPlayEngineError_ConnectFailed,
    PPYPlayEngineError_TransferFailed,
    PPYPlayEngineError_FatalError,
};

typedef NS_ENUM (int,PPYPlayEngineInfoType)  {
    PPYPlayEngineInfo_BufferingDuration,
    PPYPlayEngineInfo_RealBirate,
    PPYPlayEngineInfo_RealFPS,
    PPYPlayEngineInfo_BufferingUpdatePercent, //VOD only
    PPYPlayEngineInfo_Duration,               //VOD only
    PPYPlayEngineInfo_CurrentPlayBackTime,    //VOD only
};

typedef NS_ENUM(NSUInteger, PPYPlayEngineStatus){
    PPYPlayEngineStatus_StartCaching,
    PPYPlayEngineStatus_EndCaching,
    PPYPlayEngineStatus_FisrtKeyFrameComing,
    PPYPlayEngineStatus_RenderingStart,
    PPYPlayEngineStatus_ReceiveEOF, //tmp: receive eof to end, need reconnect;
    PPYPlayEngineStatus_SeekComplete,  //VOD only
};

@protocol PPYPlayEngineDelegate <NSObject>
-(void)didPPYPlayEngineErrorOccured:(PPYPlayEngineErrorType)error;
-(void)didPPYPlayEngineInfoThrowOut:(PPYPlayEngineInfoType)type andValue:(int)value;
-(void)didPPYPlayEngineStateChanged:(PPYPlayEngineStatus)state;
-(void)didPPYPlayEngineVideoResolutionCaptured:(int)width VideoHeight:(int)height;
@end

@interface PPYPlayEngine : NSObject

//test
@property (nonatomic, strong) NSString *vid;
@property (nonatomic, assign) NSInteger protocol;
@property (nonatomic, strong) NSString *dt;
@property (nonatomic, strong) NSString *clent;

@property (copy, readonly, nonatomic) NSString *playURL;
@property (assign, nonatomic ,readonly) PPYSourceType sourceType;
@property (assign, nonatomic) CGRect previewRect;

@property (weak, nonatomic) id<PPYPlayEngineDelegate> delegate;

+(instancetype)shareInstance;

-(void)startPlayFromURL:(NSString *)url WithType:(PPYSourceType)sourceType;
-(void)stopPlayerBlackDisplayNeeded:(BOOL)yesOrNo;

-(void)presentPreviewOnView:(UIView *)view;
-(void)disappearPreview;

//VOD only
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readonly) NSTimeInterval currentPlaybackTime;
-(void)pause;
-(void)resume;
-(void)seekToPosition:(NSTimeInterval)seekTime;

@end
