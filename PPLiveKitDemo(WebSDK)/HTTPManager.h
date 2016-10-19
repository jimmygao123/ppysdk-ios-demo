//
//  HTTPManager.h
//  PPLiveKitDemo(WebSDK)
//
//  Created by Jimmy on 16/8/26.
//  Copyright © 2016年 高国栋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

FOUNDATION_EXPORT NSString * const kNotification_NetworkStateChanged;

@interface HTTPManager : NSObject

@property (copy, nonatomic) NSString *roomID;
@property (assign, nonatomic, readonly) AFNetworkReachabilityStatus currentNetworkStatus;

+(instancetype)shareInstance;

+(void)startMonitor;
+(void)stopMonitor;

-(void)fetchPushRTMPAddressSuccess:(void (^)(NSDictionary*))successBlock
                          failured:(void (^)(NSError *))failuredBlock;
-(void)syncPushStartStateToServerSuccess:(void (^)(NSDictionary*))successBlock
                                failured:(void (^)(NSError *))failuredBlock;

-(void)fetchStreamStatusSuccess:(void (^)(NSDictionary *))successBlock
                       failured:(void (^)(NSError *))failuredBlock;

-(void)syncPushStopStateToServerSuccess:(void (^)(NSDictionary *))successBlock
                               failured:(void (^)(NSError *))failuredBlock;

-(void)fetchPlayURL:(void (^)(NSDictionary *))successBlock
                    Failured:(void (^)(NSError *))failuredBlock;

-(void)fetchLiveListWithPageNum:(int)num
                        Success:(void (^)(NSDictionary *))successBlock
                       Failured:(void (^)(NSError *))failuredBlock;

-(void)fetchVODListWithPageNum:(int)num
                       Success:(void (^)(NSDictionary *))successBlock
                      Failured:(void (^)(NSError *))failuredBlock;

-(void)fetchDetailInfoWithChannelWebID:(NSString *)channelID
                               Success:(void (^)(NSDictionary *))successBlock
                              Failured:(void (^)(NSError *))failuredBlock;

-(NSData *)downloadWebImageWithURL:(NSString *)url;

@end
