//
//  DDCustomFileLogger.m
//  VSCore
//
//  Created by Marek Kotewicz on 3/27/13.
//  Copyright (c) 2013 Bartłomiej Żarnowski. All rights reserved.
//

#import "DDCustomFileLogger.h"
#import <libkern/OSAtomic.h>
#import <Foundation/Foundation.h>

@implementation DDCustomFileLogger

- (void)logMessage:(DDLogMessage *)logMessage
{
    NSString *logMsg = logMessage->logMsg;
    if (formatter){
        logMsg = [formatter formatLogMessage:logMessage];
	}
	if (logMsg)
	{
        NSInteger myLvl = 0;
        switch(logMessage->logFlag){
            case 1: //error
                myLvl = 3; //syslog error
                break;
                
            case 2: //warning
                myLvl = 4; //syslog warning
                break;
                
            case 4: //info
                myLvl = 6;  //syslog info
                break;
                
            case 8: //verbose
                myLvl = 7;  //syslog debug
                break;
                
        }
        NSString* s = [NSString stringWithFormat:@"<%d> %@", myLvl, logMsg];
        
        // self->currentLogFileHandle moze byc nullem
        NSFileHandle *fileHandle = [super performSelector:@selector(currentLogFileHandle)];
       
        
        void *output = [self crypto:s moveNumber:5];
        [fileHandle writeData:[NSData dataWithBytes:output length:[s length]]];
		[super performSelector:@selector(maybeRollLogFileDueToSize)];
        
        /**test */
//        NSString *testString = [[[NSString alloc] initWithBytes:output length:[s lengthOfBytesUsingEncoding:NSUTF8StringEncoding] encoding:NSUTF8StringEncoding] autorelease];
//        void *testOutput = [self crypto:testString moveNumber:-5];
//        NSString *tString = [[[NSString alloc] initWithBytes:testOutput length:[s lengthOfBytesUsingEncoding:NSUTF8StringEncoding] encoding:NSUTF8StringEncoding] autorelease];
//        NSLog(@"after: %@", tString);
//        free(testOutput);
        free(output);
	}
}

- (NSString *)loggerName
{
	return @"voipswitch.vscore.cryptofileLogger";
}

- (void*)crypto:(NSString*)string moveNumber:(NSInteger)moveNumber{    
    size_t length = [string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    char *output = (char *)malloc(length);
    const char *input = [string UTF8String];
    for (unsigned i = 0; i < length; i++){
        if (input[i] + moveNumber > 255){
            output[i] = 0 + (255 - input[i]);
        } else if (input[i] + moveNumber < 0){      // if move number < 0
            output[i] = 255 - (-moveNumber - input[i]);
        } else {
            output[i] = (input[i] + moveNumber);
        }
    }
    return output;    
}

@end
