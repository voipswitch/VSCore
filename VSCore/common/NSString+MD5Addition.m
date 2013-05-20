//
//  NSString+MD5Addition.m
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski on 20.05.2013.
//

#import "NSString+MD5Addition.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString(MD5Addition)

- (NSString *) stringFromMD5{
    
    if ([self length] == 0){
        return nil;
    }
    
    const char *cStr = [self UTF8String];
    NSInteger len = [self lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, len, outputBuffer);
    
    char buff[CC_MD5_DIGEST_LENGTH * 2 + 1];
    
    char* pBuf = &buff[0];
    for(NSInteger t = 0; t < CC_MD5_DIGEST_LENGTH; t++){
        pBuf += sprintf(pBuf, "%02x",outputBuffer[t]);
    }

    return [NSString stringWithUTF8String:&buff[0]];
}

@end
