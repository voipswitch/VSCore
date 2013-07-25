//
//  AdaptiveExecutor.m
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski on 30.10.2012.
//

#import "AdaptiveExecutor.h"
#import "CommonDefines.h"
#import "QueuedRequest.h"
#import "UnivListener.h"
#import "RequestExecutor.h"
#import "RunLoopingThread.h"

#define MAX_EXEC_TIME 0.3
#define DELAY_EXEC_TIME 0.2

static AdaptiveExecutor* masterExecutor;

@implementation AdaptiveExecutor
@synthesize execThread;

+(void)initialize{
    masterExecutor = [[AdaptiveExecutor alloc] init];
    masterExecutor.execThread = [[[RunLoopingThread alloc] init] autorelease];
    [masterExecutor.execThread setName:@"AdaptiveExecutor-main"];
    [masterExecutor.execThread start];
}

-(id)init{
    self = [super init];
    if (self != nil){
        registeredExecutors = [[NSMutableDictionary alloc] init];
        requestsToExecute = [[NSMutableArray alloc] init];
        pthread_mutex_init(&mutex, NULL);
    }
    return self;
}

-(void)dealloc{
    releaseAndNil(registeredExecutors);
    releaseAndNil(requestsToExecute);
    releaseAndNil(execThread);
    pthread_mutex_destroy(&mutex);
    [super dealloc];
}

-(void)registerRequestExecutor:(id<RequestExecutor>)ex forUidSchema:(NSURL*)schema{
    NSAssert( [registeredExecutors objectForKey:[schema scheme]] == nil, @"Executor for schema %@ already exists", schema);
    [registeredExecutors setObject:ex forKey:[schema scheme]];
    DDLogInfo(@"Registering request extcutor %@ for scheme:%@", ex, [schema scheme]);
}

-(void)unregisterRequestExecutor:(NSURL*)schema{
    [registeredExecutors removeObjectForKey:[schema scheme]];
    DDLogInfo(@"Unregistering request extcutor scheme:%@", [schema scheme]);
}

-(void)privateExecute{
    NSAssert(scheduled == YES, @"scheduled must be YES here");
    
    NSAssert(execThread == nil || [[NSThread currentThread] isEqual: execThread] == YES, @"Wrong thread!");
    
    NSDate* now = [NSDate date];
    NSInteger processed = 0;
    while( [[NSDate date] timeIntervalSinceDate:now] < MAX_EXEC_TIME ){
        QueuedRequest* task;
        pthread_mutex_lock(&mutex);
        if ([requestsToExecute count] == 0){
            scheduled = NO;
            pthread_mutex_unlock(&mutex);
            return;
        }
        task = [[requestsToExecute objectAtIndex:0] retain];
        [requestsToExecute removeObjectAtIndex:0];
        pthread_mutex_unlock(&mutex);
        
        //if no executor so just return error that request can't be executed
        if (task->executor == nil){
            [self performSelector:@selector(noExecutor)
                         onThread:task->callThread
                       withObject:task
                    waitUntilDone:NO];
        } else {
            [task->executor processRequest:task];
        }
        
        [task release];
        processed++;
    }
    
    //check if we should reschedule ?
    pthread_mutex_lock(&mutex);
    if ([requestsToExecute count] == 0){
        scheduled = NO;
        pthread_mutex_unlock(&mutex);
        return;
    }
    if (execThread == nil){
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, DELAY_EXEC_TIME * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [NSThread detachNewThreadSelector:@selector( privateExecute ) toTarget:self withObject:nil];
        });
    } else {
        [self performSelector:@selector( privateExecute ) withObject:nil afterDelay:DELAY_EXEC_TIME];
    }
    
    pthread_mutex_unlock(&mutex);
}

-(void)noExecutor:(QueuedRequest*)req{
    NSError* err = [NSError errorWithDomain:@"No executor for request" code:0 userInfo:nil];
    [req->listener onRequestProccessed:req->uid withResult:nil andContext:req->context andError:err];
}

-(void)execute:(NSURL*)reqUid withListener:(id<UnivListener>)listener andContext:(id)context{
    QueuedRequest* req = [[[QueuedRequest alloc] init] autorelease];
    req->uid = [reqUid retain];
    req->context = [context retain];
    req->callThread = [NSThread currentThread]; //weak ref
    req->listener = listener;   //weak ref
    req->executor = [registeredExecutors objectForKey:[reqUid scheme]];
    
    pthread_mutex_lock(&mutex);
    [requestsToExecute addObject:req];
    if (scheduled == NO){
        scheduled = YES;
        if (execThread == nil){
            [NSThread detachNewThreadSelector:@selector( privateExecute ) toTarget:self withObject:nil];
        } else {
            [self performSelector:@selector( privateExecute ) onThread:execThread withObject:nil waitUntilDone:NO];
        }
    }
    pthread_mutex_unlock(&mutex);
}

+(void)execute:(NSURL*)reqUid withListener:(id<UnivListener>)listener andContext:(id)context{
    [masterExecutor execute:reqUid withListener:listener andContext:context];
}

+(void)registerRequestExecutor:(id<RequestExecutor>)ex forUidSchema:(NSURL*)schema{
    [masterExecutor registerRequestExecutor:ex forUidSchema:schema];
}

+(void)unregisterRequestExecutor:(NSURL*)schema{
    [masterExecutor unregisterRequestExecutor:schema];
}
-(void)delayRequest:(QueuedRequest*)request{
    [requestsToExecute addObject:request];
}
+(void)delayRequest:(QueuedRequest*)request{
    [masterExecutor delayRequest:request];
}

@end
