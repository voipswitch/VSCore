//
//  AutoSerializer.m
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski on 23.11.2012.
//

#import "AutoSerializer.h"
#import "SQLiteHelper.h"
#import "SQLBonded.h"
#import "ReflectionHelper.h"
#import <objc/runtime.h>

#define UNIQUE_ID @"primKey"

#define removePrimaryKey(tp, values) if (tp.primKeyColumn != nil){ \
                                        values = [[values mutableCopy] autorelease]; \
                                        [(NSMutableDictionary*)values removeObjectForKey:tp.primKeyColumn]; \
                                     }


static NSMutableDictionary* typesBind;

@interface TypeProxy : NSObject
@property (nonatomic, assign) Class destClass;
@property (nonatomic, retain) NSString* tableName;
@property (nonatomic, assign) sqlite3* db;
@property (nonatomic, retain) NSString* primKeyColumn;
@property (nonatomic, assign) BOOL sqlBondable; //does class implement SQLBonded?
@property (nonatomic, assign) BOOL primKeyExposed; //if sqlBondable = YES, then this key tells if primary key is exposed in destClass as property
@property (nonatomic, retain) NSString* dbFileName; //database into which object should be serialized
@end

@implementation TypeProxy

@synthesize destClass, tableName, db, primKeyColumn, sqlBondable, dbFileName, primKeyExposed;

-(void)dealloc{
    self.destClass = nil;
    self.tableName = nil;
    self.db = nil;
    self.primKeyColumn = nil;
    self.dbFileName = nil;
    [super dealloc];
}

-(NSString*)description{
    return [NSString stringWithFormat:@"[TypeProxy class:%@, dbFileName:%@, table:%@, primKeyColumn:%@, sqlBondable:%d, primKeyExposed:%d]",
            NSStringFromClass(destClass), dbFileName, tableName, primKeyColumn, sqlBondable, primKeyExposed];
}
@end

@implementation AutoSerializer

+(void)initialize{
    typesBind = [[NSMutableDictionary alloc] init];
}

+(void)bindType:(Class)cl intoTable:(NSString*)table inDBNamed:(NSString*)dbFileName{
    TypeProxy* tp = [typesBind objectForKey:cl];
    NSAssert(tp == nil, @"Class %@ is already registered !", NSStringFromClass(cl));
    tp = [[[TypeProxy alloc] init] autorelease];
    tp.destClass = cl;
    tp.tableName = table;
    tp.dbFileName = dbFileName;
    if ([cl conformsToProtocol:@protocol(SQLBonded)] == YES){
        tp.sqlBondable = YES;
        if ([cl respondsToSelector:@selector(primaryKey)] == YES){
            tp.primKeyColumn = [cl primaryKey];
        } else {
            tp.primKeyColumn = @"primKey";
        }
        //check if we have setter for primaryKey
        tp.primKeyExposed = [ReflectionHelper checkProperty:tp.primKeyColumn inClass:cl forDesription:@"Ti,N,"];
        if (tp.primKeyExposed == NO){
            tp.primKeyExposed = [ReflectionHelper checkProperty:tp.primKeyColumn inClass:cl forDesription:@"Tl,N,"];
        }
    }
    [typesBind setObject:tp forKey:(id <NSCopying>)cl];
}

+(void)ensureDB:(TypeProxy*)tp{
    if (tp.db == nil){
        tp.db = [SQLiteHelper openDB:tp.dbFileName assumeCommonLocation:YES createIfNeeded:YES];
    } else {
        return;
    }
    NSMutableDictionary* classInfo = [[ReflectionHelper fieldsDetailedInfo:tp.destClass] mutableCopy];

    if (tp.sqlBondable == YES){
        [classInfo removeObjectForKey:tp.primKeyColumn];
        [classInfo setObject:@"i" forKey:[NSString stringWithFormat:@"#%@", tp.primKeyColumn]];
    }
    [SQLiteHelper ensureCompatibility:classInfo
                              atTable:tp.tableName
                                 inDB:tp.db
                   preserveOldInTable:[NSString stringWithFormat:@"%@_old", tp.tableName]];
    [classInfo release];
}

