//
//  AutoserializerTest.m
//  VSCore
//
//  Created by Kamil Rzeźnicki on 10.12.2012.
//  Copyright (c) 2012 Bartłomiej Żarnowski. All rights reserved.
//

#import "AutoserializerTest.h"
#import "LumberjackBridge.h"
#import "SQLBonded.h"

@interface ItemForSer : NSObject<SQLBonded>
@property (assign) NSInteger intVal;
@property (assign) double doubleVal;
@property (assign) BOOL boolVal;
@property (assign) char charVal;
@property (assign) float floatVal;
@property (assign) long longVal;

@property (retain) NSDate* dateVal;
@property (retain) NSString* stringVal;


@end

@implementation ItemForSer
@synthesize intVal, stringVal, doubleVal, boolVal, charVal, dateVal, floatVal, longVal;

@end

@implementation AutoserializerTest
NSString* dbFileName;

+(void)initialize{
    // this caused errors, uncomment if you want to test this module!
    
//    [LumberjackBridge setupInDebug:LJB_DEFAULT];
//    dbFileName = [NSString stringWithFormat:@"%@%@", [FileHelper libraryPath:nil], @"testDB"];
//    NSLog(@"%@", dbFileName);
//    [dbFileName retain];
//    [FileHelper deleteFile:dbFileName];
//    [AutoSerializer bindType:[ItemForSer class] intoTable:@"itemForSer" inDBNamed:@"testDB"];
}

- (void)setUp
{
    
    [super setUp];
}

- (void)tearDown
{
    [AutoSerializer execSQL:@"DELETE FROM :table" withArguments:@[] inContextOf:[ItemForSer class]];
    [super tearDown];
}

-(void)testStoreAndLoadSingleData {
    ItemForSer* modelItem = [[[ItemForSer alloc] init] autorelease];
    modelItem.intVal = 100;
    modelItem.stringVal = @"Test string";
    modelItem.doubleVal = -69.123;
    modelItem.boolVal = YES;
    modelItem.charVal = 69;
    modelItem.dateVal = [[[NSDate alloc] init]autorelease];
    modelItem.floatVal = 0.000000000000000001;
    modelItem.longVal = LONG_MAX;
    
    
    [AutoSerializer storeData:modelItem];
    ItemForSer* testItem = [AutoSerializer loadSingleData:[ItemForSer class] where:@{@"intVal" : @(100)}];
    STAssertEquals(modelItem.intVal, testItem.intVal, @"expected YES");
    STAssertEquals(modelItem.doubleVal, testItem.doubleVal, @"expected YES");
    STAssertEquals(modelItem.boolVal, testItem.boolVal, @"expected YES");
    STAssertEquals(modelItem.charVal, testItem.charVal, @"expected  %c == %c", modelItem.charVal, testItem.charVal );
    STAssertEquals(modelItem.floatVal, testItem.floatVal, @"expected YES");
    STAssertEquals(modelItem.longVal, testItem.longVal, @"expected YES");

    STAssertEqualObjects(modelItem.stringVal, testItem.stringVal, @"expected YES");
    STAssertEquals([modelItem.dateVal timeIntervalSince1970], [testItem.dateVal timeIntervalSince1970], @"expected YES");
}

-(void)testStoreAndLoadSingleDataEmptyValues {
    ItemForSer* modelItem = [[[ItemForSer alloc] init] autorelease];
    modelItem.intVal = 100;
    modelItem.stringVal = @"";
    modelItem.dateVal = [[[NSDate alloc] init]autorelease];
    
    [AutoSerializer storeData:modelItem];
    ItemForSer* testItem = [AutoSerializer loadSingleData:[ItemForSer class] where:@{@"intVal" : @(100)}];
    STAssertEquals(modelItem.intVal, testItem.intVal, @"expected YES");
    STAssertEquals(modelItem.doubleVal, testItem.doubleVal, @"expected YES");
    STAssertEquals(modelItem.boolVal, testItem.boolVal, @"expected YES");
    STAssertEquals(modelItem.charVal, testItem.charVal, @"expected  %c == %c", modelItem.charVal, testItem.charVal );
    STAssertEquals(modelItem.floatVal, testItem.floatVal, @"expected YES");
    STAssertEquals(modelItem.longVal, testItem.longVal, @"expected YES");
    
    STAssertEqualObjects(modelItem.stringVal, testItem.stringVal, @"expected YES");
    STAssertEquals([modelItem.dateVal timeIntervalSince1970], [testItem.dateVal timeIntervalSince1970],
                   @"expected YES");
}

