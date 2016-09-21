//
//  PushViewController.m
//  PPLiveKitDemo(WebSDK)
//
//  Created by Jimmy on 16/8/25.
//  Copyright © 2016年 高国栋. All rights reserved.
//
#import <PPYLiveKit/PPYLiveKit.h>
#import "PushViewController.h"
#import "HTTPManager.h"
#import "NotifyView.h"
#import "MBProgressHUD.h"


@interface PushViewController () <PPYPushEngineDelegate>

@property (strong, nonatomic) PPYAudioConfiguration *audioConfig;
@property (strong, nonatomic) PPYVideoConfiguration *videoConfig;

@property (weak, nonatomic) IBOutlet UIButton *btnCamera;
@property (weak, nonatomic) IBOutlet UIButton *btnTorch;
@property (weak, nonatomic) IBOutlet UIButton *btnFocus;

@property (weak, nonatomic) IBOutlet UIButton *btnStart;
@property (weak, nonatomic) IBOutlet UILabel *lblRoomID;
@property (weak, nonatomic) IBOutlet UIButton *btnMute;
@property (weak, nonatomic) IBOutlet UILabel *lblFPS;
@property (weak, nonatomic) IBOutlet UILabel *lblBitrate;
@property (weak, nonatomic) IBOutlet UILabel *lblResolution;


@property (weak, nonatomic) IBOutlet UIButton *btnData;

@property (assign, nonatomic) BOOL isPushing;
@property (assign, nonatomic) BOOL needReConnect;
@property (assign, nonatomic) BOOL isDoingReconnect;



#pragma mark --UIElement--
@property (weak, nonatomic) IBOutlet UIButton *btnBeautySetting;
@property (weak, nonatomic) IBOutlet UIButton *btnMoreSetting;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ConstraitYVerticalMoreView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ConstraitYVerticalBeautyView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ConstraintBtnBeautyBottomVertical;
@property (weak, nonatomic) IBOutlet UISwitch *switchBeauty;

@property (assign, nonatomic) BOOL isBeautyViewPresented;
@property (assign, nonatomic) BOOL isMoreViewPresented;
@property (assign, nonatomic) BOOL isDataShowed;

@end






@implementation PushViewController




#pragma mark --Actions--

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self InitUI];
    
}

-(void)initData{
    self.isDataShowed = YES;
}
-(void)InitUI{
    self.lblBitrate.textColor = [UIColor whiteColor];
    self.lblFPS.textColor = [UIColor whiteColor];
    self.lblRoomID.textColor = [UIColor whiteColor];
    self.lblResolution.textColor = [UIColor whiteColor];
    self.lblResolution.text = [NSString stringWithFormat:@"分辨率：%dx%d",self.width,self.height];
    
//    self.lblFPS.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
//    self.lblBitrate.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    self.lblRoomID.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    
    self.lblRoomID.layer.cornerRadius = 10;
    self.lblFPS.layer.cornerRadius = 6;
    self.lblBitrate.layer.cornerRadius = 6;

    self.lblRoomID.layer.masksToBounds  = YES;
    self.lblFPS.layer.masksToBounds = YES;
    self.lblBitrate.layer.masksToBounds = YES;
    
    [self.lblRoomID clipsToBounds];
    [self.lblFPS clipsToBounds];
    [self.lblBitrate clipsToBounds];
}



