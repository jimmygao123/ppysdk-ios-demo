//
//  PullViewController.h
//  PPLiveKitDemo(WebSDK)
//
//  Created by Jimmy on 16/8/25.
//  Copyright © 2016年 高国栋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PPYLiveKit/PPYLiveKit.h>

@interface PullViewController : UIViewController
@property (copy, nonatomic) NSString *playAddress;
@property (assign, nonatomic) int sourceType;  //live: 0, vod: 1
@property (copy, nonatomic) NSDictionary *usefulInfo;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indictor;

@end
