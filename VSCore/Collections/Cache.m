//
//  Cache.m
//  VSCore
//
//  Created by Bartłomiej Żarnowski on 27.07.2012.
//  Copyright (c) 2012 Bartłomiej Żarnowski. All rights reserved.
//

#import "Cache.h"
#import "CommonDefines.h"
#import <mach/mach_time.h>

#if defined(WANT_SANITY) && WANT_SANITY == 1
    #warning Sanity was enabled, this is heavy debug only flag. Probably valid only in unit tests!

    #if (DEBUG == 0 && defined(DEBUG)) || defined(DEBUG) == 0
        #error This flag shouldn't be used in release! Performance will be very poor
    #endif
#endif

#if defined(COLECT_CACHE_STATS) && (COLECT_CACHE_STATS == 1) && ((DEBUG == 0 && defined(DEBUG)) || defined(DEBUG) == 0)
    #warning Cache stats are enabled, however in release this is rather strange. Was it for purpose?
#endif

int getUptimeInMilliseconds()
{
    const int64_t kOneMillion = 1000 * 1000;
    static mach_timebase_info_data_t s_timebase_info = {0, 0};

    if (s_timebase_info.denom == 0) {
        (void) mach_timebase_info(&s_timebase_info);
    }

    // mach_absolute_time() returns billionth of seconds,
    // so divide by one million to get milliseconds
    return (int)((mach_absolute_time() * s_timebase_info.numer) / (kOneMillion * s_timebase_info.denom));
}

@interface CacheProxy : NSObject {
@public
    id         destObj;          //object which should be preserved in cache
    NSString*  key;              //access key for destObject, it's used in objects dictionary
    NSInteger  lastAccessTime;   //last access time in ms see getUptimeInMilliseconds
    NSInteger  hitCount;         //how many times this element was accessed
    NSUInteger inProxiesPos;     //current index in proxies array
}
@property (retain, nonatomic) id destObj;
@property (retain, nonatomic) NSString* key;
@end

@implementation CacheProxy
@synthesize destObj, key;

- (void)dealloc {
    self.destObj = nil;
    self.key = nil;

    [super dealloc];
}

-(NSString*)description{
    NSInteger tt = getUptimeInMilliseconds() - lastAccessTime;
    return [NSString stringWithFormat:@"[CacheProxy key:%@, destObj:%@, lastAccessTime:%d ms ago(raw:%d), hitCount:%d, inProxiesPos:%d]",
            key, destObj, tt, lastAccessTime, hitCount, inProxiesPos];
}

@end

@implementation Cache

@synthesize strategy;

- (void)applyStrategy {
    if (timer != nil){
        [timer invalidate]; timer = nil;
    }

    if (strategy.cleanupCycle > 0){
        timer = [NSTimer scheduledTimerWithTimeInterval:strategy.cleanupCycle
                                                 target:self
                                               selector:@selector(timerFired)
                                               userInfo:nil
                                                repeats:YES];
    }
    switch(strategy.cleanupOrder){
        case coRandom:
            [proxies removeAllObjects];
            break;

        case coLessAccessibleFirst:
            if ([proxies count] == 0){
                [proxies addObjectsFromArray:[objects allValues]];
            }
            [proxies sortUsingComparator:^(id obj1, id obj2){
                CacheProxy* cp1 = (CacheProxy* )obj1;
                CacheProxy* cp2 = (CacheProxy* )obj2;
                const NSInteger res = (cp1->lastAccessTime - cp2->lastAccessTime);
                return res == 0 ? NSOrderedSame : (res < 0 ? NSOrderedAscending : NSOrderedDescending);
            }];
            break;

        case coOldestFirst:
            if ([proxies count] == 0){
                [proxies addObjectsFromArray:[objects allValues]];
            }
            [proxies sortUsingComparator:^(id obj1, id obj2){
                CacheProxy* cp1 = (CacheProxy* )obj1;
                CacheProxy* cp2 = (CacheProxy* )obj2;
                const NSInteger res = (cp1->lastAccessTime - cp2->lastAccessTime);
                return res == 0 ? NSOrderedSame : (res < 0 ? NSOrderedAscending : NSOrderedDescending);
            }];
            break;
    }
    for (NSUInteger t = 0, len = [proxies count]; t < len; t ++ ){
        ((CacheProxy*)[proxies objectAtIndex: t])->inProxiesPos = t;
    }
}

