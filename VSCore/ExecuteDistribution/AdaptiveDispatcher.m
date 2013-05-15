//
//  AdaptiveDispatcher.m
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski on 29.05.2012.
//

#import "AdaptiveDispatcher.h"
#import "CommonDefines.h"

#define MAX_EXEC_TIME 0.3
#define DELAY_EXEC_TIME 0.2

@implementation AdaptiveDispatcher
-(id)init{
    self = [super init];
    if (self != nil){
        tasks = [[NSMutableArray alloc] init];
        pthread_mutex_init(&mutex, NULL);
    }
    return self;
}

-(void)dealloc{
    releaseAndNil(tasks);

    pthread_mutex_destroy(&mutex);
    [super dealloc];
}

-(void)addToQueue:(NSDictionary *)info{
    pthread_mutex_lock(&mutex);
        [tasks addObject:info];
        if (scheduled == NO){
            scheduled = YES;
            [self performSelectorOnMainThread:@selector( execute ) withObject:nil waitUntilDone:NO];
        }
    pthread_mutex_unlock(&mutex);
}

-(void)execute{
    NSAssert(scheduled == YES, @"scheduled must be YES here");
    NSAssert([NSThread isMainThread] == YES, @"execute must be in main thread!");
    
    NSDate* now = [NSDate date];
    NSInteger processed = 0;
    NSMutableString* tasksNames = [NSMutableString string];
    while( [[NSDate date] timeIntervalSinceDate:now] < MAX_EXEC_TIME ){
        NSDictionary* task;
        pthread_mutex_lock(&mutex);
            if ([tasks count] == 0){
                scheduled = NO;
//                DDLogVerbose(@"Exec loop done[1], processed:%d/%d, exec time:%f",
//                      processed, totalProcessed, [[NSDate date] timeIntervalSinceDate:now]);
                pthread_mutex_unlock(&mutex);
                return;
            }
            task = [[tasks objectAtIndex:0] retain];
            [tasks removeObjectAtIndex:0];
        pthread_mutex_unlock(&mutex);
        
        NSString *name = [task objectForKey:@"name"];
        id object = [task objectForKey:@"object"];
        NSDictionary *userInfo = [task objectForKey:@"userInfo"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:name object:object userInfo:userInfo];
        [tasksNames appendString:name];
        [tasksNames appendString:@","];
        [task release];
        processed++;
        totalProcessed++;
    }
    
    //check if we should reschedule ?
    pthread_mutex_lock(&mutex);
//        DDLogVerbose(@"Exec loop took: %f, processed:%d/%d, tasks to go: %d, tasks:%@",
//              [[NSDate date] timeIntervalSinceDate:now], processed, totalProcessed, [tasks count], tasksNames);
        if ([tasks count] == 0){
            scheduled = NO;
//            DDLogVerbose(@"Exec loop done[2], processed:%d/%d, exec time:%f", 
//                  processed, totalProcessed, [[NSDate date] timeIntervalSinceDate:now]);
            pthread_mutex_unlock(&mutex);
            return;
        }
        [self performSelector:@selector(execute) withObject:nil afterDelay:DELAY_EXEC_TIME];
    pthread_mutex_unlock(&mutex);
}

@end
