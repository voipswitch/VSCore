//
//  NSMutableDictionary+Extended.h
//  VSCore
//
//  Created by Bartłomiej Żarnowski [Toster] on 21.01.2013.
//  Copyright (c) 2013 Bartłomiej Żarnowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (Extended)

-(void)addNonExistingsKeysFrom:(NSMutableDictionary*)dict;

@end
