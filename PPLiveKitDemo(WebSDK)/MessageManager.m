//
//  MessageManager.m
//  PPLiveKitDemo(WebSDK)
//
//  Created by Jimmy on 16/9/22.
//  Copyright © 2016年 高国栋. All rights reserved.
//

#import "MessageManager.h"

@implementation MessageManager

+(instancetype)shareInstance{
    static MessageManager *__instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __instance = [[[self class] alloc]init];
    });
    return __instance;
}

-(void)processMessageFromWebSKD:(int)code andInfo:(NSString *)message{
    
}

-(void)processMessageCocoa:(int)code andInfo:(NSString *)message{
    
}
@end
