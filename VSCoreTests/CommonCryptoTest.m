//
//  CommonCryptoTest.m
//  VSCore
//
//  Created by Bartłomiej Żarnowski [Toster] on 29.08.2013.
//  Copyright (c) 2013 Bartłomiej Żarnowski. All rights reserved.
//

#import "CommonCryptoTest.h"
#import "CommonCrypto.h"

@implementation CommonCryptoTest

-(void)testStringHashMD5{
    //generated by http://www.fileformat.info/tool/hash.htm?text=This+is+test+string
    NSString* test = @"This is test string";
    NSString* hexHash = [test hashMD5];
    STAssertEqualObjects(hexHash, @"cbc8824b28a863df726d421801084c01", @"Hash not valid");
}

-(void)testStringHashSHA256{
    //generated by http://www.fileformat.info/tool/hash.htm?text=This+is+test+string
    NSString* test = @"This is test string";
    NSString* hexHash = [test hashSHA256];
    STAssertEqualObjects(hexHash, @"9960a70760879076fb6096718329b023074bf6ff39c12f9ebab10c0e742c3ce8", @"Hash not valid");
}

-(void)testStringHashSHA512{
    //generated by http://www.fileformat.info/tool/hash.htm?text=This+is+test+string
    NSString* test = @"This is test string";
    NSString* hexHash = [test hashSHA512];
    STAssertEqualObjects(hexHash, @"82aa6d3db64bb7c575a778ed2ec55e61e2d6dfd596eead165912b055b01aeb998d600fb422bfe378294c561d9fbc3d3ca3133acd8d61084852d5f8550c14298c", @"Hash not valid");
}

-(void)testAESEncryption{
    NSString* test = @"This is test string";
    NSData* data = [test dataUsingEncoding:NSASCIIStringEncoding];
    NSData* encoded = [data encryptAES128WithKey:@"this is my key"];
    NSData* decoded = [encoded decryptAES128WithKey:@"this is my key"];
    STAssertEqualObjects(data, decoded, @"AES crypto failed");
}

-(void)testBlowFishEncryption{
    NSString* test = @"This is test string";
    NSData* data = [test dataUsingEncoding:NSASCIIStringEncoding];
    NSData* encoded = [data encryptBlowfishWithKey:@"this is my key"];
    NSData* decoded = [encoded decryptBlowfishWithKey:@"this is my key"];
    STAssertEqualObjects(data, decoded, @"AES crypto failed");
}
@end
