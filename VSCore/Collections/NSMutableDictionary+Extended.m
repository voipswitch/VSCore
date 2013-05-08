//
//  NSMutableDictionary+Extended.m
//  VSCore
//
//  Created by Bartłomiej Żarnowski [Toster] on 21.01.2013.
//  Copyright (c) 2013 Bartłomiej Żarnowski. All rights reserved.
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
