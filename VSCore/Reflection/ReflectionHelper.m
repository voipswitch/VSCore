//
//  ReflectionHelper.m
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski on 01.03.2012.
//

//Created using code samples from http://stackoverflow.com/questions/754824/get-an-object-attributes-list-in-objective-c

#import "ReflectionHelper.h"
#import "objc/runtime.h"

//Key-NSString(class name), Value-NSArray(list of field names)
static NSMutableDictionary* cachedFieldsList;

//Key-NSString(class name), Value-NSDictionary(K[String]-fieldName, V[String]-FieldValue see defines _C_* in runtime.h)
static NSMutableDictionary* cachedFieldsDetails;

#define KEY_CLASS_NAME @"__className"

static const char * getPropertyType(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && attribute[1] != '@') {
            // it's a C primitive type:
            /* 
             if you want a list of what will be returned for these primitives, search online for
             "objective-c" "Property Attribute Description Examples"
             apple docs list plenty of examples of what you get for int "i", long "l", unsigned "I", struct, etc.
             */
            return (const char *)[[NSData dataWithBytes:(attribute + 1) length:strlen(attribute) - 1] bytes];
        }        
        else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            // it's an ObjC id type:
            return "id";
        }
        else if (attribute[0] == 'T' && attribute[1] == '@') {
            // it's another ObjC object type:
            NSString *s = [[[NSString alloc] initWithBytes:attribute + 3
                                                    length:strlen(attribute) - 4
                                                  encoding:NSUTF8StringEncoding] autorelease];
            return [s UTF8String];
        }
    }
    return "";
}

static const char * getRawPropertyType(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && attribute[1] != '@') {
            // it's a C primitive type:
            /*
             if you want a list of what will be returned for these primitives, search online for
             "objective-c" "Property Attribute Description Examples"
             apple docs list plenty of examples of what you get for int "i", long "l", unsigned "I", struct, etc.
             */
            return (const char *)[[NSData dataWithBytes:(attribute + 1) length:strlen(attribute) - 1] bytes];
        }
        else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            // it's an ObjC id type:
            return "@"; //same as _C_ID
        }
        else if (attribute[0] == 'T' && attribute[1] == '@') {
            // it's another ObjC object type:
            return "@";//same as _C_ID
        }
    }
    return "";
}

@implementation ReflectionHelper

+(void)initialize{
    cachedFieldsList = [[NSMutableDictionary alloc] init];
    cachedFieldsDetails = [[NSMutableDictionary alloc] init];
}

+(NSArray*)fieldsList:(Class)aClass{
    return [ReflectionHelper fieldsList:aClass outName:nil];
}

+(NSArray*)fieldsList:(Class)aClass outName:(NSString**)outName{
    NSAssert(aClass != NULL, @"Illegal usage, passed class descriptor can't be NULL!");
    
    NSString* name = [NSString stringWithUTF8String:class_getName(aClass)];
    if (outName != nil){
        *outName = name;
    }
    NSMutableArray* result = [cachedFieldsList objectForKey:name];
    if (result != nil){
        return result;
    }
    
    result = [NSMutableArray array];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(aClass, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName != NULL) {
            NSString *propertyName = [NSString stringWithUTF8String:propName];
            [result addObject:propertyName];
        }
    }
    free(properties);
    if ([aClass respondsToSelector:@selector(reflectionIgnore)] == YES){
        NSArray* arr = [aClass performSelector:@selector(reflectionIgnore)];
        [result removeObjectsInArray:arr];
    }
    [cachedFieldsList setValue:result forKey:name];
    
    return result;
}

