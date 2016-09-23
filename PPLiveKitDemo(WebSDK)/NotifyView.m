//
//  NotifyView.m
//  PPLiveKitDemo(WebSDK)
//
//  Created by Jimmy on 16/8/26.
//  Copyright © 2016年 高国栋. All rights reserved.
//

#import "NotifyView.h"
#define KLableTag 1000
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
        
        CGPoint center = [self calculateDisplayCenterOfLable:notifyLabel];
        
        notifyLabel.center = CGPointMake(center.x, center.y - 30);
        
        CGRect viewFrame = notifyLabel.frame;
        notifyLabel.layer.frame = CGRectInset(viewFrame, -10, -10);
        notifyLabel.layer.cornerRadius = 7;
        notifyLabel.layer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2].CGColor;
        
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

-(void)needShwoNotifyMessage:(NSString *)text inView:(UIView *)view{
    dispatch_async(dispatch_get_main_queue(), ^{
        UILabel *notifyLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 100)];
        notifyLabel.tag = KLableTag;
        notifyLabel.text = text;
        notifyLabel.textAlignment = NSTextAlignmentCenter;
        notifyLabel.textColor = [UIColor whiteColor];
        [notifyLabel sizeToFit];
        notifyLabel.center = [self calculateDisplayCenterOfLable:notifyLabel];
        
        CGRect viewFrame = notifyLabel.frame;
        notifyLabel.layer.frame = CGRectInset(viewFrame, -10, -10);
        notifyLabel.layer.cornerRadius = 7;
        notifyLabel.layer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2].CGColor;
        
        [view addSubview:notifyLabel];
    });
}

-(void)dismissNotifyMessageInView:(UIView *)view{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSEnumerator *subviewsEnum = [view.subviews reverseObjectEnumerator];
        for (id subview in subviewsEnum){
            if([subview isKindOfClass:[UILabel class]]){
                UILabel *label = (UILabel *)subview;
                if(label.tag == KLableTag){
                    [label removeFromSuperview];
                }
            }
        }
    });
}

-(CGPoint)calculateDisplayCenterOfLable:(UILabel *)displayLabel{
    int screenHeight = [UIScreen mainScreen].bounds.size.height;
    int screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    int labelWidth = displayLabel.frame.size.width;
    
    int x = screenWidth - labelWidth/2;
    int y = screenHeight - 60;
    
    return CGPointMake(x, y);
};
@end
