//
//  SQLiteHelper.m
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski on 01.03.2012.
//

#import "SQLiteHelper.h"
#import <objc/runtime.h>
#import "FileHelper.h"

static NSMutableDictionary* typesTranslation;

static NSMutableDictionary* openedDB;

#define stripPrimKeyPrefix(x) if ([x hasPrefix:@"#"]==YES){x = [x substringFromIndex:1];}

//------------------------------------------------------------------------------------
@interface DBCacheProxy : NSObject{
    sqlite3* db;
    NSInteger refCount;
}

@property (nonatomic, assign) sqlite3* db;
@property (nonatomic, assign) NSInteger refCount;

@end

@implementation DBCacheProxy
@synthesize db, refCount;
@end

//------------------------------------------------------------------------------------
@implementation SQLiteHelper

static NSMutableDictionary* descrCache;

#pragma mark - Private routines

+(void)initialize{
    typesTranslation = [[NSDictionary dictionaryWithObjectsAndKeys:
                        @"INTEGER", @"c",      //OBJ-C: bool (or character, not sure)
                        @"INTEGER(8)", @"q",   //OBJ-C: long long
                        @"INTEGER(8)", @"Q",   //OBJ-C: unsigned long long
                        @"INTEGER", @"i",   //OBJ-C: NSInteger
                        @"INTEGER", @"I",   //OBJ-C: NSUInteger
                        @"INTEGER", @"l",   //OBJ-C: long
                        @"INTEGER", @"L",   //OBJ-C: unsigned long
                        @"REAL", @"f",      //OBJ-C: CGFloat
                        @"REAL", @"d",      //OBJ-C: double
                        @"REAL", @"NSNumber",   //OBJ-C: NSNumber
                        @"TEXT", @"NSString",   //OBJ-C: NSString
                        @"TEXT", @"NSMutableString",   //OBJ-C: NSMutableString
                        @"DATETIME", @"NSDate",   //OBJ-C: NSDate
                        nil] retain];
    descrCache = [[NSMutableDictionary alloc] init];
    openedDB = [[NSMutableDictionary alloc] init];
}

+(NSMutableDictionary*)translate:(NSDictionary*)fieldsDescr{
    __block NSMutableDictionary* result = [NSMutableDictionary dictionaryWithCapacity:[fieldsDescr count]];
    [fieldsDescr enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
//        stripPrimKeyPrefix(key);
        [result setValue:[typesTranslation objectForKey:obj] forKey:key];
    }];
    return result;
}

/**
 * NOTE: if column name starts with '#' then it's inserted as PRIMARY KEY AUTOINCREMENT, marker character is removed.
 */
+(NSString*)buildCreateStatement:(NSDictionary*)fieldsDescr forTable:(NSString*)tableName{
    NSMutableString* __block result = [NSMutableString stringWithFormat:@"CREATE TABLE %@ (", tableName];
    fieldsDescr = [SQLiteHelper translate:fieldsDescr];
    [fieldsDescr enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        if ([key hasPrefix:@"#"] == YES){
            //this is Primary key marker
            NSAssert([obj isEqualToString:@"INTEGER"], @"Primary key muste be INTEGER");
            [result appendFormat:@"'%@' %@ PRIMARY KEY AUTOINCREMENT,", [key substringFromIndex:1], obj];
        } else {
            [result appendFormat:@"'%@' %@,", key, obj];
        }
    }];
    
    [result deleteCharactersInRange:NSMakeRange([result length]-1, 1)];
    [result appendString:@")"];
    return result;
}

+(NSDictionary*)describeTable:(NSString*)tableName inDB:(sqlite3*)db{

    NSMutableDictionary* result = [descrCache objectForKey:tableName];
    if (result != nil){
        return result;
    }
    
    sqlite3_stmt *statement;
    NSString *querySQL = [NSString stringWithFormat:@"PRAGMA table_info(%@)", tableName];
    
    if (sqlite3_prepare_v2(db, [querySQL UTF8String], -1, &statement, NULL) != SQLITE_OK){
        DDLogError(@"[dT1]DB error: %s",sqlite3_errmsg(db));
        return nil;
    }

    result = [NSMutableDictionary dictionary];
    NSInteger res = sqlite3_step(statement);
    while(res == SQLITE_ROW) {
        NSString *colName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
        NSString *colType = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
        [result setValue:colType forKey:colName];
        res = sqlite3_step(statement);
    }
    
    sqlite3_finalize(statement);
    if ([result count] > 0){
        [descrCache setObject:result forKey:tableName];
        return result;
    } else {
        return nil;
    }
}

