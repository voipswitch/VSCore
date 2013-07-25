//
//  NSDictionary+Additions.h
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartlomiej Klin on 20.06.2012.
//

#import <Foundation/Foundation.h>
@interface NSDictionary (Additions)

- (BOOL)boolForKey:(NSString *)defaultName;
- (NSString *)stringForKey:(NSString *)defaultName;
- (NSInteger)integerForKey:(NSString *)defaultName;

@end