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
#import "UserTips.h"
#import "PullViewController.h"

#define JPushControllerLog(format, ...) NSLog((@"PushController_"format), ##__VA_ARGS__)

typedef NS_ENUM(int, NetWorkState){
    NetWorkState_notReachable,
    NetWorkState_WWan,
    NetWorkState_Wifi,
};

typedef enum{
    kAFNetworkUnreachable,  //local network closed
    kNetworkToWWan,
    kNetworkWifi,
    kAFNetworkAFNetworkingRequestFailed,   //connect failed

    kReconnectFailed_30s,   //reconnect failed
    kReconnectSuccess,
    kStreamCannotRecovery,  //stream state error.直播已结束。
    kCheck1006State,
    
    kRestartPushEngineFailed_3Times,
    kRestartPushEngineFailed_18Times,
    
    kPushSuccess,         //sdk push success;
    kPushEnded,     //sdk push ended;
    kPushEndedWithError_NetworkUnreached,
    kPushEndedWithError_FatalError,
    kSyncStartSuccess,
    kSyncStartFailed,
    kFetchStreamStateSuccess,
    kFetchStreamStateFailured,
    
    kDownupgradeBitrate,
}PushMessage;

@interface PushViewController () <PPYPushEngineDelegate>

@property (strong, nonatomic) PPYAudioConfiguration *audioConfig;
@property (strong, nonatomic) PPYVideoConfiguration *videoConfig;

@property (strong, nonatomic) IBOutlet UIView *viewEndLiving;
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
@property (assign, nonatomic) BOOL needReconnect;
@property (assign, nonatomic) BOOL isPushing;
@property (assign, nonatomic) BOOL isDoExitByClick;
@property (assign, nonatomic) BOOL isDoExitBySwitchNetWork;
@property (assign, nonatomic) BOOL isCheckingStreamStatus;
@property (assign, nonatomic) BOOL isSyncStartSuccess;
@property (copy, nonatomic) NSString *VODURL;
@property (copy, nonatomic) NSString *channelID;

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
    dispatch_semaphore_t semmphore;
    NSTimer *__timer;
}

#pragma mark --Life Cycle--
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self InitUI];
    [self addNSNotification];
}

-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNetworkState:) name:kNotification_NetworkStateChanged object:nil];
    semmphore = dispatch_semaphore_create(0);
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
    
    [self.indicator startAnimating];
    [self startDoLive];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.indicator stopAnimating];
    [__timer invalidate];
    __timer = nil;
    self.isCheckingStreamStatus = NO;
    self.isSyncStartSuccess = NO;
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
    
    [self.viewEndLiving setFrame:[UIScreen mainScreen].bounds];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.contraitBtnCameraTraingToBtnMute.constant = (self.btnMute.center.x -self.btnTorch.center.x)/2 - 40;
    [self.btnCamera layoutIfNeeded];
    self.contraitBtnMirrorLeadingToBtnMute.constant = (self.btnData.center.x - self.btnMute.center.x)/2 - 40;
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
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:kTips_SwitchWWANOnPusher message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *btnOK = [UIAlertAction actionWithTitle:@"继续" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self doLive];
        }];
        UIAlertAction *btnCancel = [UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
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
    
    self.pushEngine.vid = @"123456";
    self.pushEngine.dt = @"1";
    self.pushEngine.protocol = 1;
    self.pushEngine.clent = @"testClient";
    [self.pushEngine start];
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
    self.isDoExitBySwitchNetWork = YES;
    [self.pushEngine stop];
    NSNumber *value = (NSNumber *)info.object;
    NSString *tip = nil;
    switch (value.integerValue) {
        case AFNetworkReachabilityStatusUnknown:
            break;
        case AFNetworkReachabilityStatusNotReachable:
            [self sendMessage:kAFNetworkUnreachable];
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN:
            tip = @"当前使用3G/4G网络";
            break;
        case AFNetworkReachabilityStatusReachableViaWiFi:
            self.needReconnect = YES;
            tip = @"当前使用Wi-Fi网络，正在为您重连...";
            [[NotifyView getInstance] dismissNotifyMessageInView:self.view];
            [[NotifyView getInstance] needShowNotifyMessage:tip inView:self.view forSeconds:3];
            break;
    }
}
-(void)processWhenUseWWanNetwork{
    __weak typeof(self) weakSelf = self;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"当前使用移动流量，是否继续直播？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *btnOK = [UIAlertAction actionWithTitle:@"继续直播" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.needReconnect = YES;
        [[NotifyView getInstance] dismissNotifyMessageInView:weakSelf.view];
        [[NotifyView getInstance] needShowNotifyMessage:@"当前使用3G/4G网络" inView:weakSelf.view forSeconds:3];
        [weakSelf doReconnectToServer];
    }];
    UIAlertAction *btnCancel = [UIAlertAction actionWithTitle:@"退出直播" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf.indicator stopAnimating];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [alert addAction:btnOK];
    [alert addAction:btnCancel];
    [weakSelf presentViewController:alert animated:YES completion:nil];
}

