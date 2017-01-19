//
//  SLKMediaMerger.h
//  MediaStreamer
//
//  Created by Think on 2016/11/22.
//  Copyright © 2016年 Cell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLKMediaProduct.h"
#import "SLKMediaMaterialGroup.h"
#import "SLKMediaMergeAlgorithm.h"

#import "SLKMediaProcesserCommon.h"

@protocol SLKMediaMergerDelegate <NSObject>
@required
- (void)gotErrorWithErrorType:(int)errorType;
- (void)gotInfoWithInfoType:(int)infoType InfoValue:(int)infoValue;
- (void)didEnd;
@optional
@end

@interface SLKMediaMerger : NSObject

- (instancetype) init;

- (void)initializeWithInputMaterialGroup:(SLKMediaMaterialGroup*)inputSLKMediaMaterialGroup WithMergeAlgorithm:(SLK_MEDIA_MERGE_ALGORITHM)slkMediaMergeAlgorithm WithOutputMediaProduct:(SLKMediaProduct*)outputSLKMediaProduct;

- (void)start;
- (void)resume;
- (void)pause;
- (void)stop;

- (void)terminate;

@property (nonatomic, weak) id<SLKMediaMergerDelegate> delegate;

@end
