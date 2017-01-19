//
//  SLKStreamerOptions.h
//  MediaStreamer
//
//  Created by Think on 2016/12/6.
//  Copyright © 2016年 Cell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <AVFoundation/AVFoundation.h>

@interface SLKStreamerOptions : NSObject

@property (nonatomic, strong) NSString *publishUrl;

@property (nonatomic) BOOL hasVideo;
@property (nonatomic) CGSize videoSize;
@property (nonatomic) NSInteger fps;
@property (nonatomic) NSInteger videoBitrate;

@property (nonatomic) BOOL hasAudio;
@property (nonatomic) NSInteger audioBitrate;

@end
