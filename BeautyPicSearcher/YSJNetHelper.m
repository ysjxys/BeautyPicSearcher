//
//  YSJNetHelper.m
//  ysjLib
//
//  Created by ysj on 16/4/13.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import "YSJNetHelper.h"
#import "Reachability.h"
#include <ifaddrs.h>
#include <sys/socket.h>
#include <net/if.h>

NSString *const NSNetAllData = @"NSNetAllData";
NSString *const NSNetAllDataReceived = @"NSNetAllDataReceived";
NSString *const NSNetAllDataSend = @"NSNetAllDataSend";
NSString *const NSNetWifiData = @"NSNetWifiData";
NSString *const NSNetWifiDataReceived = @"NSNetWifiDataReceived";
NSString *const NSNetWifiDataSend = @"NSNetWifiDataSend";
NSString *const NSNetWWanData = @"NSNetWWanData";
NSString *const NSNetWWanDataReceived = @"NSNetWWanDataReceived";
NSString *const NSNetWWanDataSend = @"NSNetWWanDataSend";

@interface YSJNetHelper ()

@end

@implementation YSJNetHelper

+ (NetMode)checkNetMode{
    Reachability *reachability = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    NetMode netmode;
    switch ([reachability currentReachabilityStatus]) {
        case NotReachable:
            netmode =  NetModeUnknow;
            break;
        case ReachableViaWiFi:
            netmode =  NetModeWifi;
            break;
        case ReachableViaWWAN:
            netmode =  NetModeWWan;
            break;
        default:
            break;
    }
    return netmode;
}

+ (NSDictionary *)checkNetData{
    struct ifaddrs *ifa_list = 0, *ifa;
    if (getifaddrs(&ifa_list) == -1){
        return nil;
    }
    uint32_t iBytes     = 0;
    uint32_t oBytes     = 0;
    uint32_t allFlow    = 0;
    uint32_t wifiIBytes = 0;
    uint32_t wifiOBytes = 0;
    uint32_t wifiFlow   = 0;
    uint32_t wwanIBytes = 0;
    uint32_t wwanOBytes = 0;
    uint32_t wwanFlow   = 0;
    //    struct timeval time ;
    for (ifa = ifa_list; ifa; ifa = ifa->ifa_next){
        if (AF_LINK != ifa->ifa_addr->sa_family)
            continue;
        if (!(ifa->ifa_flags & IFF_UP) && !(ifa->ifa_flags & IFF_RUNNING))
            continue;
        if (ifa->ifa_data == 0)
            continue;
        // Not a loopback device.
        // network flow
        if (strncmp(ifa->ifa_name, "lo", 2)){
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            iBytes += if_data->ifi_ibytes;
            oBytes += if_data->ifi_obytes;
            allFlow = iBytes + oBytes;
        }
        if (!strcmp(ifa->ifa_name, "en0")){
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            wifiIBytes += if_data->ifi_ibytes;
            wifiOBytes += if_data->ifi_obytes;
            wifiFlow    = wifiIBytes + wifiOBytes;
        }
        if (!strcmp(ifa->ifa_name, "pdp_ip0")){
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            wwanIBytes += if_data->ifi_ibytes;
            wwanOBytes += if_data->ifi_obytes;
            wwanFlow    = wwanIBytes + wwanOBytes;
        }
    }
    
    freeifaddrs(ifa_list);
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:[self bytesToAvaiUnit:allFlow] forKey:NSNetAllData];
    [dic setObject:[self bytesToAvaiUnit:iBytes] forKey:NSNetAllDataReceived];
    [dic setObject:[self bytesToAvaiUnit:oBytes] forKey:NSNetAllDataSend];
    [dic setObject:[self bytesToAvaiUnit:wifiFlow] forKey:NSNetWifiData];
    [dic setObject:[self bytesToAvaiUnit:wifiIBytes] forKey:NSNetWifiDataReceived];
    [dic setObject:[self bytesToAvaiUnit:wifiOBytes] forKey:NSNetWifiDataSend];
    [dic setObject:[self bytesToAvaiUnit:wwanFlow] forKey:NSNetWWanData];
    [dic setObject:[self bytesToAvaiUnit:wwanIBytes] forKey:NSNetWWanDataReceived];
    [dic setObject:[self bytesToAvaiUnit:wwanOBytes] forKey:NSNetWWanDataSend];
    return dic;
}

+ (NSString *)bytesToAvaiUnit:(int)bytes
{
    if(bytes < 1024){
        return [NSString stringWithFormat:@"%dB", bytes];// B
    }else if(bytes >= 1024 && bytes < 1024 * 1024){
        return [NSString stringWithFormat:@"%.1fKB", (double)bytes/1024];//KB
    }else if(bytes >= 1024 * 1024 && bytes < 1024 * 1024 * 1024){
        return [NSString stringWithFormat:@"%.2fMB", (double)bytes/(1024* 1024)];//MB
    }else{
        return [NSString stringWithFormat:@"%.3fGB", (double)bytes / (1024 * 1024 * 1024)];//GB
    }
}
@end