+(void)renameTable:(NSString*)tableName to:(NSString*)newName atDB:(sqlite3*)db{
    
    if (newName == nil) {
        [self doQuery:[NSString stringWithFormat:@"drop table %@", tableName] onDB:db];
        return;
    }
    
    [self doQuery:[NSString stringWithFormat:@"drop table %@", newName] onDB:db];
    
    sqlite3_stmt *statement;
    NSString *querySQL = [NSString stringWithFormat:@"ALTER TABLE %@ RENAME TO %@", tableName, newName];
    
    if (sqlite3_prepare_v2(db, [querySQL UTF8String], -1, &statement, NULL) != SQLITE_OK){
        DDLogError(@"[rT1]DB error: %s",sqlite3_errmsg(db));
        return;
    }
    
    NSInteger res = sqlite3_step(statement);
    if ((res != SQLITE_OK) && (res != SQLITE_DONE)) {
        DDLogError(@"[rT2]DB error: %s",sqlite3_errmsg(db));
    } else {
        //update descriptions cache
        id val = [descrCache objectForKey:tableName];
        if (val != nil){
            [descrCache setValue:val forKey:newName];
            [descrCache removeObjectForKey:tableName];
        }
    }
    
    sqlite3_finalize(statement);
    
}

+(void)doQuery:(NSString*)query onDB:(sqlite3*)db{
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, NULL) != SQLITE_OK){
        DDLogError(@"[dQ1]DB error: %s",sqlite3_errmsg(db));
        return;
    }
    
    NSInteger res = sqlite3_step(statement);
    if ( (res != SQLITE_OK) && (res != SQLITE_DONE) ) {
        DDLogError(@"[dQ2]DB error: %s",sqlite3_errmsg(db));
    }
    
    sqlite3_finalize(statement);    
}

+(NSArray*)compatybileFields:(NSString*)tableName with:(NSDictionary*)tableDescr inDB:(sqlite3*)db{
    NSDictionary* __block inDBFields = [SQLiteHelper describeTable:tableName inDB:db];
    NSMutableArray* result = [NSMutableArray arrayWithCapacity:[inDBFields count]];
    [tableDescr enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop){
        stripPrimKeyPrefix(key);
        NSString* type = [inDBFields objectForKey:key];
        //TODO: In future more sophisticated compability check may be implemented (maybe conversion?)
        if ([obj isEqualToString:type] == YES){
            [result addObject:key];
        }
    }];
    return result;
}

+(void)copyFields:(NSArray*)fields from:(NSString*)tableNameOld into:(NSString*)tableName inDB:(sqlite3*)db{
    
    if ([fields count] == 0){
        return;
    }
    
    NSMutableString* strFields = [NSMutableString string];
    for(NSString* f in fields){
        [strFields appendFormat:@"%@,", f];
    }
    [strFields deleteCharactersInRange:NSMakeRange([strFields length]-1, 1)];
    NSString* query = [NSString stringWithFormat:@"insert into %@(%@) select %@ from %@", 
                       tableName, strFields, strFields, tableNameOld];
    [SQLiteHelper doQuery:query onDB:db];
}