-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNetworkState:) name:kNotification_NetworkStateChanged object:nil];

    self.btnStart.hidden = NO;
    NSString *roomID = [HTTPManager shareInstance].roomID;
    self.lblRoomID.text = [NSString stringWithFormat:@"     房间号: %@   ", roomID];
    
    self.audioConfig = [PPYAudioConfiguration audioConfigurationWithAudioQuality:PPYAudioQuality_Default];
    PPYCaptureSessionPreset preset = [self configurationWithWidth:self.width andHeight:self.height];
    self.videoConfig = [PPYVideoConfiguration videoConfigurationWithPreset:preset andFPS:25 andBirate:800];
    self.pushEngine = [[PPYPushEngine alloc]initWithAudioConfiguration:self.audioConfig andVideoConfiguration:self.videoConfig pushRTMPAddress:self.rtmpAddress];
    self.pushEngine.preview = self.view;
    self.pushEngine.running = YES;
    self.pushEngine.delegate = self;
    [self updateUI];
}
-(PPYCaptureSessionPreset)configurationWithWidth:(int)width andHeight:(int)height{
    if(width == 480 && height == 640)
        return PPYCaptureSessionPreset360x640;
    else if(width == 540 && height == 960)
        return PPYCaptureSessionPreset540x960;
    else if(width == 720 && height == 1280)
        return PPYCaptureSessionPreset720x1280;
    else{
        NSLog(@"can't find match preset, set 540 * 960 instead");
        return PPYCaptureSessionPreset540x960;
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotification_NetworkStateChanged object:nil];
    [self.indicator stopAnimating];
}
-(void)showNetworkState:(NSNotification *)info{
    NSNumber *value = (NSNumber *)info.object;
    NSString *tip = nil;
    switch (value.integerValue) {
        case AFNetworkReachabilityStatusUnknown:
            tip = @"网络异常发生未知错误";
            self.needReConnect = YES;
           
            break;
        case AFNetworkReachabilityStatusNotReachable:
            tip = @"网络断开,请检查网络";
            self.needReConnect = YES;
     
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN:
            tip = @"当前使用3G/4G网络";
            self.needReConnect = YES;

            break;
        case AFNetworkReachabilityStatusReachableViaWiFi:
            tip = @"当前使用Wi-Fi";
            self.needReConnect = YES;
 
            break;
    }
    [[NotifyView getInstance] needShowNotifyMessage:tip inView:self.view forSeconds:3];
}

-(void)updateUI{
    
    BOOL canSwitchCamera = ([AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count > 1);
    self.btnCamera.userInteractionEnabled = canSwitchCamera;
    self.btnTorch.userInteractionEnabled = self.pushEngine.hasTorch;
    if(self.pushEngine.hasTorch){
        NSLog(@"self.isTorch = %d",self.pushEngine.isTorch);
        [self.btnTorch setBackgroundImage:[UIImage imageNamed:(self.pushEngine.isTorch ? @"闪光灯-启用" : @"闪光灯-禁用")] forState:UIControlStateNormal];
    }
    NSLog(@"self.mute = %d",self.pushEngine.isMute);
    [self.btnMute setBackgroundImage:[UIImage imageNamed:(self.pushEngine.isMute ? @"麦克风-禁用" : @"麦克风-启用")] forState:UIControlStateNormal];
    
    [self.btnData setBackgroundImage:[UIImage imageNamed:(self.isDataShowed ? @"数据分析-启用" : @"数据分析-禁用")] forState:UIControlStateNormal];
    NSLog(@"self.beauty = %d",self.pushEngine.isBeautify);
    
    NSLog(@"self.mirror = %d",self.pushEngine.isMirror);
}



-(void)doReConnection{
    [self.pushEngine start];
}

#pragma mark --<PPYPushEngineDelegate>
-(void)didStreamStateChanged:(PPYPushEngineStreamStatus)status{
    switch (status) {
        case PPYConnectionState_Connecting:
            
            break;
        case PPYConnectionState_Connected:
            
            break;
        case PPYConnectionStatus_Started:
            [self.indicator stopAnimating];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if(!self.needReConnect){
                [[HTTPManager shareInstance] syncPushStartStateToServer];
            }
            if(self.isDoingReconnect){
                
                [[NotifyView getInstance] needShowNotifyMessage:@"重连成功" inView:self.view forSeconds:3];
                self.isDoingReconnect = NO;
                self.needReConnect = NO;
            }
            self.isPushing = YES;
            break;
        case PPYConnectionStatus_Ended:
            self.isPushing = NO;
            if(self.needReConnect){
                
                __weak __typeof(self) weakSelf = self;
                weakSelf.isDoingReconnect = YES;
                weakSelf.needReConnect = NO;
                
                [weakSelf.indicator startAnimating];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf.pushEngine start];
                });
            }else{
                if([self.indicator isAnimating]){
                    [self.indicator stopAnimating];
                }
                [[HTTPManager shareInstance] syncPushStopStateToServerSuccess:^(NSDictionary *dic) {
                    if(dic != nil){
                        if([[dic objectForKey:@"err"] isEqualToString:@"0"]){
                            [[NotifyView getInstance] needShowNotifyMessage:@"断流成功" inView:self.view forSeconds:3];
                        }else{
//                            NSString *errorInfo = (NSString *)[dic objectForKey:@"msg"];
//                            NSString *errCode = (NSString *)[dic objectForKey:@"err"];
                            [[NotifyView getInstance] needShowNotifyMessage:@"同步断流失败" inView:self.view forSeconds:3];
                        }
                    }
                    [self.delegate didPushViewControllerDismiss];
                    
                } failured:^(NSError *err) {
                    [[NotifyView getInstance] needShowNotifyMessage:@"同步断流失败" inView:self.view forSeconds:3];
                    [self.delegate didPushViewControllerDismiss];
                }];
            }
            break;
    }
    NSLog(@"PPYPushEngineStreamStatus __%lu",(unsigned long)status);
}

