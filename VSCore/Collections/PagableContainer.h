//
//  PagableContainer.h
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartlomiej Zarnowski on 1/7/12.
//

#import <Foundation/Foundation.h>

/**
 * This protocol is designed to present functionality which exposes random access collection with
 * pagination behavior. It allows to access any item in array, however switching betwean pages and
 * reading portion of data is considered as desired functionality.
 */
@protocol PagableContainer <NSObject>

#pragma mark -
#pragma mark handling of objects in whole collection
/**
 * Total size of whole collection.
 * @return size of collection.
 */
-(NSInteger)count;

/**
 * Returns element with given global index. If index is out of bounds exception should be raised.
 * @param index of object to retrieve
 * @return object on given index
 */
-(id)objectAtIndex:(NSInteger)index;

/**
 * Removes element from collection, given index is global index.
 * If index is out of bounds exception should be raised.
 * @param index of object to be deleted
 */
-(void)removeObjectAtIndex:(NSInteger)index;

/**
 * Removes object from collection. If object is not found, method will perform silent leave
 * @param object to be deleted
 */
-(void)removeObject:(id)object;

/**
 * Adds new element to end of this collection.
 * @param object to be added
 * @return global object index 
 */
-(void)addObject:(id)object;

#pragma mark -
#pragma mark handling of objects in current page
/**
 * Returns count of elements loaded in current page.
 * @return count of elements in this page.
 */
-(NSInteger)inPageCount;

/**
 * Returns count of elements loaded for given page. 
 * @param pageNo index of page to check count.
 * @return count of elements in page.
 */
-(NSInteger)inPageCount:(NSInteger)pageNo;

/**
 * Returns element with given index (this is in page index, not global index). If index is out of bounds
 * exception should be raised.
 * @param index of object to retrieve
 * @return object on given index
 */
-(id)inPageObjectAtIndex:(NSInteger)index;

/**
 * Removes element from collection, given index is in page range (not global index).
 * If index is out of bounds exception should be raised.
 * @param index of object to be deleted
 */
-(void)inPageRemoveObjectAtIndex:(NSInteger)index;

/**
 * Adds new element to end of this page.
 * @param object to be added
 * @return object index on this page
 */
-(NSInteger)inPageAddObject:(id)object;

/**
 * Returns index offset for this page from begining of collection. This value is equal to global index for 
 * first object from this page.
 * @return offset from begining of collection to first element on this page.
 */
-(NSInteger)pageIndexOffset;

/**
 * Returns index offset for given page from begining of collection. This value is equal to global index for 
 * first object from given page.
 * @param pageNo indwex of page to which offset should be counted
 * @return offset from begining of collection to first element on this page.
 */
-(NSInteger)pageIndexOffset:(NSInteger)pageNo;

/**
 * Tries to locate object on this page. If not found then NSNotFound is returned, otherwise
 * index in whole collection is returned. It may be use to determine offset from 0 index of collection.
 * @param object which should be found, isEqual will be used to determine equality.
 * @return index from begining of collection or NSNotFound
 */
-(NSInteger)globalIndexFor:(id)object;

/**
 * Clears whole collection.
 */
-(void)removeAll;

#pragma mark -
#pragma mark navigations betwean pages
/**
 * @return index of current page
 */
-(NSInteger)currentPageIndex;

/**
 * @return count of all pages
 */
-(NSInteger)pagesCount;

/**
 * Tries to swich to next page, it will load all objects which should be accessible on next page.
 * If there is no new page, method will perform silent leave.
 * @return index of page on which collection is set.
 */
-(NSInteger)nextPage;

/**
 * Tries to swich to prev page, it will load all objects which should be accessible on next page.
 * If there is no prev page, method will perform silent leave.
 * @return index of page on which collection is set.
 */
-(NSInteger)prevPage;

/**
 * Tries to move directly to given page. If there is no page with given index method will perform silent leave,
 * with no change of containter.
 * @param pageNo index of new page to which collection should switch
 * @return index of page on which collection is set.
 */
-(NSInteger)gotoPage:(NSInteger)pageNo;

- (NSInteger)goOutOfPage:(NSInteger)pageNo;

@optional
/**
 * Check if page with given number is loaded into memory. This is not mandatory requirement for implementator
 * to partialy hold pages in memory. It's up to implementing class how it deals with memory.<BR>
 * NOTE: Accessing items on various pages may affect memory state, so it's up to class to manage when which 
 * page is loaded.
 * @param pageNo index of page
 * @return YES if data are loaded and ready to access.
 */
-(BOOL)isPageLoaded:(NSInteger)pageNo;

@optional
-(void)filterUsingPredicate:(NSPredicate*)pred;
@end
