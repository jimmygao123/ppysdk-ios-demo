//
//  PushViewController.h
//  PPLiveKitDemo(WebSDK)
//
//  Created by Jimmy on 16/8/25.
//  Copyright © 2016年 高国栋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PPYLiveKit/PPYLiveKit.h>

extern NSString * const kNetworkStateChanged;

@class PushViewController;
@protocol  PushViewControllerDelegate <NSObject>
//-(void)needPlayBack:(NSString *)url;
@end

@interface PushViewController : UIViewController

@property (copy, nonatomic) NSString *rtmpAddress;
@property (strong, nonatomic) PPYPushEngine *pushEngine;
@property (assign, nonatomic) int width;
@property (assign, nonatomic) int height;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@property (weak, nonatomic) id<PushViewControllerDelegate>delegate;
@end
