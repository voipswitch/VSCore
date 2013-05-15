//
//  MainSipThread.h
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartlomiej Klin on 02.08.2012.
//
//

#import <Foundation/Foundation.h>

@interface RunLoopingThread : NSThread
{
    BOOL quit;
    NSRunLoop *threadLoop;
}
@property (assign) BOOL quit;

- (void)addTimer:(NSTimer*)t;
- (void)cancelPerformSelector:(SEL)aSelector target:(id)target argument:(id)anArgument;
- (void)cancelPerformSelectorsWithTarget:(id)target;
- (CFRunLoopRef)getCFRunLoop;
- (NSRunLoop *)getRunLoop;
@end
