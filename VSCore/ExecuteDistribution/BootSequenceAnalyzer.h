//
//  BootSequenceAnalizer.h
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Kamil Rzeźnicki on 14.03.2013.
//

#import <Foundation/Foundation.h>
#import "BootLoader.h"

#define BOOT_SEQUENCE_ANALYZE  1
#if defined(BOOT_SEQUENCE_ANALYZE) && (BOOT_SEQUENCE_ANALYZE == 1)
    #define ANALYZER(code)  code
#else
    #define ANALYZER(code) /* code */
#endif

@interface BootSequenceAnalyzer : NSObject
{
    /* dictionary with objects which are current booting */
    NSMutableDictionary*   objectsInProgress;
    
    /* dictionary with all objects which was booting */
    NSMutableDictionary*   allBootObjects;          //key is name of class and value is [@object BootSequenceForKey]
    
    /* count of nil returned by askable (@method askForObject) */
    int                    returnedNil;
    NSRecursiveLock*       theLock;
}

+(id)getInstance;

/**
 @method should be invoke when boot phase starting for any object
 @param phase is current BootPhase for this object
 @param key is identifier for this object (e.g NSString* className = NSStringFromClass(object) )
 @param buildInThread is thread on which is booting this object
 @param prio is priority in boot sequence
 **/
-(void)executePhaseStart: (BootPhase)phase forKey:(NSString*)key inThread:(NSThread*)buildInThread  withPriority: (int) prio;

/**
 @method should be invoke when boot phase ending for any object
 @param phase is current BootPhase for this object
 @param key is identifier for this object from (@method executePhaseStart)
 **/
-(void)executePhaseEndforKey:(NSString*)key;

/**
 @method should be invoke in Askable (@method askForObject)
 @param key for object from askable
 @param isNil - YES when key is not found in askable (not registered) or object for this key is nil
 @param thread on which is invoked askable  
 **/
-(void)askedForObject: (NSString*) key isNil:(BOOL) isNil inThread:(NSThread*) thread;


/**
 @return boot sequence list for thread (thread must have set name)
 **/
-(NSString*) descriptionForThread:(NSThread*) thread;

-(NSString*) dumpDotGraphRepresentation;
@end