+(NSInteger)bindData:(NSDictionary*)objData forTable:(NSString*)tableName inDB:(sqlite3*)db intoStatement:(sqlite3_stmt*)statement{
    NSDictionary* __block fieldsDescription = [SQLiteHelper describeTable:tableName inDB:db];
    NSAssert(fieldsDescription != nil, @"SQLiteHelper internal error[1] no description for table named %@", tableName);
    
    NSInteger __block index = 1;
    [objData enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop){
        NSAssert([key hasPrefix:@"#"] == NO, @"Primary key shouldn't be set in statement!");
        NSString* type = [fieldsDescription objectForKey:key];
        NSAssert(type != nil, @"unknown type[1]:'%@' for field:%@", type, key);
        //TODO: optimize for native type than change if chaining into switch statement
        if ((obj == nil) || ([obj isKindOfClass:[NSNull class]] == YES)){
            sqlite3_bind_null(statement, index);
            
        } else if ([@"INTEGER" isEqualToString:type] == YES){
            sqlite3_bind_int(statement, index, [obj longValue]);
            
        } else if ([@"TEXT" isEqualToString:type] == YES){
            sqlite3_bind_text(statement, index, [obj UTF8String], -1, SQLITE_TRANSIENT);
            //FIX_ME if char is needed - char as bool value.
        } else if ([@"BOOL" isEqualToString:type] == YES){
            sqlite3_bind_int(statement, index, [obj boolValue] == YES ? 1 : 0);
            
        } else if ([@"REAL" isEqualToString:type] == YES){
            sqlite3_bind_double(statement, index, [obj doubleValue]);
            
        } else if ([@"DATETIME" isEqualToString:type] == YES){
            sqlite3_bind_double(statement, index, [obj timeIntervalSince1970]);
            
        } else if ([@"INTEGER(8)" isEqualToString:type] == YES){
                sqlite3_bind_int64(statement, index, [obj longLongValue]);

        } else {
            NSAssert(NO, @"Unknown type[2]:'%@' for field:%@", type, key);
        }
        index++;
    }];
    return index;
}

+(void)appendWhereClausuleTo:(NSMutableString*)query describedBy:(NSDictionary*)keyFields{
    [query appendString:@" WHERE "];
    const __block Class sClass = [NSString class];
    [keyFields enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop){
        stripPrimKeyPrefix(key);
        [query appendString:@"`"];
        [query appendString:key];
        [query appendString:@"`"];
        if ([obj isKindOfClass: sClass] == YES){
            if ( [(NSString*)obj rangeOfString:@"%"].location != NSNotFound ) {
                [query appendString:@"like ?"];
            } else {
                [query appendString:@"=?"];
            }
        } else {
            [query appendString:@"=?"];
        }
        [query appendString:@" AND "];
    }];
    [query deleteCharactersInRange:NSMakeRange([query length]-4, 4)];
}

+(void)appendOrderClausuleTo:(NSMutableString*)query describedBy:(NSArray*)keyFields{
    [query appendString:@" ORDER BY "];
    for(NSString* column in keyFields){
        BOOL ASC=YES;
        if([column hasPrefix:@"-"]){
            ASC=NO;
            column = [column substringFromIndex:1];
        }
        [query appendString:@"`"];
        [query appendString:column];
        [query appendString:@"`"];
        if(ASC==NO){
            [query appendString:@" DESC"];
        }
        [query appendString:@", "];
    }
    [query deleteCharactersInRange:NSMakeRange([query length]-2, 2)];
}

+(void)appendLimitClausuleTo:(NSMutableString*)query value:(NSInteger)value{
    NSAssert([[query lowercaseString] rangeOfString:@"limit"].location == NSNotFound, @"Limit already present!");
    [query appendFormat:@" LIMIT %d", value];
}

+(NSMutableDictionary*)unpackRowFromStatement:(sqlite3_stmt*)statement withDescription:(NSDictionary*)tableDescr{
    
    const NSInteger count = sqlite3_column_count(statement);
    NSMutableDictionary* result = [NSMutableDictionary dictionaryWithCapacity:count];
    
    for(NSInteger t = 0; t < count; t++){
        NSString* name = [[NSString alloc] initWithUTF8String: sqlite3_column_name(statement, t)];
        NSString* type = [tableDescr objectForKey:name];
        NSAssert(type != nil, @"Internall structure error");
        
        //TODO: optimize for native type than change if chaining into switch statement
        if (sqlite3_column_type(statement, t) == SQLITE_NULL){
            [result setObject:[NSNull null]
                       forKey:name];
            
        } else if ([@"INTEGER" isEqualToString:type] == YES){
            [result setObject:[NSNumber numberWithInt:sqlite3_column_int(statement, t)] 
                       forKey:name];
            
        } else if ([@"TEXT" isEqualToString:type] == YES){
            [result setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, t)]
                       forKey:name];
            
        } else if ([@"BOOL" isEqualToString:type] == YES){
            [result setObject:[NSNumber numberWithBool: (sqlite3_column_int(statement, t) != 0)] 
                       forKey:name];
            
        } else if ([@"REAL" isEqualToString:type] == YES){
            [result setObject:[NSNumber numberWithDouble:sqlite3_column_double(statement, t)] 
                       forKey:name];
            
        } else if ([@"DATETIME" isEqualToString:type] == YES){
            double d = sqlite3_column_double(statement, t);
            [result setObject:[NSDate dateWithTimeIntervalSince1970:d] 
                       forKey:name];
        } else if ([@"INTEGER(8)" isEqualToString:type] == YES){
            [result setObject:[NSNumber numberWithLongLong:sqlite3_column_int64(statement, t)] 
                       forKey:name];
            
        } else {
            NSAssert(NO, @"Unknown type[3]:'%@' for field:%@", type, name);
        }
        
        [name release];
    }
    
    return result;
}

