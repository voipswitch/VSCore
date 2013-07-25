//
//  CacheTests.m
//  VSCore
//
//  Created by Bartłomiej Żarnowski on 21.11.2012.
//  Copyright (c) 2012 Bartłomiej Żarnowski. All rights reserved.
//

#import "CacheTests.h"

@implementation CacheTests
- (void)setUp
{
    [super setUp];
    cache = [[Cache alloc] init];
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    [cache release];
    cache = nil;
    
    [super tearDown];
}

- (void)testAdd_OldestFirst{
    CacheStrategy strategy;
    strategy.cleanupOrder = coOldestFirst;
    strategy.maxLifeTime = 2;
    strategy.maxObjectCount = 100;
    strategy.threadSafe = YES;
    strategy.cleanupCycle = 0;
    strategy.cleanupLoadThreshold = 0.75;
    cache.strategy = strategy;
    
    for(int t = 0; t < 110; t++){
        NSString* v = [NSString stringWithFormat:@"%d",t];
        [cache setObject:v forKey:v];
        usleep(1000);
    }
    //values form 0..9 shoudn't exist
    for(int t = 0; t < 10; t++){
        NSString* v = [NSString stringWithFormat:@"%d",t];
        STAssertNil([cache objectForKey:v], @"Expected to be nil");
    }
    //should exists
    for(int t = 10; t < 110; t++){
        NSString* v = [NSString stringWithFormat:@"%d",t];
        STAssertNotNil([cache objectForKey:v], @"Expected to exist");
    }
    usleep(2200000);
    [cache doCleanup];
    
    //ok, cache should be empty now
    NSInteger count = 0;
    for(int t = 0; t < 200; t++){
        NSString* v = [NSString stringWithFormat:@"%d",t];
        count += [cache objectForKey:v] == nil ? 0 : 1;
    }
    STAssertEquals(count, 0, @"Count expexted to be 0");
}

- (void)testAdd_LessAccessibleFirst{
    CacheStrategy strategy;
    strategy.cleanupOrder = coLessAccessibleFirst;
    strategy.maxLifeTime = 2;
    strategy.maxObjectCount = 100;
    strategy.threadSafe = YES;
    strategy.cleanupCycle = 0;
    strategy.cleanupLoadThreshold = 0.75;
    cache.strategy = strategy;
    
    for(int t = 0; t < 100; t++){
        NSString* v = [NSString stringWithFormat:@"%d",t];
        [cache setObject:v forKey:v];
    }
    
    //simulate some accessing
    for(int t = 0; t < 100; t++){
        for(int y = t; y < 100; y++){
            NSString* v = [NSString stringWithFormat:@"%d",y];
            [cache objectForKey:v];
        }
    }
    
    //add more to overflow cache
    for(int t = 100; t < 110; t++){
        NSString* v = [NSString stringWithFormat:@"%d",t];
        [cache setObject:v forKey:v];
    }
    
    //values form 0 shoudn't exist
    //valies 100..108 shoudn't exist lowest acces count
    for(int t = 100; t < 109; t++){
        NSString* v = [NSString stringWithFormat:@"%d",t];
        STAssertNil([cache objectForKey:v], @"Expected to be nil");
    }

    //values form 1..100 shoud exist
    for(int t = 1; t < 100; t++){
        NSString* v = [NSString stringWithFormat:@"%d",t];
        STAssertNotNil([cache objectForKey:v], @"Expected to be nil");
    }
    usleep(2200000);
    [cache doCleanup];
    
    //ok, cache should be empty now
    NSInteger count = 0;
    for(int t = 0; t < 200; t++){
        NSString* v = [NSString stringWithFormat:@"%d",t];
        count += [cache objectForKey:v] == nil ? 0 : 1;
    }
    STAssertEquals(count, 0, @"Count expexted to be 0");
}

