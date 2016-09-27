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

#define JPushControllerLog(format, ...) NSLog((@"PushController_"format), ##__VA_ARGS__)

typedef NS_ENUM(int, NetWorkState){
    NetWorkState_notReachable,
    NetWorkState_WWan,
    NetWorkState_Wifi,
};

typedef enum{
    kAFNetworkUnreachable,
    kNetworkToWWan,
    kNetworkWifi,
    kAFNetworkAFNetworkingRequestFailed,
    
    kReconnectFailed_30s,
    kReconnectSuccess,
    kNetworkNotStable,
    kStreamCannotRecovery,
    
    kPushSuccess,
    kPushEndedNormal,
    kPushEndedWithError,
    kSyncStartSuccess,
    kSyncStartFailed,
    kSyncStopSuccess,
    kSyncStopFailed,
    
    
    kDownupgradeBitrate,
}PushMessage;

@interface PushViewController () <PPYPushEngineDelegate>

@property (strong, nonatomic) PPYAudioConfiguration *audioConfig;
@property (strong, nonatomic) PPYVideoConfiguration *videoConfig;

@property (weak, nonatomic) IBOutlet UIButton *btnCamera;
@property (weak, nonatomic) IBOutlet UIButton *btnTorch;
@property (weak, nonatomic) IBOutlet UIButton *btnFocus;
@property (weak, nonatomic) IBOutlet UIButton *btnMirror;
@property (weak, nonatomic) IBOutlet UIButton *btnExit;

@property (weak, nonatomic) IBOutlet UILabel *lblRoomID;
@property (weak, nonatomic) IBOutlet UIButton *btnMute;
@property (weak, nonatomic) IBOutlet UILabel *lblFPS;
@property (weak, nonatomic) IBOutlet UILabel *lblBitrate;
@property (weak, nonatomic) IBOutlet UILabel *lblResolution;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contraitBtnCameraTraingToBtnMute;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contraitBtnMirrorLeadingToBtnMute;

@property (weak, nonatomic) IBOutlet UIButton *btnData;

@property (assign, nonatomic) BOOL isPushing;
@property (assign, nonatomic) BOOL needReConnect;
@property (assign, nonatomic) BOOL isDoingReconnect;
@property (assign, nonatomic) int reconnectCount;
@property (assign, nonatomic) BOOL isNetworkDisconnect;
@property (assign, nonatomic) BOOL isDoExitByClick;

#pragma mark --UIElement--
@property (strong, nonatomic) UIView *fuzzyView;
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
{
//    dispatch_semaphore_t semmphore;
}

#pragma mark --Life Cycle--
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self InitUI];
}

-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNetworkState:) name:kNotification_NetworkStateChanged object:nil];
//    semmphore = dispatch_semaphore_create(0);
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
    
    [self startDoLive];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.indicator stopAnimating];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotification_NetworkStateChanged object:nil];
}


#pragma mark --custom method--

-(void)initData{
    self.isDataShowed = YES;
}

-(void)InitUI{
    self.lblRoomID.textColor = [UIColor whiteColor];
    self.lblRoomID.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    self.lblRoomID.layer.cornerRadius = 10;
    self.lblRoomID.layer.masksToBounds  = YES;
    [self.lblRoomID clipsToBounds];
    
    self.lblBitrate.textColor = [UIColor whiteColor];
    self.lblBitrate.layer.cornerRadius = 6;
    self.lblBitrate.layer.masksToBounds = YES;
    [self.lblBitrate clipsToBounds];
    
    self.lblFPS.textColor = [UIColor whiteColor];
    self.lblFPS.layer.cornerRadius = 6;
    self.lblFPS.layer.masksToBounds = YES;
    [self.lblFPS clipsToBounds];
    
    self.lblResolution.textColor = [UIColor whiteColor];
    self.lblResolution.text = [NSString stringWithFormat:@"分辨率：%dx%d",self.width,self.height];
    
    self.contraitBtnCameraTraingToBtnMute.constant = (self.btnMute.center.x -self.btnTorch.center.x)/2 - self.btnMute.frame.size.width;
    NSLog(@"self.contraitBtnCameraTraingToBtnMute.constant = %f",self.contraitBtnCameraTraingToBtnMute.constant );
    [self.btnCamera layoutIfNeeded];
    self.contraitBtnMirrorLeadingToBtnMute.constant = (self.btnData.center.x - self.btnMute.center.x)/2 - self.btnMute.frame.size.width;
    [self.btnMirror layoutIfNeeded];
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

-(void)startDoLive{
    if([HTTPManager shareInstance].currentNetworkStatus == AFNetworkReachabilityStatusReachableViaWWAN){
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"当前使用移动流量，是否继续直播？" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *btnOK = [UIAlertAction actionWithTitle:@"继续" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self doLive];
        }];
        UIAlertAction *btnCancel = [UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.delegate didPushViewControllerDismiss];
        }];
        [alert addAction:btnOK];
        [alert addAction:btnCancel];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        [self doLive];
    }
}

