//
//  BootLoader.m
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski on 12.12.2012.
//

#import "BootLoader.h"
#import "Bootable.h"
#import "BootSequenceAnalyzer.h"
#import <objc/runtime.h>

#ifndef releaseAndNil
#define releaseAndNil(x) [x release]; x = nil
#endif

@interface BootNode : NSObject{
    @public
    Class classToBuild;
    NSInteger priority;
    NSArray*  modes;
    
    SEL explicitSelector;
    BOOL isExpSelStatic;
    
    BOOL buildInCallerThread;
    
    id externalBindTarget;
    SEL externalBindSelector;
    
    id buildedObject;
    
    //for method/block execution
    BOOL simpleMode;    //should be YES if we want exectue Methos/block
    id simpleTarget;
    SEL simpleSelector;
    BootPhase simplePhase;
    ExecutionBlock simpleBlock;
}
@end

@implementation BootNode
-(void)dealloc{
    releaseAndNil(modes);
    releaseAndNil(buildedObject);
    releaseAndNil(simpleBlock);
    [super dealloc];
}

-(NSString*)description{
    return [NSString stringWithFormat:@"[BootNode classToBuild:%@, priority:%d, modes:%@, explicitSelector:%@, \
            isExpSelStatic:%d, buildInCallerThread:%d, externalBindTarget:%@, externalBindSelector:%@",
            classToBuild, priority, modes, NSStringFromSelector(explicitSelector), isExpSelStatic, buildInCallerThread,
            externalBindTarget, NSStringFromSelector(externalBindSelector)];
    
}
@end

@implementation BootLoader
-(id)init{
    self = [super init];
    if (self != nil){
        bootNodes = [[NSMutableDictionary alloc] init];
        ANALYZER( analizer = [BootSequenceAnalyzer getInstance]; )
    }
    return self;
}

-(void)dealloc{
    ANALYZER(releaseAndNil(analizer);)
    releaseAndNil(bootNodes);
    [super dealloc];
}

-(BootSequenceAnalyzer*) analizer{
    return analizer;
}

-(id)addMethod:(SEL)sel onTarget:(id)target withPriority:(NSInteger)pri inPhase:(BootPhase)phase forModes:(NSArray*)modes inCallerThread:(BOOL)inThisThread{
    @synchronized(self){
        freeUid++;
        id key = @(freeUid);
        BootNode* node = [[[BootNode alloc] init] autorelease];
        bootNodes[key] = node;
        
        node->simpleMode = YES;
        node->modes = [modes retain];
        node->priority = pri;
        node->simpleTarget = target;
        node->simpleSelector = sel;
        node->simplePhase = phase;
        node->buildInCallerThread = inThisThread;
        return key;
    }
}

-(id)addBlock:(ExecutionBlock)blk forModes:(NSArray*)modes withPriority:(NSInteger)pri inPhase:(BootPhase)phase inCallerThread:(BOOL)inThisThread{
    @synchronized(self){
        freeUid++;
        id key = @(freeUid);
        BootNode* node = [[[BootNode alloc] init] autorelease];
        bootNodes[key] = node;
        
        node->simpleMode = YES;
        node->modes = [modes retain];
        node->priority = pri;
        node->simpleBlock = [blk copy];
        node->simplePhase = phase;
        node->buildInCallerThread = inThisThread;
        return key;
    }
}

-(id)add:(Class<Bootable>)obj forModes:(NSArray*)modes{
    @synchronized(self){
        freeUid++;
        id key = @(freeUid);
        BootNode* node = [[[BootNode alloc] init] autorelease];
        bootNodes[key] = node;
        
        node->classToBuild = obj;
        node->modes = [modes retain];
        if ([(NSObject*)obj respondsToSelector:@selector(bootCfgPriority)] == YES){
            node->priority = [obj bootCfgPriority];
        }
        if ([(NSObject*)obj respondsToSelector:@selector(bootCfgFlags)] == YES){
            node->buildInCallerThread = ([obj bootCfgFlags] & BOOT_FLAG_THREADED) == 0;
        } else {
            node->buildInCallerThread = YES;
        }
        return key;
    }
}

