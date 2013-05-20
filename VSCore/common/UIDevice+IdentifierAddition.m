//
//  UIDevice(Identifier).m
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski on 12/17/10.
//

#import "UIDevice+IdentifierAddition.h"
#import <VSCore/NSString+MD5Addition.h>

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

@implementation UIDevice (IdentifierAddition)

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Methods

- (NSString *) macAddress{
    
    int mib[6] = {CTL_NET, AF_ROUTE, 0, AF_LINK, NET_RT_IFLIST, if_nametoindex("en0")};
    if (mib[5] == 0) {
        return nil;
    }
    
    size_t len;
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        return nil;
    }
    
    char *buf = malloc(len);
    if (buf == NULL) {
        return nil;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        free(buf);
        return nil;
    }
    
    struct if_msghdr* ifm = (struct if_msghdr *)buf;
    struct sockaddr_dl* sdl = (struct sockaddr_dl *)(ifm + 1);
    unsigned char* ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", 
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);

    return outstring;
}

- (NSString*) uniqueDeviceIdentifier{
    NSString* s = [NSString stringWithFormat:@"%@%@",[[UIDevice currentDevice] macAddress],[[NSBundle mainBundle] bundleIdentifier]];
    return [s stringFromMD5];
}

- (NSString*) uniqueGlobalDeviceIdentifier{
    return [[[UIDevice currentDevice] macAddress] stringFromMD5];;
}

@end