-(void)testLoadSingleDataWithDifferentKey {
        ItemForSer* modelItem = [[[ItemForSer alloc] init] autorelease];
        modelItem.intVal = 100;
        modelItem.stringVal = @"Test string";
        modelItem.doubleVal = -69.123;
        modelItem.boolVal = YES;
        modelItem.charVal = 'P';
        modelItem.dateVal = [[[NSDate alloc] init]autorelease];
        modelItem.floatVal = 0.000000000000000001;
        modelItem.longVal = LONG_MAX;
        
        
        [AutoSerializer storeData:modelItem];
        ItemForSer* testItem = [AutoSerializer loadSingleData:[ItemForSer class] where:@{@"stringVal" : @("Test string")}];
        STAssertEquals(modelItem.intVal, testItem.intVal, @"expected YES");
        
        
        testItem = [AutoSerializer loadSingleData:[ItemForSer class] where:@{@"doubleVal" : @(-69.123)}];
        STAssertEquals(modelItem.intVal, testItem.intVal, @"expected YES");
        
        testItem = [AutoSerializer loadSingleData:[ItemForSer class] where:@{@"longVal" : @(LONG_MAX)}];
        STAssertEquals(modelItem.intVal, testItem.intVal, @"expected YES");

    }



-(void)testStoreAndLoadData {
    ItemForSer* modelItem1 = [[[ItemForSer alloc] init] autorelease];
    modelItem1.intVal = 100;
    modelItem1.stringVal = @"Test string";
    modelItem1.doubleVal = -69.123;
    modelItem1.boolVal = YES;
    modelItem1.charVal = 69;
    modelItem1.dateVal = [[[NSDate alloc] init]autorelease];
    modelItem1.floatVal = 0.000000000000000001;
    modelItem1.longVal = LONG_MAX;
    
    ItemForSer* modelItem2 = [[[ItemForSer alloc] init] autorelease];
    modelItem2.intVal = 100;
    modelItem2.stringVal = @"";
    modelItem2.dateVal = [[[NSDate alloc] init]autorelease];
    
    ItemForSer* modelItem3 = [[[ItemForSer alloc] init] autorelease];
    modelItem3.intVal = 69;
    modelItem3.stringVal = @"";
    modelItem3.dateVal = [[[NSDate alloc] init]autorelease];
    
    ItemForSer* modelItem4 = [[[ItemForSer alloc] init] autorelease];
    modelItem4.intVal = 100;
    modelItem4.stringVal = @"";
    modelItem4.dateVal = [[[NSDate alloc] init]autorelease];

    ItemForSer* modelItem5 = [[[ItemForSer alloc] init] autorelease];
    modelItem5.intVal = 69;
    modelItem5.stringVal = @"test";
    modelItem5.dateVal = [[[NSDate alloc] init]autorelease];
    
     [AutoSerializer storeData:modelItem2];
     [AutoSerializer storeData:modelItem1];
     [AutoSerializer storeData:modelItem3];
     [AutoSerializer storeData:modelItem4];
     [AutoSerializer storeData:modelItem5];
    
    NSArray* arr = [AutoSerializer loadData:[ItemForSer class] where:@{@"intVal" : @(100)}];
    
    NSUInteger a = 3;
    STAssertEquals( a, [arr count], @"expected YES");
    
    ItemForSer* testItem = [arr objectAtIndex:0];
    STAssertEquals(modelItem2.intVal, testItem.intVal , @"expected YES");
    STAssertEquals(modelItem2.doubleVal, testItem.doubleVal, @"expected YES");
    STAssertEquals(modelItem2.boolVal, testItem.boolVal, @"expected YES");
    STAssertEquals(modelItem2.charVal, testItem.charVal, @"expected  %c == %c", modelItem2.charVal, testItem.charVal );
    STAssertEquals(modelItem2.floatVal, testItem.floatVal, @"expected YES");
    STAssertEquals(modelItem2.longVal, testItem.longVal, @"expected YES");
    
    STAssertEqualObjects(modelItem2.stringVal, testItem.stringVal, @"expected YES");
    STAssertEquals([modelItem2.dateVal timeIntervalSince1970], [testItem.dateVal timeIntervalSince1970],
                   @"expected YES");


    testItem = [arr objectAtIndex:1];
    STAssertEquals(modelItem1.intVal, testItem.intVal , @"expected YES");
    STAssertEquals(modelItem1.doubleVal, testItem.doubleVal, @"expected YES");
    STAssertEquals(modelItem1.boolVal, testItem.boolVal, @"expected YES");
    STAssertEquals(modelItem1.charVal, testItem.charVal, @"expected  %c == %c", modelItem1.charVal, testItem.charVal );
    STAssertEquals(modelItem1.floatVal, testItem.floatVal, @"expected YES");
    STAssertEquals(modelItem1.longVal, testItem.longVal, @"expected YES");
    
    STAssertEqualObjects(modelItem1.stringVal, testItem.stringVal, @"expected YES");
    STAssertEquals([modelItem1.dateVal timeIntervalSince1970], [testItem.dateVal timeIntervalSince1970],
                   @"expected YES");

    testItem = [arr objectAtIndex:2];
    STAssertEquals(modelItem4.intVal, testItem.intVal , @"expected YES");
    STAssertEquals(modelItem4.doubleVal, testItem.doubleVal, @"expected YES");
    STAssertEquals(modelItem4.boolVal, testItem.boolVal, @"expected YES");
    STAssertEquals(modelItem4.charVal, testItem.charVal, @"expected  %c == %c", modelItem4.charVal, testItem.charVal );
    STAssertEquals(modelItem4.floatVal, testItem.floatVal, @"expected YES");
    STAssertEquals(modelItem4.longVal, testItem.longVal, @"expected YES");
    
    STAssertEqualObjects(modelItem4.stringVal, testItem.stringVal, @"expected YES");
    STAssertEquals([modelItem4.dateVal timeIntervalSince1970], [testItem.dateVal timeIntervalSince1970],
                   @"expected YES");

}

