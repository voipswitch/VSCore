//
//  DDCustomFileLoggerTests.m
//  VSCore
//
//  Created by Marek Kotewicz on 3/27/13.
//  Copyright (c) 2013 Bartłomiej Żarnowski. All rights reserved.
//

#import "DDCustomFileLoggerTests.h"
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
#import "DDCustomFileLogger.h"

@implementation DDCustomFileLoggerTests

- (void)setUp{
    [super setUp];
}

- (void)tearDown{
    [super tearDown];
}

- (void)test1{
    DDFileLogger *customFileLogger = [[[DDCustomFileLogger alloc] init] autorelease];
    customFileLogger.rollingFrequency = 60 * 60 * 24;
    customFileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger: customFileLogger];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    DDLogError(@"Broken sprocket detected!");
    char a = 0;
    char b = 12;
    char c = 14;
    char d = 120;
    char e = 257;
    //char e = 257;
    
    NSString *st = [NSString stringWithFormat:@"asasa: %c  %c %c %c %c kon", a, b, c, d, e];
    DDLogError(@"%@", st);
    NSString *asas = [NSString stringWithFormat:@"asa"];
    DDLogError(@"%@", asas);
    DDLogError(@"User selected file:%@ withSize:%@", @"filePath", @"fileSize");
    DDLogError(@"%@", asas);
    DDLogError(@"%@asasas", asas);
    DDLogError(@"blblbl");
}

@end
