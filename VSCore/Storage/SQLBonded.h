//
//  SQLBonded.h
//  VSCore
//
//  Created by Bartłomiej Żarnowski on 23.11.2012.
//  Copyright (c) 2012 Bartłomiej Żarnowski. All rights reserved.
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

@end
