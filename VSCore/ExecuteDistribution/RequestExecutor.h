//
//  RequestExecutor.h
//  VSCore
//
//  Created by Bartłomiej Żarnowski on 30.10.2012.
//  Copyright (c) 2012 Bartłomiej Żarnowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QueuedRequest;
@protocol RequestExecutor <NSObject>

-(void)processRequest:(QueuedRequest*)req;
@end
