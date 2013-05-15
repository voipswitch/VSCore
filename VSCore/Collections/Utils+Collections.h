//
//  Utils+Collections.h
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski [Toster] on 03.04.2013.
//

#import <Foundation/Foundation.h>
#import "Utils.h"

@interface Utils(Collections)

/**
 * Makes deep mutable copy of any NSDictionary/NSArray/NSSet. It also travers all children
 * and make any found collection mutable.
 * @param collection which should be copied and make mutable
 * @return deep copied mutable version of collection
 */
+(id)deepMutableCopy:(id)collection;

/**
 * Makes deep copy of any NSDictionary/NSArray/NSSet.
 * @param collection which should be deep copied
 * @return deep copied collection
 */
+(id)deepCopy:(id)collection;

/**
 * Compares two collections, if any collection has nested other collections, this method compares
 * also them. Each element stored in both collections is compared using isEqual. Allowed collections
 * are: NSDictionary, NSArray. At this moment NSSet is NOT supported.
 * @param collection1 first collection to compare
 * @param collection2 second collection to compare
 * @return YES if all elements match, NO otherwise
 */
+(BOOL)deepEqual:(id)collection1 with:(id)collection2;
@end

//taken from http://stackoverflow.com/a/5453600
@interface NSArray (SPDeepCopy)

- (NSArray*) deepCopy;
- (NSMutableArray*) mutableDeepCopy;

@end

@interface NSDictionary (SPDeepCopy)

- (NSDictionary*) deepCopy;
- (NSMutableDictionary*) mutableDeepCopy;

@end

//build based on above pattern

@interface NSSet (SPDeepCopy)

- (NSSet*) deepCopy;
- (NSMutableSet*) mutableDeepCopy;

@end