static int count_RestartPushEngine = 0;
-(void)checkStreamState{
    __weak typeof (self) weakSelf = self;
    [[HTTPManager shareInstance] fetchStreamStatusSuccess:^(NSDictionary *dic) {
        if(dic != nil){
            NSDictionary *data = (NSDictionary *)[dic objectForKey:@"data"];
            NSString *liveState = (NSString *)[data objectForKey:@"liveStatus"];
            NSString *streamState = (NSString *)[data objectForKey:@"streamStatus"];
            
            if([[dic objectForKey:@"err"] isEqualToString:@"0"]){
                if([liveState isEqualToString:@"living"] && [streamState isEqualToString:@"ok"]){
                    [weakSelf sendMessage:kReconnectSuccess];
                    count_RestartPushEngine = 0;
                }
            }
        }else{
            count_RestartPushEngine ++;
        }
        if(count_RestartPushEngine == 3){
            [weakSelf sendMessage:kRestartPushEngineFailed_3Times];
        }else if(count_RestartPushEngine >= 18){
            count_RestartPushEngine = 0;
            [weakSelf sendMessage:kRestartPushEngineFailed_18Times];
        }

    } failured:^(NSError *err) {
        count_RestartPushEngine ++;
        if(count_RestartPushEngine == 3){
            [weakSelf sendMessage:kRestartPushEngineFailed_3Times];
        }else if(count_RestartPushEngine >= 18){
            count_RestartPushEngine = 0;
            [weakSelf sendMessage:kRestartPushEngineFailed_18Times];
        }
    }];
}
#pragma mark ----Reconnect Logic---
//过程消息：kAFNetworkAFNetworkingRequestFailed，kReconnectFailed_30s
//最终结果：kStreamCannotRecovery
-(void)doReconnectToServer{
    JPushControllerLog(@"正在检查流状态...");
    __weak typeof (self) weakSelf = self;
    [[HTTPManager shareInstance] fetchStreamStatusSuccess:^(NSDictionary *dic) {
        if(dic != nil){
            NSDictionary *data = (NSDictionary *)[dic objectForKey:@"data"];
            NSString *liveState = (NSString *)[data objectForKey:@"liveStatus"];
            NSString *streamState = (NSString *)[data objectForKey:@"streamStatus"];
            
            if([[dic objectForKey:@"err"] isEqualToString:@"0"]){
                if([liveState isEqualToString:@"living"] && [streamState isEqualToString:@"ok"]){
                    [weakSelf sendMessage:kReconnectSuccess];
                }else if(([liveState isEqualToString:@"living"] && [streamState isEqualToString:@"error"])
                         ||[liveState isEqualToString:@"broken"]){
                    JPushControllerLog(@"监测到流状态错误，重启推流引擎");
                    if(count_RestartPushEngine == 0){
                        [weakSelf doLive];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [weakSelf checkStreamState];
                        });
                    }else if(count_RestartPushEngine >= 18){    //重启18次
                    }else{
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [weakSelf doLive];
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [weakSelf checkStreamState];
                            });
                        });
                    }
                }else{
                    [weakSelf sendMessage:kStreamCannotRecovery];
                }
            }else{
               [weakSelf sendMessage:kStreamCannotRecovery];
            }
            JPushControllerLog(@"当前流状态:livestate = %@, streamState = %@",liveState,streamState);
        }else{
            [weakSelf doReconnectToServer30s];
        }
    } failured:^(NSError *err) {
        [weakSelf doReconnectToServer30s];
    }];
}

