//
//  Bootable.h
//  Scrapyard
//
//  Created by Bartłomiej Żarnowski on 12.12.2012.
//  Copyright (c) 2012 Bartłomiej Żarnowski. All rights reserved.
//

#import <Foundation/Foundation.h>

//if set then build should be performed in new thread, not in caller thread
#define BOOT_FLAG_THREADED 1

//creation priority for object which should be created as first
#define BOOT_PRIO_EARLY   10

//creation priority for object which should be created as second (compare to BOOT_PRIO_EARLY)
#define BOOT_PRIO_NORMAL 100

//creation priority for object which should be created as last (compare to BOOT_PRIO_EARLY, BOOT_PRIO_NORMAL)
#define BOOT_PRIO_LATE    1000

/**
 * Protocol which cooperate with {@link BootLoader} class. It allows to konfigure aspect of building
 * object (by setting it's start priority, and configuration flags). It also introduces 4 steps of object creation.
 * <ol>init - default object constructor</ol>
 * <ol>bootSetup - early phase of object setup, lightweight operations, usually fields/collections setup</ol>
 * <ol>bootBind - bounding to other delegates, managers, providers etc. Preffered by {@link Askable} mechanism</ol>
 * <ol>bootFinalize - late setup, all corelations should be set at this moment, this object should finalize setup process</ol>
 */
@protocol Bootable <NSObject>

@optional   //all methods are optional

#pragma mark - configuration methods
/**
 * @return priority of this class, lower value means earielr execution in boot chain
 */
+(NSInteger)bootCfgPriority;

/**
 * @return configuration flags, refer to BOOT_FLAG_* defines
 */
+(NSUInteger)bootCfgFlags;

#pragma mark - instance methods for boot process

/**
 * Called on first phase of object setup, expected lightweight operations.
 * @param mode mode in which {@link BootLoader} has been booted.
 */
-(void)bootSetup:(NSString*)mode;

/**
 * Called on second phase of object setup. Other object should be created and we can search for
 * delegates, mamangers and other things into which we wannt to bind.
 * @param mode mode in which {@link BootLoader} has been booted.
 */
-(void)bootBind:(NSString*)mode;

/**
 * Corelation structure is prepared, object may finalize it setup. Heavy operations are expected to be here.
 * @param mode mode in which {@link BootLoader} has been booted.
 */
-(void)bootFinalize:(NSString*)mode;

/**
 * @return object which should be used in bind mechanism in BootLoader instead of object which implements this Protocol.
 */
-(id)bootObjToBind;
@end