-(void)didStreamErrorOccured:(PPYPushEngineErrorType)error{
    
    NSString *tip = nil;
    switch (error) {
        case PPYPushEngineError_Unknow:
            tip = @"发生未知错误";
            break;
        case PPYPushEngineError_ConnectFailed:
            tip = @"无法连接到服务器，正在尝试重连...";
            self.needReConnect = YES;
            if(self.isPushing){
                [self.pushEngine stop];
            }
            break;
        case PPYPushEngineError_TransferFailed:
            self.needReConnect = YES;
            if(self.isPushing){
                [self.pushEngine stop];
            }
            tip = @"网络异常，正在尝试重连...";
            break;
        case PPYPushEngineError_FatalError:
            tip = @"采集或编码失败";
            break;
            
    }
    if(self.needReConnect){
        [self.indicator startAnimating];
    }else{
        [[NotifyView getInstance] needShowNotifyMessage:tip inView:self.view forSeconds:3];
        [self.indicator stopAnimating];
    }
    
    NSLog(@"didStreamErrorOccured __%d",error);
    
}
-(void)didStreamInfoThrowOut:(PPYPushEngineStreamInfoType)type infoValue:(int)value{
    NSLog(@"current thread = %@",[NSThread currentThread]);
    switch (type) {
            
        case PPYPushEngineInfo_BufferingBytes:
            [[NotifyView getInstance] needShowNotifyMessage:@"当前网络信号较差" inView:self.view forSeconds:3];
            break;
        case PPYPushEngineInfo_RealBirate:
            self.lblBitrate.text = [NSString stringWithFormat:@"码率：%dkbps",value];
            break;
        case PPYPushEngineInfo_RealFPS:
            self.lblFPS.text = [NSString stringWithFormat:@"帧率：%d帧/秒",value];
            break;
        case PPYPushEngineInfo_DowngradeBitrate:
            [[NotifyView getInstance] needShowNotifyMessage: @"当前网络差，正在下调码率..." inView:self.view forSeconds:3];
            break;
        case PPYPUshEngineInfo_UpgradeBitrate:
            [[NotifyView getInstance] needShowNotifyMessage: @"当前网络环境较好，正在上调码率..." inView:self.view forSeconds:3];
            break;
    }
    NSLog(@"didStreamInfoThrowOut %d__%d",type,value);
}