-(void)timerFired{
    if ([proxies count] > strategy.cleanupLoadThreshold * strategy.maxObjectCount){
        [self doCleanup];
    } else if (strategy.cleanupOrder == coOldestFirst) {
        CacheProxy* cp = [proxies lastObject];
        if (cp == nil){
            //empty cache
            return;
        }
        if (getUptimeInMilliseconds() - cp->lastAccessTime > strategy.maxLifeTime){
            [self doCleanup];
        }
    }
}

- (id)init {
    self = [super init];
    if (self) {
        proxies = [[NSMutableArray alloc] init];
        objects = [[NSMutableDictionary alloc] init];
        lock = [[NSLock alloc] init];
        strategy.cleanupOrder = coOldestFirst;
        strategy.maxLifeTime = 20;
        strategy.maxObjectCount = 1500;
        strategy.threadSafe = YES;
        strategy.cleanupCycle = 60;
        strategy.cleanupLoadThreshold = 0.75;
        [self applyStrategy];
    }

    return self;
}

- (void)dealloc {
    [timer invalidate]; timer = nil;
    releaseAndNil(lock);
    releaseAndNil(proxies);
    releaseAndNil(objects);
    [super dealloc];
}

//NOTE: no need to synchronize, should be called from sync context
-(void)cleanupRandom{
    NSInteger tmp = (NSInteger)([objects count] - strategy.cleanupLoadThreshold * strategy.maxObjectCount);
#ifdef COLECT_CACHE_STATS
    stats.purgedItems += tmp;
#endif
    NSMutableArray* keys = [NSMutableArray arrayWithCapacity:(NSUInteger) tmp];

    for (NSString* key in [objects keyEnumerator]){
        tmp--;
        [keys addObject:key];
        if (tmp == 0){
            break;
        }
    }
    [objects removeObjectsForKeys:keys];
}

//NOTE: no need to synchronize, should be called from sync context
-(void)cleanupAccessibleFirst{

    NSInteger oldCount = [proxies count];
    NSInteger maxTime = getUptimeInMilliseconds() - strategy.maxLifeTime * 1000;
    NSMutableArray* keys = [NSMutableArray arrayWithCapacity:(NSUInteger) (oldCount/3)];
    NSMutableArray* newProxies = [[NSMutableArray alloc] initWithCapacity:oldCount];
    NSInteger nCount = 0;
    for (NSInteger t = [proxies count]-1; t >= 0; t--){
        const CacheProxy* cp = [proxies objectAtIndex:(NSUInteger) t];
        if (cp->lastAccessTime < maxTime){
            [keys addObject:cp.key];
        } else {
            [newProxies addObject:cp];
            cp->inProxiesPos = nCount;
            nCount++;
        }
    }
    
    if ([keys count] > 0){
        [objects removeObjectsForKeys:keys];
        releaseAndNil(proxies);
        proxies = newProxies;
        NSAssert([proxies count] == [objects count], @"Upps, error in code this two values should be equal %d, %d",
                 [proxies count] ,[objects count]);
    }
#ifdef COLECT_CACHE_STATS
    stats.purgedItems += oldCount - [proxies count];
#endif
    
}

//NOTE: no need to synchronize, should be called from sync context
- (void)cleanupOldest {

    NSInteger oldCount = [proxies count];

    NSInteger maxTime = getUptimeInMilliseconds() - strategy.maxLifeTime * 1000;
    NSMutableArray* keys = [NSMutableArray arrayWithCapacity:(NSUInteger) (oldCount/3)];
    for (NSInteger t = [proxies count]-1; t >= 0; t--){
        const CacheProxy* cp = [proxies objectAtIndex:(NSUInteger) t];
        if (cp->lastAccessTime < maxTime){
            [keys addObject:cp.key];
        } else {
            break;
        }
    }

    if ([keys count] > 0){
        [objects removeObjectsForKeys:keys];
        [proxies removeObjectsInRange:NSMakeRange([proxies count] - [keys count], [keys count])];
        NSAssert([proxies count] == [objects count], @"Upps, error in code this two values should be equal %d, %d",
                 [proxies count] ,[objects count]);
    }
#ifdef COLECT_CACHE_STATS
    stats.purgedItems += oldCount - [proxies count];
#endif

}

- (void)doCleanup {
    if (strategy.threadSafe == YES){
        [lock lock];
    }
    switch (strategy.cleanupOrder) {
        case coLessAccessibleFirst:
            [self cleanupAccessibleFirst];
            break;

        case coOldestFirst:
            [self cleanupOldest];
            break;

        case coRandom:
            [self cleanupRandom];
            break;
    }

    if (strategy.threadSafe == YES){
        [lock unlock];
    }
}