+(NSString*)getCommonDBLocation{
    return [FileHelper prefferedPath:nil withType:pathPrivateBackup];
}

#pragma mark - Public routines
+(void)ensureCompatibility:(NSDictionary*)tableDescr atTable:(NSString*)tableName inDB:(sqlite3*)db preserveOldInTable:(NSString*)tableNameOld{
    
    if ([SQLiteHelper checkCompatibility:tableDescr atTable:tableName inDB:db] == YES){
        //all ok, we don't need to do anything
        return;
    }
    
    DDLogInfo(@"ensureCompatibility failed for %@", tableName);

    //bad, lets rename table as a backup
    DDLogInfo(@"   ensureCompatibility backup old table %@ into %@", tableName, tableNameOld);
    [SQLiteHelper renameTable:tableName to:tableNameOld atDB:db];
    
    //create table with new schema
    [SQLiteHelper doQuery:[SQLiteHelper buildCreateStatement:tableDescr forTable:tableName]
                     onDB:db];
    
    //get fields which may be safely copied, this also rebuild description cache
    NSArray* fields = [SQLiteHelper compatybileFields:tableName with:tableDescr inDB:db];
    DDLogInfo(@"   ensureCompatibility list of columns to copy/preserve:%@", fields);
    
    //perform copy of old data if possible
    [SQLiteHelper copyFields:fields from:tableNameOld into:tableName inDB:db];
    
    //remove old table description, will be recreated when accessed next time
    [descrCache removeObjectForKey:tableName];
}

+(BOOL)checkCompatibility:(NSDictionary*)tableDescr atTable:(NSString*)tableName inDB:(sqlite3*)db{
    NSDictionary* __block inDBDescr = [SQLiteHelper describeTable:tableName inDB:db];
    if ((inDBDescr == nil) || ([tableDescr count] > [inDBDescr count])) {
        return NO;
    }
    tableDescr = [SQLiteHelper translate:tableDescr];
    __block BOOL result = YES;
    
    [tableDescr enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        stripPrimKeyPrefix(key);
        NSString* type = [inDBDescr objectForKey:key];
        if ( (key == nil) || ([type isEqualToString:obj] == NO) ){
            *stop = YES;
            result = NO;
        }
    }];
    
    return result;
}
    
+(void)bindWhereClausuleTo:(sqlite3_stmt*)statement describedBy:(NSDictionary*)keyFields startIndex:(NSInteger)anIndex{
    NSInteger __block index = anIndex < 1 ? 1 : anIndex;
    [keyFields enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop){
        if ([obj isKindOfClass:[NSNumber class]]){

            //refer to https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
            const char* c = [(NSNumber*)obj objCType];
            switch( (NSInteger)*c ){
                case 'i':
                case 's':
                case 'l':
                    sqlite3_bind_int(statement, index, [obj longValue]);
                    break;

                case 'q':
                    sqlite3_bind_int64(statement, index, [obj longLongValue]);
                    break;
                
                case 'c':
                case 'B':
                    sqlite3_bind_int(statement, index, [obj boolValue] == YES ? 1 : 0);
                    break;
                    
                case 'f':
                case 'd':
                    sqlite3_bind_double(statement, index, [obj doubleValue]);
                    break;
                    
                default:
                    NSAssert(NO, @"Unssuported subtype[1]");
                    break;
            }
        } else if ([obj isKindOfClass:[NSString class]]){
            sqlite3_bind_text(statement, index, [obj UTF8String], -1, SQLITE_TRANSIENT);

        } else if ([obj isKindOfClass:[NSDate class]]){
            sqlite3_bind_double(statement, index, [obj timeIntervalSince1970]);
            
        } else {
            NSAssert(NO, @"Unssuported type");
        }
        index ++;
    }];
}

