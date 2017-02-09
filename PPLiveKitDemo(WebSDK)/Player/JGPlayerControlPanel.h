//
//  JGPlayerControlPanel.h
//  PPLiveKitDemo(WebSDK)
//
//  Created by Jimmy on 16/10/16.
//  Copyright © 2016年 高国栋. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(int,JGPlayerControlState){
    JGPlayerControlState_Init,
    JGPlayerControlState_Start,
    JGPlayerControlState_Pause,
};

@class JGPlayerControlPanel;

@protocol JGPlayControlPanelDelegate <NSObject>
-(void)playControlPanelDidClickStartOrPauseButton:(JGPlayerControlPanel *)controlPanel;
-(void)playControlPanel:(JGPlayerControlPanel *)controlPanel didSliderValueChanged:(float)newValue;
@optional
//选择码率
- (void)playControlPanelDidChangeVideoRate:(JGPlayerControlPanel *)controlPanel;
//点击小窗
- (void)playControlPanelDidZoom:(JGPlayerControlPanel *)controlPanel;
@end

@interface JGPlayerControlPanel : UIView

@property (weak, nonatomic) id<JGPlayControlPanelDelegate> delegate;
@property (assign, nonatomic) JGPlayerControlState state;
@property (assign, nonatomic) NSTimeInterval progress;  //s
@property (assign, nonatomic) NSTimeInterval duration;  //s

@property (nonatomic, strong) NSString *rateTitle;

+(instancetype)playerControlPanel;
/** vod播放器样式 */
+ (instancetype)vodPlayerControlPanel;
@end
