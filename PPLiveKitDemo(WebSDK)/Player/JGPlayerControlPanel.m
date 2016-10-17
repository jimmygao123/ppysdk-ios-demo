//
//  JGPlayerControlPanel.m
//  PPLiveKitDemo(WebSDK)
//
//  Created by Jimmy on 16/10/16.
//  Copyright © 2016年 高国栋. All rights reserved.
//

#import "JGPlayerControlPanel.h"

@interface JGPlayerControlPanelOwner : NSObject
@property (strong, nonatomic) IBOutlet JGPlayerControlPanel *controlPanel;

@end
@implementation JGPlayerControlPanelOwner
@end


@interface JGPlayerControlPanel ()
@property (weak, nonatomic) IBOutlet UIButton *btnStartOrPause;
@property (weak, nonatomic) IBOutlet UISlider *sliderProgress;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;

@property (assign, nonatomic) NSString *durationDescription;
@end

@implementation JGPlayerControlPanel

- (void)awakeFromNib{
    [super awakeFromNib];
    UIImage *startImage = [UIImage imageNamed:@"开始播放.png"];
    [self.btnStartOrPause setBackgroundImage:startImage forState:UIControlStateNormal];
    [self.sliderProgress setValue:0 animated:NO];
    self.sliderProgress.continuous = NO;
    self.lblTime.text = @"00:00:00/00:00:00";
}

+(instancetype)playerControlPanel{
    JGPlayerControlPanelOwner *owner = [[JGPlayerControlPanelOwner alloc]init];
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:owner options:nil];
    return owner.controlPanel;
}

- (IBAction)doStartOrPause:(id)sender {
    [self.delegate playControlPanelDidClickStartOrPauseButton:self];
}

- (IBAction)playerProgressChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    NSTimeInterval currentTime = (NSTimeInterval)(slider.value) * self.duration;
    self.lblTime.text = [NSString stringWithFormat:@"%@/%@",[self convertSecondsToTimeFormat:currentTime],self.durationDescription];
    [self.delegate playControlPanel:self didSliderValueChanged:slider.value];
}

-(void)setState:(JGPlayerControlState)state{
    if(state == JGPlayerControlState_Start){
        [self.btnStartOrPause setBackgroundImage:[UIImage imageNamed:@"暂停播放.png"] forState:UIControlStateNormal];
    }else{
        [self.btnStartOrPause setBackgroundImage:[UIImage imageNamed:@"开始播放.png"] forState:UIControlStateNormal];
    }
}

-(void)setProgress:(NSTimeInterval)progress{
    float percent = progress/self.duration;
    [self.sliderProgress setValue:percent animated:NO];
    self.lblTime.text = [NSString stringWithFormat:@"%@/%@",[self convertSecondsToTimeFormat:progress],self.durationDescription];
}

-(void)setDuration:(NSTimeInterval)duration{
    self.durationDescription = [self convertSecondsToTimeFormat:duration];
    self.lblTime.text = [NSString stringWithFormat:@"00:00:00/%@",self.durationDescription];
}

-(NSString *)convertSecondsToTimeFormat:(NSTimeInterval)value{
    
    int hour = 0;
    int minutes = 0;
    int second = 0;
    
    int integerValue = ceil(value / 1000); //ms to s
    if(value >= 60){
        second = integerValue % 60;
        integerValue /= 60;
        if(value >= 60){
            minutes = integerValue % 60;
            integerValue /= 60;
            if(integerValue >= 24){
                hour = integerValue % 24;
            }else{
                hour = integerValue;
            }
        }else{
            minutes = integerValue;
        }
    }
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hour,minutes,second];
}
@end

