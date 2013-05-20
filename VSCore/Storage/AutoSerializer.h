//
//  AutoSerializer.h
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski on 23.11.2012.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "SQLiteHelper.h"

@interface AutoSerializer : NSObject

+(void)bindType:(Class)cl intoTable:(NSString*)table inDBNamed:(NSString*)dbFileName;
+(void)storeData:(id)obj;

//Returns nil if no object is found
+(id)loadSingleData:(Class)cl where:(NSDictionary*)keyFields;
+(NSArray*)loadData:(Class)cl where:(NSDictionary*)keyFields;
// Order - array of strings. If string start with "-" it will be desc, otherwise asc
// Limit - if 0 than return all
+(NSArray*)loadData:(Class)cl where:(NSDictionary*)keyFields order:(NSArray*)orderFields limit:(NSInteger) limit;

/**
 * Tries to rebuild link from object to database row. Primary key will be used to do this. Following conditions must be met:
 * <ol>primary key of object stored is stored in property</ol>
 * <ol>primary key must not be 0</ol>
 * @warning This method assumes that primary key is valid, no check against database is done!
 * @param object to rebind
 * @return YES if bond is recreated otherwise NO
 */
+(BOOL)tryRebind:(id)object;

/**
 * Checks if for given object primary key is known, if yes then call is redirected to {@link #updateData:}
 * otherwise {@link #storeData:} is called.
 * @param obj to be stored or updated
 */
+(void)storeOrUpdateData:(id)obj;

/**
 * @note requires primary key to be set due to call to storeData or loadSingleData or loadData
 */
+(void)removeData:(id)obj;

/**
 * @note requires primary key to be set due to call to storeData or loadSingleData or loadData
 */
+(void)updateData:(id)obj;

/**
 * Executes sql query given in argument, all arguments in args array should have matching placeholders.
 * Method will call {@link SQLiteHelper#execSQL:withArguments:inDB:} with proper database and table bound
 * to class.
 *
 * @note Substring ':table' in sql argument will be replaced with table name bound to given class
 * @param sql to be executed, use ':table' marker to specify table on which operation should be executed
 * @param args array of object which type will be identified and put into prepared statement
 * @param cl class which should be used to match proper table and database
 */
+(void)execSQL:(NSString*)sql withArguments:(NSArray*)args inContextOf:(Class)cl;
+(void)execSQL:(NSString*)sql withArguments:(NSArray*)args inContextOf:(Class)cl withResultHandler:(RawSQLResultHandler)blk;
@end
