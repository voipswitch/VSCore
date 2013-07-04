//
//  Collections+subscripts.m
//  VSCore
//
//  Created by Kamil Rzeźnicki on 27.06.2013.
//  Copyright (c) 2013 Bartłomiej Żarnowski. All rights reserved.
//

#import "Collections+subscripts.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 60000

@implementation NSDictionary(subscripts)
- (id)objectForKeyedSubscript:(id)key {
    return [self objectForKey:key];
}
@end

@implementation NSMutableDictionary(subscripts)
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key {
   [self setObject:obj forKey:key];
}
@end

@implementation NSArray(subscripts)
- (id)objectAtIndexedSubscript:(NSUInteger)idx {
    return [self objectAtIndex:idx];
}
@end

@implementation NSMutableArray(subscripts)
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx {
    [self replaceObjectAtIndex:idx withObject:obj];
}
@end

#endif