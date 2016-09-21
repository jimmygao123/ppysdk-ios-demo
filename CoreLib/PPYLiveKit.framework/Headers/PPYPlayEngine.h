//
//  PPYPlayEngine.h
//  PPYLiveKit
//
//  Created by Jimmy on 16/9/19.
//  Copyright © 2016年 高国栋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

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
};
typedef NS_ENUM(NSUInteger, PPYPlayEngineStatus){
    PPYPlayEngineStatus_StartCaching,
    PPYPlayEngineStatus_EndCaching,
    PPYPlayEngineStatus_FisrtKeyFrameComing,
    PPYPlayEngineStatus_RenderingStart,
    PPYPlayEngineStatus_ReceiveEOF, //tmp: receive eof to end, need reconnect;
};

@protocol PPYPlayEngineDelegate <NSObject>
-(void)didPPYPlayEngineErrorOccured:(PPYPlayEngineErrorType)error;
-(void)didPPYPlayEngineInfoThrowOut:(PPYPlayEngineInfoType)type andValue:(int)value;
-(void)didPPYPlayEngineStateChanged:(PPYPlayEngineStatus)state;
-(void)didPPYPlayEngineVideoResolutionCaptured:(int)width VideoHeight:(int)height;
@end

@interface PPYPlayEngine : NSObject
@property (readonly, nonatomic) NSString *playURL;
@property (weak, nonatomic) id<PPYPlayEngineDelegate> delegate;

+(instancetype)shareInstance;
-(void)setPreviewOnView:(UIView *)view;
-(void)startPlayFromURL:(NSString *)url;
-(void)stop:(BOOL)blackDisplay;
@end
