//
//  BootLoader+Askable.m
//  VSCore
//
//  Created by Bartłomiej Żarnowski [Toster] on 16.05.2013.
//  Copyright (c) 2013 Bartłomiej Żarnowski. All rights reserved.
//

#import "BootLoader+Askable.h"
#import "Askable.h"
#import "CommonDefines.h"

@interface BootLoaderBindBridge : NSObject{
    @public
    NSString* askableKey;
}

@end

@implementation BootLoaderBindBridge

-(void)dealloc{
    releaseAndNil(askableKey);
    [super dealloc];
}

-(void)bindToAskable:(id)objToBind{
    [Askable registerConstValue:objToBind forKey:askableKey];
}

@end

@implementation BootLoader (Askable)

-(void)bind:(id)key intoAskable:(NSString*)askableKey{
    BootLoaderBindBridge* bridge = [[[BootLoaderBindBridge alloc] init] autorelease];
    bridge->askableKey = [askableKey retain];
    [self bind:key withTarget:bridge andSelector:@selector(bindToAskable:)];
}

@end