static int count_doReconnectToServer30s = 0;
-(void)doReconnectToServer30s{
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(count_doReconnectToServer30s >= 3){
            count_doReconnectToServer30s = 0;
            [weakSelf doReconnectToServer3min];
            [weakSelf sendMessage:kReconnectFailed_30s];  //最遥远的距离...
        }else{
            count_doReconnectToServer30s ++;
            [weakSelf sendMessage:kAFNetworkAFNetworkingRequestFailed];  //网络异常， 重新连接。。。
            [weakSelf doReconnectToServer];
        }
    });
    
}

static int count_doReconnectToServer3min = 0;
-(void)doReconnectToServer3min{
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(count_doReconnectToServer3min >= 18){
            count_doReconnectToServer3min = 0;
            [weakSelf sendMessage:kStreamCannotRecovery];  //超过3分钟，直播结束
        }else{
            count_doReconnectToServer3min ++;
            [weakSelf doReconnectToServer];
        }
    });
}



#pragma mark ----Sync Logic----
//过程中抛出的状态 kAFNetworkAFNetworkingRequestFaile,kSyncStartFailed
//最终抛出的状态 kSyncStartSuccess，kStreamCannotRecovery
-(void)doSyncStateStateToServer{
    __weak typeof(self) weakSelf = self;
    [[HTTPManager shareInstance] syncPushStartStateToServerSuccess:^(NSDictionary *dic) {
        if(dic != nil){
            if([[dic objectForKey:@"err"] isEqualToString:@"0"]){
                [weakSelf sendMessage:kSyncStartSuccess];
                weakSelf.isSyncStartSuccess = YES;
                [[HTTPManager shareInstance] fetchPlayURL:^(NSDictionary *dic) {
                    if([[dic objectForKey:@"err"] isEqualToString:@"0"]){
                        NSLog(@"____dic = %@",dic);
                        NSDictionary *data = (NSDictionary *)[dic objectForKey:@"data"];
                        NSString *m3u8Url = (NSString *)[data objectForKey:@"m3u8Url"];
                        NSString *channelID = (NSString *)[data objectForKey:@"channelWebId"];
                        weakSelf.VODURL = m3u8Url;
                        weakSelf.channelID = channelID;
                    }
                } Failured:^(NSError *err) {
                }];
//                [weakSelf startCheckStreamState];
            }else{
                NSString *errCode = (NSString *)[dic objectForKey:@"err"];
                if([errCode isEqualToString:@"1006"]){
                    [weakSelf sendMessage:kCheck1006State];
                    [weakSelf pollingSyncStateFor10times];
                }else{
                    [weakSelf sendMessage:kStreamCannotRecovery]; //流状态发生错误，直播结束
                }
            }
        }else{
            [weakSelf reDoSyncStateStateToServer30s];
        }
    } failured:^(NSError *err) {
        [weakSelf reDoSyncStateStateToServer30s];
    }];
}
static int count_ReDoSyncStartWaitWhen1006 = 0;
-(void)pollingSyncStateFor10times{
    __weak typeof(self) weakSelf = self;
    if(count_ReDoSyncStartWaitWhen1006 >= 10){
        [weakSelf reDoSyncStateStateToServer30s];
        count_ReDoSyncStartWaitWhen1006 = 0;
    }else{
        count_ReDoSyncStartWaitWhen1006 ++;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [weakSelf doSyncStateStateToServer];
        });
    }
}
static int count_ReDoSyncStart = 0;
-(void)reDoSyncStateStateToServer30s{
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(count_ReDoSyncStart >= 3){
            [weakSelf sendMessage:kSyncStartFailed];   //最遥远的距离。。。
            count_ReDoSyncStart = 0;
            [weakSelf reDoSyncState3min];
        }else{
            [weakSelf sendMessage:kAFNetworkAFNetworkingRequestFailed];  //网络异常，正在重连接。。。
            count_ReDoSyncStart ++;
            [weakSelf doSyncStateStateToServer];
            if(weakSelf.isPushing == NO){
                [weakSelf doLive];
            }
        }
    });
}
static int count_ReDoSyncStart3min = 0;
-(void)reDoSyncState3min{
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(count_ReDoSyncStart3min >= 18){
            count_ReDoSyncStart3min = 0;
            [weakSelf sendMessage:kStreamCannotRecovery];  //3min 后直播已结束
        }else{
            count_ReDoSyncStart3min ++;
            [weakSelf doSyncStateStateToServer];
        }
    });
}