- (void)testAdd_Random{
    CacheStrategy strategy;
    strategy.cleanupOrder = coRandom;
    strategy.maxLifeTime = 2;
    strategy.maxObjectCount = 100;
    strategy.threadSafe = YES;
    strategy.cleanupCycle = 0;
    strategy.cleanupLoadThreshold = 0.75;
    cache.strategy = strategy;
    
    for(int t = 0; t < 200; t++){
        NSString* v = [NSString stringWithFormat:@"%d",t];
        [cache setObject:v forKey:v];
    }

    //only 100 values should exist
    NSInteger count = 0;
    for(int t = 0; t < 200; t++){
        NSString* v = [NSString stringWithFormat:@"%d",t];
        count += [cache objectForKey:v] == nil ? 0 : 1;
    }
    STAssertEquals(count, 100, @"Count expexted to be 100");

    [cache doCleanup];
    count = 0;
    for(int t = 0; t < 200; t++){
        NSString* v = [NSString stringWithFormat:@"%d",t];
        count += [cache objectForKey:v] == nil ? 0 : 1;
    }
    STAssertEquals((float)count, strategy.cleanupLoadThreshold * strategy.maxObjectCount, @"Count expexted to match cleanupLoadThreshold");
}

- (void)testRemove_OldestFirst{
    CacheStrategy strategy;
    strategy.cleanupOrder = coOldestFirst;
    strategy.maxLifeTime = 20;
    strategy.maxObjectCount = 100;
    strategy.threadSafe = YES;
    strategy.cleanupCycle = 0;
    strategy.cleanupLoadThreshold = 0.75;
    cache.strategy = strategy;
    
    for(int t = 0; t < 100; t++){
        NSString* v = [NSString stringWithFormat:@"%d",t];
        [cache setObject:v forKey:v];
        usleep(1000);
    }
    
    //do some randomize in access
    srand(23213);
    for(int t = 0; t < 100; t++){
        NSString* v = [NSString stringWithFormat:@"%d",rand()%110];
        usleep(1000);
        [cache objectForKey:v];
    }
    
    //remove some items
    for(int t = 0; t < 50; t++){
        NSString* v = [NSString stringWithFormat:@"%d",t];
        [cache removeObjectForKey:v];
    }
    
    //check if we have half of values ?
    NSInteger count = 0;
    for(int t = 0; t < 100; t++){
        NSString* v = [NSString stringWithFormat:@"%d",t];
        count += [cache objectForKey:v] == nil ? 0 : 1;
    }
    STAssertEquals(count, 50, @"Count expexted to be 50");
    
    [cache setObject:@"--" forKey:@"forSanityTest"];
}

- (void)testRemove_LessAccessibleFirst{
    CacheStrategy strategy;
    strategy.cleanupOrder = coLessAccessibleFirst;
    strategy.maxLifeTime = 2;
    strategy.maxObjectCount = 100;
    strategy.threadSafe = YES;
    strategy.cleanupCycle = 0;
    strategy.cleanupLoadThreshold = 0.75;
    cache.strategy = strategy;
    
    for(int t = 0; t < 100; t++){
        NSString* v = [NSString stringWithFormat:@"%d",t];
        [cache setObject:v forKey:v];
    }
    
    //simulate some accessing
    for(int t = 0; t < 100; t++){
        for(int y = t; y < 100; y++){
            NSString* v = [NSString stringWithFormat:@"%d",y];
            [cache objectForKey:v];
        }
    }
    
    //add more to overflow cache
    for(int t = 100; t < 110; t++){
        NSString* v = [NSString stringWithFormat:@"%d",t];
        [cache setObject:v forKey:v];
    }
    
    //values form 1..100 shoud exist, so remove first 50
    for(int t = 1; t < 51; t++){
        NSString* v = [NSString stringWithFormat:@"%d",t];
        [cache removeObjectForKey:v];
    }

    //ok, cache should have 50 elements
    NSInteger count = 0;
    for(int t = 0; t < 110; t++){
        NSString* v = [NSString stringWithFormat:@"%d",t];
        count += [cache objectForKey:v] == nil ? 0 : 1;
    }
    STAssertEquals(count, 50, @"Count expexted to be 50");
    [cache setObject:@"--" forKey:@"forSanityTest"];
}

