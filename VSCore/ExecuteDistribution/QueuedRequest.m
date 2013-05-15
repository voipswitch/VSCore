//
//  QueuedRequest.m
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski on 30.10.2012.
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
