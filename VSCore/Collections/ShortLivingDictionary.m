//
//  ShortLivingDictionary.m
//  TheTostersCore
//
//  Created by Bartłomiej Żarnowski on 03.10.2012.
//  Copyright (c) 2012 Bartłomiej Żarnowski. All rights reserved.
//

#import "ShortLivingDictionary.h"
#import "CommonDefines.h"
#import "FileHelper.h"

@implementation ShortLivingDictionary
@synthesize storageFile, timeToLive;

-(id)initWithStorage:(NSString*)filename andInterval:(NSTimeInterval)aTimeToLive{
    self = [super init];
    if (self != nil){
        self.timeToLive = aTimeToLive;
        self.storageFile = filename;
    }
    return self;
}

+(ShortLivingDictionary*)dictionaryWithStorage:(NSString*)filename andInterval:(NSTimeInterval)timeToLive{
    ShortLivingDictionary* result = [[ShortLivingDictionary alloc] initWithStorage:filename
                                                                       andInterval:timeToLive];
    return [result autorelease];
}

-(void)dealloc{
    if (store != nil){
        [self presistAndDestroy];
    }
    self.storageFile = nil;
    [super dealloc];
}

-(void)presistAndDestroy{
//    NSAssert(store != nil,@"uppss, store shouldn't be nil! Looks like logic error");
    if (store != nil){
        NSString* file = [FileHelper libraryPath:@"storage"];
        file = [file stringByAppendingString:self.storageFile];
        [store writeToFile:file atomically:YES];
        releaseAndNil(store);
        DDLogVerbose(@"Purging ShortLivingDictionaty to file %@", file);
    }
}

-(NSMutableDictionary*)store{
    if (store == nil){
        NSString* file = [FileHelper libraryPath:@"storage"];
        file = [file stringByAppendingString:self.storageFile];
        store = [[NSMutableDictionary alloc] initWithContentsOfFile:file];
        if (store == nil){
            store = [[NSMutableDictionary alloc] init];
        }
        DDLogVerbose(@"Restoring ShortLivingDictionaty from file %@", file);
    }
    //make object live longer
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(presistAndDestroy) withObject:nil afterDelay:self.timeToLive];
    
    return store;
}

- (void)removeObjectForKey:(id)aKey{
    [[self store] removeObjectForKey:aKey];
}

- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey{
    [[self store] setObject:anObject forKey:aKey];
}

- (void)removeAllObjects{
    [[self store] removeAllObjects];
}

- (NSUInteger)count{
    return [[self store] count];
}

- (id)objectForKey:(id)aKey{
    return [[self store] objectForKey:aKey];
}

@end
