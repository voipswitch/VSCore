//
//  ShortLivingDictionary.h
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski on 03.10.2012.
//

#import <Foundation/Foundation.h>

/**
 * This is very simple implementation of dictionary which content isn't stored in memory all the time.
 * The idea is to have dictionary which may be accessed any time, however when no operations are done 
 * on it all data should be presist somewhere and memory should be released. Set timeToLive to control
 * how long data should be hold in memory, if no operations are performed on this object and specified
 * time passed, then all values are write to file (pointed by storageFile).
 */
@interface ShortLivingDictionary : NSObject{
    NSMutableDictionary* store;
}

@property (nonatomic, retain) NSString* storageFile;
@property (nonatomic, assign) NSTimeInterval timeToLive;

-(id)initWithStorage:(NSString*)filename andInterval:(NSTimeInterval)timeToLive;
+(ShortLivingDictionary*)dictionaryWithStorage:(NSString*)filename andInterval:(NSTimeInterval)timeToLive;

- (void)removeObjectForKey:(id)aKey;
- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey;
- (void)removeAllObjects;
- (NSUInteger)count;
- (id)objectForKey:(id)aKey;

@end
