//
//  PPYMediaMerger.h
//  PPYLiveKit
//
//  Created by bobzhang on 16/12/29.
//  Copyright © 2016年 PPTV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


enum ppy_media_processer_info_type {
    //PPY_ MEDIA_PROCESSER_INFO_PROCESS_PERCENT = 0,
    PPY_MEDIA_PROCESSER_INFO_WRITE_TIMESTAMP = 1,
};

@protocol PPYMediaMergerDelegate <NSObject>
@required
- (void)gotErrorWithErrorType:(int)errorType;
- (void)gotInfoWithInfoType:(int)infoType InfoValue:(int)infoValue;
- (void)didEnd;
@optional
@end


@interface PPYMediaInfo : NSObject

@property (nonatomic, strong) NSString *mediaPath;
@property (nonatomic, assign) NSTimeInterval startPos;
@property (nonatomic, assign) NSTimeInterval endPos;

@end


@interface PPYMediaProduct : NSObject

@property (nonatomic, strong) NSString *url;
@property (nonatomic) CGSize videoSize;

@end

@interface PPYMediaMerger : NSObject

@property (nonatomic, weak) id<PPYMediaMergerDelegate> delegate;

@property (nonatomic, strong) PPYMediaProduct *mediaProduct;

-(instancetype)initWithProductPath:(NSString *)path  andVideoSize:(CGSize)videoSize;

//每段视频都要调用一次
- (void)addMediaMaterial:(PPYMediaInfo*)mediaMaterial;

- (void)start;

@end
