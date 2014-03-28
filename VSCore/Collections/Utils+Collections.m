//
//  Utils+Collections.m
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski [Toster] on 03.04.2013.
//

#import "Utils+Collections.h"

@implementation NSMutableDictionary (DeepCopy)

-(void)deepMutableAddEntriesFromDictionary:(NSDictionary*)src{
    [src enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSDictionary class]] == YES){
            NSDictionary* child = [self objectForKey:key];
            
            if (child == nil){
                //doesen't exist yet, so just add
                [self setObject: obj forKey:key];
            } else {
                //merge if types match, or overwrite
                if ([child isKindOfClass:[NSDictionary class]] == NO){
                    //types differ, overwrite
                    [self setObject: obj forKey:key];
                } else {
                    child = [child mutableCopy];    //check for mutability fails in some condiotins, so force copy
                    [(NSMutableDictionary*)child deepMutableAddEntriesFromDictionary:obj];
                    [self setObject:child forKey:key];
                    [child release];    //due +1 from copy
                }
            }
        } else if ([obj isKindOfClass:[NSArray class]] == YES){
            NSArray* child = [self objectForKey:key];
            
            if (child == nil){
                //doesen't exist yet, so just add
                [self setObject: obj forKey:key];
            } else {
                //merge if types match, or overwrite
                if ([child isKindOfClass:[NSArray class]] == NO){
                    //types differ, overwrite
                    [self setObject: obj forKey:key];
                } else {
                    child = [child mutableCopy];    //check for mutability fails in some condiotins, so force copy
                    [(NSMutableArray*)child addObjectsFromArray:obj];
                    [self setObject:child forKey:key];
                    [child release];    //due +1 from copy
                }
            }

        } else {
            [self setObject: obj forKey:key];
        }
    }];
}

@end

@implementation Utils(Collections)

+(id)deepMutableCopy:(id)collection{
    return [collection mutableDeepCopy];
}

+(id)deepCopy:(id)collection{
    return [collection deepCopy];
}

+(BOOL)deepEqual:(id)collection1 with:(id)collection2{
    BOOL is1Dict = [collection1 isKindOfClass:[NSDictionary class]];
    BOOL is2Dict = [collection2 isKindOfClass:[NSDictionary class]];
    BOOL is1Array = [collection1 isKindOfClass:[NSArray class]];
    BOOL is2Array = [collection2 isKindOfClass:[NSArray class]];
    
    if ((is1Dict != is2Dict) || (is1Array != is2Array)){
        return NO;
    }
    if ([collection1 count] != [collection2 count]){
        return NO;
    }

    if ([collection1 isKindOfClass:[NSDictionary class]]){
        __block BOOL result = YES;
        [collection1 enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if (([obj isKindOfClass:[NSDictionary class]]) || ([obj isKindOfClass:[NSArray class]])){
                result = [self deepEqual:obj with:collection2[key]];
            } else {
                result = [collection2[key] isEqual:obj];
            }
            *stop = !result;
        }];
        return result;
    } else if ([collection1 isKindOfClass:[NSArray class]]){
        for(NSInteger index =0; index < [collection1 count]; index++ ){
            id obj = collection1[index];
            if (([obj isKindOfClass:[NSDictionary class]]) || ([obj isKindOfClass:[NSArray class]])){
                if ([self deepEqual:obj with:collection2[index]] == NO){
                    return NO;
                }
            } else {
                if ([obj isEqual:collection2[index]] == NO){
                    return NO;
                }
            }
        }
        return YES;
    }
    NSAssert(NO, @"Unssuported collection?");
    return NO;
}
@end

@implementation NSArray (SPDeepCopy)

- (NSArray*) deepCopy {
    unsigned int count = [self count];
    id cArray[count];
    
    for (unsigned int i = 0; i < count; ++i) {
        id obj = [self objectAtIndex:i];
        if ([obj respondsToSelector:@selector(deepCopy)])
            cArray[i] = [obj deepCopy];
        else
            cArray[i] = [obj copy];
    }
    
    NSArray *ret = [[NSArray arrayWithObjects:cArray count:count] retain];
    
    // The newly-created array retained these, so now we need to balance the above copies
    for (unsigned int i = 0; i < count; ++i)
        [cArray[i] release];
    
    return ret;
}

- (NSMutableArray*) mutableDeepCopy {
    unsigned int count = [self count];
    id cArray[count];
    
    for (unsigned int i = 0; i < count; ++i) {
        id obj = [self objectAtIndex:i];
        
        // Try to do a deep mutable copy, if this object supports it
        if ([obj respondsToSelector:@selector(mutableDeepCopy)])
            cArray[i] = [obj mutableDeepCopy];
        
        // Then try a shallow mutable copy, if the object supports that
        else if ([obj respondsToSelector:@selector(mutableCopyWithZone:)])
            cArray[i] = [obj mutableCopy];
        
        // Next try to do a deep copy
        else if ([obj respondsToSelector:@selector(deepCopy)])
            cArray[i] = [obj deepCopy];
        
        // If all else fails, fall back to an ordinary copy
        else
            cArray[i] = [obj copy];
    }
    
    NSMutableArray *ret = [[NSMutableArray arrayWithObjects:cArray count:count] retain];
    
    // The newly-created array retained these, so now we need to balance the above copies
    for (unsigned int i = 0; i < count; ++i)
        [cArray[i] release];
    
    return ret;
}

