//
//  PullViewController.h
//  PPLiveKitDemo(WebSDK)
//
//  Created by Jimmy on 16/8/25.
//  Copyright © 2016年 高国栋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PPYLiveKit/PPYLiveKit.h>

@protocol  PullViewControllerDelegate <NSObject>

-(void)didPullViewControllerDismiss;

@end

@interface PullViewController : UIViewController

@property (nonatomic, strong) PPYPullEngine *pullEngine;
@property (copy, nonatomic) NSString *playAddress;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indictor;

@property (weak, nonatomic) id<PullViewControllerDelegate> delegate;

@end