-(id)add:(Class)obj withPriority:(NSInteger)pri forModes:(NSArray*)modes withSelector:(SEL)sel isStaticCall:(BOOL)isStatic inCallerThread:(BOOL)inThisThread{
    @synchronized(self){
        freeUid++;
        id key = @(freeUid);
        BootNode* node = [[[BootNode alloc] init] autorelease];
        bootNodes[key] = node;
        
        node->classToBuild = obj;
        node->modes = [modes retain];
        node->priority = pri;
        node->buildInCallerThread = inThisThread;
        node->explicitSelector = sel;
        node->isExpSelStatic = isStatic;
        return key;
    }
}

-(void)bind:(id)key withTarget:(id)target andSelector:(SEL)sel{
    @synchronized(self){
        BootNode* node = bootNodes[key];
        if (node == nil){
            NSAssert(NO, @"Uppss no node for key:%@", key);
            return;
        }
        node->externalBindTarget = target;
        node->externalBindSelector = sel;
    }
}

-(void)executeSimple:(BootNode*)node phase:(BootPhase)phase{
    if (node->simplePhase == phase){
        if (node->simpleTarget != nil){
            [node->simpleTarget performSelector:node->simpleSelector];
        } else {
            node->simpleBlock();
        }
    }

}

-(void)executeInit:(BootNode*)node getBootableAndSimple:(NSMutableArray*)sublist{

    if (node->simpleMode == YES){
        [self executeSimple:node phase:bpBootInit];
        [sublist addObject:node];
        return;
    }
    
    if ([node->classToBuild conformsToProtocol:@protocol(Bootable)] == YES){
        node->buildedObject = [[node->classToBuild alloc] init];
        [sublist addObject:node];
    } else {
        if (node->isExpSelStatic == YES){
            NSAssert(node->explicitSelector != nil, @"Static selector requested but no selector is given, for class:%@", node->classToBuild);
            Method m = class_getClassMethod(node->classToBuild, node->explicitSelector);
            char type[128];
            method_getReturnType(m, type, sizeof(type));
            if (type[0] == 'v'){
                [node->classToBuild performSelector:node->explicitSelector];
            } else {
                node->buildedObject = [[node->classToBuild performSelector:node->explicitSelector] retain];
            }
        } else {
            node->buildedObject = [[node->classToBuild alloc] init];
            if (node->explicitSelector != nil){
                [node->buildedObject performSelector:node->explicitSelector];
            }
        }
    }
    
    //bind to external
    if (node->externalBindSelector != nil){
        NSAssert(node->externalBindTarget != nil, @"Requested external bind but no target is given, for class:%@", node->classToBuild);
        if ([node->buildedObject respondsToSelector:@selector(bootObjToBind)] == YES){
            [node->externalBindTarget performSelector:node->externalBindSelector withObject:[node->buildedObject bootObjToBind]];
        } else {
            [node->externalBindTarget performSelector:node->externalBindSelector withObject:node->buildedObject];
        }
    }
}

