//
//  SQLiteHelperTests.m
//  VSCore
//
//  Created by Marek Kotewicz on 12/4/12.
//  Copyright (c) 2012 Bartłomiej Żarnowski. All rights reserved.
//


#import "SQLiteHelperTests.h"


@implementation SQLiteHelperTests


- (void)setUp{
    [super setUp];
}

- (void)tearDown{    
    [super tearDown];
}

- (void)testAddDifferentColTypes{
    
    sqlite3 *db = [SQLiteHelper openDB:@"test1" assumeCommonLocation:YES createIfNeeded:NO];
    //STAssertNotNil(db, @"Expected to openDB");
    
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"i", @"ColInt",
                          @"NSString", @"ColStr",
                          @"c", @"ColBool",
                          @"q", @"ColLongLong",
//                          @"I", @"ColObjCLong",
                          @"f", @"ColObjCFloat",
                          @"NSMutableString", @"ColObjCMutableString",
//                          @"NSDate", @"ColObjCNSDate",
                          nil];
    
    [SQLiteHelper ensureCompatibility:dict atTable:@"testDict1" inDB:db preserveOldInTable:@"oldDict"];
    
    STAssertTrue([SQLiteHelper checkCompatibility:dict atTable:@"testDict1" inDB:db], @"Expected YES");
    
    NSData *date = [NSDate date];
    
    NSMutableDictionary *tmp = [[[NSMutableDictionary alloc]init]autorelease];
    [tmp setObject:@"someString" forKey:@"ColStr"];
    [tmp setObject:[NSNumber numberWithInt:7] forKey:@"ColInt"];
    [tmp setObject:[NSNumber numberWithBool:YES] forKey:@"ColBool"];
    [tmp setObject:[NSNumber numberWithLongLong:123151231] forKey:@"ColLongLong"];
//    [tmp setObject:[NSNumber numberWithLong:1231231] forKey:@"ColObjCLong"];
    [tmp setObject:[NSNumber numberWithFloat:123.1231] forKey:@"ColObjCFloat"];
    [tmp setObject:@"mutableString" forKey:@"ColObjCMutableString"];
//    [tmp setObject:date forKey:@"ColObjCNSDate"];
    
    [SQLiteHelper storeData:tmp intoTable:@"testDict1" inDB:db];
    STAssertEqualObjects(tmp, [SQLiteHelper loadSingleData:tmp atTable:@"testDict1" inDB:db], @"Expected to be equal");

    [SQLiteHelper closeDB:db];
}

- (void)testPreserveOldInTable{
    
    sqlite3 *db = [SQLiteHelper openDB:@"test1" assumeCommonLocation:YES createIfNeeded:NO];
    //STAssertNotNil(db, @"Expected to openDB");
    
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc]init]autorelease];
    NSMutableDictionary *dict2 = [[[NSMutableDictionary alloc]init]autorelease];
    
    [dict setObject:[NSString stringWithFormat:@"i"] forKey:[NSString stringWithFormat:@"ColString1"]];
    
    [dict2 setObject:[NSString stringWithFormat:@"i"] forKey:[NSString stringWithFormat:@"ColString2"]];
    [dict2 setObject:[NSString stringWithFormat:@"c"] forKey:[NSString stringWithFormat:@"ColString3"]];
    
    [SQLiteHelper ensureCompatibility:dict atTable:@"testDict1" inDB:db preserveOldInTable:@"oldDict"];
    STAssertTrue([SQLiteHelper checkCompatibility:dict atTable:@"testDict1" inDB:db], @"Expected YES");
    
    [SQLiteHelper ensureCompatibility:dict2 atTable:@"testDict1" inDB:db preserveOldInTable:@"oldDict"];
    STAssertTrue([SQLiteHelper checkCompatibility:dict2 atTable:@"testDict1" inDB:db], @"Expected YES");
    
    STAssertTrue([SQLiteHelper checkCompatibility:dict atTable:@"oldDict" inDB:db], @"Expected YES");

    [SQLiteHelper closeDB:db];
}

