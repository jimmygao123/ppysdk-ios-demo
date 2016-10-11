//
//  PlayerView.h
//  PPLiveKitDemo(WebSDK)
//
//  Created by admin on 2016/10/11.
//  Copyright © 2016年 高国栋. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(int, PlayerType){
    PlayerType_Live,
    PlayerType_VOD,
};

@interface PlayerView : UIView

-(void)displayOnView:(UIView *)view;
-(void)dismiss;
@end