-(void)stopSyncStateToService{
    __weak typeof(self) weakSelf = self;
    [[HTTPManager shareInstance] syncPushStopStateToServerSuccess:^(NSDictionary *dic) {
        NSLog(@"Stop dic=%@",dic);
        if([[dic objectForKey:@"err"] isEqualToString:@"0"]){
            if(weakSelf.VODURL && weakSelf.channelID){
                [[HTTPManager shareInstance] fetchDetailInfoWithChannelWebID:weakSelf.channelID Success:^(NSDictionary *dic) {
                    if([[dic objectForKey:@"err"] isEqualToString:@"0"]){
                        NSNumber *duration = (NSNumber *)[[dic objectForKey:@"data"] objectForKey:@"duration"];
                        if(duration.integerValue > 10){
                            [weakSelf.view addSubview:weakSelf.viewEndLiving];
                        }else{
                            [weakSelf.navigationController popToRootViewControllerAnimated:NO];
                        }
                    }else{
                        [weakSelf.navigationController popToRootViewControllerAnimated:NO];
                    }
                } Failured:^(NSError *err) {
                    [weakSelf.navigationController popToRootViewControllerAnimated:NO];
                }];
            }else{
                [weakSelf.navigationController popToRootViewControllerAnimated:NO];
            }
        }else{
            [weakSelf.navigationController popToRootViewControllerAnimated:NO];
        }
    } failured:^(NSError *err) {
        [weakSelf.navigationController popToRootViewControllerAnimated:NO];
    }];
}

