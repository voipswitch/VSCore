//
//  LumberjackBridge.m
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski on 16.03.2012.
//

#import "LumberjackBridge.h"
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
#import "DDFileLogger.h"
#import "DDUDPLogger.h"
#import "DDCustomFileLogger.h"

//setup this values to your machine if you want to recieve logs via net udp.
#define LOG_SERVER_HOST @"localhost"
#define LOG_SERVER_PORT 514

//NOTICE: to setup logging level please go to pch file.

@implementation LumberjackBridge

+(void)setupInRelease{
    [DDLog addLogger:[DDASLLogger sharedInstance]];
}

+(void)setupInDebug:(NSInteger)flags{
    if ((flags & LJB_CONSOLE) != 0){
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
    }
    
    if ((flags & LJB_APPLE_SYSTEM_LOGGER) != 0){
        [DDLog addLogger:[DDASLLogger sharedInstance]];
    }
    
    if ((flags & LJB_FILE) != 0){
        DDFileLogger* fileLogger = [[[DDFileLogger alloc] init] autorelease];
        fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
        
        [DDLog addLogger:fileLogger];
    }
    
    if ((flags & LJB_LIVE_NETWORK) != 0){
        DDUDPLogger* udpLogger = [[[DDUDPLogger alloc] initWithHost:LOG_SERVER_HOST andPort:LOG_SERVER_PORT] autorelease];
        [DDLog addLogger:udpLogger];
    }
    
    if ((flags & LJB_CUSTOM_FILE_LOGGER) != 0){
        DDCustomFileLogger *customFileLogger = [[DDCustomFileLogger alloc] init];
        customFileLogger.rollingFrequency = 60 * 60 * 24;
        customFileLogger.logFileManager.maximumNumberOfLogFiles = 7;
        [DDLog addLogger:customFileLogger];
    }
}

+(void)setupLogger:(NSInteger)flags{

#ifdef DEBUG
    [LumberjackBridge setupInDebug:flags];
#else
    [LumberjackBridge setupInRelease];
#endif
}

@end
