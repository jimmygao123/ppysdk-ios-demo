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
#import "JGPlayerControlPanel.h"
#import "PushViewController.h"
#import "WatchModel.h"

#define JPlayControllerLog(format, ...) NSLog((@"PlayerController_"format), ##__VA_ARGS__)

@interface PullViewController ()<PPYPlayEngineDelegate,JGPlayControlPanelDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnExit;
//info
@property (weak, nonatomic) IBOutlet UILabel *lblRoomID;
@property (weak, nonatomic) IBOutlet UILabel *lblBitrate;
@property (weak, nonatomic) IBOutlet UILabel *lblFPS;
@property (weak, nonatomic) IBOutlet UILabel *lblRes;
//live
@property (weak, nonatomic) IBOutlet UIButton *btnData;
@property (weak, nonatomic) IBOutlet UIButton *btnRes;
@property (weak, nonatomic) IBOutlet UIButton *btnPlayProtocol;

@property (strong, nonatomic) UIView *fuzzyView;

@property (strong, nonatomic) JGPlayerControlPanel *viewControlPanel;
@property (strong, nonatomic) IBOutlet UIView *viewLivingPlayCtr;
@property (strong, nonatomic) NSTimer *timer;

@property (assign, nonatomic) BOOL isPlaying;
@property (assign, nonatomic) BOOL isReconnecting;
@property (assign, nonatomic) BOOL isDataShowed;
@property (assign, nonatomic) int reconnectCount;
@property (assign, nonatomic) int reconnectCountWhenStreamError;
@property (assign, nonatomic) int reconnectCountOfCaching;
@property (assign, nonatomic) BOOL isInitLoading;
@property (strong, nonatomic) MBProgressHUD *hud;
@end

@implementation PullViewController

#pragma mark --Action--
- (IBAction)doExit:(id)sender {
    for(id vc in self.navigationController.viewControllers){
        if([vc isKindOfClass:[PushViewController class]]){
            [self.navigationController popToRootViewControllerAnimated:NO];
        }else{
            [self.navigationController popViewControllerAnimated:NO];
        }
    }
}

- (IBAction)doShowData:(id)sender {
    self.lblBitrate.hidden = self.isDataShowed;
    self.lblFPS.hidden = self.isDataShowed;
    self.lblRes.hidden = self.isDataShowed;
    
    self.isDataShowed = !self.isDataShowed;
    [self.btnData setBackgroundImage:[UIImage imageNamed:(self.isDataShowed ? @"p数据分析-启用" : @"p数据分析-禁用")] forState:UIControlStateNormal];
}

- (IBAction)doClick:(id)sender {
    NSLog(@"click button here");
}

- (IBAction)doSelectRes:(id)sender {
    UIButton *btn = (UIButton *)sender;
    
    NSDictionary *dic = self.usefulInfo;
    WatchModel *model = [WatchModel yy_modelWithDictionary:dic];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for(RTMPModel *rtmpModel in model.rtmpsUrl){
        UIAlertAction *action = [UIAlertAction actionWithTitle:rtmpModel.ftCn style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[PPYPlayEngine shareInstance] stopPlayerBlackDisplayNeeded:NO];
            self.playAddress = rtmpModel.rtmpUrl;
            [[PPYPlayEngine shareInstance] startPlayFromURL:rtmpModel.rtmpUrl WithType:PPYSourceType_Live];
            [btn setTitle:rtmpModel.ftCn forState:UIControlStateNormal];
        }];
        
        [alert addAction:action];
    }
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)doSwitchPlayProtocol:(id)sender {
    UIButton *btn = (UIButton *)sender;
    
    NSDictionary *dic = self.usefulInfo;
    WatchModel *model = [WatchModel yy_modelWithDictionary:dic];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"RTMP" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[PPYPlayEngine shareInstance] stopPlayerBlackDisplayNeeded:NO];
        self.playAddress = model.rtmpUrl;
        [[PPYPlayEngine shareInstance] startPlayFromURL:self.playAddress WithType:PPYSourceType_Live];
        [btn setTitle:@"RTMP" forState:UIControlStateNormal];
    }];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"HTTP-FLV" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[PPYPlayEngine shareInstance] stopPlayerBlackDisplayNeeded:NO];
        self.playAddress = model.hdlUrl;
        [[PPYPlayEngine shareInstance] startPlayFromURL:self.playAddress WithType:PPYSourceType_Live];
        [btn setTitle:@"HTTP-FLV" forState:UIControlStateNormal];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];

    [alert addAction:action];
    [alert addAction:action1];
    [alert addAction:cancel];
   
    [self presentViewController:alert animated:NO completion:nil];
}

