//
//  PlayListHelper.h
//  PPLiveKitDemo(WebSDK)
//
//  Created by admin on 2016/10/13.
//  Copyright © 2016年 高国栋. All rights reserved.
//

#import <Foundation/Foundation.h>


#define kRoomName @"room_name"
#define kScreenShot @"screen_shot"
#define kLiveState @"live_status"
#define kDuration @"duration"
#define kChannelWebID @"channel_web_id"

#define kFLVURL @"hdlUrl"
#define kM3u8URL @"m3u8Url"
#define kRTMPURL @"rtmpUrl"
#define kRTMPSURL @"rtmpsUrl"


typedef NS_ENUM(int, PlayerListErrorType){
    PraseError,
    AFNetworking_Error,
};

typedef NS_ENUM(int, PlayerType){
    PlayerType_Live,
    PlayerType_VOD,
};

@protocol  PlayerListHelperDelegate <NSObject>

-(void)didFetchLiveListSuccess:(NSMutableArray *)array;
-(void)didFetchLiveListFailured:(PlayerListErrorType)type Code:(int)errorCode Info:(NSString *)errInfo;

-(void)didFetchVODListSuccess:(NSMutableArray *)array;
-(void)didFetchVODListFailued:(PlayerListErrorType)type Code:(int)errorCode Info:(NSString *)errInfo;
@end


@interface PlayListHelper : NSObject
@property (weak, nonatomic) id<PlayerListHelperDelegate> delegate;
-(void )fetchLiveListWithPageNum:(int)num;
-(void)fetchVODListWithPageNum:(int)num;

-(void)downLoadWebImage:(NSString *)url onQueueAsync:(dispatch_queue_t)queue completionHandler:(void(^)(NSData *data))handle;

-(NSString *)fetchVodURLWithChannelWebID:(NSString *)webID; //VOD
-(void)fetchLivingURLsWithRoomID:(NSString *)roomID
                    SuccessBlock:(void(^)(NSDictionary *dic))success
                   FailuredBlock:(void (^)(int errCode, NSString *errInfo))failured; //living
@end

