//
//  AdaptiveExecutor.h
//  VSCore
//
//  Created by Bartłomiej Żarnowski on 30.10.2012.
//  Copyright (c) 2012 Bartłomiej Żarnowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <pthread.h>

@protocol RequestExecutor;
@protocol UnivListener;
@class QueuedRequest;

@interface AdaptiveExecutor : NSObject{
    NSMutableDictionary* registeredExecutors;
    NSMutableArray* requestsToExecute;
    BOOL scheduled;
    pthread_mutex_t mutex;
    NSThread* execThread;
}
@property (nonatomic, retain) NSThread* execThread;
-(void)registerRequestExecutor:(id<RequestExecutor>)ex forUidSchema:(NSURL*)schema;
-(void)unregisterRequestExecutor:(NSURL*)schema;

+(void)registerRequestExecutor:(id<RequestExecutor>)ex forUidSchema:(NSURL*)schema;
+(void)unregisterRequestExecutor:(NSURL*)schema;


//type of operation, and uids/params required to do it, should be encoded in URL
+(void)execute:(NSURL*)reqUid withListener:(id<UnivListener>)listener andContext:(id)context;
-(void)execute:(NSURL*)reqUid withListener:(id<UnivListener>)listener andContext:(id)context;

+(void)delayRequest:(QueuedRequest*)request;
-(void)delayRequest:(QueuedRequest*)request;
@end
