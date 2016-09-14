//
//  HTTPManager.m
//  PPLiveKitDemo(WebSDK)
//
//  Created by Jimmy on 16/8/26.
//  Copyright © 2016年 高国栋. All rights reserved.
//

#import "HTTPManager.h"
#import "AFNetworking.h"
#import "NotifyView.h"

NSString * const kNotification_NetworkStateChanged = @"kNetworkStateChanged";

#define kURLGetPushRTMPAddr @"http://115.231.44.26:8081/live/create"
#define kURLGetPullRTMPAddr @"http://115.231.44.26:8081/live/watch"
#define kURLSyncPushStateToServer @"http://115.231.44.26:8081/live/start"
#define kURLSyncPushStopToServer @"http://115.231.44.26:8081/live/stop"
#define kURLGetStreamStatus @"http://115.231.44.26:8081/live/status"

@interface HTTPManager ()
@property (strong, nonatomic) AFHTTPSessionManager *httpManager;
@end

@implementation HTTPManager

+(instancetype)shareInstance{
    static HTTPManager *__instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __instance = [[[self class] alloc]init];
    });
    return __instance;
}

-(instancetype)init{
    if(self = [super init]){
        self.httpManager = [AFHTTPSessionManager manager];
        self.httpManager.requestSerializer = [AFJSONRequestSerializer serializer];
        self.httpManager.requestSerializer.timeoutInterval = 10;
        self.httpManager.responseSerializer = [AFJSONResponseSerializer serializer];
        self.httpManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    }
    return self;
}

-(void)fetchPushRTMPAddressSuccess:(void (^)(NSDictionary*))successBlock
                          failured:(void (^)(NSError *))failuredBlock{
    NSString *requestURL = [kURLGetPushRTMPAddr stringByAppendingPathComponent:self.roomID];
    NSLog(@"getPushRtmpaddrurl = %@",requestURL);
    [self requestURL:requestURL success:successBlock failured:failuredBlock];
}

-(void)syncPushStartStateToServerSuccess:(void (^)(NSDictionary*))successBlock
                                failured:(void (^)(NSError *))failuredBlock{
    NSString *requestURL = [kURLSyncPushStateToServer stringByAppendingPathComponent:self.roomID];
    NSLog(@"SyncPushStateToServerURL = %@",requestURL);
    [self requestURL:requestURL success:successBlock failured:failuredBlock];
}
-(void)syncPushStartStateToServer{
    NSString *requestURL = [kURLSyncPushStateToServer stringByAppendingPathComponent:self.roomID];
    NSLog(@"SyncPushStateToServerURL = %@",requestURL);
    [self requestURL:requestURL success:^(NSDictionary *dic) {
        if(dic != nil){
            if([[dic objectForKey:@"err"] isEqualToString:@"0"]){
                [self.delegate DidSyncStartStateToServerSuccess];
            }else{
                NSString *errorInfo = (NSString *)[dic objectForKey:@"msg"];
                NSString *errCode = (NSString *)[dic objectForKey:@"err"];
                [self.delegate HTTPRequestErrorOccured:errorInfo andErrorCode:errCode];
            }
        }
    } failured:^(NSError *error) {
        if(error){
            [self.delegate HTTPRequestErrorOccured:@"AFNetworking error" andErrorCode:[NSString stringWithFormat:@"%ld",(long)error.code]];
        }
    }];
}

-(void)syncPushStopStateToServerSuccess:(void (^)(NSDictionary *))successBlock
                               failured:(void (^)(NSError *))failuredBlock{
    NSString *requestURL = [kURLSyncPushStopToServer stringByAppendingPathComponent:self.roomID];
    NSLog(@"kURLSyncPushStopToServer = %@",requestURL);
    [self requestURL:requestURL success:successBlock failured:failuredBlock];
}
-(void)syncPushStopStateToServer{
    NSString *requestURL = [kURLSyncPushStopToServer stringByAppendingPathComponent:self.roomID];
    NSLog(@"kURLSyncPushStopToServer = %@",requestURL);
    [self requestURL:requestURL success:^(NSDictionary *dic) {
        if(dic != nil){
            if([[dic objectForKey:@"err"] isEqualToString:@"0"]){
                [self.delegate DidSyncStopStareToServerSuccess];
            }else{
                NSString *errorInfo = (NSString *)[dic objectForKey:@"msg"];
                NSString *errCode = (NSString *)[dic objectForKey:@"err"];
                [self.delegate HTTPRequestErrorOccured:errorInfo andErrorCode:errCode];
            }
        }
    } failured:^(NSError *error) {
        if(error){
            [self.delegate HTTPRequestErrorOccured:@"AFNetworking error" andErrorCode:[NSString stringWithFormat:@"%ld",(long)error.code]];
        }
    }];
}

