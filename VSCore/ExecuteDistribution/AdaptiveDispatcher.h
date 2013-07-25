//
//  AdaptiveDispatcher.h
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski on 29.05.2012.
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
