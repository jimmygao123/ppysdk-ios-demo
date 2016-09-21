//
//  PullViewController.m
//  PPLiveKitDemo(WebSDK)
//
//  Created by Jimmy on 16/8/25.
//  Copyright © 2016年 高国栋. All rights reserved.
//

#import "PullViewController.h"
#import "HTTPManager.h"
#import "NotifyView.h"
#import "MBProgressHUD.h"

#define JPlayControllerLog(format, ...) NSLog((@"PlayerController_"format), ##__VA_ARGS__)

@interface PullViewController ()<PPYPlayEngineDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblRoomID;
@property (weak, nonatomic) IBOutlet UILabel *lblBitrate;
@property (weak, nonatomic) IBOutlet UILabel *lblFPS;
@property (weak, nonatomic) IBOutlet UILabel *lblRes;
@property (weak, nonatomic) IBOutlet UIButton *btnData;

@property (assign, nonatomic) BOOL isDataShowed;
@property (assign, nonatomic) int reconnectCount;
@property (strong, nonatomic) MBProgressHUD *hud;
@end

@implementation PullViewController

- (IBAction)doExit:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}
- (IBAction)doShowData:(id)sender {
    self.lblBitrate.hidden = self.isDataShowed;
    self.lblFPS.hidden = self.isDataShowed;
    self.lblRes.hidden = self.isDataShowed;
    
    self.isDataShowed = !self.isDataShowed;
    [self.btnData setBackgroundImage:[UIImage imageNamed:(self.isDataShowed ? @"p数据分析-启用" : @"p数据分析-禁用")] forState:UIControlStateNormal];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initUI];
    [PPYPlayEngine shareInstance].delegate = self;
    [[PPYPlayEngine shareInstance] setPreviewOnView:self.view];
}
-(void)initData{
    self.isDataShowed = YES;
    self.reconnectCount = 0;
}
-(void)initUI{
    self.lblBitrate.textColor = [UIColor whiteColor];
    self.lblFPS.textColor = [UIColor whiteColor];
    self.lblRoomID.textColor = [UIColor whiteColor];
    self.lblRes.textColor = [UIColor whiteColor];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNetworkState:) name:kNotification_NetworkStateChanged object:nil];

    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.label.text = @"正在拼命加载...";
    [[PPYPlayEngine shareInstance] startPlayFromURL:self.playAddress];
    
    self.lblRoomID.text = [NSString stringWithFormat:@" 房间号: %@   ", [HTTPManager shareInstance].roomID];
    self.lblRoomID.layer.cornerRadius = 10;
    self.lblRoomID.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    self.lblRoomID.layer.masksToBounds = YES;
    [self.lblRoomID clipsToBounds];
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotification_NetworkStateChanged object:nil];
    
    [[PPYPlayEngine shareInstance] stop:YES];
}


-(void)reconnect{
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.label.text = @"网络异常，正在尝试重练...";
    __weak typeof(self) weakSelf = self;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         [[PPYPlayEngine shareInstance] startPlayFromURL:weakSelf.playAddress];
        weakSelf.reconnectCount++;
        if(weakSelf.reconnectCount > 10){
            weakSelf.reconnectCount = 0;
            
            [weakSelf.hud hideAnimated:YES];
            [weakSelf needShowToastMessage:@"重连失败"];
        }
    });
}

#pragma mark --<PPYPlayEngineDelegate>
-(void)dealloc{
    JPlayControllerLog(@"PlayerController delloc");
}
-(void)didPPYPlayEngineErrorOccured:(PPYPlayEngineErrorType)error{
    switch (error) {
        case PPYPlayEngineError_InvalidSourceURL:
            [self needShowToastMessage:@"无效资源"];
            break;
        case PPYPlayEngineError_ConnectFailed:
            [self reconnect];
            break;
        case PPYPlayEngineError_TransferFailed:
            [self reconnect];
            break;
        case PPYPlayEngineError_FatalError:
            [self needShowToastMessage:@"解码器出错"];
            break;
    }
    JPlayControllerLog(@"error = %d",error);
}
-(void)didPPYPlayEngineInfoThrowOut:(PPYPlayEngineInfoType)type andValue:(int)value{
    switch (type) {
        case PPYPlayEngineInfo_BufferingDuration:
            
            break;
        case PPYPlayEngineInfo_RealBirate:
            self.lblBitrate.text = [NSString stringWithFormat:@" 码率：%dkbps",value];
            break;
        case PPYPlayEngineInfo_RealFPS:
            self.lblFPS.text = [NSString stringWithFormat:@" 帧率：%d帧/秒",value];
            break;
    }
    JPlayControllerLog(@"type = %d,value = %d",type,value);
}
-(void)didPPYPlayEngineStateChanged:(PPYPlayEngineStatus)state{
    switch (state) {
        case PPYPlayEngineStatus_StartCaching:
            self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            self.hud.label.text = @"正在缓冲...";
            break;
        case PPYPlayEngineStatus_EndCaching:
            [self.hud hideAnimated:YES];
            break;
        case PPYPlayEngineStatus_FisrtKeyFrameComing:
            self.reconnectCount = 0;
            [self.hud hideAnimated:YES];
            break;
        case PPYPlayEngineStatus_RenderingStart:
            
            break;
        case PPYPlayEngineStatus_ReceiveEOF:
            [self reconnect];
            break;
    }
    JPlayControllerLog(@"state = %d",state);
}
-(void)didPPYPlayEngineVideoResolutionCaptured:(int)width VideoHeight:(int)height{
    JPlayControllerLog(@"width = %d,height = %d",width,height);
    self.lblRes.text = [NSString stringWithFormat:@" 分辨率：%dx%d",width,height];
}

- (BOOL)prefersStatusBarHidde{
    return YES;
}

-(void)needShowToastMessage:(NSString *)message{
    __weak typeof(self) weakSelf = self;
    [[NotifyView getInstance] needShowNotifyMessage:message inView:weakSelf.view forSeconds:3];
}
-(void)showNetworkState:(NSNotification *)info{
    NSNumber *value = (NSNumber *)info.object;
    NSString *tip = nil;
    switch (value.integerValue) {
        case AFNetworkReachabilityStatusUnknown:
            [self.hud hideAnimated:YES];
            [[PPYPlayEngine shareInstance] stop:NO];
            tip = @"网络异常发生未知错误";
            break;
        case AFNetworkReachabilityStatusNotReachable:
            [self.hud hideAnimated:YES];
            [[PPYPlayEngine shareInstance] stop:NO];
            tip = @"网络断开,请检查网络";
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN:
            [self.hud hideAnimated:YES];
            [[PPYPlayEngine shareInstance] stop:NO];
            [[PPYPlayEngine shareInstance] startPlayFromURL:self.playAddress];
            tip = @"当前使用3G/4G网络";
            break;
        case AFNetworkReachabilityStatusReachableViaWiFi:
            [self.hud hideAnimated:YES];
            [[PPYPlayEngine shareInstance] stop:NO];
            [[PPYPlayEngine shareInstance] startPlayFromURL:self.playAddress];
            tip = @"当前使用Wi-Fi";
            break;
    }
    [[NotifyView getInstance] needShowNotifyMessage:tip inView:self.view forSeconds:3];
}
@end
