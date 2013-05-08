//
//  RWLock.m
//  VideoLibrary
//
//  Created by Bartłomiej Żarnowski on 29.05.2012.
//  Copyright (c) 2012 VoipSwitch. All rights reserved.
//

#import "RWLock.h"

#if defined (DEBUG) && DEBUG == 1
    #define INCLUDE_LOCK_INFO_IN_THREAD     1
    //before setting this to 1 ensure INCLUDE_LOCK_INFO_IN_THREAD is also set to 1!
    #define COLLECT_THREADS 1
#endif


#if defined (INCLUDE_LOCK_INFO_IN_THREAD) && INCLUDE_LOCK_INFO_IN_THREAD == 1
@interface LockInfo:NSObject{
    @public
    NSInteger readCount, writeCount;
}
@end

@implementation LockInfo
@end
#endif

@implementation RWLock
-(id)init{
    self = [super init];
    if (self != nil){
         cond = [[NSCondition alloc] init];
        lockID = [[NSString stringWithFormat:@"rwlock:%x-%X", (NSInteger)self, arc4random()] retain];

#if defined (COLLECT_THREADS) && COLLECT_THREADS == 1
        threads = [[NSMutableSet alloc] init];
#endif
        
    }
    return self;
}

-(void)dealloc{
    [cond release];
    cond = nil;
    
    [threads release];
    threads = nil;
    [super dealloc];
}

-(void)acquireReadLock{
    [cond lock];
    while(writeCount > 0){
        [cond wait];
    }
    readCount++;
    
#if defined (INCLUDE_LOCK_INFO_IN_THREAD) && INCLUDE_LOCK_INFO_IN_THREAD == 1
    LockInfo* li = [[NSThread currentThread].threadDictionary objectForKey:lockID];
    if (li == nil){
        li = [[[LockInfo alloc] init] autorelease];
        [[NSThread currentThread].threadDictionary setValue:li forKey:lockID];
#if defined (COLLECT_THREADS) && COLLECT_THREADS == 1
        [threads addObject:[NSThread currentThread]];
#endif
    }
    li->readCount++;
#endif
    
    [cond unlock];
}

-(void)acquireWriteLock{
    [cond lock];
    while( (writeCount > 0) || (readCount > 0) ) {
        [cond wait];
    }
    writeCount++;
    if (writeCount == 2){
        NSLog(@"--");
    }
#if defined (INCLUDE_LOCK_INFO_IN_THREAD) && INCLUDE_LOCK_INFO_IN_THREAD == 1
    LockInfo* li = [[NSThread currentThread].threadDictionary objectForKey:lockID];
    if (li == nil){
        li = [[[LockInfo alloc] init] autorelease];
        [[NSThread currentThread].threadDictionary setValue:li forKey:lockID];
#if defined (COLLECT_THREADS) && COLLECT_THREADS == 1
        [threads addObject:[NSThread currentThread]];
#endif
    }
    li->writeCount++;
#endif
    
    [cond unlock];
}

-(void)unlockRead{
    [cond lock];
    readCount--;
    NSAssert(readCount >= 0, @"To many unlockRead on %@", [self description]);
    
#if defined (INCLUDE_LOCK_INFO_IN_THREAD) && INCLUDE_LOCK_INFO_IN_THREAD == 1
    LockInfo* li = [[NSThread currentThread].threadDictionary objectForKey:lockID];
    NSAssert(li != nil, @"unlock on non locked thread! %@", [NSThread currentThread]);
    li->readCount--;
    NSAssert(li->readCount >= 0, @"To many unlockRead %@ on thread %@", [self description], [NSThread currentThread]);
    if ( (li->readCount == 0) && (li->writeCount == 0) ){
        [[NSThread currentThread].threadDictionary removeObjectForKey:lockID];
#if defined (COLLECT_THREADS) && COLLECT_THREADS == 1
        [threads removeObject:[NSThread currentThread]];
#endif
    }
#endif    
    
    [cond broadcast];   //if less aggressive then [cond signal];
    [cond unlock];
}

