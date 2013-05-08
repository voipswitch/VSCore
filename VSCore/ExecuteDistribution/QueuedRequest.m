//
//  QueuedRequest.m
//  VSCore
//
//  Created by Bartłomiej Żarnowski on 30.10.2012.
//  Copyright (c) 2012 Bartłomiej Żarnowski. All rights reserved.
//

#import "CommonDefines.h"
#import "QueuedRequest.h"

@implementation QueuedRequest

-(void)dealloc{
    releaseAndNil(uid);
    releaseAndNil(context);
    releaseAndNil(dataToDeliver);
    
    [super dealloc];
}

@end
