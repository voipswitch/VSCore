//
//  EventLogger.h
//  VSCore
//
//  Created by Bartłomiej Żarnowski [Toster] on 07.10.2013.
//  Copyright (c) 2013 Bartłomiej Żarnowski. All rights reserved.
//

#import <Foundation/Foundation.h>

//WARNING: This is not thread safe!
@interface EventLogger : NSObject{
    NSMutableArray* pool;
}

/** Maximum size of logging pool, if 0 then pool is infinite */
@property (nonatomic, assign) NSInteger poolSize;

/** Remove all events from pool */
-(void)clear;

/** Add new named event 
 * @param name of event
 */
-(void)addEvent:(NSString*)name;

/** Add new named event with extra data
 * @param name of event
 * @param data specific for event
 */
-(void)addEvent:(NSString*)name withData:(NSDictionary*)data;

/**
 * Process all stored events and dump it as a list.
 * @return log of events in human readable form
 */
-(NSString*)dumpAsPlainText;

/**
 * Process all stored events and dump it in form of graph. You can then
 * visualize this graph by any DOT language parser (eg. http://hughesbennett.co.uk/Graphviz 
 * or http://rise4fun.com/agl )
 * @return string in DOT language format
 */
-(NSString*)dumpAsDOT;

/**
 * Puts log from {@link #dumpAsDOT} into console.
 */
-(void)dumpAsDOTToConsole;
/**
 * Puts log from {@link #dumpAsPlainText} into console.
 */
-(void)dumpAsPlainTextToConsole;
@end