-(void)testDoubleStoreOrUpdateData {
    ItemForSer* modelItem = [[[ItemForSer alloc] init] autorelease];
    modelItem.intVal = 100;
    modelItem.stringVal = @"";
    modelItem.dateVal = [[[NSDate alloc] init]autorelease];
    
    [AutoSerializer storeOrUpdateData:modelItem];
    [AutoSerializer storeOrUpdateData:modelItem];
    
    NSArray* arr = [AutoSerializer loadData:[ItemForSer class] where:@{@"intVal" : @(100)}];

    NSUInteger a = 1;
    STAssertEquals( a, [arr count], @"expected YES");
}

-(void)testStoreOrUpdateData {
    ItemForSer* modelItem = [[[ItemForSer alloc] init] autorelease];
    modelItem.intVal = 100;
    modelItem.stringVal = @"Test string";
    modelItem.doubleVal = -69.123;
    modelItem.boolVal = YES;
    modelItem.charVal = 'p';
    modelItem.dateVal = [[[NSDate alloc] init]autorelease];
    modelItem.floatVal = 0.000000000000000001;
    modelItem.longVal = LONG_MAX;
    
    [AutoSerializer storeData:modelItem];
    modelItem.boolVal = NO;
    
    [AutoSerializer storeOrUpdateData:modelItem];
    
    ItemForSer* testItem = [AutoSerializer loadSingleData:[ItemForSer class] where:@{@"intVal" : @(100)}];
    STAssertEquals(modelItem.boolVal, testItem.boolVal, @"expected YES");
    NSArray* arr = [AutoSerializer loadData:[ItemForSer class] where:@{@"intVal" : @(100)}];
    
    NSUInteger a = 1;
    STAssertEquals( a, [arr count], @"expected YES");
}