-(void)fetchPullRTMPAddrSuccess:(void (^)(NSDictionary *))successBlock
                       Failured:(void (^)(NSError *))failuredBlock{
    NSString *requestURL = [kURLGetPullRTMPAddr stringByAppendingPathComponent:self.roomID];
    NSLog(@"kURLGetPullRTMPAddr = %@",requestURL);
    [self requestURL:requestURL success:successBlock failured:failuredBlock];
}

-(void)fetchPullRTMPAddr{
    NSString *requestURL = [kURLGetPullRTMPAddr stringByAppendingPathComponent:self.roomID];
    NSLog(@"kURLGetPullRTMPAddr = %@",requestURL);
    [self requestURL:requestURL success:^(NSDictionary *dic) {
        if(dic != nil){
            NSLog(@"jimmy_dic = %@",dic);
            if([[dic objectForKey:@"err"] isEqualToString:@"0"]){
                NSDictionary *data = (NSDictionary *)[dic objectForKey:@"data"];
                NSString *url = (NSString *)[data objectForKey:@"rtmpUrl"];
                [self.delegate DidFetchPullAddressSuccess:url];
            }else{
                NSString *errorInfo = (NSString *)[dic objectForKey:@"msg"];
                NSString *errCode = (NSString *)[dic objectForKey:@"err"];
                [self.delegate HTTPRequestErrorOccured:errorInfo andErrorCode:errCode];
            }
        }
    } failured:^(NSError *error) {
        if(error){
            [self.delegate HTTPRequestErrorOccured:@"AFNetworking error" andErrorCode:[NSString stringWithFormat:@"%ld",(long)error.code]];
        }
    }];
}

-(void)fetchStreamStatusSuccess:(void (^)(NSDictionary *))successBlock
                       failured:(void (^)(NSError *))failuredBlock
{
    NSString *requestURL = [kURLGetStreamStatus stringByAppendingPathComponent:self.roomID];
    NSLog(@"kURLGetStreamStatus = %@",requestURL);
    NSString *requestURL1 = [[kURLGetStreamStatus stringByAppendingString:@"/"] stringByAppendingString:self.roomID];
     NSLog(@"kURLGetStreamStatus1 = %@",requestURL1);
    [self requestURL:requestURL1 success:successBlock failured:failuredBlock];
}

-(void)fetchStreamStatus{
    NSString *requestURL = [kURLGetStreamStatus stringByAppendingPathComponent:self.roomID];
    NSLog(@"kURLGetStreamStatus = %@",requestURL);
    [self requestURL:requestURL success:^(NSDictionary *dic) {
        if(dic != nil){
            if([[dic objectForKey:@"err"] isEqualToString:@"0"]){
                NSDictionary *data = (NSDictionary *)[dic objectForKey:@"data"];
                NSString *liveState = (NSString *)[data objectForKey:@"liveStatus"];
                NSString *streamState = (NSString *)[data objectForKey:@"streamStatus"];
                [self.delegate DidFetchLiveStatusSuccess:liveState andStreamStatusSuccess:streamState];
            }else{
                NSString *errorInfo = (NSString *)[dic objectForKey:@"msg"];
                NSString *errCode = (NSString *)[dic objectForKey:@"err"];
                [self.delegate HTTPRequestErrorOccured:errorInfo andErrorCode:errCode];
            }
        }
    } failured:^(NSError *error) {
        if(error){
            [self.delegate HTTPRequestErrorOccured:@"AFNetworking error" andErrorCode:[NSString stringWithFormat:@"%ld",(long)error.code]];
        }
    }];
}

#pragma mark --custom method--
-(void)requestURL:(NSString *)url
          success:(void (^)(NSDictionary*))successBlock
         failured:(void (^)(NSError *))failuredBlock
{
    NSString *aURL =  [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self.httpManager GET:aURL parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = (NSDictionary *)responseObject;
        successBlock(dic);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failuredBlock(error);
    }];
}

+(void)startMonitor{
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_NetworkStateChanged object:[NSNumber numberWithInteger:status]];
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

+(void)stopMonitor{
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

#pragma mark --Getter,Setter--
-(AFNetworkReachabilityStatus)currentNetworkStatus{
    return [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
}

@end
