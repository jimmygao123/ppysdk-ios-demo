//
//  SLKMediaProduct.h
//  MediaStreamer
//
//  Created by Think on 2016/11/22.
//  Copyright © 2016年 Cell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <AVFoundation/AVFoundation.h>

@interface SLKMediaProduct : NSObject

@property (nonatomic) NSInteger iD;
@property (nonatomic, strong) NSString *url;

@property (nonatomic) BOOL hasVideo;
@property (nonatomic) CGSize videoSize;

@property (nonatomic) BOOL hasAudio;

@property (nonatomic) NSInteger bps;


@end
