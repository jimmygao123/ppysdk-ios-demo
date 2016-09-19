//
//  PullViewController.m
//  PPLiveKitDemo(WebSDK)
//
//  Created by Jimmy on 16/8/25.
//  Copyright © 2016年 高国栋. All rights reserved.
//

#import "PullViewController.h"
#import <IJKMediaFramework/IJKMediaFramework.h>
#import "HTTPManager.h"
#import "NotifyView.h"
@interface PullViewController ()<PPYPullEngineDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblRoomID;

@end

@implementation PullViewController

- (IBAction)doExit:(id)sender {
    [self.pullEngine stopPlay];
    [self.delegate didPullViewControllerDismiss];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.pullEngine = [[PPYPullEngine alloc]initWithRTMPAddr:self.playAddress];
    self.pullEngine.delegate = self;
    self.pullEngine.preview = self.view;
    [self.pullEngine startPlay];
    self.lblRoomID.text = [NSString stringWithFormat:@"     房间号: %@   ", [HTTPManager shareInstance].roomID];
    
    self.lblRoomID.layer.cornerRadius = 10;
    [self.lblRoomID sizeToFit];
    [self.lblRoomID clipsToBounds];
    [self.lblRoomID.layer masksToBounds];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.pullEngine.preview removeFromSuperview];

}


#pragma mark --<PPYPullEngineDelegate>
-(void)playerStateChanged:(PPYPlayerStatus)status{
    switch (status) {
        case PPYPlayerStatus_PlayStarted:
            NSLog(@"Jimmy_started");
            break;
        case PPYPlayerStatus_PlayEnded:
            [[HTTPManager shareInstance] fetchStreamStatus];
            NSLog(@"Jimmy_playended");
            break;
        case PPYPlayerStatus_PlayStopped:
            NSLog(@"Jimmy_playStopped");
            break;
        case PPYPlayerStatus_ErrorOccured:
            NSLog(@"Jimmy_playError");
            break;
    }
}
- (BOOL)prefersStatusBarHidde{
    return YES;
}
@end
