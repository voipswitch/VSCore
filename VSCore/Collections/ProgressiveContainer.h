//
//  ProgressiveContainer.h
//  Join
//
//  Created by Bartlomiej Zarnowski on 1/15/12.
//  Copyright (c) 2012 Voipswitch. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Introduces interface for collection which allows loading data by fixed portions (pages). It
 * will probably work on some not-public source which allows loading next portions of data.
 */
@protocol ProgressiveContainer <NSObject>
/**
 * Checks if undelying source has more data than it's loaded at this moment. 
 * @return YES if more data may be loaded.
 * @see loadMore
 */
-(BOOL)moreCanBeLoaded;

/**
 * Requests loading biger part of data into memory.
 * @see moreCanBeLoaded 
 */
-(void)loadMore;

/**
 * Request loading of all data from source into memory
 */
-(void)loadAll;

/**
 * Request removal of all loaded data from memory.
 */
-(void)unloadAll;

@optional
-(NSInteger)count;
-(id)objectAtIndex:(NSInteger)index;
-(void)removeObjectAtIndex:(NSInteger)index;
-(void)removeObject:(id)object;
-(void)addObject:(id)object;
-(void)removeAll;
-(void)filterUsingPredicate:(NSPredicate*)pred;
@end
