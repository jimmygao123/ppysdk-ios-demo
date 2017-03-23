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
#import "PPYPlayModel.h"

NSString * const kNotification_NetworkStateChanged = @"kNetworkStateChanged";

#ifdef TEST
    #define kBaseURL @"http://10.200.20.139:8080"
#else
    #define kBaseURL @"http://115.231.44.26:8081"
#endif

#define kURLGetPushRTMPAddr [NSString stringWithFormat:@"%@/live/create",kBaseURL]
#define kURLGetPullRTMPAddr [NSString stringWithFormat:@"%@/live/watch",kBaseURL]
#define kURLSyncPushStateToServer [NSString stringWithFormat:@"%@/live/start",kBaseURL]
#define kURLSyncPushStopToServer [NSString stringWithFormat:@"%@/live/stop",kBaseURL]
#define kURLGetStreamStatus [NSString stringWithFormat:@"%@/live/status",kBaseURL]
#define kURLGetDetailInfo [NSString stringWithFormat:@"%@/live/detail",kBaseURL]
#define kURLGetLiveList [NSString stringWithFormat:@"%@/live/living/list",kBaseURL]
#define kURLGetVODList [NSString stringWithFormat:@"%@/live/vod/list",kBaseURL]
#define kURLGetPlayURL [NSString stringWithFormat:@"%@/live/playstr",kBaseURL]

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
        self.httpManager.requestSerializer.timeoutInterval = 30;
        
        AFJSONResponseSerializer *jsonSerizlizer = [AFJSONResponseSerializer serializer];
        jsonSerizlizer.removesKeysWithNullValues = YES;
        self.httpManager.responseSerializer = jsonSerizlizer;
        self.httpManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
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

-(void)syncPushStopStateToServerSuccess:(void (^)(NSDictionary *))successBlock
                               failured:(void (^)(NSError *))failuredBlock{
    NSString *requestURL = [kURLSyncPushStopToServer stringByAppendingPathComponent:self.roomID];
    NSLog(@"kURLSyncPushStopToServer = %@",requestURL);
    [self requestURL:requestURL success:successBlock failured:failuredBlock];
}

-(void)fetchPlayURL:(void (^)(NSDictionary *))successBlock
                       Failured:(void (^)(NSError *))failuredBlock{
    NSString *requestURL = [kURLGetPullRTMPAddr stringByAppendingPathComponent:self.roomID];
    NSLog(@"kURLGetPullRTMPAddr = %@",requestURL);
    [self requestURL:requestURL success:successBlock failured:failuredBlock];
}


-(void)fetchStreamStatusSuccess:(void (^)(NSDictionary *))successBlock
                       failured:(void (^)(NSError *))failuredBlock
{
    NSString *requestURL = [kURLGetStreamStatus stringByAppendingPathComponent:self.roomID];
    NSLog(@"kURLGetStreamStatus = %@",requestURL);
    [self requestURL:requestURL success:successBlock failured:failuredBlock];
}

-(void)fetchLiveListWithPageNum:(int)num
                        Success:(void (^)(NSDictionary *))successBlock
                       Failured:(void (^)(NSError *))failuredBlock{
    NSString *requestURL = [NSString stringWithFormat:@"%@/?page_size=10&page_num=%d",kURLGetLiveList,num];
    NSLog(@"kURLGetLiveList = %@",requestURL);
    [self requestURL:requestURL success:successBlock failured:failuredBlock];
}

-(void)fetchVODListWithPageNum:(int)num
                        Success:(void (^)(NSDictionary *))successBlock
                       Failured:(void (^)(NSError *))failuredBlock{
    NSString *requestURL = [NSString stringWithFormat:@"%@/?page_size=10&page_num=%d",kURLGetVODList,num];
    NSLog(@"kURLGetLiveList = %@",requestURL);
    [self requestURL:requestURL success:successBlock failured:failuredBlock];
}

-(void)fetchDetailInfoWithChannelWebID:(NSString *)channelID
                               Success:(void (^)(NSDictionary *))successBlock
                              Failured:(void (^)(NSError *))failuredBlock{
    NSString *requestURL = [NSString stringWithFormat:@"%@/%@",kURLGetDetailInfo,channelID];
    NSLog(@"kURLGetDetailInfo = %@",requestURL);
    [self requestURL:requestURL success:successBlock failured:failuredBlock];
}

- (void)fetchPlayURLWithChannelWebID:(NSString *)channelID
                             Success:(void (^)(PPYPlayModel *))successBlock
                            Failured:(void (^)(NSError *))failuredBlock {
    NSString *requestURL = [NSString stringWithFormat:@"%@/%@",kURLGetPlayURL,channelID];
    NSLog(@"kURLGetPlayURL = %@",requestURL);
    [self requestURL:requestURL success:^(NSDictionary *responseObject) {
        NSDictionary *data = responseObject[@"data"];
        PPYPlayModel *model = [PPYPlayModel yy_modelWithJSON:data];
        successBlock(model);
    } failured:failuredBlock];
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


static BOOL isMonitoringNetwork = NO;
+(void)startMonitor{
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_NetworkStateChanged object:[NSNumber numberWithInteger:status]];
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    isMonitoringNetwork = YES;
}

+(void)stopMonitor{
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
    isMonitoringNetwork = NO;
}

#pragma mark --Getter,Setter--
-(AFNetworkReachabilityStatus)currentNetworkStatus{
    if(!isMonitoringNetwork){
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    }
    return [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
}


-(NSData *)downloadWebImageWithURL:(NSString *)url{
    NSError *error=nil;
    NSURLRequest *request=[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    NSData *imgData=[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if(imgData)
    {
        return imgData;
    }else{
        return nil;
    }
}
@end
