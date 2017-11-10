//
//  JL_DeviceInfoCenter.m
//  JL_AlbumHelper
//
//  Created by JasonLee on 2017/11/10.
//  Copyright © 2017年 JasonLee. All rights reserved.
//

#import "JL_DeviceInfoCenter.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

@implementation JL_DeviceInfoCenter

+ (NSString *)deviceIPAddress {
    
    NSString       *address    = nil;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr  = NULL;
    
    if (getifaddrs(&interfaces) == 0) {
        
        temp_addr = interfaces;
        
        while (temp_addr != NULL) {
            
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    return address;
}

@end