#pragma mark - load
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)requestPlayInfo
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNetworkState:) name:kNotification_NetworkStateChanged object:nil];
    
    self.isInitLoading = YES;
    [self presentFuzzyViewOnView:self.view WithMessage:@"正在拼命加载..." loadingNeeded:YES];
    
    self.btnExit.hidden = self.isWindowPlayer;
    
    if(self.sourceType == PPYSourceType_Live){
        
        [self startPullStream];
    }else if(self.sourceType == PPYSourceType_VOD){
        
        [self startPlayBack];
    }
}

- (void)preparePlayerView
{
    [PPYPlayEngine shareInstance].delegate = self;
    [[PPYPlayEngine shareInstance] presentPreviewOnView:self.view];
    [[PPYPlayEngine shareInstance] setPreviewRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    [self performSelector:@selector(requestPlayInfo) withObject:nil afterDelay:0.5];
    
    self.reconnectCount = 0;
    [self initUI];
}

-(void)initUI{
    self.lblBitrate.textColor = [UIColor whiteColor];
    self.lblFPS.textColor = [UIColor whiteColor];
    self.lblRoomID.textColor = [UIColor whiteColor];
    self.lblRes.textColor = [UIColor whiteColor];
   
    if(self.sourceType == PPYSourceType_VOD){
        [self doShowData:nil];
    };
    
    if(self.sourceType == PPYSourceType_VOD && !self.isWindowPlayer){
        self.viewControlPanel = [JGPlayerControlPanel playerControlPanel];
        CGRect screenSize = [UIScreen mainScreen].bounds;
        
        self.viewControlPanel.frame = CGRectMake(0, 0, screenSize.size.width,60);
        self.viewControlPanel.center = CGPointMake(self.view.center.x, (screenSize.size.height - self.viewControlPanel.frame.size.height/2));
        [self.view addSubview:self.viewControlPanel];
        
        self.viewControlPanel.delegate = self;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(doRunloop) userInfo:nil repeats:YES];
    }else{
        if(self.sourceType == PPYSourceType_Live){
            self.viewLivingPlayCtr.center = self.view.center;
            [self.view addSubview:self.viewLivingPlayCtr];
        }
    }
    
    self.lblRoomID.text = [NSString stringWithFormat:@" 房间号: %@   ", [HTTPManager shareInstance].roomID];
    if (self.sourceType == PPYSourceType_VOD) {
        self.lblRoomID.hidden = YES;
    } else {
        self.lblRoomID.hidden = NO;
    }
    self.lblRoomID.layer.cornerRadius = 10;
    self.lblRoomID.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    self.lblRoomID.layer.masksToBounds = YES;
    [self.lblRoomID clipsToBounds];
}

#pragma mark --PlayControlPanelDelegate--
-(void)playControlPanelDidClickStartOrPauseButton:(JGPlayerControlPanel *)controlPanel{
    switch (controlPanel.state) {
        case JGPlayerControlState_Init:
            [[PPYPlayEngine shareInstance] startPlayFromURL:self.playAddress WithType:PPYSourceType_VOD];
            break;
        case JGPlayerControlState_Start:
            [[PPYPlayEngine shareInstance] resume];
            break;
        case JGPlayerControlState_Pause:
            [[PPYPlayEngine shareInstance] pause];
            break;
    }
}

