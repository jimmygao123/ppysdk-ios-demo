//
//  PullViewController.h
//  PPLiveKitDemo(WebSDK)
//
//  Created by Jimmy on 16/8/25.
//  Copyright © 2016年 高国栋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PPYLiveKit/PPYLiveKit.h>

@class PlayListController;
@interface PullViewController : UIViewController

@property (copy, nonatomic) NSString *channelWebID;
@property (copy, nonatomic) NSString *playAddress;
@property (assign, nonatomic) PPYSourceType sourceType;
@property (copy, nonatomic) NSDictionary *usefulInfo;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indictor;

@property (assign, nonatomic) BOOL windowPlayerDisabled;  //是否需要小窗,仅在播放VOD时有用。
@property (assign, nonatomic) BOOL isWindowPlayer;
@property (weak, nonatomic) PlayListController *playListController;
@property CGRect windowPlayerFrame;

- (void)preparePlayerView;
- (void)requestOtherVideo;
- (void)releaseObject;


@end
