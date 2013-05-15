//
//  RWLock.h
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski on 29.05.2012.
//

#import <Foundation/Foundation.h>

/**
 * This is simplest approach to Multiple Read-Single Write lock. Each call to acquireReadLock must
 * be balanced with unlockRead, this same aplies to acquireWriteLock/unlockWrite. It allows single
 * thread to call multiple times read and/or write lock recursive without blocking (similar to
 * NSReculsive lock). If define INCLUDE_LOCK_INFO_IN_THREAD is set to 1 additional safe-checks are
 * enabled helping to find problems with wrong unlocking in multithread envriroment. For even more
 * info please add COLLECT_THREADS definition, it's enables dumpThreads method.
 */
@interface RWLock : NSObject{
    NSCondition* cond;
    NSString* lockID;
    NSInteger readCount;
    NSInteger writeCount;
    NSMutableSet* threads;
}

/**
 * Tries to enter critical section with read rights, multiple threads may be inside due to call to this method.
 * If another thread is in critical section with write rights then this call will wait until write-lock is released.
 */
-(void)acquireReadLock;

/**
 * Tries to enter critical section with write rights, only one thread may be inside due to call to this method.
 * If another thread(s) is in critical section then this call will wait until all locks are released.
 */
-(void)acquireWriteLock;

/**
 * Releases read lock, should be balanced with acquireReadLock.
 */
-(void)unlockRead;

/**
 * Releases write lock, should be balanced with acquireWriteLock.
 */
-(void)unlockWrite;

/**
 * Returns list of all threads which holds any kind of lock. Requires COLLECT_THREADS define to be set to 1
 * to work.
 */
-(NSString*)dumpThreads;

@end

@interface RWLock( SelfCheck )
+(void)testRWLock;
@end
