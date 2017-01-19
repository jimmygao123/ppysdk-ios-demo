//
//  SLKMediaInfo.h
//  MediaStreamer
//
//  Created by Think on 2016/11/29.
//  Copyright © 2016年 Cell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "SLKMediaProcesserCommon.h"

@protocol SLKMediaInfoDelegate <NSObject>
@required
- (void)gotMediaDetailInfoWithDuration:(int64_t)duration WithWidth:(int)width WithHeight:(int)height;
- (void)gotThumbnailWithCVPixelBuffer:(CVPixelBufferRef)outputThumbnailData;
- (void)gotErrorWithErrorType:(int)errorType;
- (void)gotInfoWithInfoType:(int)infoType InfoValue:(int)infoValue;
- (void)didEnd;
@optional
@end

@interface SLKMediaInfo : NSObject

+ (NSTimeInterval)syncGetMediaDurationWithInputFile:(NSString*)inputMediaFile;

- (instancetype) init;

- (void)initialize;

- (void)setThumbnailsOptionWithWidth:(int)width WithHeight:(int)height WithThumbnailCount:(int)thumbnailCount;

- (void)loadAsync:(NSString*)inputMediaFile;
- (void)quit;

- (void)terminate;

@property (nonatomic, weak) id<SLKMediaInfoDelegate> delegate;


@end