-(void)playControlPanel:(JGPlayerControlPanel *)controlPanel didSliderValueChanged:(float)newValue{
    [[PPYPlayEngine shareInstance] seekToPosition:newValue * [PPYPlayEngine shareInstance].duration];
}

#pragma mark ---PlayBack---
-(void)startPlayBack{
    [[PPYPlayEngine shareInstance] startPlayFromURL:self.playAddress WithType:PPYSourceType_VOD];
    
    self.isPlaying = YES;
}


-(void)viewDidDisappear:(BOOL)animated{
    if(self.fuzzyView){
        [self.fuzzyView removeFromSuperview];
        self.fuzzyView = nil;
    }
    [[NotifyView getInstance] dismissNotifyMessageInView:self.view];
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotification_NetworkStateChanged object:nil];
    
    [[PPYPlayEngine shareInstance] stopPlayerBlackDisplayNeeded:YES];
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

-(void)reconnect{
    
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(weakSelf.sourceType == PPYSourceType_Live){
            [weakSelf doPullStream];
            if(weakSelf.reconnectCount > 3){
                weakSelf.reconnectCount = 0;
                [weakSelf throwError:9];
            }
        }else{
            [[PPYPlayEngine shareInstance] startPlayFromURL:self.playAddress WithType:PPYSourceType_VOD];
        }
    });
}

-(void)doReconnectWhenStreamError{
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf doPullStream];
        if(weakSelf.reconnectCountWhenStreamError > 18){  //3min
            weakSelf.reconnectCountWhenStreamError = 0;
            [weakSelf throwError:2];
        }
    });
}

-(void)doStopWhenCachingMoreThanTenSeconds{
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[PPYPlayEngine shareInstance] stopPlayerBlackDisplayNeeded:NO];
        if(weakSelf.sourceType == PPYSourceType_VOD){
            weakSelf.viewControlPanel.state = JGPlayerControlState_Init;
        }
        [weakSelf doPullStream];
        weakSelf.reconnectCountOfCaching ++;
        if(weakSelf.reconnectCountOfCaching > 6){  //1min
            weakSelf.reconnectCountOfCaching = 0;
            [weakSelf throwError:9];
        }
    });
}

#pragma mark --<PPYPlayEngineDelegate>
-(void)dealloc{
    JPlayControllerLog(@"PlayerController delloc");
}

-(void)didPPYPlayEngineErrorOccured:(PPYPlayEngineErrorType)error{
    if(self.isInitLoading){
        [self dismissFuzzyView];
        self.isInitLoading = NO;
    }
    
    switch (error) {
        case PPYPlayEngineError_InvalidSourceURL:
//            [self needShowToastMessage:@"无效资源"];
            [self throwError:7];
            break;
        case PPYPlayEngineError_ConnectFailed:
            [self throwError:10];
            self.reconnectCount++;
            [self reconnect];
            break;
        case PPYPlayEngineError_TransferFailed:
            [self throwError:10];
            self.reconnectCount++;
            [self reconnect];
            break;
        case PPYPlayEngineError_FatalError:
            [self throwError:7];
//            [self needShowToastMessage:@"解码器出错"];
            break;
    }
    JPlayControllerLog(@"error = %d",error);
}

-(void)didPPYPlayEngineInfoThrowOut:(PPYPlayEngineInfoType)type andValue:(int)value{
    if(self.isInitLoading){
        [self dismissFuzzyView];
        self.isInitLoading = NO;
    }
    switch (type) {
        case PPYPlayEngineInfo_BufferingDuration:
            break;
        case PPYPlayEngineInfo_RealBirate:
            self.lblBitrate.text = [NSString stringWithFormat:@" 码率：%dkbps",value];
            break;
        case PPYPlayEngineInfo_RealFPS:
            self.lblFPS.text = [NSString stringWithFormat:@" 帧率：%d帧/秒",value];
        case PPYPlayEngineInfo_BufferingUpdatePercent:
            break;
        case PPYPlayEngineInfo_Duration:
            self.viewControlPanel.duration = value;
            self.viewControlPanel.state = JGPlayerControlState_Start;
            break;
    }
    JPlayControllerLog(@"type = %d,value = %d",type,value);
}