- (void)testDontPreserveOldInTable{
    
    sqlite3 *db = [SQLiteHelper openDB:@"test1" assumeCommonLocation:YES createIfNeeded:NO];
    //STAssertNotNil(db, @"Expected to openDB");
    
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc]init]autorelease];
    NSMutableDictionary *dict2 = [[[NSMutableDictionary alloc]init]autorelease];
    
    [dict setObject:@"i" forKey:@"ColString1"];
    
    [dict2 setObject:@"i" forKey:@"ColString2"];
    [dict2 setObject:@"c" forKey:@"ColString3"];
    
    [SQLiteHelper ensureCompatibility:dict atTable:@"testDict1" inDB:db preserveOldInTable:@"oldDict"];
    STAssertTrue([SQLiteHelper checkCompatibility:dict atTable:@"testDict1" inDB:db], @"Expected YES");
    
    [SQLiteHelper ensureCompatibility:dict2 atTable:@"testDict1" inDB:db preserveOldInTable:nil];
    STAssertTrue([SQLiteHelper checkCompatibility:dict2 atTable:@"testDict1" inDB:db], @"Expected YES");
    
    //STAssertTrue([SQLiteHelper checkCompatibility:dict atTable:@"oldDict" inDB:db], @"Expected YES");
    
    [SQLiteHelper closeDB:db];
}



- (void)testStoreData{
    
    sqlite3 *db = [SQLiteHelper openDB:@"test1" assumeCommonLocation:YES createIfNeeded:NO];
    //STAssertNotNil(db, @"Expected to openDB");
    
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc]init]autorelease];
    NSMutableDictionary *dict2 = [[[NSMutableDictionary alloc]init]autorelease];
    
    [dict setObject:[NSString stringWithFormat:@"NSString"] forKey:[NSString stringWithFormat:@"ColStore1"]];
    [dict setObject:[NSString stringWithFormat:@"NSString"] forKey:[NSString stringWithFormat:@"ColStore2"]];
    
    [SQLiteHelper ensureCompatibility:dict atTable:@"testDict1" inDB:db preserveOldInTable:@"oldDict"];
    STAssertTrue([SQLiteHelper checkCompatibility:dict atTable:@"testDict1" inDB:db], @"Expected YES");
    
    [dict2 setObject:[NSString stringWithFormat:@"test1"] forKey:[NSString stringWithFormat:@"ColStore1"]];
    [dict2 setObject:[NSString stringWithFormat:@"test2"] forKey:[NSString stringWithFormat:@"ColStore2"]];
    
    [SQLiteHelper storeData:dict2 intoTable:@"testDict1" inDB:db];
    
    STAssertEqualObjects(dict2, [SQLiteHelper loadSingleData:dict2 atTable:@"testDict1" inDB:db], @"Expected to be equal");
    
    [SQLiteHelper closeDB:db];
}

- (void)testMultiAccessFromSingleThread{
    
    sqlite3 *db1 = [SQLiteHelper openDB:@"test1" assumeCommonLocation:YES createIfNeeded:NO];
    //STAssertNotNil(db1, @"Expected to openDB");
    sqlite3 *db2 = [SQLiteHelper openDB:@"test1" assumeCommonLocation:YES createIfNeeded:NO];
    //STAssertNotNil(db2, @"Expected to openDB");
    
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc]init]autorelease];
    
    [dict setObject:[NSString stringWithFormat:@"q"] forKey:[NSString stringWithFormat:@"ColLongLong"]];
    
    [SQLiteHelper ensureCompatibility:dict atTable:@"testDict1" inDB:db1 preserveOldInTable:@"oldDict"];
    
    STAssertTrue([SQLiteHelper checkCompatibility:dict atTable:@"testDict1" inDB:db2], @"Expected YES");
    
    [SQLiteHelper closeDB:db1];
    [SQLiteHelper closeDB:db2];
}
//
- (void)testUpdateData{
    
    sqlite3 *db = [SQLiteHelper openDB:@"test1" assumeCommonLocation:YES createIfNeeded:NO];
    //STAssertNotNil(db, @"Expected to openDB");
    
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc]init]autorelease];
    NSMutableDictionary *dict2 = [[[NSMutableDictionary alloc]init]autorelease];
    
    [dict setObject:[NSString stringWithFormat:@"NSString"] forKey:[NSString stringWithFormat:@"ColUpdate"]];
    [dict setObject:[NSString stringWithFormat:@"NSString"] forKey:[NSString stringWithFormat:@"ColUpdate2"]];

    
    [SQLiteHelper ensureCompatibility:dict atTable:@"testDict1" inDB:db preserveOldInTable:@"oldDict"];
    
    STAssertTrue([SQLiteHelper checkCompatibility:dict atTable:@"testDict1" inDB:db], @"Expected YES");
    
    [dict setObject:@"test1" forKey:@"ColUpdate"];
    [dict setObject:@"test2" forKey:@"ColUpdate2"];
    [SQLiteHelper storeData:dict intoTable:@"testDict1" inDB:db];
    STAssertEqualObjects([SQLiteHelper loadSingleData:dict atTable:@"testDict1" inDB:db], dict, @"Expected to be equal");

    [dict2 setObject:@"test123" forKey:@"ColUpdate"];
    [SQLiteHelper updateData:dict2 where:dict atTable:@"testDict1" inDB:db singleRecord:YES];
    STAssertEqualObjects([[SQLiteHelper loadSingleData:dict2 atTable:@"testDict1" inDB:db] objectForKey:@"ColUpdate"],
                         [dict2 objectForKey:@"ColUpdate"] ,
                         @"Expected to be equal");
    
    [SQLiteHelper closeDB:db];
    
}

