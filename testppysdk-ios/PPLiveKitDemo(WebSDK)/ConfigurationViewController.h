//
//  ConfigurationViewController.h
//  PPLiveKitDemo(WebSDK)
//
//  Created by Jimmy on 16/9/7.
//  Copyright © 2016年 高国栋. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ConfigurationViewController;

@protocol ConfigurationViewControllerDelegate <NSObject>
-(void)viewController:(ConfigurationViewController *)controller didFetchPushRTMPAddress:(NSString *)rtmpAddr;
-(void)viewController:(ConfigurationViewController *)controller didFetchPullRTMPAddress:(NSString *)rtmpAddr;
-(void)viewControllerDoExit:(ConfigurationViewController *)controller;
@end


@interface ConfigurationViewController : UIViewController

@property (weak, nonatomic) id<ConfigurationViewControllerDelegate> delegate;

@property (copy, nonatomic,readonly) NSString *roomID;
@property (assign, nonatomic, readonly) int width;
@property (assign, nonatomic, readonly) int height;

@property (assign, nonatomic) int type; //0,configure push, 1, configure pull;

@end
