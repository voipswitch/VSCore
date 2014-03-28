//
//  SQLBonded.h
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski on 23.11.2012.
//

#import <Foundation/Foundation.h>

/**
 * This is marker protocol, it's detected by AutoSerializer class and used to store primary key information
 * for object instance retrieved/stored from/into SQLite database.
 */
@protocol SQLBonded <NSObject>

@optional
/** 
 * If you want to specify column name for primary unique key you can specify it here, if not defined]
 * 'primKey' will be used. If database key should be stored in donded object then property with this 
 * same name must exist (long type).
 */
+(NSString*)primaryKey;

/**
 * Return array of indices, two forms of elements inside are allowed:
 * 1) String with name of column which index should be taken
 * 2) array of strings, each string contains name of column, this is used to create index for multiple columns
 * Each string which contains column name may have one of three allowed prefixes:
 * '+' if index on this column should be ASCending
 * '-' if index on this column should be DESCending
 * '!' if this index should be UNIQUE (this prefix shoukld be only in first column name, it may be followed by '+' or '-')
 * example:
 * 1) create index on column foo -> @["foo"]
 * 2) create index on column foo ascending -> @["+foo"]
 * 3) create unique index on column foo -> @["!foo"]
 * 4) create unique index on column foo descending -> @["!-foo"] 
 * 5) create two indices: a) on unique on column foo, b) unique on columns 'name' ascending, 'address' descending
 *    @[ @"!foo", @["!+name", "-address"]]
 */
+(NSArray*)indices;
@end
