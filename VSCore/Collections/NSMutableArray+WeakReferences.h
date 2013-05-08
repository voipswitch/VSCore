//
//  NSMutableArray(WeakReferences)
//  Vippie
//
//  Created by Bartłomiej Żarnowski on 11.07.2012
//  Copyright (c) VoipSwitch. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
* Introduces possibility to have collection which doesn't retain children. Taken from http://stackoverflow.com/a/4692229
*/
@interface NSMutableArray (WeakReferences)
+ (id)mutableArrayUsingWeakReferences;
+ (id)mutableArrayUsingWeakReferencesWithCapacity:(NSUInteger)capacity;

@end