- (void)testUpdateDataSingleNo{
    
    sqlite3 *db = [SQLiteHelper openDB:@"test1" assumeCommonLocation:YES createIfNeeded:NO];
    //STAssertNotNil(db, @"Expected to openDB");
    
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc]init]autorelease];
    NSMutableDictionary *dict2 = [[[NSMutableDictionary alloc]init]autorelease];
    
    [dict setObject:[NSString stringWithFormat:@"NSString"] forKey:[NSString stringWithFormat:@"ColUpdate"]];
    [dict setObject:[NSString stringWithFormat:@"NSString"] forKey:[NSString stringWithFormat:@"ColUpdate2"]];
    
    
    [SQLiteHelper ensureCompatibility:dict atTable:@"testDict1" inDB:db preserveOldInTable:@"oldDict"];
    
    STAssertTrue([SQLiteHelper checkCompatibility:dict atTable:@"testDict1" inDB:db], @"Expected YES");
    
    [dict setObject:@"test1" forKey:@"ColUpdate"];
    [dict setObject:@"test2" forKey:@"ColUpdate2"];
    [SQLiteHelper storeData:dict intoTable:@"testDict1" inDB:db];
    STAssertEqualObjects([SQLiteHelper loadSingleData:dict atTable:@"testDict1" inDB:db], dict, @"Expected to be equal");
    
    [dict2 setObject:@"test123" forKey:@"ColUpdate"];
    [SQLiteHelper updateData:dict2 where:dict atTable:@"testDict1" inDB:db singleRecord:NO];
    STAssertEqualObjects([[SQLiteHelper loadSingleData:dict2 atTable:@"testDict1" inDB:db] objectForKey:@"ColUpdate"],
                         [dict2 objectForKey:@"ColUpdate"] ,
                         @"Expected to be equal");
    
    [SQLiteHelper closeDB:db];
    
}

- (void)testRemoveSomeKeys{
    
    sqlite3 *db = [SQLiteHelper openDB:@"test1" assumeCommonLocation:YES createIfNeeded:NO];
    //STAssertNotNil(db, @"Expected to openDB");
 
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc]init]autorelease];
    [dict setObject:[NSString stringWithFormat:@"NSString"] forKey:[NSString stringWithFormat:@"ColRemove1"]];
    
    [SQLiteHelper ensureCompatibility:dict atTable:@"testDict1" inDB:db preserveOldInTable:@"oldDict"];
    
    [dict setObject:@"second_remove1" forKey:@"ColRemove1"];
    
    [SQLiteHelper storeData:dict intoTable:@"testDict1" inDB:db];
    
    [SQLiteHelper removeData:dict fromTable:@"testDict1" inDB:db];
    
    STAssertEquals(0, (int)[[SQLiteHelper loadSingleData:dict atTable:@"testDict1" inDB:db] count], @"Expected to be equal");
    
    NSMutableDictionary *dict2 = [[[NSMutableDictionary alloc]init]autorelease];
    [dict2 setObject:@"NSString" forKey:@"ColRemove1"];
    [dict2 setObject:@"NSString" forKey:@"ColRemove2"];
    
    [SQLiteHelper ensureCompatibility:dict2 atTable:@"testDict1" inDB:db preserveOldInTable:@"oldDict"];
    
    [dict2 setObject:@"second_remove1" forKey:@"ColRemove1"];
    [dict2 setObject:@"second_remove2" forKey:@"ColRemove2"];
    
    [SQLiteHelper storeData:dict2 intoTable:@"testDict1" inDB:db];
    
    [SQLiteHelper removeData:dict fromTable:@"testDict1" inDB:db];
    
    STAssertEquals(0, (int)[[SQLiteHelper loadSingleData:dict atTable:@"testDict1" inDB:db] count], @"Expected to be equal");

    [SQLiteHelper closeDB:db];
}

