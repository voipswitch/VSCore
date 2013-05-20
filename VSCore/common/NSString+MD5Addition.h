//
//  NSString+MD5Addition.h
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski on 20.05.2013.
//

#import <Foundation/Foundation.h>

@interface NSString(MD5Addition)

/**
 * @return MD5 hash of this string.
 */
- (NSString *) stringFromMD5;

@end