-(void)executeList:(NSArray*)list inMode:(NSString*)mode{
    
    NSMutableArray* sublist = [NSMutableArray array];
    //init & external bind

    for(BootNode* node in list){
        ANALYZER(
            NSString* className = NSStringFromClass(node->classToBuild);
            NSThread* thread = [NSThread currentThread];
            if(node->buildInCallerThread == YES){
                [thread setName:@"InCallerThread"];
            }
            else {
                [thread setName:@"InSideThread"];
            }
            [analizer executePhaseStart:bpBootInit forKey:className  inThread:thread withPriority:node->priority];
        )//ANALYZER
        
        [self executeInit:node getBootableAndSimple:sublist];
        
        ANALYZER([analizer executePhaseEndforKey:className];)
    }

    
    //bootSetup - Bootable/Simple
    for(BootNode* node in sublist){
        ANALYZER(
            NSString* className = NSStringFromClass(node->classToBuild);
            [analizer executePhaseStart:bpBootSetup forKey:className  inThread:[NSThread currentThread] withPriority:node->priority];
        )//ANALYZER
        
        if (node->simpleMode == YES){
            [self executeSimple:node phase:bpBootSetup];
            ANALYZER([analizer executePhaseEndforKey:className];)
            continue;
        }
        if ([node->buildedObject respondsToSelector:@selector(bootSetup:)] == YES){
            [node->buildedObject bootSetup:mode];
        }
        
        ANALYZER([analizer executePhaseEndforKey:className];)
    }

    
    //bootBind - Bootable/Simple
    for(BootNode* node in sublist){
        ANALYZER(
            NSString* className = NSStringFromClass(node->classToBuild);
            [analizer executePhaseStart:bpBootBind forKey:className  inThread:[NSThread currentThread] withPriority:node->priority];
        )//ANALYZER
        if (node->simpleMode == YES){
            [self executeSimple:node phase:bpBootBind];
            ANALYZER([analizer executePhaseEndforKey:className];)
            continue;
        }
        if ([node->buildedObject respondsToSelector:@selector(bootBind:)] == YES){
            [node->buildedObject bootBind:mode];
        }
        ANALYZER([analizer executePhaseEndforKey:className];)
    }

    //bootFinalize - Bootable/Simple
    for(BootNode* node in sublist){
        ANALYZER(
            NSString* className = NSStringFromClass(node->classToBuild);
            [analizer executePhaseStart:bpBootFinalize forKey:className  inThread:[NSThread currentThread] withPriority:node->priority];
        )//ANALYZER
        if (node->simpleMode == YES){
            [self executeSimple:node phase:bpBootFinalize];
            ANALYZER([analizer executePhaseEndforKey:className];)
            continue;
        }
        if ([node->buildedObject respondsToSelector:@selector(bootFinalize:)] == YES){
            [node->buildedObject bootFinalize:mode];
        }
        ANALYZER([analizer executePhaseEndforKey:className];)
    }
    
    //boot END - Simple
    for(BootNode* node in sublist){
        ANALYZER(
            NSString* className = NSStringFromClass(node->classToBuild);
            [analizer executePhaseStart:bpBootEnd forKey:className  inThread:[NSThread currentThread] withPriority:node->priority];
        )//ANALYZER
        
        if (node->simpleMode == YES){
            [self executeSimple:node phase:bpBootEnd];
        }
        
        ANALYZER([analizer executePhaseEndforKey:className];)
    }
    ANALYZER(DDLogVerbose(@"%@", [analizer descriptionForThread:[NSThread currentThread]]);)
}

-(void)boot:(NSString*)mode{
    __block NSMutableArray* inThisThread = [NSMutableArray array];
    __block NSMutableArray* inOtherThread = [NSMutableArray array];
    //select proper nodes
    [bootNodes enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
        BootNode* node = obj;
        if ((node->modes == nil) || ([node->modes containsObject:mode] == YES)){
            if (node->buildInCallerThread == YES){
                [inThisThread addObject:obj];
            } else {
                [inOtherThread addObject:obj];
            }
        }
        *stop = NO;
    }];
    
    //sort
    NSComparator cmp = ^NSComparisonResult(id obj1, id obj2){
        BootNode* node1 = obj1;
        BootNode* node2 = obj2;
        NSInteger i = node1->priority - node2->priority;
        if (i == 0){
            return NSOrderedSame;
        } else {
            return i < 0 ? NSOrderedAscending : NSOrderedDescending;
        }
    };
    [inOtherThread sortUsingComparator:cmp];
    [inThisThread sortUsingComparator:cmp];
    
    //execute
    if ([inOtherThread count] > 0){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [inOtherThread retain];
                [self executeList:inOtherThread inMode:mode];
                [inOtherThread release];


        });
    }
    
    if ([inThisThread count] > 0){
        [self executeList:inThisThread inMode:mode];
    }
}

@end