- (void)testMultiStore{
    sqlite3 *db = [SQLiteHelper openDB:@"test1" assumeCommonLocation:YES createIfNeeded:NO];
    //STAssertNotNil(db, @"Expected to openDB");
    
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc]init]autorelease];
    NSMutableDictionary *dict2 = [[[NSMutableDictionary alloc]init]autorelease];
    
    [dict setObject:@"NSString" forKey:@"ColMultiStore1"];
    [dict setObject:@"NSString" forKey:@"ColMultiStore2"];
    
    [SQLiteHelper ensureCompatibility:dict atTable:@"testDict1" inDB:db preserveOldInTable:@"oldDict"];
    
    [dict setObject:@"first_store" forKey:@"ColMultiStore1"];
    [dict setObject:@"first_store" forKey:@"ColMultiStore2"];
    
    [SQLiteHelper storeData:dict intoTable:@"testDict1" inDB:db];
    
    STAssertEqualObjects([SQLiteHelper loadSingleData:dict atTable:@"testDict1" inDB:db], dict, @"Expected to be equal");
    
    //FIXME: Store dictionary with smaller size
    
    [dict2 setObject:@"second_store" forKey:@"ColMultiStore1"];
    [dict2 setObject:@"second_store" forKey:@"ColMultiStore2"];
    
    [SQLiteHelper storeData:dict2 intoTable:@"testDict1" inDB:db];
    
    //NSMutableDictionary *tmp = [SQLiteHelper loadSingleData:dict2 atTable:@"testDict1" inDB:db];
    
    STAssertEqualObjects([SQLiteHelper loadSingleData:dict2 atTable:@"testDict1" inDB:db], dict2, @"Expected to be equal");
    
    [SQLiteHelper closeDB:db];
}


- (void)testLoadData{
    sqlite3 *db = [SQLiteHelper openDB:@"test1" assumeCommonLocation:YES createIfNeeded:NO];
    //STAssertNotNil(db, @"Expected to openDB");
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    
    [dict setObject:@"NSString" forKey:@"ColLoadData1"];
    [dict setObject:@"NSString" forKey:@"ColLoadData2"];
    
    [SQLiteHelper ensureCompatibility:dict atTable:@"testDict1" inDB:db preserveOldInTable:@"oldDict"];
    
    [dict setObject:@"some_value1" forKey:@"ColLoadData1"];
    [dict setObject:@"some_value2" forKey:@"ColLoadData2"];
    
    [SQLiteHelper storeData:dict intoTable:@"testDict1" inDB:db];

    STAssertEqualObjects(dict, (NSDictionary*)[[SQLiteHelper loadData:dict atTable:@"testDict1" inDB:db] objectAtIndex:0], @"Expected to be equal");
    
    [SQLiteHelper closeDB:db];
}

- (void)threadedStart{
    sqlite3 *db = [SQLiteHelper openDB:@"multiTest1" assumeCommonLocation:YES createIfNeeded:YES];
    
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc]init]autorelease];
    
    for (int i = 0; i < 300; i++){
        [dict setObject:@"NSString" forKey:[NSString stringWithFormat:@"ColTest1_%i", i]];
    }
    
    [SQLiteHelper ensureCompatibility:dict atTable:@"multi1" inDB:db preserveOldInTable:@"multiOld1"];
    
    [SQLiteHelper storeData:dict intoTable:@"multi1" inDB:db];
    
    [SQLiteHelper closeDB:db];
}

- (void)threadedEdit1{
    @autoreleasepool {
    sqlite3 *db = [SQLiteHelper openDB:@"multiTest1" assumeCommonLocation:YES createIfNeeded:NO];
    
    NSMutableDictionary *original = [[[NSMutableDictionary alloc]init]autorelease];
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc]init]autorelease];
    
    for (int i = 0; i < 100; i++){
        [original setObject:@"NSString" forKey:[NSString stringWithFormat:@"ColTest1_%i", i]];
    }
    
    for (int i = 0; i < 100; i++){
        [dict setObject:@"test1" forKey:[NSString stringWithFormat:@"ColTest1_%i", i]];
    }
    
    [SQLiteHelper updateData:dict where:original atTable:@"multi1" inDB:db singleRecord:NO];
    
    [SQLiteHelper closeDB:db];
    }
}

