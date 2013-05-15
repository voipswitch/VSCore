//
//  BootSequenceForKey.h
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Kamil Rzeźnicki on 14.03.2013.
//

#import <Foundation/Foundation.h>
#import "BootLoader.h"

@interface BootSequenceForKey : NSObject
{
    BootPhase   phase;
    BOOL        inProgress;
    NSMutableDictionary*    objects;     //key is objKey from [Askable askForObject:objKey defaultValue:def], value is bootPhase
    NSMutableDictionary*    nilObjects;  //key is objKey from [Askable askForObject:objKey defaultValue:def], value is bootPhase
}

@property (nonatomic,retain)   NSThread*   buildInThread;
@property (nonatomic,retain)   NSString*   name;
@property (nonatomic,assign)   int         priority;
@property (nonatomic, readonly) NSDictionary* objects;
@property (nonatomic, readonly) NSDictionary* nilObjects;

-(id) initWithKey:(NSString*)keyy buildInThread:(NSThread*) inThread;

-(void) startPhase: (BootPhase)startPhase;
-(void) endPhase;
-(void) addAskedKey:(NSString*) askedKey isNil:(BOOL) isNil;
-(NSString*) descriptionPhaseSequence: (BootPhase) descrPhase;

@end
