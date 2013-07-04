//
//  Collections+subscripts.h
//  VSCore
//
//  Created by Kamil Rzeźnicki on 27.06.2013.
//  Copyright (c) 2013 Bartłomiej Żarnowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 60000

@interface NSDictionary(subscripts)
- (id)objectForKeyedSubscript:(id)key;
@end

@interface NSMutableDictionary(subscripts)
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;
@end

@interface NSArray(subscripts)
- (id)objectAtIndexedSubscript:(NSUInteger)idx;
@end

@interface NSMutableArray(subscripts)
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;

@end
#endif
