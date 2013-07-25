//
//  NSMutableDictionary+Extended.m
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski [Toster] on 21.01.2013.
//

#import "NSMutableDictionary+Extended.h"

@implementation NSMutableDictionary (Extended)

-(void)addNonExistingsKeysFrom:(NSMutableDictionary*)dict{
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([self objectForKey:key] == nil){
            [self setObject:obj forKey:key];
        }
        *stop = NO;
    }];
}

@end
