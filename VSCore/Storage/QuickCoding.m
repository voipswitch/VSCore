//
//  QuickCoding.m
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Marek Kotewicz on 8/10/13.
//

#import "QuickCoding.h"
#import "ReflectionHelper.h"

#define QUICK_CODING_HASH   @"h4"

@implementation QuickCoding

+ (void)quickEncode:(NSObject<NSCoding>*)object withEncoder:(NSCoder *)encoder{
    NSArray *codingKeys = [ReflectionHelper fieldsList:[object class]];
    NSUInteger hash = [[codingKeys componentsJoinedByString:@""] hash];
    [encoder encodeObject:@(hash) forKey:QUICK_CODING_HASH];
    
    [codingKeys enumerateObjectsUsingBlock:^(NSString *key, __unused NSUInteger idx, __unused BOOL *stop) {
        id val = [object valueForKey:key];
        if ([val conformsToProtocol:@protocol(NSCoding)]){
            [encoder encodeObject:val forKey:key];
        }
    }];
}

+ (void)quickDecode:(NSObject<NSCoding>*)object withDecoder:(NSCoder *)decoder{
    NSArray *codingKeys = [ReflectionHelper fieldsList:[object class]];
    NSUInteger hash = [[codingKeys componentsJoinedByString:@""] hash];
    NSUInteger decodedHash = [[decoder decodeObjectForKey:QUICK_CODING_HASH] unsignedIntegerValue];
    BOOL equalHash = hash == decodedHash;
    
    [codingKeys enumerateObjectsUsingBlock:^(NSString *key, __unused NSUInteger idx, __unused BOOL *stop) {
        id val = [decoder decodeObjectForKey:key];
        if (equalHash || val){
            [object setValue:val forKey:key];
        }
    }];
}

@end