+(int64_t)storeData:(NSDictionary*)objData intoTable:(NSString*)tableName inDB:(sqlite3*)db{
    NSMutableString* __block fields = [NSMutableString string];
    NSMutableString* __block placeholders = [NSMutableString string];
    NSMutableArray* __block values = [NSMutableArray arrayWithCapacity:[objData count]];
    [objData enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop){
        NSAssert([key hasPrefix:@"#"] == NO, @"Primary key shouldn't be here!");
        [values addObject:obj];
        [fields appendString:@"`"];
        [fields appendString:key];
        [fields appendString:@"`,"];
        
        [placeholders appendString:@"?,"];
    }];
    [fields deleteCharactersInRange:NSMakeRange([fields length]-1, 1)];
    [placeholders deleteCharactersInRange:NSMakeRange([placeholders length]-1, 1)];
    
    NSString* query = [NSString stringWithFormat:@"INSERT INTO %@(%@) values (%@)", tableName, fields, placeholders];
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, NULL) != SQLITE_OK){
        DDLogError(@"[3]DB error: %s",sqlite3_errmsg(db));
        return -1;
    }
    
    [SQLiteHelper bindData:objData forTable:tableName inDB:db intoStatement:statement];
            
    NSInteger res = sqlite3_step(statement);
    if (res != SQLITE_DONE) {
        DDLogError(@"[4]DB error: %d: %s", res, sqlite3_errmsg(db));
    }
    int64_t rowId = sqlite3_last_insert_rowid(db);
    
    sqlite3_finalize(statement);
    return rowId;
}

+(void)execSQL:(NSString*)sql withArguments:(NSArray*)args inDB:(sqlite3*)db{

    RawSQLResultHandler blk = ^(sqlite3_stmt *statement){
        NSInteger res = sqlite3_step(statement);
        if ((res != SQLITE_OK) && (res != SQLITE_DONE)) {
            DDLogError(@"[ES2]DB error: %s",sqlite3_errmsg(db));
        }
    };
    
    [self execSQL:sql withArguments:args andResultHandler:blk inDB:db];
}

+(void)execSQL:(NSString*)sql withArguments:(NSArray*)args andResultHandler:(RawSQLResultHandler)blk inDB:(sqlite3*)db{
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK){
        DDLogError(@"[ES1]DB error: %s",sqlite3_errmsg(db));
        return;
    }
    NSInteger index = 1;
    for(id sqlArg in args){
        if ([sqlArg isKindOfClass:[NSNumber class]] == YES){
            NSNumber* n = sqlArg;
            const char* nType = [n objCType];
            switch((int)*nType){
                default:
                case _C_CHR:
                case _C_INT:
                case _C_UINT:
                case _C_LNG:
                case _C_ULNG:
                    sqlite3_bind_int(statement, index, [n longValue]);
                    break;
                    
                case _C_BOOL:
                    sqlite3_bind_int(statement, index, [n boolValue] == YES ? 1 : 0);
                    break;
                    
                case _C_LNG_LNG:
                case _C_ULNG_LNG:
                    sqlite3_bind_int64(statement, index, [n longLongValue]);
                    break;
                    
                case _C_FLT:
                case _C_DBL:
                    sqlite3_bind_double(statement, index, [n doubleValue]);
                    break;
            }
            
        } else if ([sqlArg isKindOfClass:[NSDate class]] == YES){
            sqlite3_bind_double(statement, index, [sqlArg timeIntervalSince1970]);
            
        } else if ([sqlArg isKindOfClass:[NSString class]] == YES){
            sqlite3_bind_text(statement, index, [sqlArg UTF8String], -1, SQLITE_TRANSIENT);
            
        } else {
            NSAssert(NO, @"Unknown type[2]:'%@' for at index:%d", [sqlArg class], index);
        }
        index++;
    }
    
    blk(statement);
    
    sqlite3_finalize(statement);
}

