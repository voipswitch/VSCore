//
//  CommonCrypto.h
//  VSCore
//
//  Created by Bartłomiej Żarnowski [Toster] on 29.08.2013.
//  Copyright (c) 2013 Bartłomiej Żarnowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CryptoHashes)
-(NSString*)hashMD5;
-(NSString*)hashSHA256;
-(NSString*)hashSHA512;
-(NSString*)hashCRC;
-(long)hashCRCAsLong;
@end

@interface NSData (CryptoHashes)
-(NSString*)hashMD5;
-(NSString*)hashSHA256;
-(NSString*)hashSHA512;
-(NSString*)hashCRC;
@end

@interface NSData (Crypto)
-(NSData*)encryptAES128WithKey:(id)key;
-(NSData*)decryptAES128WithKey:(id)key;

-(NSData*)encryptBlowfishWithKey:(id)key;
-(NSData*)decryptBlowfishWithKey:(id)key;
@end
