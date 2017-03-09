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

typedef NS_ENUM(NSInteger,PPYMediaMergerType) {
    PPYMediaMergerTypeVideoOnly,
    PPYMediaMergerTypeMusicVideoMix
};

@protocol PPYMediaMergerDelegate <NSObject>
@required
- (void)gotErrorWithErrorType:(int)errorType;
- (void)gotInfoWithInfoType:(int)infoType InfoValue:(int)infoValue;
- (void)didEndWithMergeType:(PPYMediaMergerType)type;
@optional
@end


@interface PPYMediaInfo : NSObject

@property (nonatomic, strong) NSString *mediaPath;
@property (nonatomic, assign) NSTimeInterval startPos;
@property (nonatomic, assign) NSTimeInterval endPos;
@property (nonatomic, assign) float weight;

@end


@interface PPYMediaProduct : NSObject

@property (nonatomic, strong) NSString *url;
@property (nonatomic) CGSize videoSize;

@end

@interface PPYMediaMerger : NSObject

@property (nonatomic, weak) id<PPYMediaMergerDelegate> delegate;

@property (nonatomic, strong) PPYMediaProduct *mediaProduct;

@property (nonatomic, strong) NSString *productPath;
- (instancetype)initWithProductPath:(NSString *)path  andVideoSize:(CGSize)videoSize;

- (void)mergeVideoMedias:(NSArray <PPYMediaInfo *> *)medias;

- (void)addMusicMedia:(PPYMediaInfo *)musicMedia toVideoMedia:(PPYMediaInfo *)videoMedia;

@end
