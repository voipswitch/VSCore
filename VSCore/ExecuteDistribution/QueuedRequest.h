//
//  QueuedRequest.h
//  VSCore
//
//  Created by Bartłomiej Żarnowski on 30.10.2012.
//  Copyright (c) 2012 Bartłomiej Żarnowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UnivListener;
@protocol RequestExecutor;

@interface QueuedRequest : NSObject{
@public
    NSURL* uid;
    id<UnivListener> listener;      //weak ref!
    id context;
    
    NSThread* callThread;           //weak ref!
    id<RequestExecutor> executor;   //weak ref!
    id dataToDeliver;
}

@end
