//
//  EventLogger.m
//  VSCore
//
//  Created by Bartłomiej Żarnowski [Toster] on 07.10.2013.
//  Copyright (c) 2013 Bartłomiej Żarnowski. All rights reserved.
//

#import "EventLogger.h"
#import "CommonDefines.h"

@interface EventLoggerItem : NSObject
@property (nonatomic, assign) double timestamp;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSDictionary* data;
@end

@implementation EventLoggerItem
+(EventLoggerItem*)event:(NSString*)name withData:(NSDictionary*)data{
    EventLoggerItem* item = [[[EventLoggerItem alloc] init] autorelease];
    item.name = name;
    item.data = data;
    item.timestamp = [[NSDate date] timeIntervalSince1970];
    return item;
}

-(void)dealloc{
    releaseAndNil(_name);
    releaseAndNil(_data);
    [super dealloc];
}
@end

@implementation EventLogger

-(id)init{
    self = [super init];
    if (self != nil){
        pool = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)dealloc{
    releaseAndNil(pool);
    [super dealloc];
}

-(void)clear{
    [pool removeAllObjects];
}

-(void)addEvent:(NSString*)name{
    [self addEvent:name withData:nil];
}

-(void)addEvent:(NSString*)name withData:(NSDictionary*)data{
    EventLoggerItem* item = [EventLoggerItem event:name withData:data];
    [pool addObject:item];
    if ((self.poolSize > 0) &&([pool count] > self.poolSize)){
        [pool removeObjectAtIndex:0];
    }
}

-(NSString*)dumpAsPlainText{
    if ([pool count] == 0){
        return @"";
    }
    
    NSMutableString* result = [NSMutableString string];
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateStyle:kCFDateFormatterNoStyle];
    [df setTimeStyle:kCFDateFormatterLongStyle];
    
    double last = ((EventLoggerItem*)pool[0]).timestamp;
    for(EventLoggerItem* item in pool){
        [result appendFormat:@"%@: (%d ms) %@ %@\n", [df stringFromDate:[NSDate dateWithTimeIntervalSince1970:item.timestamp]],
            (NSInteger)(item.timestamp - last) * 100, item.name, item.data == nil ? @"" : item.data];
        last = item.timestamp;
    }
    releaseAndNil(df);
    return result;
}

-(NSString*)parseData:(NSDictionary*)data{
    NSMutableString* result = [NSMutableString string];
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSArray class]] == YES) {
            [result appendFormat:@"%@=[", key];
            for(id val in obj){
                [result appendFormat:@"%@,\\n", val];
            }
            [result appendString:@"]\\n"];
        } else if ([obj isKindOfClass:[NSDictionary class]] == YES) {
            [result appendFormat:@"%@={%@}\\n", key, [self parseData:obj]];
            
        } else {
            NSString* s = [[obj description] stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
            [result appendFormat:@"%@=%@\\n", key, s];
        }
    }];
    return result;
}

-(NSString*)dumpAsDOT{
    if ([pool count] == 0){
        return @"";
    }
    NSMutableString* result = [NSMutableString stringWithString:@"digraph {"];
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateStyle:kCFDateFormatterNoStyle];
    [df setTimeStyle:kCFDateFormatterLongStyle];
    
    NSInteger index = 0;
    for(EventLoggerItem* item in pool){
        if (item.data == nil){
            [result appendFormat:@"a%d [label=\"%@\" shape=box];", index, item.name];
        } else {
            [result appendFormat:@"a%d [shape=box label=\"%@\\n%@\"];", index, item.name, [self parseData:item.data]];
        }
        index++;
    }
    [result appendString:@"\n"];
    
    for(index =0; index < [pool count]-1; index++){
        double t0 = ((EventLoggerItem*)pool[index]).timestamp;
        double t1 = ((EventLoggerItem*)pool[index+1]).timestamp;
        [result appendFormat:@"a%d->a%d [label=\"%d ms\"];", index, index+1,(NSInteger)(t1-t0) * 100];
    }
    releaseAndNil(df);
    [result appendString:@"}"];
    return result;
}

-(void)dumpAsDOTToConsole{
    DDLogInfo(@"%@", [self dumpAsDOT]);
}

-(void)dumpAsPlainTextToConsole{
    DDLogInfo(@"%@", [self dumpAsPlainText]);
}

@end
