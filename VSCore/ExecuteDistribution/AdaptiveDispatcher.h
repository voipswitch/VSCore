//
//  AdaptiveDispatcher.h
//  Vippie
//
//  Created by Bartłomiej Żarnowski on 29.05.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <pthread.h>

@interface AdaptiveDispatcher : NSObject{
    NSMutableArray* tasks;
    BOOL scheduled;
    NSInteger totalProcessed;
    pthread_mutex_t mutex;
}

-(void)addToQueue:(NSDictionary *)info;

@end
