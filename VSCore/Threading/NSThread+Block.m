//
//  NSThread+Block.m
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski [Toster] on 10.04.2013.
//

#import "NSThread+Block.h"

//Taken from: http://objcolumnist.com/2011/05/03/performing-a-block-of-code-on-a-given-thread/

@implementation NSThread (Block)

+ (void)MCSM_performBlockOnMainThread:(void (^)())block{
	[[NSThread mainThread] MCSM_performBlock:block];
}

+ (void)MCSM_performBlockInBackground:(void (^)())block{
	[NSThread performSelectorInBackground:@selector(MCSM_runBlock:)
                               withObject:[[block copy] autorelease]];
}

+ (void)MCSM_runBlock:(void (^)())block{
	block();
}


- (void)MCSM_performBlock:(void (^)())block{
    
	if ([[NSThread currentThread] isEqual:self])
        block();
	else
        [self MCSM_performBlock:block waitUntilDone:NO];
}
- (void)MCSM_performBlock:(void (^)())block waitUntilDone:(BOOL)wait{
    
	[NSThread performSelector:@selector(MCSM_runBlock:)
					 onThread:self
				   withObject:[[block copy] autorelease]
				waitUntilDone:wait];
}

- (void)MCSM_performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay{
    
	[self performSelector:@selector(MCSM_performBlock:)
			   withObject:[[block copy] autorelease]
               afterDelay:delay];
}

@end