- (void)doLive{
    if(self.rtmpAddress == nil) return;
    NSLog(@"self.rtmpAddress = %@",self.rtmpAddress);
    
    [self.pushEngine start];
    
    if(![self.indicator isAnimating]){
        [self.indicator startAnimating];
    }
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


-(void)showNetworkState:(NSNotification *)info{
    NSNumber *value = (NSNumber *)info.object;
    NSString *tip = nil;
    switch (value.integerValue) {
        case AFNetworkReachabilityStatusUnknown:
            break;
        case AFNetworkReachabilityStatusNotReachable:
            self.isNetworkDisconnect = YES;
            [self throwMessage:kAFNetworkUnreachable];
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN:
        {
            self.isNetworkDisconnect = NO;
            tip = @"当前使用3G/4G网络";
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"当前使用移动流量，是否继续直播？" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *btnOK = [UIAlertAction actionWithTitle:@"继续直播" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.needReConnect = YES;
                [[NotifyView getInstance] dismissNotifyMessageInView:self.view];
                [[NotifyView getInstance] needShowNotifyMessage:tip inView:self.view forSeconds:3];
                [self doReconnectToServer];
            }];
            UIAlertAction *btnCancel = [UIAlertAction actionWithTitle:@"退出直播" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.indicator stopAnimating];
                [self.delegate didPushViewControllerDismiss];
            }];
            [alert addAction:btnOK];
            [alert addAction:btnCancel];
            [self presentViewController:alert animated:YES completion:nil];
        }
            break;
        case AFNetworkReachabilityStatusReachableViaWiFi:
            tip = @"当前使用Wi-Fi网络，正在为您重连...";
            self.isNetworkDisconnect = YES;
            self.needReConnect = YES;
            [[NotifyView getInstance] dismissNotifyMessageInView:self.view];
            [[NotifyView getInstance] needShowNotifyMessage:tip inView:self.view forSeconds:3];
            [self doReconnectToServer];
            break;
    }
}

