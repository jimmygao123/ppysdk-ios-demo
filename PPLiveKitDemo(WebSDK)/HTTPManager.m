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

#define kURLGetPushRTMPAddr @"http://115.231.44.26:8081/live/create"
#define kURLGetPullRTMPAddr @"http://115.231.44.26:8081/live/watch"
#define kURLSyncPushStateToServer @"http://115.231.44.26:8081/live/start"
#define kURLSyncPushStopToServer @"http://115.231.44.26:8081/live/stop"
#define kURLGetStreamStatus @"http://115.231.44.26:8081/live/status"
#define kURLGetDetailInfo @"http://115.231.44.26:8081/live/detail"
#define kURLGetLiveList @"http://115.231.44.26:8081/live/living/list"
#define kURLGetVODList @"http://115.231.44.26:8081/live/vod/list"
#define kURLGetPlayURL @"http://115.231.44.26:8081/live/playstr/"

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
        self.httpManager.requestSerializer.timeoutInterval = 5;
        
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