//NOTE: no need to synchronize, should be called from sync context
- (void)forceSpaceForItem {
    if (strategy.cleanupOrder == coRandom) {
        NSEnumerator* n = [objects keyEnumerator];
        [objects removeObjectForKey:[n nextObject]];
    } else {
        // coLessAccessibleFirst, coOldestFirst
        CacheProxy* cp = [proxies lastObject];
        [objects removeObjectForKey:cp.key];
        [proxies removeLastObject];
    }
#ifdef COLECT_CACHE_STATS
    stats.cacheOverflows ++;
#endif
}

- (void)updateItemPosition:(CacheProxy*)proxy {
     if (strategy.cleanupOrder == coLessAccessibleFirst){
         if (proxy->inProxiesPos == 0){
             return;
         }
#if WANT_SANITY == 1
         //sanity check
         for(int t = 0; t < [proxies count]-1; t++){
             CacheProxy* p1 = [proxies objectAtIndex:t];
             NSAssert( p1->inProxiesPos == t, @"Sanity check failed [inProxyPos] at index %d", t);
         }
#endif
         [proxy retain];
         NSUInteger oldPos = proxy->inProxiesPos;
         [proxies removeObjectAtIndex:proxy->inProxiesPos];
         NSUInteger index = [proxies indexOfObject:proxy
                                     inSortedRange:NSMakeRange(0,[proxies count])
                                           options:NSBinarySearchingInsertionIndex
                                   usingComparator:^(id obj1, id obj2){
                                       CacheProxy* cp1 = (CacheProxy* )obj1;
                                       CacheProxy* cp2 = (CacheProxy* )obj2;
                                       const NSInteger res = (cp1->hitCount - cp2->hitCount);
                                       return res == 0 ? NSOrderedSame : (res > 0 ? NSOrderedAscending : NSOrderedDescending);
                                   }];
         [proxies insertObject:proxy atIndex:index];
         [proxy release];
         index = index < oldPos ? index : oldPos;
         for (;index < [proxies count]; index++){
             proxy = [proxies objectAtIndex:index];
             proxy->inProxiesPos = index;
         }
#if WANT_SANITY == 1
         //sanity check
         for(int t = 0; t < [proxies count]-1; t++){
             CacheProxy* p1 = [proxies objectAtIndex:t];
             CacheProxy* p2 = [proxies objectAtIndex:t+1];
             NSAssert( p1->hitCount >= p2->hitCount, @"Sanity check failed [rule] at index %d", t);
             NSAssert( p1->inProxiesPos == t, @"Sanity check failed [inProxyPos] at index %d", t);
         }
#endif
     } else if (strategy.cleanupOrder == coOldestFirst){
#if WANT_SANITY == 1
         //sanity check
         for(int t = 0; t < [proxies count]-1; t++){
             CacheProxy* p1 = [proxies objectAtIndex:t];
             NSAssert( p1->inProxiesPos == t, @"Sanity check failed [inProxyPos] at index %d", t);
         }
#endif
         [proxy retain];
         NSUInteger oldPos = proxy->inProxiesPos;
         [proxies removeObjectAtIndex:proxy->inProxiesPos];
         NSUInteger index = [proxies indexOfObject:proxy
                                     inSortedRange:NSMakeRange(0,[proxies count])
                                           options:NSBinarySearchingInsertionIndex
                                   usingComparator:^(id obj1, id obj2){
                                       CacheProxy* cp1 = (CacheProxy* )obj1;
                                       CacheProxy* cp2 = (CacheProxy* )obj2;
                                       const NSInteger res = (cp1->lastAccessTime - cp2->lastAccessTime);
                                       return res == 0 ? NSOrderedSame : (res > 0 ? NSOrderedAscending : NSOrderedDescending);
                                   }];
         [proxies insertObject:proxy atIndex:index];
         [proxy release];
         index = index < oldPos ? index : oldPos;
         for (;index < [proxies count]; index++){
             proxy = [proxies objectAtIndex:index];
             proxy->inProxiesPos = index;
         }
#if WANT_SANITY == 1
         //sanity check
         for(int t = 0; t < [proxies count]-1; t++){
             CacheProxy* p1 = [proxies objectAtIndex:t];
             CacheProxy* p2 = [proxies objectAtIndex:t+1];
             NSAssert( p1->lastAccessTime >= p2->lastAccessTime, @"Sanity check failed [rule] at index %d", t);
             NSAssert( p1->inProxiesPos == t, @"Sanity check failed [inProxyPos] at index %d", t);
         }
#endif
     }
}

