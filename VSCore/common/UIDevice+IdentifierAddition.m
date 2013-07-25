//
//  UIDevice(Identifier).m
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski on 12/17/10.
//

#import "UIDevice+IdentifierAddition.h"
#import "NSData_Base64.h"

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <Security/SecRandom.h>

@implementation UIDevice (IdentifierAddition)
//32 bajty długości

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

-(NSString*)generateUID{
    uint8_t pool[32];
    SecRandomCopyBytes(kSecRandomDefault, sizeof(char) * 32, &pool[0]);
    CFAbsoluteTime timestamp = CFAbsoluteTimeGetCurrent();
    memcpy(&pool[4], &timestamp, sizeof(timestamp));
    NSString* result = [[NSData dataWithBytes:&pool[0] length:32] base64EncodedString];
    if ([result length] > 32){
        result = [result substringToIndex:32];
    }
    return result;
}

- (NSString*) uniqueDeviceIdentifier{
    NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString* key = [NSString stringWithFormat:@"uniqueDeviceIdentifier_%@", appID];
    
    NSDictionary* d = [UIDevice load:key];
    NSString* uid;
    if ([d count] == 0){
        uid = [self generateUID];
        [UIDevice save:key data:@{@"uid" : uid}];
    } else {
        uid = d[@"uid"];
    }
    return uid;
}

- (NSString*) uniqueGlobalDeviceIdentifier{

    NSString* key = @"uniqueGlobalDeviceIdentifier";
    NSDictionary* d = [UIDevice load:key];
    NSString* uid;
    if ([d count] == 0){
        uid = [self generateUID];
        [UIDevice save:key data:@{@"uid" : uid}];
    } else {
        uid = d[@"uid"];
    }
    return uid;
}

#pragma mark KeyChain helpers

//taken from  http://stackoverflow.com/questions/5247912/saving-email-password-to-keychain-in-ios

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (id)kSecClassGenericPassword, (id)kSecClass,
            service, (id)kSecAttrService,
            service, (id)kSecAttrAccount,
            (id)kSecAttrAccessibleAfterFirstUnlock, (id)kSecAttrAccessible,
            nil];
}

+ (void)save:(NSString *)service data:(id)data {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((CFDictionaryRef)keychainQuery);
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(id)kSecValueData];
    SecItemAdd((CFDictionaryRef)keychainQuery, NULL);
}

+ (id)load:(NSString *)service {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)keyData];
        }
        @catch (NSException *e) {
            DDLogError(@"Unarchive of %@ failed: %@", service, e);
        }
        @finally {}
    }
    if (keyData) CFRelease(keyData);
    return ret;
}
@end