-(void)testUpdateData {
    ItemForSer* modelItem = [[[ItemForSer alloc] init] autorelease];
    modelItem.intVal = 100;
    modelItem.stringVal = @"Test string";
    modelItem.doubleVal = -69.123;
    modelItem.boolVal = YES;
    modelItem.charVal = 69;
    modelItem.dateVal = [[[NSDate alloc] init]autorelease];
    modelItem.floatVal = 0.000000000000000001;
    modelItem.longVal = LONG_MAX;
    
    [AutoSerializer storeData:modelItem];
    modelItem.stringVal = @"lolo";
    modelItem.doubleVal = -69.0;
    modelItem.boolVal = NO;
    modelItem.charVal = 5678;
    modelItem.dateVal = [[[NSDate alloc] init]autorelease];
    modelItem.floatVal = 0.001;
    modelItem.longVal = 12;
    
       [AutoSerializer updateData:modelItem];

    ItemForSer* testItem = [AutoSerializer loadSingleData:[ItemForSer class] where:@{@"intVal" : @(100)}];
    NSArray* a = [AutoSerializer loadData:[ItemForSer class] where:nil];
    STAssertEquals(modelItem.intVal, testItem.intVal, @"expected YES");
    STAssertEquals(modelItem.doubleVal, testItem.doubleVal, @"expected YES");
    STAssertEquals(modelItem.boolVal, testItem.boolVal, @"expected YES");
    STAssertEquals(modelItem.charVal, testItem.charVal, @"expected  %c == %c", modelItem.charVal, testItem.charVal );
    STAssertEquals(modelItem.floatVal, testItem.floatVal, @"expected YES");
    STAssertEquals(modelItem.longVal, testItem.longVal, @"expected YES");
    
    STAssertEqualObjects(modelItem.stringVal, testItem.stringVal, @"expected YES");
    STAssertEquals([modelItem.dateVal timeIntervalSince1970], [testItem.dateVal timeIntervalSince1970],
                   @"expected YES");
    

}

-(void)testRemoveData {
    ItemForSer* modelItem1 = [[[ItemForSer alloc] init] autorelease];
    modelItem1.intVal = 100;
    modelItem1.stringVal = @"Test string";
    modelItem1.doubleVal = -69.123;
    modelItem1.boolVal = YES;
    modelItem1.charVal = 69;
    modelItem1.dateVal = [[[NSDate alloc] init]autorelease];
    modelItem1.floatVal = 0.000000000000000001;
    modelItem1.longVal = LONG_MAX;
    
    ItemForSer* modelItem2 = [[[ItemForSer alloc] init] autorelease];
    modelItem2.intVal = 100;
    modelItem2.stringVal = @"";
    modelItem2.dateVal = [[[NSDate alloc] init]autorelease];
    
    ItemForSer* modelItem3 = [[[ItemForSer alloc] init] autorelease];
    modelItem3.intVal = 69;
    modelItem3.stringVal = @"";
    modelItem3.dateVal = [[[NSDate alloc] init]autorelease];
    
    ItemForSer* modelItem4 = [[[ItemForSer alloc] init] autorelease];
    modelItem4.intVal = 100;
    modelItem4.stringVal = @"arrr";
    modelItem4.dateVal = [[[NSDate alloc] init]autorelease];
    
    ItemForSer* modelItem5 = [[[ItemForSer alloc] init] autorelease];
    modelItem5.intVal = 69;
    modelItem5.stringVal = @"test";
    modelItem5.dateVal = [[[NSDate alloc] init]autorelease];
    
    [AutoSerializer storeData:modelItem2];
    [AutoSerializer storeData:modelItem1];
    [AutoSerializer storeData:modelItem3];
    [AutoSerializer storeData:modelItem4];
    [AutoSerializer storeData:modelItem5];
    
    [AutoSerializer removeData:modelItem1];
    [AutoSerializer removeData:modelItem2];
    [AutoSerializer removeData:modelItem3];
  
    NSArray* arr = [AutoSerializer loadData:[ItemForSer class] where:@{@"intVal" : @(69)}];
    
    NSUInteger a = 1;
    STAssertEquals( a, [arr count], @"expected YES");
    
    ItemForSer* testItem = [arr objectAtIndex:0];
    STAssertEquals(modelItem5.intVal, testItem.intVal , @"expected YES");
    STAssertEquals(modelItem5.doubleVal, testItem.doubleVal, @"expected YES");
    STAssertEquals(modelItem5.boolVal, testItem.boolVal, @"expected YES");
    STAssertEquals(modelItem5.charVal, testItem.charVal, @"expected  %c == %c", modelItem2.charVal, testItem.charVal );
    STAssertEquals(modelItem5.floatVal, testItem.floatVal, @"expected YES");
    STAssertEquals(modelItem5.longVal, testItem.longVal, @"expected YES");

    
}

