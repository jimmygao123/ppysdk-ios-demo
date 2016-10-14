//
//  FlowCell.h
//  PPLiveKitDemo(WebSDK)
//
//  Created by admin on 2016/10/13.
//  Copyright © 2016年 高国栋. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlowCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgBackground;
@property (weak, nonatomic) IBOutlet UIImageView *imgLiveState;
@property (weak, nonatomic) IBOutlet UILabel *lblRoomID;
@end
