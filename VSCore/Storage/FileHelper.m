//
//  FileHelper.m
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski on 05.04.2012.
//

#import "FileHelper.h"

@implementation FileHelper
+(NSURL*)asFileURL:(id)pathOrURL{

    if ([pathOrURL isKindOfClass:[NSString class]] == YES){
        return [NSURL fileURLWithPath: pathOrURL];
    } else {
        //assume NSURL
        if ([pathOrURL isFileURL] == YES){
            return pathOrURL;
        } else {
            return [NSURL fileURLWithPath: [pathOrURL absoluteString] ];
        }
    }
}

+(BOOL)createDirIfNeeded:(NSString*)path{
    BOOL result = YES;
    NSFileManager * fileManagr = [NSFileManager defaultManager];
	if ([fileManagr fileExistsAtPath:path] == NO){
		NSError* error = nil;
		DDLogVerbose(@"creating thumbnail dir");
		result = [fileManagr createDirectoryAtPath:path 
                       withIntermediateDirectories:YES 
                                        attributes:nil
                                             error:&error];
		if (result == NO){
			DDLogError(@"Error: %@", [error description]);
		}
	}
    return result;
}

+(BOOL)deleteFiles:(NSArray*)files{
    BOOL result = YES;
    NSFileManager* fm = [[NSFileManager alloc] init];
    for(NSString* file in files){
        NSError* error = nil;
        if ([fm fileExistsAtPath:file] == YES){
            result &= [fm removeItemAtPath:file error:&error];
            if (error != nil){
                DDLogError(@"Error on deletion file %@: %@", file, error);
            }
        }
    }
    [fm release];
    return result;
}

+(BOOL)deleteFile:(id)pathOrURL{
    NSURL* url = [FileHelper asFileURL:pathOrURL];
    NSError* error = nil;
    BOOL b = [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
    if (b == NO){
        DDLogError(@"Error while deleting: %@, error:%@", pathOrURL, error);
    }
    return b;
}

+(BOOL)copyFileFrom:(id)srcPathOrURL to:(id)destPathOrURL{
    NSURL* inURL = [FileHelper asFileURL:srcPathOrURL];
    NSURL* outURL = [FileHelper asFileURL:destPathOrURL];
    NSError* error;
    
    if ([[NSFileManager defaultManager] copyItemAtURL:inURL toURL:outURL error:&error] == NO){
        DDLogError(@"Error while coping file from: %@\nto:%@\nerror:%@", inURL, outURL, error);
        return NO;
    }    
    return YES;
}

+(BOOL)moveFileFrom:(id)srcPathOrURL to:(id)destPathOrURL{
    NSURL* inURL = [FileHelper asFileURL:srcPathOrURL];
    NSURL* outURL = [FileHelper asFileURL:destPathOrURL];
    NSError* error;
    
    if ([[NSFileManager defaultManager] moveItemAtURL:inURL toURL:outURL error:&error] == NO){
        DDLogError(@"Error while moving file from: %@\nto:%@\nerror:%@", inURL, outURL, error);
        return NO;
    }
    return YES;
}

+(NSString*)generateUniqueName:(NSString*)nameFormat onPath:(NSString*)path{
    if (path == nil){
        //get documents path
        path = [FileHelper prefferedPath:nil withType:pathPrivateNonBackup];
    }
    if ([path hasSuffix:@"/"] == NO){
        path = [path stringByAppendingString:@"/"];
    }
    
    nameFormat = [nameFormat stringByReplacingOccurrencesOfString:@"[gen]" withString:@"%lx-%x"];
    nameFormat = [@"%@" stringByAppendingString:nameFormat];
    
    NSFileManager* fm = [[NSFileManager alloc] init];
    NSString* result;
    do{
        result = [NSString stringWithFormat:nameFormat, path, time(NULL),rand()%0xffff];
    }while([fm fileExistsAtPath:result] == YES);
    [fm release];
    return result;
}

+(NSString*)generateUniqueName:(NSString*)path andExtensions:(NSString*)ext{
    
    return [self generateUniqueName:[@"[gen]." stringByAppendingString:ext] onPath:path];
}

+(NSString*)documentsPath:(NSString*)subDir{
    static NSArray* paths = nil;
    if (paths == nil){
        paths = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) retain];
    }
    
    NSString* documentsDirectory = [paths objectAtIndex:0];
    
    if ([subDir length] > 0){
        if ([subDir characterAtIndex:0] != '/'){
            subDir = [NSString stringWithFormat:@"/%@", subDir];
        }
        documentsDirectory = [documentsDirectory stringByAppendingPathComponent:subDir];
    }
    
    [FileHelper createDirIfNeeded:documentsDirectory];
    if ([documentsDirectory characterAtIndex:[documentsDirectory length]-1] != '/'){
        documentsDirectory = [documentsDirectory stringByAppendingString:@"/"];
    }
    return documentsDirectory;
}

+(NSString*)libraryPath:(NSString*)subDir{
    static NSArray* paths = nil;
    if (paths == nil){
        paths = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) retain];
    }
    
    NSString* libraryDirectory = [paths objectAtIndex:0];
    
    if ([subDir length] > 0){
        if ([subDir characterAtIndex:0] != '/'){
            subDir = [NSString stringWithFormat:@"/%@", subDir];
        }
        libraryDirectory = [libraryDirectory stringByAppendingPathComponent:subDir];
    }
    
    [FileHelper createDirIfNeeded:libraryDirectory];
    if ([libraryDirectory characterAtIndex:[libraryDirectory length]-1] != '/'){
        libraryDirectory = [libraryDirectory stringByAppendingString:@"/"];
    }
    return libraryDirectory;
}

+(NSString*)prefferedPath:(NSString*)subDir withType:(FileHelperPathType)pathType
{
    static NSArray* paths = nil;
    if (paths == nil){
        if(pathType == pathPrivateBackup || pathType == pathPrivateNonBackup){
            paths = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) retain];
        }else{
            paths = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) retain];
        }
    }
    
    NSString* prefferedDirectory = [paths objectAtIndex:0];
    
    if(pathType == pathPrivateNonBackup || pathType == pathPublicNonBackup){
        // Prevent iCloud backup
        prefferedDirectory = [prefferedDirectory stringByAppendingPathComponent:@"/Caches/"];
    }
    
    if ([subDir length] > 0){
        if ([subDir characterAtIndex:0] != '/'){
            subDir = [NSString stringWithFormat:@"/%@", subDir];
        }
        prefferedDirectory = [prefferedDirectory stringByAppendingPathComponent:subDir];
    }
    
    [FileHelper createDirIfNeeded:prefferedDirectory];
    if ([prefferedDirectory characterAtIndex:[prefferedDirectory length]-1] != '/'){
        prefferedDirectory = [prefferedDirectory stringByAppendingString:@"/"];
    }
    return prefferedDirectory;
}

+(BOOL)fileExists:(id)path{
    if ([path isKindOfClass:[NSURL class]] == YES){
        path = [path path];
    }
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}
@end
