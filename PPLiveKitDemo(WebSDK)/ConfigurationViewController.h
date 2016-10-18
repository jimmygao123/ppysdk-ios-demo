//
//  ConfigurationViewController.h
//  PPLiveKitDemo(WebSDK)
//
//  Created by Jimmy on 16/9/7.
//  Copyright © 2016年 高国栋. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfigurationViewController : UIViewController

@property (copy, nonatomic,readonly) NSString *roomID;
@property (assign, nonatomic, readonly) int width;
@property (assign, nonatomic, readonly) int height;

@end