-(void)unlockWrite{
    [cond lock];
    writeCount--;
    NSAssert(writeCount >= 0, @"To many writeUnlock on %@", [self description]);

#if defined (INCLUDE_LOCK_INFO_IN_THREAD) && INCLUDE_LOCK_INFO_IN_THREAD == 1
    LockInfo* li = [[NSThread currentThread].threadDictionary objectForKey:lockID];
    NSAssert(li != nil, @"unlock on non locked thread! %@",[NSThread currentThread]);
    li->writeCount--;
    NSAssert(li->writeCount >= 0, @"To many unlockWrite %@ on thread %@", [self description], [NSThread currentThread]);
    if ( (li->readCount == 0) && (li->writeCount == 0) ){
        [[NSThread currentThread].threadDictionary removeObjectForKey:lockID];
#if defined (COLLECT_THREADS) && COLLECT_THREADS == 1
        [threads removeObject:[NSThread currentThread]];
#endif
    }
#endif
    
    [cond broadcast];   //if less aggressive then [cond signal];
    [cond unlock];    
}

-(NSString*)description{
    return [NSString stringWithFormat:@"[RWLock uid:%@]", lockID];
}

-(NSString*)dumpThreads{
#if defined (COLLECT_THREADS) && COLLECT_THREADS == 1
    NSMutableString* result = [NSMutableString stringWithFormat:@"RWLock dump, uid: %@\n",lockID];
    for(NSThread* th in threads){
        LockInfo* li = [[NSThread currentThread].threadDictionary objectForKey:lockID];
        NSAssert(li != nil, @"Internall error, RWLock with thread %@",th);
        [result appendFormat:@" Thread: %@, rLocks=%d, wLocks=%d\n", th.name, li->readCount, li->writeCount];
    }
    return result;
#else
    return @"COLLECT_THREADS needs to be defined to 1";
#endif
    
}

#pragma mark - Unit tests
+(void)simpleTestW:(NSMutableDictionary*)enterDict{

    NSMutableDictionary* dict = [enterDict objectForKey:@"dict"];
    RWLock* lock = [enterDict objectForKey:@"lock"];
    NSInteger added=0;
    for(int t = 0; t < 1000; t ++){
        [lock acquireWriteLock];
        if ([dict objectForKey:[NSString stringWithFormat:@"%d",t]] != nil){
            [lock unlockWrite];
            continue;
        }
        added++;
        [dict setValue:[NSNumber numberWithInt:t] forKey:[NSString stringWithFormat:@"%d",t]];
        [lock unlockWrite];
        [NSThread sleepForTimeInterval:arc4random()%10 / 10000.0];
    }
    NSLog(@"Thread done: %@, added:%d", [[NSThread currentThread] name], added);
}

+(void)simpleTestR:(NSMutableDictionary*)enterDict{
    
    NSMutableDictionary* dict = [enterDict objectForKey:@"dict"];
    RWLock* lock = [enterDict objectForKey:@"lock"];
    NSInteger found = 0;
    while(found < 1000){
        [lock acquireReadLock];
        if ([dict objectForKey:[NSString stringWithFormat:@"%d",found]] != nil){
            found ++;
        }
        [lock unlockRead];
    }
    NSLog(@"Thread done: %@, found:%d", [[NSThread currentThread] name], found);
}

+(void)testRWLock{
    RWLock* rwlock = [[RWLock alloc] init];
    NSMutableDictionary* dict = [[NSMutableDictionary dictionaryWithObject:rwlock forKey:@"lock"] retain];
    [dict setObject:[NSMutableDictionary dictionary] forKey:@"dict"];
    
    for(NSInteger t = 0; t < 16; t++){
        if ((t & 1) != 1){
            NSThread* thr = [[NSThread alloc] initWithTarget:[RWLock class] selector:@selector(simpleTestW:) object:dict];
            [thr setName:[NSString stringWithFormat:@"Writter-%d",t]];
            [thr start];
        } else {
            NSThread* thr = [[NSThread alloc] initWithTarget:[RWLock class] selector:@selector(simpleTestR:) object:dict];
            [thr setName:[NSString stringWithFormat:@"Reader-%d",t]];
            [thr start];
        }
    }
}

@end