-(void)didPPYPlayEngineStateChanged:(PPYPlayEngineStatus)state{
    __weak typeof(self) weakSelf = self;
    if(self.isInitLoading){
        [self dismissFuzzyView];
        self.isInitLoading = NO;
    }

    switch (state) {
        case PPYPlayEngineStatus_StartCaching:
        {
            [weakSelf performSelector:@selector(doStopWhenCachingMoreThanTenSeconds) withObject:weakSelf afterDelay:10];
            [self throwError:4];
        }
            break;
        case PPYPlayEngineStatus_EndCaching:
            [NSObject cancelPreviousPerformRequestsWithTarget:weakSelf selector:@selector(doStopWhenCachingMoreThanTenSeconds) object:nil];
            [self throwError:5];
            break;
        case PPYPlayEngineStatus_FisrtKeyFrameComing:
            if(self.sourceType == PPYSourceType_VOD){
                
            }
            [self throwError:6];
            break;
        case PPYPlayEngineStatus_RenderingStart:
            break;
        case PPYPlayEngineStatus_ReceiveEOF:
            [self throwError:8];
            if(self.sourceType == PPYSourceType_VOD){
                self.viewControlPanel.state = JGPlayerControlState_Init;
                if (self.timer) {
                    [self.timer invalidate];
                    self.timer = nil;
                }
            }else{
                [self startPullStream];
            }
            
            break;
        case PPYPlayEngineStatus_SeekComplete:
            break;
    }
    JPlayControllerLog(@"state = %lu",(unsigned long)state);
}

-(void)didPPYPlayEngineVideoResolutionCaptured:(int)width VideoHeight:(int)height{
    JPlayControllerLog(@"width = %d,height = %d",width,height);
    self.lblRes.text = [NSString stringWithFormat:@" 分辨率：%dx%d",width,height];
}

-(void)showNetworkState:(NSNotification *)info{
    NSNumber *value = (NSNumber *)info.object;
    switch (value.integerValue) {
        case AFNetworkReachabilityStatusUnknown:
            break;
            
        case AFNetworkReachabilityStatusNotReachable:
            [[PPYPlayEngine shareInstance] stopPlayerBlackDisplayNeeded:NO];
            if(self.sourceType == PPYSourceType_VOD){
                self.viewControlPanel.state = JGPlayerControlState_Init;
            }
            [self throwError:11];
            break;
            
        case AFNetworkReachabilityStatusReachableViaWWAN:
            [[PPYPlayEngine shareInstance] stopPlayerBlackDisplayNeeded:NO];
            if(self.sourceType == PPYSourceType_VOD){
                self.viewControlPanel.state = JGPlayerControlState_Init;
            }else{
                [self startPullStream];
            }
            break;
            
        case AFNetworkReachabilityStatusReachableViaWiFi:
            [[PPYPlayEngine shareInstance] stopPlayerBlackDisplayNeeded:NO];
            [self throwError:12];
            if(self.sourceType == PPYSourceType_VOD){
                self.viewControlPanel.state = JGPlayerControlState_Init;
            }else{
                [self startPullStream];
            }
            break;
    }
}

#pragma mark --UIElelment--

