//
//  ViewController.m
//  PPLiveKitDemo(WebSDK)
//
//  Created by Jimmy on 16/8/25.
//  Copyright © 2016年 高国栋. All rights reserved.
//

#import "ViewController.h"
#import "PushViewController.h"
#import "PullViewController.h"
#import "ConfigurationViewController.h"
#import "HTTPManager.h"
#import "NotifyView.h"




@interface ViewController ()<HTTPManagerDelegate,PullViewControllerDelegate,PushViewControllerDelegate,ConfigurationViewControllerDelegate>
@property (nonatomic, strong) PushViewController *pushVC;
@property (nonatomic, strong) PullViewController *pullVC;
@property (nonatomic, strong) ConfigurationViewController *pushConfigVC;
@property (nonatomic, strong) ConfigurationViewController *pullConfigVC;

@property (nonatomic, strong) HTTPManager *httpMgr;

@property (weak, nonatomic) IBOutlet UIButton *btnPush;
@property (weak, nonatomic) IBOutlet UIButton *btnPull;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    self.httpMgr = [HTTPManager shareInstance];
    self.httpMgr.delegate = self;
    [HTTPManager startMonitor];
    [self initUI];
}

-(void)initUI{
    self.btnPush.layer.cornerRadius = 10;
    [self.btnPush clipsToBounds];
    
    self.btnPull.layer.cornerRadius = 10;
    self.btnPull.layer.borderWidth = 1.5;
    self.btnPull.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
    [self.btnPull clipsToBounds];
}


- (IBAction)doPush:(id)sender {
    self.pushConfigVC = [[ConfigurationViewController alloc]init];
    self.pushConfigVC.delegate = self;
    [self presentViewController:self.pushConfigVC animated:NO completion:nil];
}
-(void)didPushViewControllerDismiss{
    [self.pushVC dismissViewControllerAnimated:NO completion:nil];
    self.pushVC = nil;
}


- (IBAction)doPull:(id)sender {
    self.pullConfigVC = [[ConfigurationViewController alloc]init];
    self.pullConfigVC.delegate = self;
    self.pullConfigVC.type = 1;
    [self presentViewController:self.pullConfigVC animated:NO completion:nil];
}

-(void)didPullViewControllerDismiss{
    [self.pullVC dismissViewControllerAnimated:YES completion:nil];
    self.pushVC = nil;
}

#pragma mark --ConfigurationViewControllerDelegate--
-(void)viewControllerDoExit:(ConfigurationViewController *)controller{
    if(controller == self.pushConfigVC){
        [self.pushConfigVC dismissViewControllerAnimated:NO completion:nil];
        self.pushConfigVC = nil;
    }
    if(controller == self.pullConfigVC){
        [self.pullConfigVC dismissViewControllerAnimated:NO completion:nil];
        self.pullConfigVC = nil;
    }
}
-(void)viewController:(ConfigurationViewController *)controller didFetchPushRTMPAddress:(NSString *)rtmpAddr{
    if(controller == self.pushConfigVC){
        self.pushVC = [[PushViewController alloc]init];
        self.pushVC.delegate = self;
        self.pushVC.rtmpAddress = rtmpAddr;
        NSLog(@"FetchPushRTMPAddress = %@",rtmpAddr);
        self.pushVC.width = self.pushConfigVC.width;
        self.pushVC.height = self.pushConfigVC.height;
        NSLog(@"Set Video Size = %d,%d",self.pushVC.width,self.pushVC.height);
        
        [self.pushConfigVC dismissViewControllerAnimated:NO completion:nil];
        self.pushConfigVC = nil;
        [self presentViewController:self.pushVC animated:YES completion:nil];
    }
}
-(void)viewController:(ConfigurationViewController *)controller didFetchPullRTMPAddress:(NSString *)rtmpAddr{
    if(controller == self.pullConfigVC){
        self.pullVC = [[PullViewController alloc]init];
        self.pullVC.delegate = self;
        self.pullVC.playAddress = rtmpAddr;
        NSLog(@"Pull address = %@",rtmpAddr);
        [self.pullConfigVC dismissViewControllerAnimated:NO completion:nil];
        self.pushConfigVC = nil;
        [self presentViewController:self.pullVC animated:YES completion:nil];
    }
}

#pragma mark --<HTTPManagerDelegate>--
-(void)HTTPRequestErrorOccured:(NSString *)errorInfo andErrorCode:(NSString *)errorCode{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"errorInfo = %@,errorCode = %@",errorInfo,errorCode);
        if([errorCode isEqualToString:@"300005"]){
            [[NotifyView getInstance] needShowNotifyMessage:@"房间不存在" inView:self.view forSeconds:3];
        }else if ([errorCode isEqualToString:@"1006"]){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.httpMgr syncPushStartStateToServer];
            });
        }else{
            [[NotifyView getInstance] needShowNotifyMessage:errorInfo inView:self.view forSeconds:3];
        }
    });
}

-(void)DidSyncStartStateToServerSuccess{
    [[NotifyView getInstance] needShowNotifyMessage:@"推流成功" inView:self.pushVC.view forSeconds:3];
    [self.pushVC.indicator stopAnimating];
}
-(void)DidSyncStopStareToServerSuccess{
    [[NotifyView getInstance] needShowNotifyMessage:@"推流已经断开" inView:self.view forSeconds:3];
}

-(void)DidFetchPullAddressSuccess:(NSString *)pullURL{
    self.pullVC.playAddress = pullURL;
    [self.httpMgr fetchStreamStatus];
  
}

-(void)DidFetchLiveStatusSuccess:(NSString *)liveStatus andStreamStatusSuccess:(NSString *)streamStatus{
    if(streamStatus == nil){
        [[NotifyView getInstance] needShowNotifyMessage:@"资源不存在" inView:self.view forSeconds:3];
    }else if([streamStatus isEqualToString:@"ok"] && [liveStatus isEqualToString:@"stopped"]){
            [[NotifyView getInstance] needShowNotifyMessage:@"主播已离开房间" inView:self.view forSeconds:3];
    }else if([streamStatus isEqualToString:@"ok"] && [liveStatus isEqualToString:@"living"]){
        [self presentViewController:self.pullVC animated:YES completion:nil];
    }else{
        NSString *status = [NSString stringWithFormat:@"live status:%@,streaStatus:%@",liveStatus,streamStatus];
        [[NotifyView getInstance] needShowNotifyMessage:status inView:self.view forSeconds:3];
    }
}



-(void)showAlertWithMessage:(NSString *)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:message  message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *OK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:OK];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