-(void)testDoubleConditions {
    ItemForSer* modelItem1 = [[[ItemForSer alloc] init] autorelease];
    modelItem1.intVal = 100;
    modelItem1.stringVal = @"Test string";
    modelItem1.doubleVal = -69.123;
    modelItem1.boolVal = YES;
    modelItem1.charVal = 69;
    modelItem1.dateVal = [[[NSDate alloc] init]autorelease];
    modelItem1.floatVal = 0.000000000000000001;
    modelItem1.longVal = 2;
    
    [AutoSerializer storeData:modelItem1];
    NSArray* arr = [AutoSerializer loadData:[ItemForSer class] where:@{@"intVal" : @(100), @"longVal" : @(2)}];
    
    NSUInteger a = 1;
    STAssertEquals( a, [arr count], @"expected YES");
}

-(void)testExecSQL{
    
    ItemForSer* modelItem1 = [[[ItemForSer alloc] init] autorelease];
    modelItem1.intVal = 100;
    modelItem1.stringVal = @"Test string";
    modelItem1.doubleVal = -69.123;
    modelItem1.boolVal = YES;
    modelItem1.charVal = 69;
    modelItem1.dateVal = [[[NSDate alloc] init]autorelease];
    modelItem1.floatVal = 0.000000000000000001;
    modelItem1.longVal = 2;
    
    [AutoSerializer storeData:modelItem1];
    NSValue *intValue = [NSNumber numberWithInt:modelItem1.intVal];
    NSValue *longValue = [NSNumber numberWithLong: modelItem1.longVal];
    NSArray *myArray = [NSArray arrayWithObjects: intValue ,longValue,  nil];

    [AutoSerializer execSQL:@"DELETE FROM itemForSer WHERE intVal = ? AND longVal = ?" withArguments:myArray inContextOf:[ItemForSer class]];
    
    NSArray* arr = [AutoSerializer loadData:[ItemForSer class] where:nil];
    
    NSUInteger a = 0;
    STAssertEquals( a, [arr count], @"expected YES");
    
    
    NSValue *doubleValue = [NSNumber numberWithDouble: modelItem1.doubleVal];
    NSValue *boolValue = [NSNumber numberWithBool: modelItem1.boolVal];
    NSValue *charValue = [NSNumber numberWithChar: modelItem1.charVal];
    NSValue *floatValue = [NSNumber numberWithFloat: modelItem1.floatVal];
    myArray = [NSArray arrayWithObjects: intValue, modelItem1.stringVal, doubleValue, boolValue, charValue, modelItem1.dateVal, floatValue, longValue,  nil];
    
    
    [AutoSerializer execSQL:@"INSERT INTO :table (intVal, stringVal, doubleVal, boolVal, charVal, dateVal, floatVal, longVal) values(?, ?, ?, ?, ?, ?, ?, ?)" withArguments:myArray inContextOf:[ItemForSer class]];
    
    
    arr = [AutoSerializer loadData:[ItemForSer class] where:nil];
    
    a = 1;
    STAssertEquals( a, [arr count], @"expected YES");
    
    ItemForSer* testItem = [AutoSerializer loadSingleData:[ItemForSer class] where:@{@"intVal" : @(100)}];
    STAssertEquals(modelItem1.intVal, testItem.intVal, @"expected YES");
    STAssertEquals(modelItem1.doubleVal, testItem.doubleVal, @"expected YES");
    STAssertEquals(modelItem1.boolVal, testItem.boolVal, @"expected YES");
    STAssertEquals(modelItem1.charVal, testItem.charVal, @"expected  %c == %c", modelItem1.charVal, testItem.charVal );
    STAssertEquals(modelItem1.floatVal, testItem.floatVal, @"expected YES");
    STAssertEquals(modelItem1.longVal, testItem.longVal, @"expected YES");

    intValue = [NSNumber numberWithInt: 69];
    NSString* str2 = @"FELIZ NAVIDAD!";
    NSValue* i = [NSNumber numberWithInt:0];
    
    myArray = [NSArray arrayWithObjects: intValue ,str2, i, nil];

    [AutoSerializer execSQL:@"UPDATE itemForSer SET intVal = ?, stringVal = ? WHERE longVal > ?" withArguments:myArray inContextOf:[ItemForSer class]];
    
    testItem = [AutoSerializer loadSingleData:[ItemForSer class] where:@{@"intVal" : @(69)}];
    STAssertEquals(69, testItem.intVal, @"expected YES");
    STAssertEqualObjects(str2, testItem.stringVal, @"expected YES");
 
    
    	

}