- (void)threadedEdit2{
    @autoreleasepool {
    sqlite3 *db = [SQLiteHelper openDB:@"multiTest1" assumeCommonLocation:YES createIfNeeded:NO];
    
    NSMutableDictionary *original = [[[NSMutableDictionary alloc]init]autorelease];
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc]init]autorelease];
    
    for (int i = 100; i < 200; i++){
        [original setObject:@"NSString" forKey:[NSString stringWithFormat:@"ColTest1_%i", i]];
    }
    
    for (int i = 100; i < 200; i++){
        [dict setObject:@"test2" forKey:[NSString stringWithFormat:@"ColTest1_%i", i]];
    }
    
    [SQLiteHelper updateData:dict where:original atTable:@"multi1" inDB:db singleRecord:NO];
    
    [SQLiteHelper closeDB:db];
    }
}

- (void)threadedEdit3{
    @autoreleasepool {
    sqlite3 *db = [SQLiteHelper openDB:@"multiTest1" assumeCommonLocation:YES createIfNeeded:NO];
    
    NSMutableDictionary *original = [[[NSMutableDictionary alloc]init]autorelease];
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc]init]autorelease];
    
    for (int i = 200; i < 300; i++){
        [original setObject:@"NSString" forKey:[NSString stringWithFormat:@"ColTest1_%i", i]];
    }
    
    for (int i = 200; i < 300; i++){
        [dict setObject:@"test3" forKey:[NSString stringWithFormat:@"ColTest1_%i", i]];
    }
    
    [SQLiteHelper updateData:dict where:original atTable:@"multi1" inDB:db singleRecord:NO];
    
    [SQLiteHelper closeDB:db];
    }
}

- (void)testThreads{
    [self threadedStart];
    NSThread* editThread1 = [[NSThread alloc]initWithTarget:self selector:@selector(threadedEdit1) object:nil];
    NSThread* editThread2 = [[NSThread alloc]initWithTarget:self selector:@selector(threadedEdit2) object:nil];
    NSThread* editThread3 = [[NSThread alloc]initWithTarget:self selector:@selector(threadedEdit3) object:nil];
    
    [editThread1 setName:@"Editting thread1"];
    [editThread2 setName:@"Editting thread2"];
    [editThread3 setName:@"Editting thread3"];
    
    [editThread1 start];
    [editThread2 start];
    [editThread3 start];
    
    while ( ([editThread1 isFinished] == NO) || ([editThread2 isFinished] == NO) || ([editThread3 isFinished] == NO) ){
        usleep(500);
    };
    
    [editThread1 release];
    [editThread2 release];
    [editThread3 release];
    
    sqlite3 *db = [SQLiteHelper openDB:@"multiTest1" assumeCommonLocation:YES createIfNeeded:NO];
    
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc]init]autorelease];
    for (int i = 0; i < 100; i++){
        [dict setObject:@"test1" forKey:[NSString stringWithFormat:@"ColTest1_%i", i]];
        [dict setObject:@"test2" forKey:[NSString stringWithFormat:@"ColTest1_%i", (i+100)]];
        [dict setObject:@"test3" forKey:[NSString stringWithFormat:@"ColTest1_%i", (i+200)]];
    }
    
    STAssertTrue([SQLiteHelper checkCompatibility:dict atTable:@"multi1" inDB:db], @"Expected YES");
    
    NSDictionary *tmp = [SQLiteHelper loadSingleData:dict atTable:@"multi1" inDB:db];
    
    STAssertEqualObjects([SQLiteHelper loadSingleData:dict atTable:@"multi1" inDB:db], dict, @"Expected to be equal");
}

