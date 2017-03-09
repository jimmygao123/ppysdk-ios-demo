//
//  SLKMediaProcesserUtils.h
//  MediaStreamer
//
//  Created by Think on 16/11/14.
//  Copyright © 2016年 Cell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SLKMediaProcesserUtils : NSObject 

+ (BOOL)qtFaststartWithInputFile:(NSString*)inputFile OutputFile:(NSString*)outputFile;

+ (CVPixelBufferRef)getCoverImageWithInputFile:(NSString*)inputFile OutputWidth:(int)width OutputHeight:(int)height;

+ (BOOL)getCoverImageFileWithInputFile:(NSString*)inputFile OutputWidth:(int)width OutputHeight:(int)height OutputPNGFile:(NSString*)outputFile;

+ (BOOL)getCoverImageFileWithInputFile:(NSString*)inputFile OutputWidth:(int)width OutputHeight:(int)height OutputJPEGFile:(NSString*)outputFile;

//Position : MS
+ (CVPixelBufferRef)getCoverImageWithInputFile:(NSString*)inputFile Position:(NSTimeInterval)position OutputWidth:(int)width OutputHeight:(int)height;

+ (BOOL)getCoverImageFileWithInputFile:(NSString*)inputFile Position:(NSTimeInterval)position OutputWidth:(int)width OutputHeight:(int)height OutputPNGFile:(NSString*)outputFile;

+ (BOOL)getCoverImageFileWithInputFile:(NSString*)inputFile Position:(NSTimeInterval)position OutputWidth:(int)width OutputHeight:(int)height OutputJPEGFile:(NSString*)outputFile;


@end
