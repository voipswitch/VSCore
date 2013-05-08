//
//  NSMutableArray(WeakReferences)
//  Vippie
//
//  Created by Bartłomiej Żarnowski on 11.07.2012
//  Copyright (c) VoipSwitch. All rights reserved.
//

#import "NSMutableArray+WeakReferences.h"


@implementation NSMutableArray (WeakReferences)
+ (id)mutableArrayUsingWeakReferences {
    return [NSMutableArray mutableArrayUsingWeakReferencesWithCapacity:0];
}

+ (id)mutableArrayUsingWeakReferencesWithCapacity:(NSUInteger)capacity {
    CFArrayCallBacks callbacks = {0, NULL, NULL, CFCopyDescription, CFEqual};
    // We create a weak reference array
    return (id)(CFArrayCreateMutable(0, capacity, &callbacks));
}
@end