- (void)threadedRandom1{
    @autoreleasepool {
        sqlite3 *db = [SQLiteHelper openDB:@"multiTest1" assumeCommonLocation:YES createIfNeeded:NO];
        for (int i = 0; i < 5000; i++){
            int a = rand()%300;
            
            NSDictionary *dict = [[[NSDictionary alloc]
                                  initWithObjectsAndKeys:
                                  @"rand", [NSString stringWithFormat:@"ColTest1_%i", a],
                                  nil]autorelease];
            
            NSDictionary *where = [[[NSDictionary alloc]
                                   initWithObjectsAndKeys:[[SQLiteHelper loadSingleData:dict atTable:@"multi1" inDB:db]  objectForKey:[NSString stringWithFormat:@"ColTest1_%i", a]],
                                   [NSString stringWithFormat:@"ColTest1_%i", a], nil]autorelease];
            
            [SQLiteHelper updateData:dict
                               where:where
                             atTable:@"multi1"
                                inDB:db
                        singleRecord:NO];
            usleep(rand()%200);
        }
        [SQLiteHelper closeDB:db];
    }
}

- (void)threadedRandom2{
    @autoreleasepool {
        sqlite3 *db = [SQLiteHelper openDB:@"multiTest1" assumeCommonLocation:YES createIfNeeded:NO];
        for (int i = 0; i < 5000; i++){
            int a = rand()%300;
            
            NSDictionary *dict = [[[NSDictionary alloc]
                                   initWithObjectsAndKeys:
                                   @"rand", [NSString stringWithFormat:@"ColTest1_%i", a],
                                   nil]autorelease];
            
            NSDictionary *where = [[[NSDictionary alloc]
                                    initWithObjectsAndKeys:[[SQLiteHelper loadSingleData:dict atTable:@"multi1" inDB:db]  objectForKey:[NSString stringWithFormat:@"ColTest1_%i", a]],
                                    [NSString stringWithFormat:@"ColTest1_%i", a], nil]autorelease];
            
            [SQLiteHelper updateData:dict
                               where:where
                             atTable:@"multi1"
                                inDB:db
                        singleRecord:NO];
            usleep(rand()%200);
        }
        [SQLiteHelper closeDB:db];
    }
}

- (void)threadedRandom3{
    @autoreleasepool {
        sqlite3 *db = [SQLiteHelper openDB:@"multiTest1" assumeCommonLocation:YES createIfNeeded:NO];
        for (int i = 0; i < 5000; i++){
            int a = rand()%300;
            
            NSDictionary *dict = [[[NSDictionary alloc]
                                   initWithObjectsAndKeys:
                                   @"rand", [NSString stringWithFormat:@"ColTest1_%i", a],
                                   nil]autorelease];
            
            [SQLiteHelper removeData:dict fromTable:@"multi1" inDB:db];
            usleep(rand()%200);
        }
        
        [SQLiteHelper closeDB:db];
    }
}

- (void)threadedRandom4{
    @autoreleasepool {
        sqlite3 *db = [SQLiteHelper openDB:@"multiTest1" assumeCommonLocation:YES createIfNeeded:NO];
        for (int i = 0; i < 5000; i++){
            int a = rand()%300;
            
            NSDictionary *dict = [[[NSDictionary alloc]
                                   initWithObjectsAndKeys:
                                   @"rand", [NSString stringWithFormat:@"ColTest1_%i", a],
                                   nil]autorelease];
            
            [SQLiteHelper removeData:dict fromTable:@"multi1" inDB:db];
            usleep(rand()%200);
        }
        
        [SQLiteHelper closeDB:db];
    }
}


- (void)testThreadsRandom{
    [self threadedStart];
    NSThread* thread1 = [[NSThread alloc]initWithTarget:self selector:@selector(threadedRandom1) object:nil];
    NSThread* thread2 = [[NSThread alloc]initWithTarget:self selector:@selector(threadedRandom2) object:nil];
    NSThread* thread3 = [[NSThread alloc]initWithTarget:self selector:@selector(threadedRandom3) object:nil];
    NSThread* thread4 = [[NSThread alloc]initWithTarget:self selector:@selector(threadedRandom4) object:nil];

    [thread1 setName:@"Editting thread1"];
    [thread2 setName:@"Editting thread2"];
    [thread3 setName:@"Editting thread3"];
    [thread4 setName:@"Editting thread4"];
    
    [thread1 start];
    [thread2 start];
    [thread3 start];
    [thread4 start];
    
    while ( ([thread1 isFinished] == NO) || ([thread2 isFinished] == NO) || ([thread3 isFinished] == NO) || ([thread4 isFinished] == NO)){
        usleep(500);
    };
    
    [thread1 release];
    [thread2 release];
    [thread3 release];
}


@end
