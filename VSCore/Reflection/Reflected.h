//
//  Reflected.h
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski [Toster] on 03.01.2013.
//

#import <Foundation/Foundation.h>

/**
 * Marker interface which gives more control over reflecting class. It allows to change way in which {@link ReflectionHelper} will
 * parse given class.
 */
@protocol Reflected <NSObject>

@optional
/** 
 * Method return list of properties which will be hidden from result of methods like {@link ReflectionHelper#fieldsList:}
 *
 * @return list of names of properties, can't be nil
 */
+(NSArray*)reflectionIgnore;
@end