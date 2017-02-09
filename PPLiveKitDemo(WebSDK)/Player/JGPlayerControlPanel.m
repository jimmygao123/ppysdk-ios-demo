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
@property (weak, nonatomic) IBOutlet UIButton *rateButton;

@property (assign, nonatomic) NSString *durationDescription;
@end

@implementation JGPlayerControlPanel

- (void)awakeFromNib{
    [super awakeFromNib];
    
    [self.sliderProgress setThumbImage:[UIImage imageNamed:@"组-4"] forState:UIControlStateNormal];
    [self.sliderProgress setThumbImage:[UIImage imageNamed:@"组-4"] forState:UIControlStateSelected];
    [self.sliderProgress setThumbImage:[UIImage imageNamed:@"组-4"] forState:UIControlStateHighlighted];
}


+(instancetype)playerControlPanel{
    JGPlayerControlPanelOwner *owner = [[JGPlayerControlPanelOwner alloc]init];
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:owner options:nil];
    return owner.controlPanel;
}

+ (instancetype)vodPlayerControlPanel {
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"JGVodPlayerControlPanel" owner:self options:nil];
    JGPlayerControlPanel *pannel = nibs.firstObject;
    return pannel;
}


-(void)setState:(JGPlayerControlState)state{
    if(_state == state){
        return;
    }
    _state = state;
    UIImage *startImage = [UIImage imageNamed:@"startplay.png"];
    UIImage *pauseImage = [UIImage imageNamed:@"pause.png"];
    switch (_state) {
        case JGPlayerControlState_Init:
        
            [self.btnStartOrPause setBackgroundImage:startImage forState:UIControlStateNormal];
            [self.sliderProgress setValue:0 animated:NO];
            self.sliderProgress.continuous = NO;
            self.lblTime.text = @"00:00:00/00:00:00";
        
            break;
        case JGPlayerControlState_Start:
            [self.btnStartOrPause setBackgroundImage:pauseImage forState:UIControlStateNormal];
        
            break;
        case JGPlayerControlState_Pause:
        
            [self.btnStartOrPause setBackgroundImage:startImage forState:UIControlStateNormal];
        
            break;
    }
}

- (IBAction)doStartOrPause:(id)sender {
    switch (self.state) {
        case JGPlayerControlState_Init:
            break;
            
        case JGPlayerControlState_Pause:
            self.state = JGPlayerControlState_Start;
            break;
        case JGPlayerControlState_Start:
            self.state = JGPlayerControlState_Pause;
            break;
            
        default:
            break;
    }
    [self.delegate playControlPanelDidClickStartOrPauseButton:self];
}

- (IBAction)playerProgressChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    NSTimeInterval currentTime = (NSTimeInterval)(slider.value) * self.duration;
    self.lblTime.text = [NSString stringWithFormat:@"%@/%@",[self convertSecondsToTimeFormat:currentTime],self.durationDescription];
    [self.delegate playControlPanel:self didSliderValueChanged:slider.value];
}

-(void)setProgress:(NSTimeInterval)progress{
    if(self.duration < 0 || progress < 0){
        _progress = 0;
        return;
    }
    
    if(_progress == progress)
        return;
    
    _progress = progress;
    
    NSString *text = nil;
    if(self.duration == 0){
        self.lblTime.text = @"00:00:00/00:00:00";
        return;
    }
    
    float percent = _progress/self.duration;
    [self.sliderProgress setValue:percent animated:NO];
    
    text = [NSString stringWithFormat:@"%@/%@",[self convertSecondsToTimeFormat:progress],self.durationDescription];
    self.lblTime.text = text;
}

#pragma mark vod player
- (IBAction)didChangeVideoRateAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(playControlPanelDidChangeVideoRate:)]) {
        [self.delegate playControlPanelDidChangeVideoRate:self];
    }
}

- (IBAction)didPlayerZoomAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(playControlPanelDidZoom:)]) {
        [self.delegate playControlPanelDidZoom:self];
    }
}

- (void)setRateTitle:(NSString *)rateTitle {
    _rateTitle = rateTitle;
    [self.rateButton setTitle:rateTitle forState:UIControlStateNormal];
}

#pragma mark 显示播放时间

-(NSString *)durationDescription{
    if(self.duration <= 0){
        return @"00:00:00";
    }
    return [self convertSecondsToTimeFormat:self.duration];
}
-(NSString *)convertSecondsToTimeFormat:(NSTimeInterval)value{
    if(value <= 0){
        return @"00:00:00";
    }
    
    int hour = 0;
    int minutes = 0;
    int second = 0;
    
    int integerValue = ceil(value / 1000); //ms to s
    if(integerValue >= 60){
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
    }else{
        second = integerValue;
    }
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hour,minutes,second];
}
@end

