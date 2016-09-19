//
//  PPYPullEngine.h
//  PPYLiveKit
//
//  Created by Jimmy on 16/8/25.
//  Copyright © 2016年 高国栋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PPYPlayerStatus){
    PPYPlayerStatus_PlayStarted,
    PPYPlayerStatus_PlayStopped,
    PPYPlayerStatus_PlayEnded,
    PPYPlayerStatus_ErrorOccured
};


@protocol  PPYPullEngineDelegate <NSObject>
-(void)playerStateChanged:(PPYPlayerStatus)status;
@end

@interface PPYPullEngine : NSObject

@property (assign, nonatomic) id<PPYPullEngineDelegate> delegate;
@property (assign, nonatomic, readonly) BOOL isPlaying;
@property (strong, nonatomic) UIView *preview;

-(instancetype)initWithRTMPAddr:(NSString *)addr;

-(void)startPlay;
-(void)stopPlay;

@end