-(void)testExecSQLWithBlock {
    ItemForSer* modelItem1 = [[[ItemForSer alloc] init] autorelease];
    modelItem1.intVal = 100;
    modelItem1.stringVal = @"Test string";
    modelItem1.doubleVal = -69.123;
    modelItem1.boolVal = YES;
    modelItem1.charVal = 69;
    modelItem1.dateVal = [[[NSDate alloc] init]autorelease];
    modelItem1.floatVal = 0.000000000000000001;
    modelItem1.longVal = 4;
    
    ItemForSer* modelItem2 = [[[ItemForSer alloc] init] autorelease];
    modelItem2.intVal = 100;
    modelItem2.stringVal = @"";
    modelItem2.longVal = -100;
    modelItem2.dateVal = [[[NSDate alloc] init]autorelease];
    
    ItemForSer* modelItem3 = [[[ItemForSer alloc] init] autorelease];
    modelItem3.intVal = 69;
    modelItem3.stringVal = @"";
    modelItem3.longVal = 1234567890;
    modelItem3.dateVal = [[[NSDate alloc] init]autorelease];
    
    ItemForSer* modelItem4 = [[[ItemForSer alloc] init] autorelease];
    modelItem4.intVal = 100;
    modelItem4.stringVal = @"arrr";
    modelItem4.longVal = LONG_MIN;
    modelItem4.dateVal = [[[NSDate alloc] init]autorelease];
    
    ItemForSer* modelItem5 = [[[ItemForSer alloc] init] autorelease];
    modelItem5.intVal = 69;
    modelItem5.stringVal = @"test";
    modelItem5.longVal = 7;
    modelItem5.dateVal = [[[NSDate alloc] init]autorelease];
    
    [AutoSerializer storeData:modelItem2];
    [AutoSerializer storeData:modelItem1];
    [AutoSerializer storeData:modelItem3];
    [AutoSerializer storeData:modelItem4];
    [AutoSerializer storeData:modelItem5];
    
    __block NSMutableArray* myArray = [[NSMutableArray alloc] init];
    RawSQLResultHandler handler = ^(sqlite3_stmt *st){
        NSInteger sqlRes = sqlite3_step(st);
        while(sqlRes == SQLITE_ROW) {
            NSNumber* dest = [NSNumber numberWithLongLong: sqlite3_column_int64(st, 1)];
            NSLog(@"-------  %@", dest);
                [myArray addObject:dest];
            sqlRes = sqlite3_step(st);
        }
        NSLog(@"kuniec");
    };
    
    NSArray* arr = [NSArray arrayWithObjects:[NSNumber numberWithInt:100], nil];
    NSString* sql = @"SELECT stringVal, longVal FROM :table WHERE intVal = ?  ORDER BY longVal";
    [AutoSerializer execSQL:sql withArguments:arr inContextOf:[ItemForSer class] withResultHandler:handler];
    
    NSUInteger a = 3;
    STAssertEquals( a, [myArray count], @"expected YES");
    NSNumber* val = [myArray objectAtIndex:0];
    STAssertEqualObjects([NSNumber numberWithLong: modelItem4.longVal], val , @"expected YES");
     val = [myArray objectAtIndex:1];
    STAssertEqualObjects([NSNumber numberWithLong: modelItem2.longVal], val , @"expected YES");
     val = [myArray objectAtIndex:2];
    STAssertEqualObjects([NSNumber numberWithLong: modelItem1.longVal], val , @"expected YES");
}

-(void)dealloc {
//    [FileHelper deleteFile:dbFileName];
//    [dbFileName release];
    [super dealloc];
}


@end

