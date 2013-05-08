//
//  BootSequenceAnalizer.m
//  VSCore
//
//  Created by Kamil Rzeźnicki on 14.03.2013.
//  Copyright (c) 2013 Bartłomiej Żarnowski. All rights reserved.
//

#import "BootSequenceAnalyzer.h"
#import "BootSequenceForKey.h"
#import "CommonDefines.h"
#import "Askable.h"

static BootSequenceAnalyzer* analyzer = nil;

@implementation BootSequenceAnalyzer

-(id)init {
    self = [super init];
    if(self != nil){
        theLock =[[NSRecursiveLock alloc] init];
        allBootObjects = [[NSMutableDictionary alloc] init];
        objectsInProgress = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+(id)getInstance {
    @synchronized(self) {
        if (analyzer == nil)
            analyzer = [[BootSequenceAnalyzer alloc] init];
    }
    return analyzer;
}

-(void)executePhaseStart: (BootPhase)phase forKey:(NSString*)key inThread:(NSThread*)buildInThread  withPriority: (int) prio{
   
    [theLock lock];
    if(key != nil) {
        BootSequenceForKey* seq = [allBootObjects objectForKey:key];
    
        if(seq == nil) {
            seq = [[[BootSequenceForKey alloc] initWithKey:key buildInThread:buildInThread] autorelease];
            seq.priority = prio;
            allBootObjects[key] = seq;
        }
        [seq startPhase:phase];
        objectsInProgress[key] = seq;
    }
    [theLock unlock];
}

-(void)executePhaseEndforKey:(NSString*)key {
    [theLock lock];
    if(key != nil){
        BootSequenceForKey* seq = [allBootObjects objectForKey:key];
        [seq endPhase];
        [objectsInProgress removeObjectForKey:key];
    }
    [theLock unlock];

}

-(void)askedForObject: (NSString*) askedKey isNil:(BOOL) isNil inThread:(NSThread*) thread {
    [theLock lock];
    [objectsInProgress enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        BootSequenceForKey* bsfk = (BootSequenceForKey*) obj;
        *stop = [bsfk.buildInThread isEqual:thread];
        if(*stop == YES){
            [obj addAskedKey:askedKey isNil:isNil];
            returnedNil += isNil ? 1 : 0;
        }
    }];
    [theLock unlock];
}

-(void) dealloc {
    releaseAndNil(analyzer);
    releaseAndNil(objectsInProgress);
    releaseAndNil(allBootObjects);
    [super dealloc];
}

/* description */
-(NSString*) descriptionForThread:(NSThread*) thread {
    [theLock lock];
    
    __block NSMutableString* descr = [NSMutableString stringWithFormat:@"BootSequenceAnalizer for %@: \nreturned nils: %d\n", thread.name, returnedNil];
    
    NSComparator cmp = ^NSComparisonResult(id obj1, id obj2){
        BootSequenceForKey* bsfk1 = obj1;
        BootSequenceForKey* bsfk2 = obj2;
        NSInteger i = bsfk1.priority - bsfk2.priority;
        if (i == 0){
            return NSOrderedSame;
        } else {
            return i < 0 ? NSOrderedAscending : NSOrderedDescending;
        }
    };

    NSArray* allObj = [allBootObjects keysSortedByValueUsingComparator:cmp];
    
    for(int i = bpBootInit; i <= bpBootEnd; ++i){
        [descr appendString:[self descriptionPhase:i]];
        [allObj enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            BootSequenceForKey* bsfk = [allBootObjects valueForKey:(NSString *) obj];
            if([bsfk.buildInThread.name isEqualToString:thread.name]){
                [descr appendFormat:@"    %@",bsfk.name];
                [descr appendString:[bsfk descriptionPhaseSequence:i]];
            }
        }];
    }
    
    [theLock unlock];
    
    return descr;
}

- (NSString*) descriptionPhase: (BootPhase) descrPhase {
    switch (descrPhase) {
        case bpBootInit:
            return @"INIT\n";
        case bpBootSetup:
            return @"SETUP\n";
        case bpBootBind:
            return @"BIND\n";
        case bpBootFinalize:
            return @"FINALIZE\n";
        case bpBootEnd:
            return @"END\n";
        default:
            return @"UNKNOWN\n";
    }
}

-(NSString*) dumpDotGraphRepresentation{
    
    __block NSMutableString* str = [NSMutableString stringWithString:@"digraph BootSequence{"];
    [allBootObjects enumerateKeysAndObjectsUsingBlock:^(id masterKey, id obj, BOOL *stop) {
        BootSequenceForKey* dep = obj;
        
        [dep.objects enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            id a = [Askable askForObject:key defaultValue:nil];
            [str appendFormat:@"%@ -> %@;", masterKey, NSStringFromClass([a class])];
        }];
        [dep.nilObjects enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            id a = [Askable askForObject:key defaultValue:nil];
            [str appendFormat:@"%@ -> %@;", masterKey, NSStringFromClass([a class])];
        }];
    }];
    
    [str appendString:@"}"];
    return str;
}
@end

