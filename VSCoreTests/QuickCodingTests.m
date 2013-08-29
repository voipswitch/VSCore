//
//  QuickCodingTests.m
//  VSCore
//
//  Created by Marek Kotewicz on 8/12/13.
//  Copyright (c) 2013 Bartłomiej Żarnowski. All rights reserved.
//

#import "QuickCodingTests.h"
#import "QuickCoding.h"
#import "FileHelper.h"

// TODO: test overwritting already created objects!

@interface QCTestObject : NSObject<NSCoding>

@property (nonatomic, retain) NSString *testString0;
@property (nonatomic, retain) NSString *testString1;
@property (nonatomic, assign) NSInteger intValue0;
@property (nonatomic, assign) NSInteger intValue1;
@property (nonatomic, retain) NSArray *array0;
@property (nonatomic, retain) NSMutableArray *mutArr0;
@property (nonatomic, assign) BOOL asa;

@end

@implementation QCTestObject

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]){
        [QuickCoding quickDecode:self withDecoder:aDecoder];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [QuickCoding quickEncode:self withEncoder:aCoder];
}

@end

@class QCTestObject3;

@interface QCTestObject2 : NSObject<NSCoding>

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) QCTestObject3 *testObj;

@end

@implementation QCTestObject2

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]){
        [QuickCoding quickDecode:self withDecoder:aDecoder];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [QuickCoding quickEncode:self withEncoder:aCoder];
}

@end

@interface QCTestObject3 : NSObject<NSCoding>

@property (nonatomic, retain) NSString *name;

@end

@implementation QCTestObject3

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]){
        [QuickCoding quickDecode:self withDecoder:aDecoder];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [QuickCoding quickEncode:self withEncoder:aCoder];
}

@end

@interface QuickCodingTests ()

@property (nonatomic, retain) NSString *savePath;

@end

@implementation QuickCodingTests


- (void)setUp{
    [super setUp];
    self.savePath = [[FileHelper prefferedPath:@"QuickCodingTests" withType:pathPrivateNonBackup] stringByAppendingFormat:@"test"];
}

- (void)testStoreSimple{
    [FileHelper deleteFile:self.savePath];
    QCTestObject3 *t1 = [[[QCTestObject3 alloc] init] autorelease];
    t1.name = @"lalalala";
    BOOL saveOk = [NSKeyedArchiver archiveRootObject:t1 toFile:self.savePath];
    NSAssert(saveOk, @"saving to file failed!");
    
    QCTestObject3 *t2 = [NSKeyedUnarchiver unarchiveObjectWithFile:self.savePath];
    NSAssert(t2, @"loading from file failed!");
    
    NSAssert([t1.name isEqualToString:t2.name], @"objects do not match!");
}

- (void)testStoreMutli{
    [FileHelper deleteFile:self.savePath];
    NSMutableArray *arr = [[[NSMutableArray alloc] initWithCapacity:100] autorelease];
    for (int i = 0; i < 100; i++){
        QCTestObject3 *t = [[[QCTestObject3 alloc] init] autorelease];
        t.name = [NSString stringWithFormat:@"test: %d", i];
        [arr addObject:t];
    }
    
    BOOL saveOk = [NSKeyedArchiver archiveRootObject:arr toFile:self.savePath];
    NSAssert(saveOk, @"saving failed!");
    
    NSMutableArray *lArr = [NSKeyedUnarchiver unarchiveObjectWithFile:self.savePath];
    NSAssert(lArr , @"loading file failed!");
    NSAssert([lArr count] != 0, @"loading file failed!2");
    
    for (int i = 0; i < 100; i++){
        NSAssert([[arr[i] name] isEqualToString:[lArr[i] name]], @"objects do not match! :%@", @(i));
    }
}

- (void)testStoreEmptyFields{
    [FileHelper deleteFile:self.savePath];
    QCTestObject2 *t1 = [[[QCTestObject2 alloc] init] autorelease];
    t1.name = @"dadada";
    BOOL saveOk = [NSKeyedArchiver archiveRootObject:t1 toFile:self.savePath];
    NSAssert(saveOk, @"saving to file failed!");
    
    QCTestObject2 *t2 = [NSKeyedUnarchiver unarchiveObjectWithFile:self.savePath];
    NSAssert(t2, @"loading from file failed!");
    
    NSAssert([t1.name isEqualToString:t2.name], @"objects do not match!");
    NSAssert(t2.testObj == nil, @"test object should be nil!");
}

- (void)testStoreManyValues{
    [FileHelper deleteFile:self.savePath];
    QCTestObject *t = [[[QCTestObject alloc] init] autorelease];
    t.testString0 = @"ada";
    t.testString1 = @"asasa";
    t.intValue0 = 231212;
    t.intValue1 = 12312;
    t.asa = YES;
    t.array0 = @[@(1), @(2)];
    t.mutArr0 = [[[NSMutableArray alloc] initWithObjects:@"lala", @"dada", @"sasa", nil] autorelease];
    
    BOOL saveOk = [NSKeyedArchiver archiveRootObject:t toFile:self.savePath];
    NSAssert(saveOk, @"saving to file failed!");


    QCTestObject *tObj = [NSKeyedUnarchiver unarchiveObjectWithFile:self.savePath];
    NSAssert(tObj, @"loading file failed");
    
    NSAssert([t.testString0 isEqualToString:tObj.testString0], @"string are not equal1");
    NSAssert(t.intValue0 == tObj.intValue0, @"values are not equal1");
    NSAssert(t.asa = tObj.asa,  @"bools are not equal1");
    NSAssert([t.array0 isEqual:tObj.array0], @"arrays are not equal");
    
    [t.mutArr0 enumerateObjectsUsingBlock:^(NSString *str, NSUInteger idx, BOOL *stop) {
        NSAssert([str isEqualToString:tObj.mutArr0[idx]], @"mutable arrays do not match at index: %d", idx);
    }];
}

- (void)testStoreObjectInside{
    QCTestObject2 *t1 = [[[QCTestObject2 alloc] init] autorelease];
    t1.name = @"lalalala";
    t1.testObj = [[[QCTestObject3 alloc] init] autorelease];
    t1.testObj.name = @"dadada";
    BOOL saveOk = [NSKeyedArchiver archiveRootObject:t1 toFile:self.savePath];
    NSAssert(saveOk, @"saving to file failed!");
    
    QCTestObject2 *t2 = [NSKeyedUnarchiver unarchiveObjectWithFile:self.savePath];
    NSAssert(t2, @"loading from file failed!");
    
    NSAssert([t1.name isEqualToString:t2.name], @"objects do not match!");
    NSAssert([t1.testObj.name isEqualToString:t2.testObj.name], @"objects do not match2!");
}



@end



















