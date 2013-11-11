//
//  Askable.m
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski on 05.10.2012.
//

#import "Askable.h"
#import "BootSequenceAnalyzer.h"


static NSMutableDictionary* routes;

@implementation Askable

+(void)initialize{
    routes = [[NSMutableDictionary alloc] init];
}

+(BOOL)keyRegistered:(NSString*)key{
    return [routes objectForKey:key] != nil;
}

+(void)registerAsDirectSource:(id)source withSelector:(SEL)selector forKey:(NSString*)key{
    NSAssert([routes objectForKey:key] == nil, @"Key %@ already binded", key);
    
    DDLogVerbose(@"Askable register:%@", key);
    
    NSMethodSignature* ms = [source methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:ms];
    
    [invocation setSelector:selector];
    [invocation setTarget:source];
    if (invocation != nil){
        [routes setObject:invocation forKey:key];
    } else {
        DDLogError(@"Error while setting route: %@, nil invocation, skipped!", key);
    }
}

+(void)registerConstValue:(id)value forKey:(NSString*)key{
    NSAssert([routes objectForKey:key] == nil, @"Key %@ already binded", key);
    DDLogVerbose(@"Askable register:%@ with value:%@", key, value);
    if (value != nil){
        [routes setObject:value forKey:key];
    } else {
        DDLogError(@"Error while setting route: %@, nil const value, skipped!", key);
    }
}

+(void)unregisterKey:(NSString*)key{
    DDLogVerbose(@"Askable unregister:%@", key);
    [routes removeObjectForKey:key];
}

+(BOOL)askFor:(NSString*)key result:(void*)result{
    id obj = [routes objectForKey:key];
    if (obj == nil){
        return NO;
    }

    if ([obj isKindOfClass:[NSInvocation class]] == NO){
        //*result = obj;
        memcpy(result, &obj, sizeof(obj));
        return YES;
    }
    const NSInvocation *invocation = obj;
    [invocation invoke];
    [invocation getReturnValue:result];
    return YES;
}

+(BOOL)askForBool:(NSString*)key defaultValue:(BOOL)def{
    BOOL res;
    BOOL found = [self askFor:key result:&res];
    return found == YES ? res : def;
}

+(NSInteger)askForInt:(NSString*)key defaultValue:(NSInteger)def{
    NSInteger res;
    BOOL found = [self askFor:key result:&res];
    return found == YES ? res : def;
}

+(float)askForFloat:(NSString*)key defaultValue:(float)def{
    float res;
    BOOL found = [self askFor:key result:&res];
    return found == YES ? res : def;
}

+(id)askForObject:(NSString*)key defaultValue:(id)def{
    id res;
    BOOL found = [self askFor:key result:&res];
    ANALYZER(
        BootSequenceAnalyzer* analyzer = [BootSequenceAnalyzer getInstance];
        [analyzer askedForObject:key isNil:(res == nil || found == NO) inThread:[NSThread currentThread]];
    )//ANALYZER
    return found == YES ? res : def;
    
}

+(id)requireObject:(NSString*)key{
    id res;
    BOOL found = [self askFor:key result:&res];
    ANALYZER(
             BootSequenceAnalyzer* analyzer = [BootSequenceAnalyzer getInstance];
             [analyzer askedForObject:key isNil:(res == nil || found == NO) inThread:[NSThread currentThread]];
    )//ANALYZER
    NSAssert(found == YES, @"Required object not found for askable key: %@", key);
    return res;
}

+(void)destroy{
    [routes removeAllObjects];
}

+(void)list{
    DDLogInfo(@"Askable dump list:");
    __block NSSet* autoDump = [NSSet setWithObjects:[NSString class], [NSNumber class], [NSURL class], nil];
    
    [routes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSInvocation class]] == NO){
            for( Class c in autoDump){
                if ([obj isKindOfClass:c] == YES){
                    DDLogInfo(@"  \"%@\" = [%@]%@", key, c, [obj description]);
                    return;
                }
            }
            DDLogInfo(@"  \"%@\" = %@", key, [obj class]);
        } else {
            NSInvocation* i = obj;
            DDLogInfo(@"  \"%@\" -> [%@ %@]", key, [i.target class], NSStringFromSelector(i.selector));
        }
    }];
    DDLogInfo(@"Askable dump list end");
}
@end