- (void)testRemove_Ranodm{
    CacheStrategy strategy;
    strategy.cleanupOrder = coRandom;
    strategy.maxLifeTime = 2;
    strategy.maxObjectCount = 100;
    strategy.threadSafe = YES;
    strategy.cleanupCycle = 0;
    strategy.cleanupLoadThreshold = 0.75;
    cache.strategy = strategy;
    
    for(int t = 0; t < 200; t++){
        NSString* v = [NSString stringWithFormat:@"%d",t];
        [cache setObject:v forKey:v];
    }
    
    for(int t = 0; t < 200; t++){
        NSString* v = [NSString stringWithFormat:@"%d",t];
        [cache removeObjectForKey:v];
    }
    
    //only 0 values should exist
    NSInteger count = 0;
    for(int t = 0; t < 200; t++){
        NSString* v = [NSString stringWithFormat:@"%d",t];
        count += [cache objectForKey:v] == nil ? 0 : 1;
    }
    STAssertEquals(count, 00, @"Count expexted to be 0");
}

-(void)threadedAdd{
    @autoreleasepool {
        for(int t =0; t < 5000; t++){
            NSString* v = [NSString stringWithFormat:@"%d",rand()%250];
            [cache setObject:v forKey:v];
            usleep(rand()%200);
        }
    }
}

-(void)threadedRemove{
    @autoreleasepool {
        for(int t =0; t < 5000; t++){
            NSString* v = [NSString stringWithFormat:@"%d",rand()%250];
            [cache removeObjectForKey:v];
            usleep(rand()%200);
        }
    }
}

-(void)threadedCheck{
    @autoreleasepool {
        for(int t =0; t < 10000; t++){
            NSString* v = [NSString stringWithFormat:@"%d",rand()%250];
            [cache objectForKey:v];
            usleep(rand()%100);
        }
    }
}

-(void)spawnThreads{
    NSThread* addThread = [[NSThread alloc]initWithTarget:self selector:@selector(threadedAdd) object:nil];
    NSThread* delThread = [[NSThread alloc]initWithTarget:self selector:@selector(threadedRemove) object:nil];
    NSThread* checkThread = [[NSThread alloc]initWithTarget:self selector:@selector(threadedCheck) object:nil];
    [addThread setName:@"Adding thread"];
    [delThread setName:@"Removing thread"];
    [checkThread setName:@"Checking thread"];
    
    [addThread start];
    [delThread start];
    [checkThread start];
    while ( ([addThread isFinished] == NO) || ([delThread isFinished] == NO) || ([checkThread isFinished] == NO) ){
        usleep(500);
    }
    [addThread release];
    [delThread release];
    [checkThread release];
}

-(void)testStability_Random{
    CacheStrategy strategy;
    strategy.cleanupOrder = coRandom;
    strategy.maxLifeTime = 1;
    strategy.maxObjectCount = 200;
    strategy.threadSafe = YES;
    strategy.cleanupCycle = 0;
    strategy.cleanupLoadThreshold = 0.75;
    cache.strategy = strategy;
    [self spawnThreads];
}

-(void)testStability_LessAccessibleFirst{
    CacheStrategy strategy;
    strategy.cleanupOrder = coLessAccessibleFirst;
    strategy.maxLifeTime = 1;
    strategy.maxObjectCount = 200;
    strategy.threadSafe = YES;
    strategy.cleanupCycle = 0;
    strategy.cleanupLoadThreshold = 0.75;
    cache.strategy = strategy;
    [self spawnThreads];
}

-(void)testStability_OldestFirst{
    CacheStrategy strategy;
    strategy.cleanupOrder = coOldestFirst;
    strategy.maxLifeTime = 20;
    strategy.maxObjectCount = 200;
    strategy.threadSafe = YES;
    strategy.cleanupCycle = 0;
    strategy.cleanupLoadThreshold = 0.75;
    cache.strategy = strategy;
    [self spawnThreads];
}
@end
