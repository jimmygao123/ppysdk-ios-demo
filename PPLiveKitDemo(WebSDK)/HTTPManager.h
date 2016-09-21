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

@protocol HTTPManagerDelegate<NSObject>
@optional
-(void)HTTPRequestErrorOccured:(NSString *)errorInfo andErrorCode:(NSString *)errorCode;
-(void)DidFetchPushAddressSuccess:(NSString *)pushURL;
-(void)DidFetchPullAddressSuccess:(NSString *)pullURL;
-(void)DidSyncStartStateToServerSuccess;
-(void)DidSyncStopStareToServerSuccess;
-(void)DidFetchLiveStatusSuccess:(NSString *)streamStatus andStreamStatusSuccess:(NSString *)liveStatus;
@end

@interface HTTPManager : NSObject

@property (copy, nonatomic) NSString *roomID;
@property (weak, nonatomic) id<HTTPManagerDelegate> delegate;
@property (assign, nonatomic, readonly) AFNetworkReachabilityStatus currentNetworkStatus;

+(instancetype)shareInstance;

+(void)startMonitor;
+(void)stopMonitor;

-(void)fetchPullRTMPAddr;
-(void)syncPushStartStateToServer;
-(void)syncPushStopStateToServer;
-(void)fetchStreamStatus;
-(void)fetchPushRTMPAddressSuccess:(void (^)(NSDictionary*))successBlock
                          failured:(void (^)(NSError *))failuredBlock;
-(void)syncPushStartStateToServerSuccess:(void (^)(NSDictionary*))successBlock
                                failured:(void (^)(NSError *))failuredBlock;

-(void)fetchStreamStatusSuccess:(void (^)(NSDictionary *))successBlock
                       failured:(void (^)(NSError *))failuredBlock;

-(void)syncPushStopStateToServerSuccess:(void (^)(NSDictionary *))successBlock
                               failured:(void (^)(NSError *))failuredBlock;

-(void)fetchPullRTMPAddrSuccess:(void (^)(NSDictionary *))successBlock
                       Failured:(void (^)(NSError *))failuredBlock;
@end
