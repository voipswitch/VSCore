//
//  Cache.h
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski on 27.07.2012.
//

#import <Foundation/Foundation.h>

//uncomment this define to enable stats gathering
//#define COLECT_CACHE_STATS 1

typedef enum {
    //OVERFLOWS: removed oldest from collection
    //PURGES: removed items with life time exceeding strategy.maxLifeTime
    coOldestFirst,

    //OVERFLOWS: removed element with less hit count from collection
    //PURGES: removed items with life time exceeding strategy.maxLifeTime (this may be slow, consider if this is what you want for large caches)
    coLessAccessibleFirst,

    //OVERFLOWS: removed random element from collection
    //PURGES: removes random elements as long as % of collection fulfilment goes below strategy.cleanupLoadThreshold
    coRandom
} CleanupOrder;

typedef struct{
    NSInteger hitCount;  //how many positive hits into cache
    NSInteger missCount; //how many misses while trying to access objects from cache
    NSInteger cacheOverflows;  //how many times cache was overflowed and space for new item was forced to create
    NSInteger addedItems;   //how many items was put into cache
    NSInteger removedItems; //how many items was removed from cache by explicit call
    NSInteger purgedItems;  //how many items was removed from cache due to strategy dependent cleanup mechanism
} CacheStats;

typedef struct{
    //Describes maxLifetime for object in cache in seconds. This is used in cyclic cleanup process (if cleanupCycle >0)
    //to remove old objects from memory. Used if cleanupOrder != coRandom
    NSInteger maxLifeTime;

    //Describes upper limit of this cache. If this value is exceeded while adding new object, then some other object
    //will be removed from cache. Removal conditions are described by cleanupOrder field.
    NSInteger maxObjectCount;

    //describes strategy which should be used while cleaning cache.
    CleanupOrder cleanupOrder;

    //Set to YES if this cache should be thread safe
    BOOL threadSafe;

    //Delay between cleanup cycles, set to 0 to disable. Timer will be started on thread from which strategy property
    //was set.
    NSTimeInterval cleanupCycle;

    //Value from 0..1 it says how much % of cache must be filled to fire cleanup method from timer. Set to 1 if no
    //cleanup should be done, or set cleanupCycle to 0 if you want to disable cyclic cleanups.
    float cleanupLoadThreshold;
} CacheStrategy;

//NOTE: Change strategy may be time expensive and it's not thread safe. It's recommended to do this once for each cache
@interface Cache : NSObject{
@private
    NSMutableArray* proxies;
    NSMutableDictionary* objects;
    CacheStrategy strategy;
    NSTimer* timer;
    NSLock* lock;
#ifdef COLECT_CACHE_STATS
    CacheStats stats;
#endif
}

@property (nonatomic, assign) CacheStrategy strategy;

/**
* Request cache to perform check in this moment. All objects which doesn't meet required conditions (defined by strategy)
* will be removed from cache. Usually you don't need to call this method, however you may do it when you expect that
* application is under low load, and cache is heavily loaded.
*/
-(void)doCleanup;
-(void)setObject:(id)obj forKey:(NSString*)key;
-(id)objectForKey:(NSString*)key;
-(void)removeObjectForKey:(NSString*)key;
-(void)removeAllObjects;
@end