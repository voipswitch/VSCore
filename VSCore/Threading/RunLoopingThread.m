//
//  MainSipThread.m
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartlomiej Klin on 02.08.2012.
//
//

#import "RunLoopingThread.h"
#import <pthread.h>
#import "CommonDefines.h"

@implementation RunLoopingThread
@synthesize quit;
-(id)init
{
    self=[super init];
    if(self!=nil)
    {
        quit=NO;
    }
    return self;
}

-(void)addTimer:(NSTimer*)t
{
    [threadLoop addTimer:t forMode: NSDefaultRunLoopMode];
}

- (void)cancelPerformSelector:(SEL)aSelector target:(id)target argument:(id)anArgument
{
    [threadLoop cancelPerformSelector:aSelector target:target argument:anArgument];
}

- (void)cancelPerformSelectorsWithTarget:(id)target
{
    [threadLoop cancelPerformSelectorsWithTarget:target];
}

- (CFRunLoopRef)getCFRunLoop{
    return [threadLoop getCFRunLoop];
}
- (NSRunLoop *)getRunLoop{
    return threadLoop;
}
-(void)main
{
    DDLogVerbose(@"main running %@",[self name]);
    
    if([self name]!=nil && ![[self name] isEqualToString:@""])
    {
        pthread_setname_np([self.name UTF8String]);
    }
    
    CFRunLoopSourceContext context = {0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL};
	CFRunLoopSourceRef source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
	CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
    
    threadLoop = [NSRunLoop currentRunLoop];
    
	while (!quit) {
        @try{
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            CFRunLoopRun();
            [pool drain];
        } @catch (NSException* exception) {
            NSLog(@"Uncaught exception[Thread:%@]: %@", self.name, exception.description);
            NSLog(@"Stack trace: %@", [exception callStackSymbols]);
        }
	}// Should never be called, but anyway
	CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
	SafeCFRelease(source);
    
    DDLogVerbose(@"main exiting %@",[self name]);
}
@end
