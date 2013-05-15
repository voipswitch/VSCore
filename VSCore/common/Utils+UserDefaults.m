//
//  Utils+UserDefaults.m
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Witold Matuszczak on 17.05.2012.
//

#import <VSCore/Utils+UserDefaults.h>

@implementation Utils (UserDefaults)

+(id) objectFromUserDefaultsForPath:(NSString*)path
{
    if (path == nil){
        return nil;
    }
    NSRange i =[path rangeOfString:@"."];
    id result=nil;
    if(i.location != NSNotFound){
        NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
        NSDictionary* context = [def dictionaryRepresentation];
        NSArray* aDot = [path componentsSeparatedByString:@"."];
        for(int t=0;t<aDot.count-1;++t){
            context = [context objectForKey:[aDot objectAtIndex:t]];
        }
        result = [context objectForKey:[aDot objectAtIndex:aDot.count-1]];
    }
    else{
        result = [[NSUserDefaults standardUserDefaults] objectForKey:path];
    }
    return result;
}

+(NSMutableDictionary*) setObject:(id) object forPath:(NSString*) path atDictionary:(NSDictionary*) dict{
    int i =[path rangeOfString:@"."].location;
    if(i!=NSNotFound){
        NSString* key = [path substringToIndex:i];
        path = [path substringFromIndex:i+1];
        NSDictionary* dictKey = [dict objectForKey:key];
        NSMutableDictionary* dict2 = [Utils setObject:object forPath:path atDictionary:dictKey];
        NSMutableDictionary* result = [NSMutableDictionary dictionaryWithDictionary:dict];
        [result setObject:dict2 forKey:key];
        return  result;
    }else{
        NSMutableDictionary* result = [NSMutableDictionary dictionaryWithDictionary:dict];
        [result setObject:object forKey:path];
        return result;
    }
}

+(void) setObjectFromUserDefaultsForPath:(NSString*)path value:(id) value{
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
    int i =[path rangeOfString:@"."].location;
    if(i!=NSNotFound){
        NSString* key = [path substringToIndex:i];
        path = [path substringFromIndex:i+1];
        NSDictionary* dictKey = [def dictionaryForKey:key];
        NSMutableDictionary* dict = [Utils setObject:value forPath:path atDictionary:dictKey];
        [def setObject:dict forKey:key];
    }else{
        [def setObject:value forKey:path];
    }
}

+(NSMutableDictionary*) removeObjectForPath:(NSString*) path atDictionary:(NSDictionary*) dict{
    int i =[path rangeOfString:@"."].location;
    if(i!=NSNotFound){
        NSString* key = [path substringToIndex:i];
        path = [path substringFromIndex:i+1];
        NSDictionary* dictKey = [dict objectForKey:key];
        NSMutableDictionary* dict2 = [Utils removeObjectForPath:path atDictionary:dictKey];
        NSMutableDictionary* result = [NSMutableDictionary dictionaryWithDictionary:dict];
        [result setObject:dict2 forKey:key];
        return  result;
    }else{
        NSMutableDictionary* result = [NSMutableDictionary dictionaryWithDictionary:dict];
        [result removeObjectForKey:path];
        return result;
    }
}

+(void) removeObjectFromUserDefaultsForPath:(NSString*)path{
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
    int i =[path rangeOfString:@"."].location;
    if(i!=NSNotFound){
        NSString* key = [path substringToIndex:i];
        path = [path substringFromIndex:i+1];
        NSDictionary* dictKey = [def dictionaryForKey:key];
        NSMutableDictionary* dict = [Utils removeObjectForPath:path atDictionary:dictKey];
        [def setObject:dict forKey:key];
    }else{
        [def removeObjectForKey:path];
    }
}
@end
