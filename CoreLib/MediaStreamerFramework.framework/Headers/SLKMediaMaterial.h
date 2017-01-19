//
//  SLKMediaMaterial.h
//  MediaStreamer
//
//  Created by Think on 2016/11/22.
//  Copyright © 2016年 Cell. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum SLK_MEDIA_MATERIAL_TYPE{
    SLK_MEDIA_MATERIAL_TYPE_UNKNOWN     = -1,
    SLK_MEDIA_MATERIAL_TYPE_VIDEO_AUDIO = 0,
    SLK_MEDIA_MATERIAL_TYPE_VIDEO       = 1,
    SLK_MEDIA_MATERIAL_TYPE_AUDIO       = 2,
    SLK_MEDIA_MATERIAL_TYPE_TEXT        = 3,
    SLK_MEDIA_MATERIAL_TYPE_PNG         = 4,
    SLK_MEDIA_MATERIAL_TYPE_JPEG        = 5,
}SLK_MEDIA_MATERIAL_TYPE;

@interface SLKMediaMaterial : NSObject

@property (nonatomic) NSInteger iD;
@property (nonatomic, strong) NSString *url;
@property (nonatomic) SLK_MEDIA_MATERIAL_TYPE slk_media_material_type;
@property (nonatomic) NSTimeInterval startPos;
@property (nonatomic) NSTimeInterval endPos;
@property (nonatomic) NSTimeInterval weight; //0.0 - 1.0
@property (nonatomic) NSInteger x;
@property (nonatomic) NSInteger y;

@end
