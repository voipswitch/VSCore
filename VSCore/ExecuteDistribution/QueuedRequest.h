//
//  QueuedRequest.h
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski on 30.10.2012.
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
