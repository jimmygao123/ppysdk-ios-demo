//
//  PPYMediaUtils.h
//  PPYLiveKit
//
//  Created by admin on 2016/11/18.
//  Copyright © 2016年 高国栋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PPYMediaUtils : NSObject

+ (BOOL)qtFaststartWithInputFile:(NSString*)inputFile OutputFile:(NSString*)outputFile;

//CVPixelBufferRef retained， should release after processing;
+ (CVPixelBufferRef)getCoverImageWithInputFile:(NSString*)inputFile OutputWidth:(int)width OutputHeight:(int)height;

//You can get the output image from param 'outputfile'.
+ (BOOL)getCoverImageFileWithInputFile:(NSString*)inputFile OutputWidth:(int)width OutputHeight:(int)height OutputFile:(NSString*)outputFile;

@end
