//
//  YSJNetHelper.h
//  ysjLib
//
//  Created by ysj on 16/4/13.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKitDefines.h>

UIKIT_EXTERN NSString *const NSNetAllData;
UIKIT_EXTERN NSString *const NSNetAllDataReceived;
UIKIT_EXTERN NSString *const NSNetAllDataSend;
UIKIT_EXTERN NSString *const NSNetWifiData;
UIKIT_EXTERN NSString *const NSNetWifiDataReceived;
UIKIT_EXTERN NSString *const NSNetWifiDataSend;
UIKIT_EXTERN NSString *const NSNetWWanData;
UIKIT_EXTERN NSString *const NSNetWWanDataReceived;
UIKIT_EXTERN NSString *const NSNetWWanDataSend;

typedef NS_ENUM(NSInteger, NetMode){
    NetModeWifi = 0,
    NetModeWWan,
    NetModeUnknow,
};

@interface YSJNetHelper : NSObject



+ (NetMode)checkNetMode;
+ (NSDictionary *)checkNetData;

@end