#pragma mark --Actions--
- (IBAction)doExit:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定要关闭直播吗？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *btnOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"stop thread = %@",[NSThread currentThread]);
        [self.indicator stopAnimating];
        [self.pushEngine stop];
    }];
    
    UIAlertAction *btnCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:btnOK];
    [alert addAction:btnCancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)switchCamera:(id)sender {
    if(self.pushEngine.hasTorch){
        self.pushEngine.torch = NO;
    }
    if([AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count > 1){
        AVCaptureDevicePosition current = self.pushEngine.cameraPosition;
        if(current == AVCaptureDevicePositionBack){
            self.pushEngine.cameraPosition = AVCaptureDevicePositionFront;
        }else if(current == AVCaptureDevicePositionFront){
            self.pushEngine.cameraPosition = AVCaptureDevicePositionBack;
        }
    }
    [self updateUI];
}

- (IBAction)doShowData:(id)sender {
    self.lblBitrate.hidden = !self.isDataShowed;
    self.lblFPS.hidden = !self.isDataShowed;
    [self updateUI];
    
    self.isDataShowed = !self.isDataShowed;
}

- (IBAction)doMirror:(id)sender {
    self.pushEngine.mirror = !self.pushEngine.mirror;
}
- (IBAction)doTorch:(id)sender {
    if(self.pushEngine.hasTorch){
        self.pushEngine.torch = !self.pushEngine.isTorch;
        [self updateUI];
    }
}
- (IBAction)doFocus:(id)sender {
    if(self.pushEngine.hasFocus){
        self.pushEngine.autoFocus = !self.pushEngine.isAutoFocus;
    }
}

- (IBAction)doMute:(id)sender {
    self.pushEngine.mute = !self.pushEngine.isMute;
    [self updateUI];
}

- (IBAction)doLive:(id)sender {
    self.btnStart.hidden = YES;
  
    if(self.rtmpAddress == nil) return;
    NSLog(@"self.rtmpAddress = %@",self.rtmpAddress);
    
    [self.pushEngine start];
    
    if(![self.indicator isAnimating]){
        [self.indicator startAnimating];
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (IBAction)doBeauty:(UISwitch *)sender {
    self.pushEngine.beautify = sender.isOn;
}
- (IBAction)beautifyLevel:(UISlider*)sender {
    self.pushEngine.beautyLevel = sender.value;
}
- (IBAction)brightnessLevel:(UISlider*)sender {
    self.pushEngine.brightLevel = sender.value;
}
- (IBAction)ToneLevel:(UISlider*)sender {
    self.pushEngine.toneLevel = sender.value;
}

- (IBAction)doBeautySetting:(id)sender {
    
    [UIView animateWithDuration:0.25 animations:^{
        CGFloat height = [UIScreen mainScreen].bounds.size.height;
        if(self.isBeautyViewPresented){
            self.ConstraitYVerticalBeautyView.constant = height;  //美颜设置界面隐藏；
            self.ConstraintBtnBeautyBottomVertical.constant = 8;
            
        }else{
            self.ConstraitYVerticalBeautyView.constant = height - 190; //美颜设置界面弹出；
            self.ConstraintBtnBeautyBottomVertical.constant = 190 + 8;
        }
        self.ConstraitYVerticalMoreView.constant = height;   //更多设置界面隐藏；
        self.isMoreViewPresented = NO;
        
        [self.view layoutIfNeeded];
        self.isBeautyViewPresented = !self.isBeautyViewPresented;
    }];
}
- (IBAction)doMoreSetting:(id)sender {
    
    [UIView animateWithDuration:0.25 animations:^{
        CGFloat height = [UIScreen mainScreen].bounds.size.height;
        if(self.isMoreViewPresented){
            self.ConstraitYVerticalMoreView.constant = height;   //更多设置界面隐藏；
            self.ConstraintBtnBeautyBottomVertical.constant = 8;
        }else{
            self.ConstraitYVerticalMoreView.constant = height - 74; //更多设置界面弹出；
            self.ConstraintBtnBeautyBottomVertical.constant = 74 + 8;
        }
        self.ConstraitYVerticalBeautyView.constant = height;  //美颜设置界面隐藏；
        self.isBeautyViewPresented = NO;
        
        [self.view layoutIfNeeded];
        self.isMoreViewPresented = !self.isMoreViewPresented;
    }];
}


#pragma mark --Override Method--
- (BOOL)prefersStatusBarHidde{
    [super prefersStatusBarHidden];
    return YES;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    
    [UIView animateWithDuration:0.25 animations:^{
        CGFloat height = [UIScreen mainScreen].bounds.size.height;
        if(self.isBeautyViewPresented){
            self.ConstraitYVerticalBeautyView.constant = height;  //美颜设置界面隐藏；
            self.ConstraintBtnBeautyBottomVertical.constant = 8;
            self.isBeautyViewPresented = NO;
            return;
        }else if(self.isMoreViewPresented){
            self.ConstraitYVerticalMoreView.constant = height;   //更多设置界面隐藏；
            self.ConstraintBtnBeautyBottomVertical.constant = 8;
            self.isMoreViewPresented = NO;
            return;
        }
    }];
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.view];
    [self.pushEngine doFocusOnPoint:location onView:self.view needDisplayLocation:YES];
}

@end