-(void)doReconnectToServer{
//    if(!self.needReConnect){
//        NSLog(@"dispatch_semaphore_wait_wait................................");
//        dispatch_semaphore_wait(semmphore, DISPATCH_TIME_FOREVER);   //a semphore to ensure reconnect after sync start to server success;
//    }
    __weak typeof (self) weakSelf = self;
    [[HTTPManager shareInstance] fetchStreamStatusSuccess:^(NSDictionary *dic) {
        if(dic != nil){
            if([[dic objectForKey:@"err"] isEqualToString:@"0"]){
                NSDictionary *data = (NSDictionary *)[dic objectForKey:@"data"];
                NSString *liveState = (NSString *)[data objectForKey:@"liveStatus"];

                if([liveState isEqualToString:@"living"] ||[liveState isEqualToString:@"broken"]){
                    [weakSelf.pushEngine start];
                    weakSelf.isDoingReconnect = YES;
                }else{
                    [weakSelf throwMessage:kStreamCannotRecovery];
                }
            }else{
               [weakSelf throwMessage:kStreamCannotRecovery];
            }
        }
    } failured:^(NSError *err) {
        if(err){
            [weakSelf throwMessage:kAFNetworkAFNetworkingRequestFailed];
        }
    }];
}
-(void)reDoSyncStartStateToServer{
     __weak typeof(self) weakSelf = self;
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[HTTPManager shareInstance] syncPushStartStateToServerSuccess:^(NSDictionary *dic) {
            
            if(dic != nil){
                if([[dic objectForKey:@"err"] isEqualToString:@"0"]){
                    
                    count_ReDoSyncStartStateToServer = 0;
                    [weakSelf throwMessage:kSyncStartSuccess];
                }else{
                    NSString *errorInfo = (NSString *)[dic objectForKey:@"msg"];
                    NSString *errCode = (NSString *)[dic objectForKey:@"err"];
                    [weakSelf throwError:3 info:[NSString stringWithFormat:@"%@:%@",errCode,errorInfo]];
                }
            }
        } failured:^(NSError *err) {
            [weakSelf.indicator stopAnimating];
        }];
    });
}
-(void)stopSyncStateToService{
    __weak typeof(self) weakSelf = self;
    [[HTTPManager shareInstance] syncPushStopStateToServerSuccess:^(NSDictionary *dic) {
        if(dic != nil){
            if([[dic objectForKey:@"err"] isEqualToString:@"0"]){
//                [[NotifyView getInstance] needShowNotifyMessage:@"断流成功" inView:weakSelf.view forSeconds:3];
            }else{
                //                            NSString *errorInfo = (NSString *)[dic objectForKey:@"msg"];
                //                            NSString *errCode = (NSString *)[dic objectForKey:@"err"];
//                [[NotifyView getInstance] needShowNotifyMessage:@"同步断流失败" inView:weakSelf.view forSeconds:3];
            }
        }
        [weakSelf.delegate didPushViewControllerDismiss];
        
    } failured:^(NSError *err) {

        [weakSelf.delegate didPushViewControllerDismiss];
    }];

}


-(void)throwMessage:(PushMessage)message{
    NSString *log = nil;
    NSString *displayInfo = nil;
    if(message == kPushSuccess){
       log = @"SDK推流成功";
    }else if(message == kPushEndedNormal){
        [self.indicator stopAnimating];
        log = @"SDK正常结束推流";
    }else if(message == kPushEndedWithError){
        [self.indicator stopAnimating];
        log = @"SDK发生错误，结束推流";
        
    }else if(message == kSyncStartSuccess){
        [self.indicator stopAnimating];
        [[NotifyView getInstance] dismissNotifyMessageInView:self.view];
        log = @"同步推流成功";
        displayInfo = @"推流成功";
        [[NotifyView getInstance] dismissNotifyMessageInView:self.view];
        [[NotifyView getInstance] needShowNotifyMessage:displayInfo inView:self.view forSeconds:3];
    }else if(message == kSyncStartFailed){
        [self.indicator stopAnimating];
        log = @"同步推流成功失败";
        displayInfo = @"推流状态无法同步到服务器，播放端无法观看";
    }else if(message == kAFNetworkAFNetworkingRequestFailed){
        log = @"AFNetworking 请求失败";
        [self.indicator stopAnimating];
    }else if(message == kDownupgradeBitrate){
        displayInfo =  @"当前网络环境差，已经为您重新调整码率...";
        [[NotifyView getInstance] dismissNotifyMessageInView:self.view];
        [[NotifyView getInstance] needShowNotifyMessage:displayInfo inView:self.view forSeconds:3];
    }else if(message == kReconnectFailed_30s){
        displayInfo = @"世界上最遥远的距离就是断网，请检查您的网络设置，网络恢复后将自动为您重连接...";
        [[NotifyView getInstance] needShwoNotifyMessage:displayInfo inView:self.view ];
    }else if(message == kStreamCannotRecovery){
        displayInfo = @"直播已结束";
        [self presentFuzzyViewOnView:self.view WithMessage:displayInfo loadingNeeded:NO];
    }else if(message == kAFNetworkUnreachable){
        displayInfo = @"世界上最遥远的距离就是断网，请检查您的网络设置，网络恢复后将自动为您重连接...";
        [[NotifyView getInstance] needShwoNotifyMessage:displayInfo inView:self.view ];
    }else if(message == kNetworkNotStable){
        displayInfo = @"当前网络环境异常，正在重新连接...";
        [[NotifyView getInstance] dismissNotifyMessageInView:self.view];
        [[NotifyView getInstance] needShowNotifyMessage:displayInfo inView:self.view forSeconds:3];
    }else if(message == kReconnectSuccess){
        displayInfo = @"重连成功";
        [self.indicator stopAnimating];
        [[NotifyView getInstance] dismissNotifyMessageInView:self.view];
        [[NotifyView getInstance] needShowNotifyMessage:displayInfo inView:self.view forSeconds:3];
    }
    JPushControllerLog(@"push = %@",log);
    JPushControllerLog(@"display = %@",displayInfo);
}

