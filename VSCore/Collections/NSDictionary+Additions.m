//
//  NSDictionary+Additions.m
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartlomiej Klin on 20.06.2012.
//


#import "NSDictionary+Additions.h"


@implementation NSDictionary (Additions)

- (BOOL)boolForKey:(NSString *)defaultName
{
    id value = [self valueForKey:defaultName];
    if (![value respondsToSelector:@selector(boolValue)])
        return NO;
    return [value boolValue];
}

- (NSString *)stringForKey:(NSString *)defaultName
{
    id value = [self valueForKey:defaultName];
    if (![value isKindOfClass:[NSString class]])
        return nil;
    return value;
}

- (NSInteger)integerForKey:(NSString *)defaultName
{
    id value = [self valueForKey:defaultName];
    if (![value respondsToSelector:@selector(integerValue)])
        return 0;
    return [value integerValue];
}

@end