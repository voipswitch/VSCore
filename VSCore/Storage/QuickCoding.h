//
//  QuickCoding.h
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Marek Kotewicz on 8/10/13.
//

#import <Foundation/Foundation.h>

/**
 * This is helper in encoding decoding objects. It uses reflection helper to get all properties of the given object
 */
@interface QuickCoding : NSObject

+ (void)quickEncode:(NSObject<NSCoding>*)object withEncoder:(NSCoder*)encoder;
+ (void)quickDecode:(NSObject<NSCoding>*)object withDecoder:(NSCoder*)decoder;

@end