static int count_ReDoSyncStartStateToServer = 0;
-(void)throwError:(int)errorCode info:(NSString *)errorInfo{
    __weak typeof(self) weakSelf = self;

    if(errorCode == 3){  //sync start errorcode
        
        NSArray *componets = [errorInfo componentsSeparatedByString:@":"];
        NSLog(@"componets = %@",componets);
        if([componets[0] isEqualToString:@"1006"]){
            count_ReDoSyncStartStateToServer ++;
            if(count_ReDoSyncStartStateToServer < 20){   //kTimeout 20s
                 [weakSelf reDoSyncStartStateToServer];
            }else{
                 [weakSelf throwMessage:kSyncStartFailed];
            }
        }else{
            [weakSelf throwMessage:kSyncStartFailed];
        }
    }
    
    [[NotifyView getInstance] dismissNotifyMessageInView:weakSelf.view];
}

#pragma mark --<PPYPushEngineDelegate>
-(void)didStreamStateChanged:(PPYPushEngineStreamStatus)status{
    switch (status) {
        case PPYConnectionState_Connecting:
            
            break;
        case PPYConnectionState_Connected:
            
            break;
        case PPYConnectionStatus_Started:
            if(!self.needReConnect){
                [self throwMessage:kPushSuccess];
                [[HTTPManager shareInstance] syncPushStartStateToServerSuccess:^(NSDictionary *dic) {
                    if(dic != nil){
                        if([[dic objectForKey:@"err"] isEqualToString:@"0"]){
                            self.isPushing = YES;
//                            NSLog(@"dispatch_semaphore_wait_send.............");
//                            dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                                dispatch_semaphore_signal(semmphore);
//                            });
                            [self throwMessage:kSyncStartSuccess];
                        }else{
                            NSString *errorInfo = (NSString *)[dic objectForKey:@"msg"];
                            NSString *errCode = (NSString *)[dic objectForKey:@"err"];
                            [self throwError:3 info:[NSString stringWithFormat:@"%@:%@",errCode,errorInfo]];
                        }
                    }
                } failured:^(NSError *err) {
                    [self throwMessage:kAFNetworkAFNetworkingRequestFailed];
                }];
            }
            if(self.isDoingReconnect){
                
                [self throwMessage:kReconnectSuccess];
                self.isDoingReconnect = NO;
                self.needReConnect = NO;
                self.reconnectCount = 0;
            }
            self.isPushing = YES;
            break;
        case PPYConnectionStatus_Ended:
            
            self.isPushing = NO;
            
            __weak __typeof(self) weakSelf = self;
            if(self.isDoExitByClick){
                self.isDoExitByClick = NO;
                [self stopSyncStateToService];
            }else{
                if(self.needReConnect){
                    
                    weakSelf.isDoingReconnect = YES;
                    weakSelf.needReConnect = NO;
                    [weakSelf.indicator startAnimating];
                    [weakSelf doReconnectToServer];
                    
                }else{
                    if([weakSelf.indicator isAnimating]){
                        [weakSelf.indicator stopAnimating];
                    }
                    if(weakSelf.isNetworkDisconnect == YES){
                        NSLog(@"network disconnect");
                    }else{
//                        [self stopSyncStateToService];
                    }
                }
            }
            break;
    }
    NSLog(@"PPYPushEngineStreamStatus __%lu",(unsigned long)status);
}