+(NSDictionary*)fieldsRawInfo:(Class)aClass outName:(NSString**)outName{
    NSAssert(aClass != NULL, @"Illegal usage, passed class descriptor can't be NULL!");
    NSString* name = [NSString stringWithUTF8String:class_getName(aClass)];
    if (outName != nil){
        *outName = name;
    }
    NSMutableDictionary* result = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(aClass, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName != NULL) {
            const char *propType = getRawPropertyType(property);
            NSString *propertyName = [NSString stringWithUTF8String:propName];
            NSString *propertyType = [NSString stringWithUTF8String:propType];
            [result setObject:propertyType forKey:propertyName];
        }
    }
    free(properties);
    
    return result;
}

+(NSDictionary*)fieldsDetailedInfo:(Class)aClass{
    return [ReflectionHelper fieldsDetailedInfo:aClass outName:nil];
}

+(BOOL)checkProperty:(NSString*)name inClass:(Class)cl forDesription:(NSString*)dscr{
    NSAssert(cl != NULL, @"Illegal usage, passed class descriptor can't be NULL!");

    unsigned int outCount = 0, i;
    objc_property_t *properties = class_copyPropertyList(cl, &outCount);
    
    const char* cName = [name cStringUsingEncoding:NSASCIIStringEncoding];
    uint cNameLen = [name length];
    BOOL result = NO;
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if ((propName != NULL) && (strncmp(propName, cName, cNameLen) == 0)){
            const char * res = property_getAttributes(property);
            result = strncmp(res, [dscr cStringUsingEncoding:NSASCIIStringEncoding], [dscr length]) == 0;
            break;
        }
    }
    free(properties);
    return result;
}

+(NSDictionary*)fieldsDetailedInfo:(Class)aClass outName:(NSString**)outName{
    NSAssert(aClass != NULL, @"Illegal usage, passed class descriptor can't be NULL!");
    
    NSString* name = [NSString stringWithUTF8String:class_getName(aClass)];
    if (outName != nil){
        *outName = name;
    }
    NSMutableDictionary* result = [cachedFieldsDetails objectForKey:name];
    if (result != nil){
        return result;
    }

    NSArray* exclude = nil;
    if ([aClass respondsToSelector:@selector(reflectionIgnore)] == YES){
        exclude = [aClass performSelector:@selector(reflectionIgnore)];
    }

    result = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(aClass, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName != NULL) {
            const char *propType = getPropertyType(property);
            NSString *propertyName = [NSString stringWithUTF8String:propName];
            if ([exclude containsObject:propertyName] == YES){
                continue;
            }
            NSString *propertyType = [NSString stringWithUTF8String:propType];
            [result setObject:propertyType forKey:propertyName];
        }
    }
    free(properties);
    
    [cachedFieldsDetails setValue:result forKey:name];
    
    return result;
}

+(NSDictionary*)serializeObjectRAW:(NSObject*)obj{
    
    return [obj dictionaryWithValuesForKeys: 
            [ReflectionHelper fieldsList:[obj class] outName:nil]];
    
}

+(id)deserializeRAWObject:(NSDictionary*)data asType:(Class)outType{

    NSObject* result = [[outType alloc] init];
    [result setValuesForKeysWithDictionary:data];
    return [result autorelease];
}


+(NSDictionary*)serializeObject:(NSObject*)obj{
    NSString* name = nil;
    NSMutableDictionary* d = [NSMutableDictionary dictionaryWithDictionary: 
                              [obj dictionaryWithValuesForKeys: 
                               [ReflectionHelper fieldsList:[obj class] outName:&name]]];
    NSAssert(name != nil, @"internall error");
    [d setValue:name forKey:KEY_CLASS_NAME];
    return d;
}

+(id)deserializeObject:(NSDictionary*)data{
    NSString* name = [data objectForKey:KEY_CLASS_NAME];
    NSAssert(name != nil, @"Illegal call, please check you code. No class name specified");
    Class theClass = NSClassFromString(name);
    NSMutableDictionary* d = [data mutableCopy];
    [d removeObjectForKey:KEY_CLASS_NAME];
    NSObject* result = [[theClass alloc] init];
    [result setValuesForKeysWithDictionary:d];
    [d release];
    return [result autorelease];
}

@end
