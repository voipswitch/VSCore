//
//  FileHelper.h
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski on 05.04.2012.
//

#import <Foundation/Foundation.h>

typedef enum {
    pathPrivateBackup,       //for files not accessible via iTunes but backuped by iCloud
    pathPrivateNonBackup,    //for files not accessible via iTunes and not backuped by iCloud
    pathPublicBackup,        //for files accessible via iTunes but backuped by iCloud
    pathPublicNonBackup      //for files accessible via iTunes and not backuped by iCloud
} FileHelperPathType;

@interface FileHelper : NSObject

/**
 * Checks if directory with given path exists. If it doesn't then 
 * it will be created.
 * @param path to check or create
 * @return YES if path exist or creation succeed otherwise NO
 */
+(BOOL)createDirIfNeeded:(NSString*)path;

/**
 * Removes all files given in array, method assumes that all items are NSString
 * with full qualified filename. It return YES if all files was deleted, NO if
 * while deleting some error occured. (Non existing files are omited and not 
 * threated as error while deletion process).
 * @param array of paths to files to delete
 * @return YES if all files was deleted, NO otherwise.
 */
+(BOOL)deleteFiles:(NSArray*)files;

/**
 * Removes single file which may be pointed as NSString with fully qualified path
 * or as URL. If given URL is not filePath type it will be converted to it.
 * @param pathOrURL NSURL or NSString pointing file to deletion
 * @return YES if file was deleted, otherwise NO
 */
+(BOOL)deleteFile:(id)pathOrURL;

/**
 * Copies file from one location to another. Either src or dest may be specified as
 * NSString or NSURL. If given URL is not filePath type it will be converted to it.
 * If destination file already exists error is returned. This method may be used to 
 * copy directories, for more info refer to NSFileManager copyItemAtURL:toURL:error:
 * @param srcPathOrURL NSURL or NSString pointing to source file
 * @param destPathOrURL NSURL or NSString pointing to destination file
 * @return YES if file is copied, otherwise NO
 */
+(BOOL)copyFileFrom:(id)srcPathOrURL to:(id)destPathOrURL;


/**
 * Moves file from one location to another. Either src or dest may be specified as
 * NSString or NSURL. If given URL is not filePath type it will be converted to it.
 * If destination file already exists error is returned. This method may be used to
 * copy directories, for more info refer to NSFileManager moveItemAtURL:toURL:error:
 * @param srcPathOrURL NSURL or NSString pointing to source file
 * @param destPathOrURL NSURL or NSString pointing to destination file
 * @return YES if file is moved, otherwise NO
 */
+(BOOL)moveFileFrom:(id)srcPathOrURL to:(id)destPathOrURL;

/**
 * Generates random name and returns fully qualified path to this file (file is not 
 * created). If path is not given (nil) then it's obtaind by call to 
 * [FileHelper libraryPath:nil]. If path is given then only file name is generated.
 * Call to this function guarantees that generated path doesn't point to any existing
 * file. However no check to existance of given path is done!
 * @param path where file should be stored, or nil if default path should be taken.
 * @param ext file extension, if nil then no extension (and '.' sign) will be appended
 * @return fully qualified path to rangom generated filename.
 */
+(NSString*)generateUniqueName:(NSString*)path andExtensions:(NSString*)ext;

/**
 * Generates random name and returns fully qualified path to this file (file is not
 * created). If path is not given (nil) then it's obtaind by call to
 * [FileHelper prefferedPath:nil withType:pathPrivateNonBackup]. If path is given 
 * then only file name is generated
 * using nameFormat format, substring '[gen]' must exist and it's used to generate 
 * random part of filename.
 * Call to this function guarantees that generated path doesn't point to any existing
 * file. However no check to existance of given path is done!
 * Example of nameFormats and possible effects:
 * '[gen].jpg' -> '13672DF9-112D.jpg'
 * 'test_[gen]_el.dat' -> 'test_53672DFA-152F_el.dat'
 * @param path where file should be stored, or nil if default path should be taken.
 * @param ext file extension, if nil then no extension (and '.' sign) will be appended
 * @return fully qualified path to random generated filename.
 */
+(NSString*)generateUniqueName:(NSString*)nameFormat onPath:(NSString*)path;

/**
 * Returns path at which public data such recorded calls should be stored by application.
 * Data stored in NSDcoumentsDirectory will be accessible via iTunes. It also includes
 * given subDir (however it may be nil) to returned path. Method checks if returned
 * path exist (if not it's created). Returned path will end with '/' character.
 * @param subDir last part of path which should be included to returned path or nil
 * @return path at which data can be stored.
 * @deprecated Use {@link #prefferedPath:withType:} instead.
 */
+(NSString*)documentsPath:(NSString*)subDir DEPRECATED_ATTRIBUTE; 

/**
 * Returns path at which data should be stored by application in library directory.
 * It also includes given subDir (however it may be nil) to returned path. Method
 * checks if returned path exist (if not it's created). Returned path will end
 * with '/' character.
 * @param subDir last part of path which should be included to returned path or nil
 * @return path at which data can be stored.
 * @deprecated Use {@link #prefferedPath:withType:} instead.
 */
+(NSString*)libraryPath:(NSString*)subDir DEPRECATED_ATTRIBUTE;

/**
 * Returns path at which data should be stored by application.
 * It also includes given subDir (however it may be nil) to returned path. Method
 * checks if returned path exist (if not it's created). Returned path will end
 * with '/' character.
 * @param subDir last part of path which should be included to returned path or nil
 * @param pathType determine if file at the path is accesible via iTunes or/and backup by iCloud
 * @return path at which data can be stored.
 */
+(NSString*)prefferedPath:(NSString*)subDir withType:(FileHelperPathType)pathType;

/**
 * Check if file exists, file may be pointed as NSString with fully qualified path
 * or as URL. If given URL is not filePath type it will be converted to it.
 * @param pathOrURL NSURL or NSString pointing file
 * @return YES if file exists, otherwise NO
 */
+(BOOL)fileExists:(id)path;

/**
 * List all files from pointed folder. Path may be pointed as NSString with fully qualified path
 * or as URL. If given URL is not filePath type it will be converted to it.
 * @param pathOrURL NSURL or NSString pointing file
 * @return YES if file exists, otherwise NO
 */
+(NSArray*)listFolder:(id)path;
@end
