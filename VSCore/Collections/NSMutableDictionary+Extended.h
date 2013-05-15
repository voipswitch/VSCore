//
//  NSMutableDictionary+Extended.h
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski [Toster] on 21.01.2013.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (Extended)

-(void)addNonExistingsKeysFrom:(NSMutableDictionary*)dict;

@end
