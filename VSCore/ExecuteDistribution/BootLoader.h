//
//  BootLoader.h
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski on 12.12.2012.
//

#import <Foundation/Foundation.h>
#import "Bootable.h"

@class BootSequenceAnalyzer;

typedef enum {
    bpBootInit, //before any setup
    bpBootSetup,
    bpBootBind,
    bpBootFinalize,
    bpBootEnd   //after all finalize
} BootPhase;

typedef void(^ExecutionBlock)();

/**
 * Class designed to perform creation, and configuration of other objects in selected order. It allows to select one of
 * build paths (refered as mode in methods) which should be used to determine which object builds. It cooperates with
 * interface {@link Bootable} to perform several phases of object creation (init, early setup, bind, late setup). It
 * also allows to perform building in sync/async/mixed manner.
 */
@interface BootLoader : NSObject{
    NSMutableDictionary* bootNodes;
    NSInteger freeUid;
    BootSequenceAnalyzer* analizer;
}

/**
 * Adds bootable to boot proces, all metrics required by boot procedure are take throught {@link Bootable} interface.
 * @param obj class of object to be created during boot process
 * @param modes array of mode specifiers in which obj should be booted, if nil all modes are valid.
 * @return key which may be used to access this added item (for example in bind method)
 */
-(id)add:(Class<Bootable>)obj forModes:(NSArray*)modes;

/**
 * if we have class which should only be created use:
 * @code{.obj-c}
 * [bootLoader add:[SomeClass class] withPriority:1 forModes:@["normal"] withSelector:nil isStaticCall:NO inCallerThread:YES];
 * @endcode
 *
 * if we have class which should be created, and then some method called use:
 * @code{.obj-c}
 * [bootLoader add:[SomeClass class] withPriority:1 forModes:@["normal"] withSelector:@selector(someSetupMethod) isStaticCall:NO inCallerThread:YES];
 * @endcode
 *
 * for singleton like classes (no init, just static method should be called) use:
 * @code{.obj-c}
 * [bootLoader add:[SomeClass class] withPriority:1 forModes:@["normal"] withSelector:@selector(getInstance) isStaticCall:YES inCallerThread:YES];
 * @endcode
 *
 * @param obj class which should be used to create object instance
 * @param pri is used to put order of execution while booting. Lower number means higher priority (executed earlier than others with higher pri value)
 * @param modes array of mode specifiers in which obj should be booted, if nil all modes are valid
 * @param sel selector of method which should be executed after object creation (if isStatic=NO), or selector which should be called
 * on obj class (is isStatic=YES)
 * @param isStatic controls call type (on instance or on class) performed on sel argument
 * @param inThisThread if set to YES boot procedure will be executed in thread which called (@link #boot:), otherwise it will be
 * executed on some other thread.
 * @return key which may be used to access this added item (for example in bind method)
 */
-(id)add:(Class)obj withPriority:(NSInteger)pri forModes:(NSArray*)modes withSelector:(SEL)sel isStaticCall:(BOOL)isStatic inCallerThread:(BOOL)inThisThread;

/**
 * Adds a method call to boot load process.
 * @param sel selector which should be called
 * @param target on which selector should be performed
 * @param pri is used to put order of execution while booting. Lower number means higher priority (executed earlier than others with higher pri value)
 * @param phase in boot sequence in which execution should be done, see enum for more info
 * @param modes array of mode specifiers in which selector should be called, if nil all modes are valid
 * @param inThisThread if set to YES boot procedure will be executed in thread which called (@link #boot:), otherwise it will be
 * executed on some other thread.
 */
-(id)addMethod:(SEL)sel onTarget:(id)target withPriority:(NSInteger)pri inPhase:(BootPhase)phase forModes:(NSArray*)modes inCallerThread:(BOOL)inThisThread;

/**
 * Adds a block call to boot load process. Block must match ExecutionBlock signature.
 * @param blk to execute
 * @param pri is used to put order of execution while booting. Lower number means higher priority (executed earlier than others with higher pri value)
 * @param phase in boot sequence in which execution should be done, see enum for more info
 * @param modes array of mode specifiers in which selector should be called, if nil all modes are valid
 * @param inThisThread if set to YES boot procedure will be executed in thread which called (@link #boot:), otherwise it will be
 * executed on some other thread.
 */
-(id)addBlock:(ExecutionBlock)blk forModes:(NSArray*)modes withPriority:(NSInteger)pri inPhase:(BootPhase)phase inCallerThread:(BOOL)inThisThread;

/**
 * Method may be used to perform binding between newly created object in boot proces and owner for this object. For example if an application
 * want to hold manager created in bootloader it should call block simillar to:
 * @code{.obj-c}
 * id key = [bootLoader add:[SomeClass class] withPriority:1 forModes:@["normal"] withSelector:nil isStaticCall:NO inCallerThread:YES];
 * [bootLoader bind:key withTarget:application andSelector:@selector(setSomeClass:)];
 * [bootLoader boot:@"normal"];
 * @endcode
 * This example assumes that application class has method with signature setSomeClass:(id)obj. This method will be called when
 * object pointed by SomeClass will be created.
 * @param key used to select bind object (returned by one of add methods)
 * @param target on which given selector will be called
 * @param sel selector which should be called after new object is build, it must have signature in form name:(id)obj
 */
-(void)bind:(id)key withTarget:(id)target andSelector:(SEL)sel;

/**
 * Method may be used to perform binding between newly created object in boot proces and Askable interface.
 * @param key used to select bind object (returned by one of add methods)
 * @param askableKey key which will be used to put object into {@link Askable}
 */
-(void)bind:(id)key withAskable:(NSString*)askableKey;

/**
 * Starts execution sequence in selected mode. Mode parameter determines which added class will be created. Dependent on given settings
 * execution may start in caller thread (sync) or in other thread (async) or in both modes (async + sync).
 * @param mode identifier describing start mode.
 */
-(void)boot:(NSString*)mode;

-(BootSequenceAnalyzer*) analizer;
@end
