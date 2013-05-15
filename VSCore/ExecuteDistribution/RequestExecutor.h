//
//  RequestExecutor.h
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski on 30.10.2012.
//

#import <Foundation/Foundation.h>

@class QueuedRequest;
@protocol RequestExecutor <NSObject>

-(void)processRequest:(QueuedRequest*)req;
@end
