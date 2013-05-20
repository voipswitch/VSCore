//
//  PropertyPhantom.h
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski [Toster] on 20.05.2013.
//

#import <Foundation/Foundation.h>

/**
 * This is experimental class, it's only purpouse is to have object which may behave as
 * any other object with given set of properties. It was primary used to store properties of
 * object which exposes it as readonly without possibility of build this object.
 * After phantomization you can read properties as from source object. So if you had class A
 * with property foo, then you can later use phantom as [phantom foo].
 * Note: Whole tree of embeded object is created, if any property is object type it's check
 * against NSCopying protocol, if it conforms then copy is called otherwise another Phantom 
 * is build for non copying instances.
 */
@interface PropertyPhantom : NSObject{
    NSDictionary* fieldValues;
    NSDictionary* fieldTypes;
    NSString* classMimic;
}

/**
 * Builds phantom object based on given argument. 
 * @param anyObject which should be phantomized
 * @return ready to use phantom
 */
+(PropertyPhantom*)phantomFrom:(id)anyObject;

@end
