//
//  PlayListHelper.m
//  PPLiveKitDemo(WebSDK)
//
//  Created by admin on 2016/10/13.
//  Copyright © 2016年 高国栋. All rights reserved.
//

#import "PlayListHelper.h"
#import "HTTPManager.h"

@implementation PlayListHelper


-(void)fetchVODListWithPageNum:(int)num{
    [[HTTPManager shareInstance] fetchVODListWithPageNum:num Success:^(NSDictionary *dic) {
        NSMutableArray *newList = [[NSMutableArray alloc]init];
        
        NSString *errCode = (NSString *)[dic objectForKey:@"err"];
        NSString *errInfo = (NSString *) [dic objectForKey:@"msg"];
        NSArray *VODList = (NSArray *)[dic objectForKey:@"data"];
        NSString *totalNum = (NSString *)[dic objectForKey:@"totalnum"];
        
        if([errCode isEqualToString:@"0"]){
            if(([dic objectForKey:@"totalnum"] != [NSNull null]) && [dic objectForKey:@"data"] != [NSNull null]){
                if(VODList.count > 0 && totalNum.integerValue > 0){
                    for(NSDictionary *VOD in VODList){
                        if([VOD objectForKey:kRoomName] == [NSNull null]) continue;
                        if([VOD objectForKey:kDuration] == [NSNull null]) continue;
                        NSString *duration = [VOD objectForKey:kDuration];
                        if(duration.integerValue < 10) continue;
                        
                        NSString *roomID = (NSString *)[VOD objectForKey:kRoomName];
                        NSString *imageURL = (NSString *)[VOD objectForKey:kScreenShot];
                        NSString *liveState = (NSString *)[VOD objectForKey:kLiveState];
                        NSString *webChannelID = (NSString *)[VOD objectForKey:kChannelWebID];
                    
                        NSDictionary *filitedVOD = [[NSDictionary alloc]initWithObjectsAndKeys:roomID,kRoomName,imageURL,kScreenShot,liveState,kLiveState,webChannelID,kChannelWebID, nil];
                        
                        [newList addObject:filitedVOD];
                    }
                }
            }
            [self.delegate didFetchVODListSuccess:newList];
        }else{
            [self.delegate didFetchVODListFailued:PraseError Code:errCode.integerValue Info:errInfo];
        }
        
    } Failured:^(NSError *err) {
        [self.delegate didFetchVODListFailued:AFNetworking_Error Code:err.code Info:err.debugDescription];
    }];
}

-(void)fetchLiveListWithPageNum:(int)num{
  
    [[HTTPManager shareInstance] fetchLiveListWithPageNum:num Success:^(NSDictionary *dic) {
        NSMutableArray *newList = [[NSMutableArray alloc]init];
        
        NSString *errCode = (NSString *)[dic objectForKey:@"err"];
        NSString *errInfo = (NSString *) [dic objectForKey:@"msg"];
        NSArray *liveList = (NSArray *)[dic objectForKey:@"data"];
        NSString *totalNum = (NSString *)[dic objectForKey:@"totalnum"];
    
        if([errCode isEqualToString:@"0"]){
            
            if((liveList != nil) && (totalNum != nil)){
                if([dic objectForKey:@"totalnum"] != [NSNull null] &&  [dic objectForKey:@"data"] != [NSNull null]){
                    for(NSDictionary *live in liveList){
                        if([live objectForKey:@"room_name"] == [NSNull null]){
                            continue;
                        }
                        
                        NSString *roomID = [live objectForKey:kRoomName];
                        NSString *image = [live objectForKey:kScreenShot];
                        NSString *liveState = [live objectForKey:kLiveState];
                        NSDictionary *filitedLive = [[NSDictionary alloc]initWithObjectsAndKeys:roomID,kRoomName,image,kScreenShot,liveState,kLiveState, nil];
                        
                        [newList addObject:filitedLive];
                    }
                }
            }
            [self.delegate didFetchLiveListSuccess:newList];
        }else{
            [self.delegate didFetchLiveListFailured:PraseError Code:errCode.integerValue Info:errInfo];
        }
    } Failured:^(NSError *err) {
        
        [self.delegate didFetchLiveListFailured:AFNetworking_Error Code:err.code Info:err.debugDescription];
    }];
    
}

-(void)downLoadWebImage:(NSString *)url onQueueAsync:(dispatch_queue_t)queue completionHandler:(void(^)(NSData *data))handle{
    
    dispatch_async(queue, ^{
        NSData *imageData = [[HTTPManager shareInstance] downloadWebImageWithURL:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            handle(imageData);
        });
    });
}


-(void)startPlayWithType:(PlayerType)playerType withNeededInfo:(NSDictionary *)dic{
    
}

-(NSString *)fetchVodURLWithChannelWebID:(NSString *)webID{
    return [NSString stringWithFormat:@"http://player.pptvyun.com/svc/m3u8player/pl/%@.m3u8",webID];
}
@end

