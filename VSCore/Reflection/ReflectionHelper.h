//
//  ReflectionHelper.h
//  Tosters Core
//
//  Created by Bartłomiej Żarnowski on 01.03.2012.
//  Copyright (c) 2012 The Tosters. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * This is helper interface to serializing objects. It main purpose is to extract definitions of all public properties of given object. 
 * It also provides methods to get all values from public properties, or set values to public properties (using dictionary as container).
 * Most results are cached so, several calls to functions which describe objects are lightweight, no need to cache in external modules.
 */
@interface ReflectionHelper : NSObject

/**
 * Returns array of NSStrings which represents names of properties exposed by given class.
 * @param aClass definition to be examined and extracted
 * @return list of names of public properties
 */
+(NSArray*)fieldsList:(Class)aClass;
/**
 * Works same as {@link #fieldsList:} however you can additionaly pass reference to string in which name of class is returned.
 * @see #fieldsList:
 * @param aClass definition to be examined and extracted
 * @param[out] outName string representation of name of class
 * @return list of names of public properties
 */
+(NSArray*)fieldsList:(Class)aClass outName:(NSString**)outName;

/**
 * Returns dictionary which holds names of all public properties for given class, with corresponding types for it.
 * It should be used to get info about name and type of each property, types are encoded using internall apple notation.
 * Refer for comments in .m file to get more details. If you need only names of properties use {@link #fieldsList:} method.
 * @param aClass definition to be examined and extracted
 * @return dictionary of names and types of public properties
 */
+(NSDictionary*)fieldsDetailedInfo:(Class)aClass;
/**
 * This works this same as {@link #fieldsDetailedInfo:}, however you can additionaly pass reference to string in which name of class is returned.
 * @param aClass definition to be examined and extracted
 * @param[out] outName string representation of name of class
 * @return dictionary of names and types of public properties
 */
+(NSDictionary*)fieldsDetailedInfo:(Class)aClass outName:(NSString**)outName;

/**
 * Extracts all fields with corresponding values from given object. It also stores information about class name (under key KEY_CLASS_NAME) in
 * returned dictionary. Information from this dictionary are enougth to recreate object by call to {@link #deserializeObject:} or can be stored
 * in some storage. If you don't want to store type information use {@link #serializeObjectRAW} method instead.
 * @param obj to serialize
 * @return serialized data for given object including it type information.
 */
+(NSDictionary*)serializeObject:(NSObject*)obj;
/**
 * Recreates object from given serialization data.
 * @param data to be used in deserialization process
 * @return recreated object
 */
+(id)deserializeObject:(NSDictionary*)data;

/**
 * Works same as {@link #serializeObject:} only difference is that no class information are stored. So you can't use {@link #deserializeObject:} instead
 * use {@link #deserializeRAWObject:asType:}.
 * @param obj to serialize
 * @return serialized data for given object
 */
+(NSDictionary*)serializeObjectRAW:(NSObject*)obj;
/**
 * Recreates object from given serialization data, outType argument is used to create instance of object. This method will fail with exception if
 * given type doesn't match serialized data.
 * @param data to be used in deserialization process
 * @param outType class which should be used to create object instance
 * @return recreated object
 */
+(id)deserializeRAWObject:(NSDictionary*)data asType:(Class)outType;

/**
 * This is low level check if given property has description of given type (or starts with). To understand fully please refer to:
 * https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
 * section: Property Attribute Description Examples
 * @param name of property to examine
 * @param cl class to examine
 * @param dscr description to compare
 * @return YES if property descrition has prefix given in dscr argument
 */
+(BOOL)checkProperty:(NSString*)name inClass:(Class)cl forDesription:(NSString*)dscr;
@end