+(NSMutableDictionary*)loadSingleData:(NSDictionary*)keyFields atTable:(NSString*)tableName inDB:(sqlite3*)db{
    NSDictionary* descr = [SQLiteHelper describeTable:tableName inDB:db];
    NSAssert(descr != nil, @"No description for %@", tableName);
    NSMutableString* query = [NSMutableString stringWithFormat:@"SELECT * FROM %@",tableName];
    if ([keyFields count] > 0){
        [SQLiteHelper appendWhereClausuleTo:query describedBy:keyFields];
    }
    [query appendString:@" LIMIT 1"];
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, NULL) != SQLITE_OK){
        DDLogError(@"[5]DB error: %s",sqlite3_errmsg(db));
        NSLog(@"[5]DB error: %s",sqlite3_errmsg(db));
        return [NSMutableDictionary dictionary];
    }
    
    [SQLiteHelper bindWhereClausuleTo:statement describedBy:keyFields startIndex:1];
    //NSDictionary* tableDescr = [SQLiteHelper describeTable:tableName inDB:db];
    NSMutableDictionary* result;
    NSInteger res = sqlite3_step(statement);
    if (res != SQLITE_ROW) {
        if (res != SQLITE_DONE){
            DDLogError(@"[6]DB error: %s\nquery:%@",sqlite3_errmsg(db),query);
        }
        result = [NSMutableDictionary dictionary];
    } else {
        result = [SQLiteHelper unpackRowFromStatement:statement withDescription:descr];
    }
    
    sqlite3_finalize(statement); 
    return result;
}

+(void)updateData:(NSDictionary*)objData where:(NSDictionary*)where atTable:(NSString*)tableName inDB:(sqlite3*)db singleRecord:(BOOL)single{
    NSDictionary* descr = [SQLiteHelper describeTable:tableName inDB:db];
    NSAssert(descr != nil, @"No description for %@", tableName);
    
    NSMutableString* __block set = [NSMutableString string];
    NSMutableArray* __block values = [NSMutableArray arrayWithCapacity:[objData count]];
    [objData enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop){
        NSAssert([key hasPrefix:@"#"] == NO, @"Primary key shouldn't be here!");
        [values addObject:obj];
        [set appendString:key];
        [set appendString:@"=?,"];
    }];
    [set deleteCharactersInRange:NSMakeRange([set length]-1, 1)];   //remove last comma

    NSMutableString* query = [NSMutableString stringWithFormat:@"UPDATE %@ SET %@",tableName, set];
    
    if ([where count] > 0){
        [SQLiteHelper appendWhereClausuleTo:query describedBy:where];
    }

//    if (single == YES){
//        if ([where count] > 0){
//            [query appendString:@" LIMIT 1"];
//        } else {
//            NSAssert(NO, @"Requested LIMIT but no WHERE is given!");
//        }
//    }
    
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, NULL) != SQLITE_OK){
        DDLogError(@"[R1]DB error: %s",sqlite3_errmsg(db));
        return;
    }
    NSInteger off = [SQLiteHelper bindData:objData forTable:tableName inDB:db intoStatement:statement];
    [SQLiteHelper bindWhereClausuleTo:statement describedBy:where startIndex:off];
    NSInteger res = sqlite3_step(statement);
    if ((res != SQLITE_OK) && (res != SQLITE_DONE)) {
        DDLogError(@"[R2]DB error: %s",sqlite3_errmsg(db));
    }
    
    sqlite3_finalize(statement);
}

+(void)removeData:(NSDictionary*)keyFields fromTable:(NSString*)tableName inDB:(sqlite3*)db{
    NSDictionary* descr = [SQLiteHelper describeTable:tableName inDB:db];
    NSAssert(descr != nil, @"No description for %@", tableName);
    NSMutableString* query = [NSMutableString stringWithFormat:@"DELETE from %@",tableName];
    if ([keyFields count] > 0){
        [SQLiteHelper appendWhereClausuleTo:query describedBy:keyFields];
    }
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, NULL) != SQLITE_OK){
        DDLogError(@"[R1]DB error: %s",sqlite3_errmsg(db));
        return;
    }
    
    [SQLiteHelper bindWhereClausuleTo:statement describedBy:keyFields startIndex:1];
    NSInteger res = sqlite3_step(statement);
    if ((res != SQLITE_OK) && (res != SQLITE_DONE)) {
        DDLogError(@"[R2]DB error: %s",sqlite3_errmsg(db));
    }
    
    sqlite3_finalize(statement);
}

+(NSMutableArray*)loadData:(NSDictionary*)keyFields atTable:(NSString*)tableName inDB:(sqlite3*)db{
    return [SQLiteHelper loadData:keyFields atTable:tableName inDB:db order:nil limit:0];
}

