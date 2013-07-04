//
//  PropertyPhantom.m
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski [Toster] on 20.05.2013.
//

#import "PropertyPhantom.h"
#import "objc/runtime.h"
#import "ReflectionHelper.h"
#import "CommonDefines.h"

#import "Collections+subscripts.h"

@implementation PropertyPhantom

+(PropertyPhantom*)phantomFrom:(id)anyObject{
    PropertyPhantom* ph = [[[PropertyPhantom alloc] init] autorelease];
    ph->fieldTypes = [[ReflectionHelper fieldsRawInfo:[anyObject class] outName:&ph->classMimic] retain];
    [ph->classMimic retain];
    NSDictionary* vals = [[ReflectionHelper serializeObjectRAW:anyObject] retain];
    NSMutableDictionary* dd = [NSMutableDictionary dictionary];
    [ph->fieldTypes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id valObj = vals[key];
        if ([obj isEqual:@"@"] == YES){
            if ([valObj conformsToProtocol:@protocol(NSCopying)] == YES){
                dd[key] = [[valObj copy] autorelease];
            } else {
                dd[key] = [PropertyPhantom phantomFrom:valObj];
            }
        } else {
            dd[key] = valObj;
        }
    }];
    ph->fieldValues = [dd retain];
    return ph;
}

-(void)dealloc{
    releaseAndNil(classMimic);
    releaseAndNil(fieldTypes);
    releaseAndNil(fieldValues);
    [super dealloc];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    NSString* s = NSStringFromSelector(aSelector);
    if (fieldTypes[s] == nil){
        return [super methodSignatureForSelector:aSelector];
    }
    return [NSMethodSignature signatureWithObjCTypes:[[NSString stringWithFormat:@"%@%s%s", fieldTypes[s], @encode(id), @encode(SEL)] UTF8String]];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation{
    NSString* sel = NSStringFromSelector( anInvocation.selector );
    
    //looks like we are not interested?
    if (fieldTypes[sel] == nil){
        [super forwardInvocation:anInvocation];
        return;
    }
    id aa = fieldValues[sel];
    if (aa != nil){
        if ([aa isKindOfClass:[NSValue class]]){
            char c[30];
            memset(&c, 30, sizeof(char));
            [aa getValue:&c];
            [anInvocation setReturnValue:&c];
        } else {
            [anInvocation setReturnValue:&aa];
        }
    } else {
        id aNil = nil;
        [anInvocation setReturnValue:&aNil];
    }
}

-(NSString*)description{
    return [NSString stringWithFormat:@"[PropertyPhantom class:%@, values:%@]", classMimic, fieldValues];
}

@end
