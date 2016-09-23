//
//  NotifyView.h
//  PPLiveKitDemo(WebSDK)
//
//  Created by Jimmy on 16/8/26.
//  Copyright © 2016年 高国栋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NotifyView : NSObject

+(instancetype)getInstance;
-(void)needShowNotifyMessage:(NSString *)text inView:(UIView*)view forSeconds:(NSInteger)second;

-(void)dismissNotifyMessageInView:(UIView *)view;
-(void)needShwoNotifyMessage:(NSString *)text inView:(UIView *)view;
@end