+(NSMutableArray*)loadData:(NSDictionary*)keyFields atTable:(NSString*)tableName inDB:(sqlite3*)db order:(NSArray*)order limit:(NSInteger)limit{
    NSDictionary* descr = [SQLiteHelper describeTable:tableName inDB:db];
    NSAssert(descr != nil, @"No description for %@", tableName);
    NSMutableString* query = [NSMutableString stringWithFormat:@"SELECT * from %@", tableName];
    if ([keyFields count] > 0){
        [SQLiteHelper appendWhereClausuleTo:query describedBy:keyFields];
    }
    if ([order count] > 0){
        [SQLiteHelper appendOrderClausuleTo:query describedBy:order];
    }
    if (limit > 0){
        [SQLiteHelper appendLimitClausuleTo:query value:limit];
    }
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, NULL) != SQLITE_OK){
        DDLogError(@"[7]DB error: %s",sqlite3_errmsg(db));
        return [NSMutableArray array];
    }
    
    [SQLiteHelper bindWhereClausuleTo:statement describedBy:keyFields startIndex:1];
    NSMutableArray* result = [NSMutableArray array];
    NSInteger res = sqlite3_step(statement);
    while(res == SQLITE_ROW) {
        [result addObject: [SQLiteHelper unpackRowFromStatement:statement withDescription:descr]];
        res = sqlite3_step(statement);
    }
    
    sqlite3_finalize(statement);
    return result;
}

+(void)loadData:(NSDictionary*)keyFields atTable:(NSString*)tableName inDB:(sqlite3*)db withFactory:(FactoryBlock)factBlk andCollection:(id)col andColFiller:(FillerBlock)flrBlk{
    NSDictionary* descr = [SQLiteHelper describeTable:tableName inDB:db];
    NSAssert(descr != nil, @"No description for %@", tableName);
    NSMutableString* query = [NSMutableString stringWithFormat:@"SELECT * from %@", tableName];
    if ([keyFields count] > 0){
        [SQLiteHelper appendWhereClausuleTo:query describedBy:keyFields];
    }
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, NULL) != SQLITE_OK){
        DDLogError(@"[L1]DB error: %s",sqlite3_errmsg(db));
        return;
    }
    
    [SQLiteHelper bindWhereClausuleTo:statement describedBy:keyFields startIndex:1];
    NSInteger res = sqlite3_step(statement);
    while(res == SQLITE_ROW) {
        id item = factBlk([SQLiteHelper unpackRowFromStatement:statement withDescription:descr]);
        flrBlk(col, item);
        res = sqlite3_step(statement);
    }
    
    sqlite3_finalize(statement);
}

+(sqlite3*)openDB:(NSString*)dbFileName assumeCommonLocation:(BOOL)cLoc createIfNeeded:(BOOL)doCreate{
    if (cLoc == YES){
        dbFileName = [NSString stringWithFormat:@"%@%@", [SQLiteHelper getCommonDBLocation], dbFileName];
    }
    
    DBCacheProxy* proxy = [openedDB objectForKey:dbFileName];
    if (proxy != nil){
        proxy.refCount ++;
        return proxy.db;
    }
    
    if ( ([[NSFileManager defaultManager] fileExistsAtPath:dbFileName] == NO) && (doCreate == NO) ){
        return nil;
    }
    
    sqlite3* db = nil;
    if (sqlite3_open_v2([dbFileName UTF8String], &db,SQLITE_OPEN_CREATE|SQLITE_OPEN_READWRITE|SQLITE_OPEN_FULLMUTEX,nil) != SQLITE_OK){
//    if (sqlite3_open([dbFileName UTF8String], &db) != SQLITE_OK){
        //Failed to open database
        return nil;
    }
    
    proxy = [[DBCacheProxy alloc] init];
    proxy.db = db;
    proxy.refCount = 1;
    [openedDB setObject:proxy forKey:dbFileName];
    [proxy release];    //notice:openedDB holds ref count
    
    DDLogInfo(@"Opening DB:%@", dbFileName);
    return proxy.db;
}

+(void)closeDB:(sqlite3*)dbRef{
    
    __block id toRemove = nil;

    [openedDB enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop){
        DBCacheProxy* proxy = obj;
        if (proxy.db != dbRef) {
            proxy.refCount--;
            if (proxy.refCount == 0){
                toRemove = key;
                sqlite3_close(proxy.db);
            }
            *stop = YES;
        }
    }];
    
    if (toRemove != nil){
        [openedDB removeObjectForKey:toRemove];
    }
}

@end
