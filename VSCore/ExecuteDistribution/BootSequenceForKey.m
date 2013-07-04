//
//  BootSequenceForKey.m
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Kamil Rzeźnicki on 14.03.2013.
//

#import "BootSequenceForKey.h"
#import "BootLoader.h"
#import "CommonDefines.h"

#import "Collections+subscripts.h"

@implementation BootSequenceForKey

@synthesize buildInThread;
@synthesize name, nilObjects, objects;

-(id) initWithKey:(NSString*)keyy buildInThread:(NSThread*) inThread {
    self = [super init];
    if(self != nil){
        self.name = keyy;
        self.buildInThread = inThread;
        objects = [[NSMutableDictionary alloc] init];
        nilObjects = [[NSMutableDictionary alloc] init];
        inProgress = NO;
    }
    return self;
}

-(void)startPhase: (BootPhase)startPhase {
    phase = startPhase;
    inProgress = YES;
}

-(void)endPhase {
    inProgress = NO;
}

-(void) addAskedKey:(NSString*) askedKey isNil:(BOOL) isNil {
    if(isNil == YES) {
        nilObjects[askedKey] = [NSNumber numberWithInt: phase];
    }
    else {
        if([objects objectForKey:name] == nil){
            objects[askedKey] = [NSNumber numberWithInt: phase];
        }
    }
}

-(void) dealloc {
    releaseAndNil(buildInThread);
    releaseAndNil(name);
    releaseAndNil(objects);
    releaseAndNil(nilObjects);
    [super dealloc];
}

/* Description */

- (NSString*) description{

    NSMutableString* descr = [NSMutableString stringWithFormat:@"Boot sequence for class name: %@ \n", name];
    for(int i = bpBootInit; i <= bpBootEnd; ++i){
        [descr appendString:[self descriptionPhaseSequence:i]];
    }
    return descr;
}


-(NSString*) descriptionPhaseSequence: (BootPhase) descrPhase {


    __block NSMutableString*  descr = [NSMutableString stringWithFormat:@"\n"]; 
    [objects enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSNumber* phaseNum = (NSNumber*)obj;
        if([phaseNum intValue] == descrPhase){
            [descr appendFormat:@"            %@\n", key];
        }
    }];
    if(nilObjects.count > 0){
    [descr appendFormat:@"        returned NIL\n"];
    }
    [nilObjects enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSNumber* phaseNum = (NSNumber*)obj;
        if([phaseNum intValue] == descrPhase){
            [descr appendFormat:@"            %@\n", key];
        }
    }];
    
    return descr;
}

@end
