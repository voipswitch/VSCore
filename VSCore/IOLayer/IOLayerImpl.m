//
//  IOLayerImpl.m
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski on 24.08.2012.
//
//

#import "IOLayerImpl.h"

@implementation IOLayerImpl
@synthesize inputParser, sender, inSink;

-(id)init{
    self = [super init];
    if (self != nil){
        chains = [[NSMutableDictionary alloc] init];
        inModules = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)dealloc{
    [chains release]; chains = nil;
    [inModules release]; inModules = nil;
    self.inputParser = nil;
    self.sender = nil;
    [super dealloc];
}

- (void) addInModule:(id<IOInModule>)inModule{
    if ([inModules containsObject:inModule] == NO){
        [inModules addObject:inModule];
        [inModules sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            id<IOInModule> mod1 = obj1;
            id<IOInModule> mod2 = obj2;
            NSInteger dif = mod1.priority - mod2.priority;
            return  dif == 0 ? NSOrderedSame : ( (dif < 0) ? NSOrderedAscending : NSOrderedDescending);
        }];
    }
    
    //use only for debug, when you need to verify inModules order
//    NSInteger index = 0;
//    DDLogVerbose(@"Current order of "in modules" on IOLayer");
//    for(id<IOInModule> m in inModules){
//        DDLogVerbose(@"%d: priority:%d class:%@", index, m.priority, NSStringFromClass([m class]));
//        index++;
//    }
}

- (void) addOutChain:(NSArray*)chain withId:(NSString*)chainId{
    [chains setObject:chain forKey:chainId];
}

- (void) processInMessage:(NSString*)msg context:(NSMutableDictionary*)context{
    NSArray* a = [inputParser parseInMessage:msg];
    if (a == nil){
        return;
    }
    
    NSMutableDictionary *commonDict = [NSMutableDictionary dictionary];
    [context setObject:commonDict forKey:CONTEXT_COMMON_PART];

//    BOOL anyPartProcessed = NO;
    for(NSObject* s in a){
        NSMutableDictionary* tmpContext = [NSMutableDictionary dictionaryWithDictionary:context];
        BOOL processed = NO;
        for(id<IOInModule> mod in inModules){
            processed = [mod processIn:s context:tmpContext ioLayer:self];
            if (processed == YES){
//                anyPartProcessed = YES;
                break;
            }
        }
        if (processed == NO){
            NSLog(@"Unsupported message control word:'%@', ignored", s);
        }
    }
}

- (void)sendMessage:(NSString*)msg withContext:(NSMutableDictionary*)context{
    NSString* chainId = [context objectForKey:CONTEXT_CHAIN_ID];
    if (chainId != nil){
        NSArray* chain = [chains objectForKey:chainId];
        NSAssert(chain != nil, @"Unknown chain: %@", chainId);
        for(id<IOOutModule> mod in chain){
            msg = [mod processOut:msg context:context];
        }
    }
    [sender ioSend:msg withContext:context];
}

@end
