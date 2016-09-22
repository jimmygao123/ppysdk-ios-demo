//
//  MessageManager.h
//  PPLiveKitDemo(WebSDK)
//
//  Created by Jimmy on 16/9/22.
//  Copyright © 2016年 高国栋. All rights reserved.
//
//  This file collected message for UI processing and log recording;

#import <Foundation/Foundation.h>


typedef NS_ENUM(int, PPYMessageType){
    PPYMessageType_Error,
    PPYMessageType_Info,
    PPYMessageType_Warning
};

typedef NS_ENUM(int, PPYMessageDomain){
    PPYMessageDomain_Cocoa,
    PPYMessageDomain_SDK,
    PPYMessageDomain_WebSDK
};

@interface MessageManager : NSObject

+(instancetype)shareInstance;

//-(void)processErrorMessage:(int)errorCode andInfo:(NSString *)errorMessage;
-(void)processMessageFromWebSKD:(int)code andInfo:(NSString *)message;
-(void)processMessageCocoa:(int)code andInfo:(NSString *)message;
@end