#pragma mark ---Message handle---
-(void)sendMessage:(PushMessage)message{
    NSString *log = nil;
    NSString *displayInfo = nil;
    if(message == kPushSuccess){
        log = @"SDK推流成功";
    }else if(message == kPushEnded){
        log = @"SDK结束推流";
    }else if(message == kPushEndedWithError_NetworkUnreached){
        log = @"SDK发生错误,无法连接到服务器";
    }else if(message == kPushEndedWithError_FatalError){
        log = @"SDK发生错误，编码或采集错误";
    }else if(message == kCheck1006State){
        log = @"检查1006 state。。。";
    }else if(message == kSyncStartSuccess){
        [self.indicator stopAnimating];
        log = @"同步推流成功";
        displayInfo = @"推流成功";
        [[NotifyView getInstance] dismissNotifyMessageInView:self.view];
        [[NotifyView getInstance] needShowNotifyMessage:displayInfo inView:self.view forSeconds:3];
    }else if(message == kSyncStartFailed){
        [self.indicator stopAnimating];
        log = @"同步推流成功失败";
        displayInfo = @"世界上最遥远的距离就是断网，请检查您的网络设置，网络恢复后将自动为您重连接...";
        [[NotifyView getInstance] needShwoNotifyMessage:displayInfo inView:self.view ];
    }else if(message == kDownupgradeBitrate){
        displayInfo =  @"当前网络环境差，已经为您重新调整码率...";
        log = displayInfo;
        if(self.isSyncStartSuccess){
            [[NotifyView getInstance] dismissNotifyMessageInView:self.view];
            [[NotifyView getInstance] needShowNotifyMessage:displayInfo inView:self.view forSeconds:3];
        }
    }else if(message == kReconnectFailed_30s){
        [self.indicator stopAnimating];
        displayInfo = @"世界上最遥远的距离就是断网，请检查您的网络设置，网络恢复后将自动为您重连接...";
        log = @"重连超过30s";
        [[NotifyView getInstance] needShwoNotifyMessage:displayInfo inView:self.view ];
    }else if(message == kStreamCannotRecovery){
        [self.indicator stopAnimating];
        displayInfo = @"直播已结束";
        log = @"直播已结束";
        [self presentFuzzyViewOnView:self.view WithMessage:displayInfo loadingNeeded:NO];
    }else if(message == kAFNetworkUnreachable){
        [self.indicator stopAnimating];
        displayInfo = @"世界上最遥远的距离就是断网，请检查您的网络设置，网络恢复后将自动为您重连接...";
        log = displayInfo;
        [[NotifyView getInstance] needShwoNotifyMessage:displayInfo inView:self.view ];
    }else if(message == kAFNetworkAFNetworkingRequestFailed){
        [self.indicator startAnimating];
        log = @"当前网络环境异常，正在重新连接...";
        displayInfo = @"当前网络环境异常，正在重新连接...";
        [[NotifyView getInstance] dismissNotifyMessageInView:self.view];
        [[NotifyView getInstance] needShowNotifyMessage:displayInfo inView:self.view forSeconds:3];
       
    }else if(message == kReconnectSuccess){
        [self.indicator stopAnimating];
        displayInfo = @"重连成功";
        log = @"重连成功";
        [[NotifyView getInstance] dismissNotifyMessageInView:self.view];
        [[NotifyView getInstance] needShowNotifyMessage:displayInfo inView:self.view forSeconds:3];
    }else if(message == kRestartPushEngineFailed_3Times){
        [self.indicator stopAnimating];
        displayInfo =  @"世界上最遥远的距离就是断网，请检查您的网络设置，网络恢复后将自动为您重连接...";
        log = @"SDK重启3次失败...";
        [[NotifyView getInstance] dismissNotifyMessageInView:self.view];
        [[NotifyView getInstance] needShowNotifyMessage:displayInfo inView:self.view forSeconds:3];
    }else if(message == kRestartPushEngineFailed_18Times){
        [self.indicator stopAnimating];
        displayInfo = @"直播已结束";
        log = @"SDK重启18次..";
        [self presentFuzzyViewOnView:self.view WithMessage:displayInfo loadingNeeded:NO];
    }
    JPushControllerLog(@"log = %@",log);
//    JPushControllerLog(@"display = %@",displayInfo);
}