-(void)presentFuzzyViewOnView:(UIView *)view WithMessage:(NSString *)info loadingNeeded:(BOOL)needLoading{
    
    UILabel *label = [[UILabel alloc]init];
    label.text = info;
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    [label sizeToFit];
    label.frame = CGRectMake(0, self.view.frame.origin.y/2 + 20, self.view.frame.size.width, 30);
    [self.fuzzyView addSubview:label];
    
    if(needLoading){
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [indicator hidesWhenStopped];
        indicator.frame = CGRectMake(20, self.view.frame.origin.y/2 + 20, 30, 30);
        [indicator startAnimating];

        [self.fuzzyView addSubview:indicator];
    }
    
    if (!self.isWindowPlayer){
        UIButton *exitBtn = [[UIButton alloc]initWithFrame:self.btnExit.frame];
        [exitBtn setImage:[UIImage imageNamed:@"关闭.png"] forState:UIControlStateNormal];
        [exitBtn addTarget:self action:@selector(doExit:) forControlEvents:UIControlEventTouchUpInside];
        [self.fuzzyView addSubview:exitBtn];
    }
 
    [view addSubview:self.fuzzyView];
}

-(void)dismissFuzzyView{
    [self.fuzzyView removeFromSuperview];
    self.fuzzyView = nil;
}

-(UIView *)fuzzyView{
    if(_fuzzyView == nil){
        _fuzzyView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        _fuzzyView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    }
    return _fuzzyView;
}

- (BOOL)prefersStatusBarHidde{
    return YES;
}

-(void)needShowToastMessage:(NSString *)message{
    __weak typeof(self) weakSelf = self;
    [[NotifyView getInstance] needShowNotifyMessage:message inView:weakSelf.view forSeconds:3];
}

#pragma mark --NetworkRequest--
-(void)startPullStream{
    if([HTTPManager shareInstance].currentNetworkStatus == AFNetworkReachabilityStatusReachableViaWWAN){
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"当前使用移动流量，是否继续观看？" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *btnOK = [UIAlertAction actionWithTitle:@"继续" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self doPullStream];
        }];
        UIAlertAction *btnCancel = [UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popToRootViewControllerAnimated:NO];
        }];
        [alert addAction:btnOK];
        [alert addAction:btnCancel];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        [self doPullStream];
    }
}

-(void)doPullStream{
    if(self.sourceType == PPYSourceType_VOD)
        return;
    
    __weak typeof(self)weakSelf = self;
    [[HTTPManager shareInstance] fetchStreamStatusSuccess:^(NSDictionary *dic) {
        if(dic != nil){
            if([[dic objectForKey:@"err"] isEqualToString:@"0"]){
                NSDictionary *data = (NSDictionary *)[dic objectForKey:@"data"];
                NSString *liveState = (NSString *)[data objectForKey:@"liveStatus"];
                NSString *streamState = (NSString *)[data objectForKey:@"streamStatus"];
                
                if([liveState isEqualToString:@"living"] && [streamState isEqualToString:@"ok"]){
                    if(weakSelf.reconnectCountWhenStreamError > 0){
                        weakSelf.reconnectCountWhenStreamError = 0;
                        [weakSelf throwError:13];
                    }
                    [[PPYPlayEngine shareInstance] startPlayFromURL:weakSelf.playAddress WithType:PPYSourceType_Live];
                }else if([liveState isEqualToString:@"living"] && [streamState isEqualToString:@"error"]){
                    weakSelf.reconnectCountWhenStreamError++;
                    [weakSelf throwError:3];
                }else if([liveState isEqualToString:@"broken"] && [streamState isEqualToString:@"error"]){
                    weakSelf.reconnectCountWhenStreamError++;
                    [weakSelf throwError:3];
                }else{
                    [weakSelf throwError:2];
                }
                
                NSString *status = [NSString stringWithFormat:@"live status:%@,streaStatus:%@",liveState,streamState];
                NSLog(@"%s,%@",__FUNCTION__,status);
            }else{
                NSString *errorInfo = (NSString *)[dic objectForKey:@"msg"];
                NSString *errCode = (NSString *)[dic objectForKey:@"err"];
                NSLog(@"%s,%@:%@",__FUNCTION__,errCode,errorInfo);
                [weakSelf throwError:2];
            }
        }else{
            [weakSelf throwError:1];
        }
    } failured:^(NSError *err) {
        [weakSelf throwError:0];
    }];
}

