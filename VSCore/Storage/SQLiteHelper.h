//
//  SQLiteHelper.h
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski on 01.03.2012.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

typedef id(^FactoryBlock)(NSDictionary* item );
typedef void(^FillerBlock)(id collection, id item);
typedef void(^RawSQLResultHandler)(sqlite3_stmt* statement);

@interface SQLiteHelper : NSObject

#pragma mark - DB level operations
/**
 * This method tries to open and return back SQLite object ready for operations. File may be created if
 * doCreate == YES, if cLoc == YES then dbFileName should contain only local name of db file without full
 * path, destination location will be autoobtained. Several calls to this method result only in one
 * SQLite object creation, it will be shared. Opened DB connection is in mode: SQLITE_OPEN_READWRITE,
 * SQLITE_OPEN_FULLMUTEX. All calls to this method should be balanced with {@link #closeDB:}
 *
 * @param dbFileName file in which database is stored.
 * @param cLoc if YES dbFileName will be searched/created in common location {@link FileHelper#libraryPath}, 
 *             otherwise full path is expected in dbFileName
 * @param doCreate if YES db file will be created if not exist.
 */
+(sqlite3*)openDB:(NSString*)dbFileName assumeCommonLocation:(BOOL)cLoc createIfNeeded:(BOOL)doCreate;
/**
 * "Relases" usage of SQLite object. It decrases internal ref counter, when it goes to 0 SQLite object will
 * be released (connection closed). This method cooperate with {@link #openDB:assumeCommonLocation:createIfNeeded:},
 * and should be balanced with calls to openDB.
 * @param dbRef database connection object to be released
 */
+(void)closeDB:(sqlite3*)dbRef;

#pragma mark - Tables level operations

/**
 * This method tries to open table of a given name. If this table do not exist or is different then tableDescr, it creates
 * new table, and save old one in preserveOldInTable. Otherwise it does nothing.
 * @param tableDescr dictionary which describes Cols of the table
 * @param tableName name of the table in db
 * @param db sqlite3 database
 * @param tableNameOld, place to store old table if it differs from the new one.
 */
+(void)ensureCompatibility:(NSDictionary*)tableDescr atTable:(NSString*)tableName inDB:(sqlite3*)db preserveOldInTable:(NSString*)tableNameOld;

/** 
 * This method check if table existing in database is the same as tableDescr
 * @param tableDescr dictionary which describes Cols of the table
 * @param tableName name of the table in db
 * @param db sqlite3 database
 * @return YES if tables are compatible, otherwise NO
 */
+(BOOL)checkCompatibility:(NSDictionary*)tableDescr atTable:(NSString*)tableName inDB:(sqlite3*)db;

#pragma mark - Object level operations

/**
 * This method stores data in database
 * @param objData data which are stored
 * @param tableName name of the table, where data is stored
 * @param db sqlite3 database
 * @return last insert rowID
 */
+(int64_t)storeData:(NSDictionary*)objData intoTable:(NSString*)tableName inDB:(sqlite3*)db;

/**
 * This method returns dictionary from database of keys given in keyFields
 * @param keyFields fields of keys
 * @param tableName name of the table, where data is stored
 * @param db sqlite3 database
 * @return dictionary of values for given keys
 */
+(NSMutableDictionary*)loadSingleData:(NSDictionary*)keyFields atTable:(NSString*)tableName inDB:(sqlite3*)db;

/**
 * This method return array of dictionaries of keys given in keyFields
 * @param keyFields fields of keys
 * @param tableName name of the table, where data is stored
 * @param db sqlite3 database
 * @return array of dictionaries
 */
+(NSMutableArray*)loadData:(NSDictionary*)keyFields atTable:(NSString*)tableName inDB:(sqlite3*)db;

/**
 * This method return array of dictionaries of keys given in keyFields
 * @param keyFields fields of keys
 * @param tableName name of the table, where data is stored
 * @param db sqlite3 database
 * @param order columns to sort, if start with "-" - DESC, for example [-primKey,name], null if no sorting
 * @param limit how many wors to select, 0 od null if all
 * @return array of dictionaries
 */
+(NSMutableArray*)loadData:(NSDictionary*)keyFields atTable:(NSString*)tableName inDB:(sqlite3*)db order:(NSArray*)order limit:(NSInteger)limit;
+(void)loadData:(NSDictionary*)keyFields atTable:(NSString*)tableName inDB:(sqlite3*)db withFactory:(FactoryBlock)factBlk andCollection:(id)col andColFiller:(FillerBlock)flrBlk;

/**
 * This method removes from database dictionaries with keys given in keyFields
 * @param keyFields fields of keys
 * @param tableName name of the table, where data is stored
 * @param db sqlite3 database
 */
+(void)removeData:(NSDictionary*)keyFields fromTable:(NSString*)tableName inDB:(sqlite3*)db;

/**
 * This method updates data everywhere, where keys and values are equal to these in "NSDictionary *where"
 * @param objData objects which are replacing objects set in where
 * @param where objects which are being replaced
 * @param tableName name of the table, where data is stored
 * @param db sqlite3 database
 * @param single, YES if it is a single record
 */
+(void)updateData:(NSDictionary*)objData where:(NSDictionary*)where atTable:(NSString*)tableName inDB:(sqlite3*)db singleRecord:(BOOL)single;

/**
 * Tries to create indices on table. If indices are empty or nil, method silently quits.
 * @param indices array with description of indices, see SQLBonded method +indices for more info about format
 * @param table name of table on which indices should be added
 * @param db sqlite3 database
 */
+(void)ensureIndices:(NSArray*)indices onTable:(NSString*)table inDB:(sqlite3*)db;

+(void)execSQL:(NSString*)sql withArguments:(NSArray*)args inDB:(sqlite3*)db;
+(void)execSQL:(NSString*)sql withArguments:(NSArray*)args andResultHandler:(RawSQLResultHandler)blk inDB:(sqlite3*)db;
@end
