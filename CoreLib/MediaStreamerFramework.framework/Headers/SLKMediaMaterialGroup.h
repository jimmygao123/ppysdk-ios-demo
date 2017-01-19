//
//  SLKMediaMaterialGroup.h
//  MediaStreamer
//
//  Created by Think on 2016/11/22.
//  Copyright © 2016年 Cell. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SLKMediaMaterial.h"

@interface SLKMediaMaterialGroup : NSObject

- (instancetype) init;

- (void)addMediaMaterial:(SLKMediaMaterial*)mediaMaterial;

- (void)insertMediaMaterial:(SLKMediaMaterial*)mediaMaterial atIndex:(NSUInteger)index;

- (void)removeMediaMaterial:(SLKMediaMaterial*)mediaMaterial;

- (void)removeMediaMaterialAtIndex:(NSUInteger)index;

- (void)removeAllMediaMaterials;

- (NSUInteger)count;

- (SLKMediaMaterial*)getMediaMaterialAtIndex:(NSUInteger)index;

@end
