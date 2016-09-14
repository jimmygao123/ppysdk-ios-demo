//
//  NotifyView.m
//  PPLiveKitDemo(WebSDK)
//
//  Created by Jimmy on 16/8/26.
//  Copyright © 2016年 高国栋. All rights reserved.
//

#import "NotifyView.h"

@implementation NotifyView
static NotifyView* viewMrg = nil;

+(instancetype)getInstance{
    if(viewMrg == nil)
    {
        viewMrg = [[self alloc] init];
    }
    return viewMrg;
}

-(void)needShowNotifyMessage:(NSString *)text inView:(UIView*)view forSeconds:(NSInteger)second{
    dispatch_async(dispatch_get_main_queue(), ^{
        UILabel *notifyLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 100)];
        notifyLabel.text = text;
        notifyLabel.textAlignment = NSTextAlignmentCenter;
        notifyLabel.textColor = [UIColor whiteColor];
        [notifyLabel sizeToFit];
        notifyLabel.center = view.center;
        
        CGRect viewFrame = notifyLabel.frame;
        notifyLabel.layer.frame = CGRectInset(viewFrame, -10, -10);
        notifyLabel.layer.cornerRadius = 7;
        notifyLabel.layer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6].CGColor;
        
        [UIView animateWithDuration:0.5 animations:^{
            [view addSubview:notifyLabel];
        } completion:^(BOOL finished) {
            if(finished)
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(second * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [notifyLabel removeFromSuperview];
                });
            }
        }];
    });
}

@end