-(void)didStreamErrorOccured:(PPYPushEngineErrorType)error{
    
    NSString *tip = nil;
    switch (error) {
        case PPYPushEngineError_Unknow:
//            tip = @"发生未知错误";
            break;
        case PPYPushEngineError_ConnectFailed:
            self.needReConnect = YES;
            [self throwMessage:kNetworkNotStable];

            break;
        case PPYPushEngineError_TransferFailed:
            [self throwMessage:kNetworkNotStable];
            self.needReConnect = YES;
            break;
        case PPYPushEngineError_FatalError:
//            tip = @"采集或编码失败";
            break;
            
    }
    if(self.needReConnect){
        self.reconnectCount ++;
        if(self.reconnectCount > 5){   //5times * 5s = 25s, 25s to reconnect;
            self.needReConnect = NO;
            self.reconnectCount = 0;
            [self throwMessage:kReconnectFailed_30s];
            
        }else{
            [self.indicator startAnimating];
        }
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
//            [[NotifyView getInstance] needShowNotifyMessage:@"当前网络信号较差" inView:self.view forSeconds:3];
            break;
        case PPYPushEngineInfo_RealBirate:
            self.lblBitrate.text = [NSString stringWithFormat:@"码率：%dkbps",value];
            break;
        case PPYPushEngineInfo_RealFPS:
            self.lblFPS.text = [NSString stringWithFormat:@"帧率：%d帧/秒",value];
            break;
        case PPYPushEngineInfo_DowngradeBitrate:
            [self throwMessage:kDownupgradeBitrate];
            
            break;
        case PPYPUshEngineInfo_UpgradeBitrate:
//            [[NotifyView getInstance] needShowNotifyMessage: @"当前网络环境较好，正在上调码率..." inView:self.view forSeconds:3];
            break;
    }
    NSLog(@"didStreamInfoThrowOut %d__%d",type,value);
}

#pragma mark --Actions--
- (IBAction)doExit:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定要关闭直播吗？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *btnOK = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"stop thread = %@",[NSThread currentThread]);
        self.isDoExitByClick = YES;
        [self.indicator stopAnimating];
        if(self.isPushing){
            [self.pushEngine stop];
        }else{
            [self.delegate didPushViewControllerDismiss];
        }
    }];
    
    UIAlertAction *btnCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
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
    self.lblResolution.hidden = !self.isDataShowed;
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
#pragma mark --Custom View--
-(void)presentFuzzyViewOnView:(UIView *)view WithMessage:(NSString *)info loadingNeeded:(BOOL)needLoading{
    
    UILabel *label = [[UILabel alloc]init];
    label.text = info;
    label.font = [UIFont systemFontOfSize:25];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    [label sizeToFit];
    
    label.center = self.view.center;
    [self.fuzzyView addSubview:label];
    
    if(needLoading){
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [indicator hidesWhenStopped];
        indicator.center = CGPointMake(self.view.center.x, self.view.center.y + 30);
        [indicator startAnimating];
        
        [self.fuzzyView addSubview:indicator];
    }
    
    UIButton *exitBtn = [[UIButton alloc]initWithFrame:self.btnExit.frame];
    [exitBtn setImage:[UIImage imageNamed:@"关闭.png"] forState:UIControlStateNormal];
    [exitBtn addTarget:self action:@selector(doExit:) forControlEvents:UIControlEventTouchUpInside];
    [self.fuzzyView addSubview:exitBtn];
    
    [view addSubview:self.fuzzyView];
}

-(void)dismissFuzzyView{
    [self.fuzzyView removeFromSuperview];
    self.fuzzyView = nil;
}
-(UIView *)fuzzyView{
    if(_fuzzyView == nil){
        _fuzzyView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _fuzzyView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    }
    return _fuzzyView;
}

@end