@end

@implementation NSDictionary (SPDeepCopy)

- (NSDictionary*) deepCopy {
    unsigned int count = [self count];
    id cObjects[count];
    id cKeys[count];
    
    NSEnumerator *e = [self keyEnumerator];
    unsigned int i = 0;
    id thisKey;
    while ((thisKey = [e nextObject]) != nil) {
        id obj = [self objectForKey:thisKey];
        
        if ([obj respondsToSelector:@selector(deepCopy)])
            cObjects[i] = [obj deepCopy];
        else
            cObjects[i] = [obj copy];
        
        if ([thisKey respondsToSelector:@selector(deepCopy)])
            cKeys[i] = [thisKey deepCopy];
        else
            cKeys[i] = [thisKey copy];
        
        ++i;
    }
    
    NSDictionary *ret = [[NSDictionary dictionaryWithObjects:cObjects forKeys:cKeys count:count] retain];
    
    // The newly-created dictionary retained these, so now we need to balance the above copies
    for (unsigned int i = 0; i < count; ++i) {
        [cObjects[i] release];
        [cKeys[i] release];
    }
    
    return ret;
}

- (NSMutableDictionary*) mutableDeepCopy {
    unsigned int count = [self count];
    id cObjects[count];
    id cKeys[count];
    
    NSEnumerator *e = [self keyEnumerator];
    unsigned int i = 0;
    id thisKey;
    while ((thisKey = [e nextObject]) != nil) {
        id obj = [self objectForKey:thisKey];
        
        // Try to do a deep mutable copy, if this object supports it
        if ([obj respondsToSelector:@selector(mutableDeepCopy)])
            cObjects[i] = [obj mutableDeepCopy];
        
        // Then try a shallow mutable copy, if the object supports that
        else if ([obj respondsToSelector:@selector(mutableCopyWithZone:)])
            cObjects[i] = [obj mutableCopy];
        
        // Next try to do a deep copy
        else if ([obj respondsToSelector:@selector(deepCopy)])
            cObjects[i] = [obj deepCopy];
        
        // If all else fails, fall back to an ordinary copy
        else
            cObjects[i] = [obj copy];
        
        // I don't think mutable keys make much sense, so just do an ordinary copy
        if ([thisKey respondsToSelector:@selector(deepCopy)])
            cKeys[i] = [thisKey deepCopy];
        else
            cKeys[i] = [thisKey copy];
        
        ++i;
    }
    
    NSMutableDictionary *ret = [[NSMutableDictionary dictionaryWithObjects:cObjects forKeys:cKeys count:count] retain];
    
    // The newly-created dictionary retained these, so now we need to balance the above copies
    for (unsigned int i = 0; i < count; ++i) {
        [cObjects[i] release];
        [cKeys[i] release];
    }
    
    return ret;
}

@end

@implementation NSSet (SPDeepCopy)

- (NSSet*) deepCopy {
    unsigned int count = [self count];
    id cArray[count];
    
    NSInteger i = 0;
    for(id obj in self){
        if ([obj respondsToSelector:@selector(deepCopy)]){
            cArray[i] = [obj deepCopy];
        } else {
            cArray[i] = [obj copy];
        }
        i++;
    };
    
    NSSet *ret = [[NSSet setWithObjects:cArray count:count] retain];
    
    // The newly-created array retained these, so now we need to balance the above copies
    for (unsigned int i = 0; i < count; ++i)
        [cArray[i] release];
    
    return ret;
}

- (NSMutableSet*) mutableDeepCopy {
    unsigned int count = [self count];
    id cArray[count];
    
    NSInteger i = 0;
    for(id obj in self){
        
        // Try to do a deep mutable copy, if this object supports it
        if ([obj respondsToSelector:@selector(mutableDeepCopy)])
            cArray[i] = [obj mutableDeepCopy];
        
        // Then try a shallow mutable copy, if the object supports that
        else if ([obj respondsToSelector:@selector(mutableCopyWithZone:)])
            cArray[i] = [obj mutableCopy];
        
        // Next try to do a deep copy
        else if ([obj respondsToSelector:@selector(deepCopy)])
            cArray[i] = [obj deepCopy];
        
        // If all else fails, fall back to an ordinary copy
        else
            cArray[i] = [obj copy];
    }
    
    NSMutableSet *ret = [[NSMutableSet setWithObjects:cArray count:count] retain];
    
    // The newly-created array retained these, so now we need to balance the above copies
    for (unsigned int i = 0; i < count; ++i)
        [cArray[i] release];
    
    return ret;
}

@end