+(void)storeData:(id)obj{
    Class cl = [obj class];
    TypeProxy* tp = [typesBind objectForKey:cl];
    NSAssert(tp != nil, @"Class %@ is not registered !", NSStringFromClass(cl));
    NSDictionary* values = [ReflectionHelper serializeObjectRAW:obj];
    [self ensureDB:tp];
    removePrimaryKey(tp, values);
    int64_t r = [SQLiteHelper storeData:values intoTable:tp.tableName inDB:tp.db];
    NSNumber* n = [NSNumber numberWithLongLong:r];
    objc_setAssociatedObject(obj, UNIQUE_ID, n, OBJC_ASSOCIATION_RETAIN);
    if (tp.primKeyExposed == YES){
        [obj setValue:n forKey:tp.primKeyColumn];
    }
}

+(BOOL)tryRebind:(id)object{
    if (objc_getAssociatedObject(object, UNIQUE_ID) != nil){
        //already bond
        return YES;
    }
    SEL ss;
    if ([[object class] respondsToSelector:@selector(primaryKey)] == YES){
        ss = NSSelectorFromString([[object class] primaryKey]);
    } else {
        ss = @selector(primKey);
    }
    
    if ([object respondsToSelector:ss] == NO){
        return NO;
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                [[object class] instanceMethodSignatureForSelector:ss]];
    [invocation setSelector:ss];
    [invocation setTarget:object];
    [invocation invoke];
    long returnValue;
    [invocation getReturnValue:&returnValue];
    if (returnValue == 0){
        return NO;
    }
    objc_setAssociatedObject(object, UNIQUE_ID, @(returnValue), OBJC_ASSOCIATION_RETAIN);
    return YES;
}

+(void)storeOrUpdateData:(id)obj{
    NSNumber* n = objc_getAssociatedObject(obj, UNIQUE_ID);
    if (n == nil){
        [self storeData:obj];
    } else {
        [self updateData:obj];
    }
}

+(id)loadSingleData:(Class)cl where:(NSDictionary*)keyFields{
    TypeProxy* tp = [typesBind objectForKey:cl];
    NSAssert(tp != nil, @"Class %@ is not registered !", NSStringFromClass(cl));
    [self ensureDB:tp];
    NSMutableDictionary* r = [SQLiteHelper loadSingleData:keyFields atTable:tp.tableName inDB:tp.db];
    NSNumber* n = nil;
    if (tp.sqlBondable == YES){
        n = [r objectForKey:tp.primKeyColumn];
        [r removeObjectForKey:tp.primKeyColumn];
    }
    if ([r count] == 0){
        return nil;
    }
    //TODO: this block may be optimizd due to functionality refactor. Need more advanced architecture
    //ensure kye/objects coherence
    NSSet* clDesSet = [NSSet setWithArray:[ReflectionHelper fieldsList:cl]];
    NSMutableSet* dataKeySet = [NSMutableSet setWithArray:[r allKeys]];
    [dataKeySet minusSet:clDesSet];
    [r removeObjectsForKeys:[dataKeySet allObjects]];
    //deserialize
    id result = [ReflectionHelper deserializeRAWObject:r asType:cl];
    if (n != nil){
        objc_setAssociatedObject(result, UNIQUE_ID, n, OBJC_ASSOCIATION_RETAIN);
        if (tp.primKeyExposed == YES){
            [result setValue:n forKey:tp.primKeyColumn];
        }
    }
    return result;
}