-(void)throwError:(int)errCode{
    __weak typeof(self)weakSelf = self;
    NSString *tip = nil;
    if(errCode == 0){
        NSLog(@"AFNetworking connection error");
    }else if(errCode == 1){
        NSLog(@"AFNetworking return object error");
    }else if(errCode == 2){
        tip = @"直播已经结束";
        [weakSelf presentFuzzyViewOnView:weakSelf.view WithMessage:tip loadingNeeded:NO];
    }else if(errCode == 3){
        if(weakSelf.reconnectCountWhenStreamError > 0){
            tip = @"主播离开一会儿，不要离开啊";
            [[NotifyView getInstance] needShwoNotifyMessage:tip inView:weakSelf.view];
        }
        [weakSelf doReconnectWhenStreamError];
    }else if(errCode == 13){
        tip = @"主播回来了";
        [[NotifyView getInstance] dismissNotifyMessageInView:weakSelf.view];
    }else if(errCode == 4){
        if(weakSelf.sourceType == PPYSourceType_Live){
            tip = @"网络有些卡顿，正在拼命缓冲...";  //start caching
        }else{
            tip = @"正在缓冲...";
        }
        [[NotifyView getInstance] needShwoNotifyMessage:tip inView:weakSelf.view];
    }else if(errCode == 5){
        tip = @"网络卡顿恢复结束";             //end caching
        [[NotifyView getInstance] dismissNotifyMessageInView:weakSelf.view];
    }else if(errCode == 6){                     //receive fisrt key frame mark as pull stream success
        if(weakSelf.isReconnecting){
            weakSelf.isReconnecting = NO;
            tip = @"重连成功";
            [weakSelf needShowToastMessage:tip];
            [[NotifyView getInstance] dismissNotifyMessageInView:weakSelf.view];
        }else if(weakSelf.reconnectCountOfCaching > 0){
            weakSelf.reconnectCountOfCaching = 0;
        }else{
            tip = @"拉流成功";
            [weakSelf needShowToastMessage:tip];
            [[NotifyView getInstance] dismissNotifyMessageInView:weakSelf.view];
        }
    }else if(errCode == 7){
        NSLog(@"解码器错误或者资源错误");
    }else if(errCode == 8){
        NSLog(@"收到EOF包，暂时用重连逻辑代替");
    }else if(errCode == 9){
        tip = @"世界上最遥远的距离就是断网，请检查您的网络设置，网络恢复后将为您重新连接";
        [[NotifyView getInstance] needShwoNotifyMessage:tip inView:weakSelf.view];
        weakSelf.isReconnecting = NO;
    }else if(errCode == 10){
        tip = @"当前网络环境异常，正在重新连接...";
        [[NotifyView getInstance] needShowNotifyMessage:tip inView:weakSelf.view forSeconds:3];
        weakSelf.isReconnecting = YES;
    }else if(errCode == 11){        //AFNetworking 断网事件
        tip = @"世界上最遥远的距离就是断网，请检查您的网络设置，网络恢复后将为您重新连接";
        [[NotifyView getInstance] needShwoNotifyMessage:tip inView:weakSelf.view];
    }else if(errCode == 12){        //AFNetworking wifi连接事件
        tip = @"当前使用Wi-Fi网络,正在重新连接...";
        [[NotifyView getInstance] needShwoNotifyMessage:tip inView:weakSelf.view];
    }
    JPlayControllerLog(@"tip = %@",tip);
}

-(void)doRunloop
{
    NSTimeInterval  currentPlayTime = [PPYPlayEngine shareInstance].currentPlaybackTime;
    NSLog(@"currentPlayTime = %f,",currentPlayTime);
    self.viewControlPanel.progress = [PPYPlayEngine shareInstance].currentPlaybackTime;
}

@end
