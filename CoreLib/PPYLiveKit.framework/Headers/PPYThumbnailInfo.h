//
//  PPYThumbnailInfo.h
//  PPYLiveKit
//
//  Created by bobzhang on 16/12/29.
//  Copyright © 2016年 PPTV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol PPYThumbnailInfoDelegate <NSObject>
@required
- (void)gotMediaDetailInfoWithDuration:(int64_t)duration WithWidth:(int)width WithHeight:(int)height;
- (void)gotThumbnailWithImageData:(NSData *)imageData;
- (void)gotErrorWithErrorType:(int)errorType;
- (void)gotInfoWithInfoType:(int)infoType InfoValue:(int)infoValue;
- (void)didEnd;
@optional
@end

@interface PPYThumbnailInfo : NSObject

@property (nonatomic, weak) id<PPYThumbnailInfoDelegate> delegate;

- (instancetype) init;

- (void)setThumbnailsOptionWithWidth:(int)width WithHeight:(int)height WithThumbnailCount:(int)thumbnailCount;

- (void)loadAsync:(NSString*)inputMediaFile;
- (void)quit;

- (void)terminate;


+ (BOOL)qtFaststartWithInputFile:(NSString*)inputFile OutputFile:(NSString*)outputFile;

//CVPixelBufferRef retained， should release after processing;
+ (CVPixelBufferRef)getCoverImageWithInputFile:(NSString*)inputFile OutputWidth:(int)width OutputHeight:(int)height;

//You can get the output image from param 'outputfile'.
+ (BOOL)getCoverImageFileWithInputFile:(NSString*)inputFile OutputWidth:(int)width OutputHeight:(int)height OutputFile:(NSString*)outputFile;

@end