+(NSArray*)loadData:(Class)cl where:(NSDictionary*)keyFields order:(NSArray*)orderFields limit:(NSNumber*) limit{
    TypeProxy* tp = [typesBind objectForKey:cl];
    NSAssert(tp != nil, @"Class %@ is not registered !", NSStringFromClass(cl));
    [self ensureDB:tp];
    NSMutableArray* arr = [SQLiteHelper loadData:keyFields atTable:tp.tableName inDB:tp.db];
    
    for(NSInteger t = 0, len = [arr count]; t < len; t++){
        NSMutableDictionary* r = [arr objectAtIndex:t];
        NSNumber* n = nil;
        if (tp.sqlBondable == YES){
            n = [r objectForKey:tp.primKeyColumn];
            [r removeObjectForKey:tp.primKeyColumn];
        }
        //TODO: this block may be optimizd due to functionality refactor. Need more advanced architecture
        //ensure kye/objects coherence
        NSSet* clDesSet = [NSSet setWithArray:[ReflectionHelper fieldsList:cl]];
        NSMutableSet* dataKeySet = [NSMutableSet setWithArray:[r allKeys]];
        [dataKeySet minusSet:clDesSet];
        [r removeObjectsForKeys:[dataKeySet allObjects]];
        
        //deserialize
        id tmp = [ReflectionHelper deserializeRAWObject:r asType:cl];
        if (n != nil){
            objc_setAssociatedObject(tmp, UNIQUE_ID, n, OBJC_ASSOCIATION_RETAIN);
            if (tp.primKeyExposed == YES){
                [tmp setValue:n forKey:tp.primKeyColumn];
            }
            
        }
        [arr setObject:tmp atIndexedSubscript:t];
    }
    return arr;
}
+(NSArray*)loadData:(Class)cl where:(NSDictionary*)keyFields{
    return [AutoSerializer loadData:cl where:keyFields order:nil limit:nil];
}

+(void)removeData:(id)obj{
    Class cl = [obj class];
    TypeProxy* tp = [typesBind objectForKey:cl];
    NSAssert(tp != nil, @"Class %@ is not registered !", NSStringFromClass(cl));
    [self ensureDB:tp];
    NSNumber* n = objc_getAssociatedObject(obj, UNIQUE_ID);
    NSAssert(n != nil, @"No primary key defined for object %@", obj);
    NSDictionary* d = [NSDictionary dictionaryWithObject:n forKey:tp.primKeyColumn];
    [SQLiteHelper removeData:d fromTable:tp.tableName inDB:tp.db];
}

+(void)updateData:(id)obj{
    Class cl = [obj class];
    TypeProxy* tp = [typesBind objectForKey:cl];
    NSAssert(tp != nil, @"Class %@ is not registered !", NSStringFromClass(cl));
    [self ensureDB:tp];
    NSNumber* n = objc_getAssociatedObject(obj, UNIQUE_ID);
    NSAssert(n != nil, @"No primary key defined for object %@", obj);
    NSMutableDictionary* d = [NSMutableDictionary dictionaryWithObject:n forKey:tp.primKeyColumn];

    NSDictionary* values = [ReflectionHelper serializeObjectRAW:obj];
    removePrimaryKey(tp, values);
    
    [SQLiteHelper updateData:values
                       where:d
                     atTable:tp.tableName
                        inDB:tp.db
                singleRecord:YES];
}

+(void)execSQL:(NSString*)sql withArguments:(NSArray*)args inContextOf:(Class)cl{
    TypeProxy* tp = [typesBind objectForKey:cl];
    NSAssert(tp != nil, @"Class %@ is not registered !", NSStringFromClass(cl));
    [self ensureDB:tp];
    sql = [sql stringByReplacingOccurrencesOfString:@":table" withString:tp.tableName];
    [SQLiteHelper execSQL:sql withArguments:args inDB:tp.db];
}

+(void)execSQL:(NSString*)sql withArguments:(NSArray*)args inContextOf:(Class)cl withResultHandler:(RawSQLResultHandler)blk{
    TypeProxy* tp = [typesBind objectForKey:cl];
    NSAssert(tp != nil, @"Class %@ is not registered !", NSStringFromClass(cl));
    [self ensureDB:tp];
    sql = [sql stringByReplacingOccurrencesOfString:@":table" withString:tp.tableName];
    [SQLiteHelper execSQL:sql withArguments:args andResultHandler:blk inDB:tp.db];
}
@end
