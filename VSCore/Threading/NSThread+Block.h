//
//  NSThread+Block.h
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski [Toster] on 10.04.2013.
//

#import <Foundation/Foundation.h>

@interface NSThread (Block)

/**
 * Executes a given block on main thread, if call is done from main thread then
 * this call is sync. If called from not main thread then block is
 * async sheduled on main thread and method returns immediately.
 * @param block to execute
 */
+ (void)MCSM_performBlockOnMainThread:(void (^)())block;

/**
 * Spawn new thread and schedule async execution of given block, returns immediately.
 * @param block to execute
 */
+ (void)MCSM_performBlockInBackground:(void (^)())block;

/**
 * Executes a block on this thread, if call is from this thread method is sync,
 * otherwise async execution is done.
 * @param block to execute
 */
- (void)MCSM_performBlock:(void (^)())block;

/**
 * Executes a block on this thread, call is sync or async depending of argument wait.
 * @param block to execute
 * @param wait if YES then call is blocking otherwise it's async
 */
- (void)MCSM_performBlock:(void (^)())block waitUntilDone:(BOOL)wait;

/**
 * Schedules a block of code to execute on this thread after given delay.
 * @param block to execute
 * @param delay in sec
 */
- (void)MCSM_performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay;

@end