- (void)setObject:(id)obj forKey:(NSString*)key {
    if (strategy.threadSafe == YES){
        [lock lock];
    }
    CacheProxy* cp = [objects objectForKey:key];
    if (cp == nil){
        cp = [[[CacheProxy alloc] init] autorelease];
        cp.key = key;
        if ([objects count] == strategy.maxObjectCount){
            [self forceSpaceForItem];
        }
        if (strategy.cleanupOrder != coRandom){
            [proxies addObject:cp];
            cp->inProxiesPos = [proxies count]-1;
        }
        [objects setObject:cp forKey:key];
    }
    cp.destObj = obj;
    cp->lastAccessTime = getUptimeInMilliseconds();
    cp->hitCount++;
    [self updateItemPosition: cp];
#ifdef COLECT_CACHE_STATS
    stats.addedItems ++;
#endif
    if (strategy.threadSafe == YES){
        [lock unlock];
    }
}

- (id)objectForKey:(NSString*)key {
    if (strategy.threadSafe == YES){
        [lock lock];
    }
    CacheProxy* cp = [objects objectForKey:key];
#ifdef COLECT_CACHE_STATS
    if (cp == nil){
        stats.missCount ++;
    } else {
        stats.hitCount ++;
    }
#endif
    if (cp != nil) {
        cp->hitCount ++;
        cp->lastAccessTime = getUptimeInMilliseconds();
        [self updateItemPosition: cp];
    }
    if (strategy.threadSafe == YES){
        [lock unlock];
    }
    return cp == nil ? nil : cp.destObj;
}

- (void)removeObjectForKey:(NSString*)key {
    if (strategy.threadSafe == YES){
        [lock lock];
    }
    CacheProxy* cp = [objects objectForKey:key];
    
    if (cp != nil){
        NSAssert([cp isKindOfClass:[CacheProxy class]], @"Upss, really bad");
        [objects removeObjectForKey:key];
        if (strategy.cleanupOrder != coRandom){
            [proxies removeObjectAtIndex:(NSUInteger) cp->inProxiesPos];
            //rebuild indexes
            for(NSUInteger t = cp->inProxiesPos, len = [proxies count]; t < len; t++){
                ((CacheProxy*) [proxies objectAtIndex:t])->inProxiesPos = t;
            }
        }
#ifdef COLECT_CACHE_STATS
        stats.removedItems ++;
#endif
    }
    if (strategy.threadSafe == YES){
        [lock unlock];
    }
}

- (void)setStrategy:(CacheStrategy)str {
    strategy = str;
    [self applyStrategy];
}

- (NSString*)description {
    NSString* cord[] = {@"coOldestFirst", @"coLessAccessibleFirst", @"coRandom"};
    NSString* str = [NSString stringWithFormat:@"maxLifeTime:%d ms, maxObjectCount:%d, cleanupOrder:%@, threadSafe:%@, cleanupCycle: %0.0f s, cleanupLoadThreshod: %0.1f%%",
        strategy.maxLifeTime, strategy.maxObjectCount, cord[strategy.cleanupOrder],
        strategy.threadSafe == YES ? @"YES" : @"NO", strategy.cleanupCycle, strategy.cleanupLoadThreshold *100];
    NSMutableString* stat = [NSMutableString string];

#ifdef COLECT_CACHE_STATS
    NSInteger totalHits = stats.hitCount + stats.missCount;
    [stat appendFormat:@"hitCount: %d (%0.1f%%),", stats.hitCount, 100.0f * stats.hitCount/totalHits];
    [stat appendFormat:@"missCount: %d (%0.1f%%),", stats.hitCount, 100.0f * stats.missCount/totalHits];
    [stat appendFormat:@"cacheOverflows: %d(%0.1f%%),", stats.cacheOverflows, 100.0f * stats.cacheOverflows/stats.addedItems];
    [stat appendFormat:@"addedItems: %d,", stats.addedItems];
    [stat appendFormat:@"removedItems: %d,", stats.removedItems];
    [stat appendFormat:@"purgedItems: %d(%0.1f%%)", stats.purgedItems, 100.0f * stats.purgedItems / stats.addedItems];
#else
    [stat appendString:@"disabled"];
#endif
    NSInteger cnt = [objects count];
    return [NSString stringWithFormat:@"[Cache objects: %d (%0.1f)\n strategy:[%@]\n stats:[%@]",
                    cnt, (float)cnt / strategy.maxObjectCount, str, stat];
}

@end