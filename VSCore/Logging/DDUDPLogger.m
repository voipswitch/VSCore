//
//  DDUDPLogger.m
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski on 19.03.2012.
//

#import "DDUDPLogger.h"

@implementation DDUDPLogger

- (id)initWithHost:(NSString*)host andPort:(NSInteger)port
{
	if ((self = [super init]))
	{
		sock = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        dateFrm = [[NSDateFormatter alloc] init];
        [dateFrm setDateFormat:@"MMM dd, yyyy HH:mm:ss"];
        NSError* error = nil;
        [sock connectToHost:host onPort:port error:&error];
        if (error != nil){
            NSLog(@"DDUDPLogger error on connect: %@", error);
        }
	}
	return self;
}

- (void)logMessage:(DDLogMessage *)logMessage
{
	NSString *logMsg = logMessage->logMsg;
	
	if (formatter)
	{
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
        NSString* s = [NSString stringWithFormat:@"<%d>%@ %@", myLvl, logMessage->timestamp, logMsg];
		const char *msg = [s UTF8String];
        
        [sock sendData:[NSData dataWithBytes:msg length:strlen(msg)] withTimeout:-1.0 tag:0];
	}
}

- (NSString *)loggerName
{
	return @"cocoa.lumberjack.UDPLogger";
}

/* Just for deep debug
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address{
    NSLog(@"didConnectToAddress");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error{
    NSLog(@"didNotConnect:%@", error);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    NSLog(@"didSendDataWithTag");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
    NSLog(@"didNotSendDataWithTag:%@", error);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext{
    NSLog(@"didReceiveData");
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error{
    NSLog(@"udpSocketDidClose:%@",error);
}
*/
@end