#pragma mark --<PPYPushEngineDelegate>
-(void)didStreamStateChanged:(PPYPushEngineStreamStatus)status{
    __weak __typeof(self) weakSelf = self;
    switch (status) {
        case PPYConnectionState_Connecting:
            break;
        case PPYConnectionState_Connected:
            break;
        case PPYConnectionStatus_Started:
            self.isPushing = YES;
            [self sendMessage:kPushSuccess];
            
            if(!self.needReconnect){
                [self doSyncStateStateToServer];
            }
            
            break;
        case PPYConnectionStatus_Ended:
            [self sendMessage:kPushEnded];
            self.isPushing = NO;

            if(self.isDoExitByClick){
                self.isDoExitByClick = NO;
                //直接退出
                [self.navigationController popToRootViewControllerAnimated:NO];
            }else{
                if(self.isDoExitBySwitchNetWork){
                    self.isDoExitBySwitchNetWork = NO;
                    if([HTTPManager shareInstance].currentNetworkStatus == AFNetworkReachabilityStatusReachableViaWWAN){
                        [weakSelf processWhenUseWWanNetwork];
                    }else if([HTTPManager shareInstance].currentNetworkStatus == AFNetworkReachabilityStatusReachableViaWiFi){
                        [weakSelf doReconnectToServer];
                    }
                    //do nothing.
                }else if(!weakSelf.isSyncStartSuccess){
                    
                }else{
                    [weakSelf doReconnectToServer];
                }
            }
            break;
    }
    NSLog(@"PPYPushEngineStreamStatus __%lu",(unsigned long)status);
//    JPushControllerLog(@"PPYPushEngineStreamStatus = %d",status);
}

-(void)didStreamErrorOccured:(PPYPushEngineErrorType)error{
    switch (error) {
        case PPYPushEngineError_Unknow:
            [self sendMessage:kPushEndedWithError_FatalError];
            self.needReconnect = NO;
            break;
        case PPYPushEngineError_ConnectFailed:
            [self sendMessage:kPushEndedWithError_NetworkUnreached];
            self.needReconnect = YES;
            break;
        case PPYPushEngineError_TransferFailed:
            [self sendMessage:kPushEndedWithError_NetworkUnreached];
            self.needReconnect = YES;
            break;
        case PPYPushEngineError_FatalError:
            [self sendMessage:kPushEndedWithError_FatalError]; //"采集或编码失败";
            self.needReconnect = NO;
            break;
    }
    NSLog(@"didStreamErrorOccured __%d",error);
    JPushControllerLog(@"didStreamErrorOccured = %d",error);
    
}
-(void)didStreamInfoThrowOut:(PPYPushEngineStreamInfoType)type infoValue:(int)value{
    //NSLog(@"current thread = %@",[NSThread currentThread]);
    switch (type) {
            
        case PPYPushEngineInfo_BufferingBytes:
            break;
        case PPYPushEngineInfo_RealBirate:
            self.lblBitrate.text = [NSString stringWithFormat:@"码率：%dkbps",value];
            break;
        case PPYPushEngineInfo_RealFPS:
            self.lblFPS.text = [NSString stringWithFormat:@"帧率：%d帧/秒",value];
            break;
        case PPYPushEngineInfo_DowngradeBitrate:
            [self sendMessage:kDownupgradeBitrate];
            
            break;
        case PPYPUshEngineInfo_UpgradeBitrate:

            break;
        case PPYPushEngineInfo_PublishTime:
            
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
        }
        [self removeNSNotification];
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

#pragma mark --End living--
- (IBAction)doExitWhenEndLiving:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doPlayBack:(id)sender {
    PullViewController *pullViewController = [[PullViewController alloc]initWithNibName:@"PullViewController" bundle:nil];
//    [pullViewController.view setFrame:[UIScreen mainScreen].bounds];
    pullViewController.playAddress = self.VODURL;
    pullViewController.sourceType = PPYSourceType_VOD;
    pullViewController.windowPlayerDisabled = YES;
    [self.navigationController pushViewController:pullViewController animated:YES];
}


#pragma mark - NSNotificationCenter
- (void)addNSNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)removeNSNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

#pragma mark -- notification methods

- (void)appBecomeActive:(NSNotification *)note
{
    NSString *tip = @"正在为您重连...";
    [[NotifyView getInstance] dismissNotifyMessageInView:self.view];
    [[NotifyView getInstance] needShowNotifyMessage:tip inView:self.view forSeconds:3];
    [self doReconnectToServer];
}

- (void)appResignActive:(NSNotification *)note
{
    [self.pushEngine stop];
}

@end
