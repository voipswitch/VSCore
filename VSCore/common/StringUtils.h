//
//  StringUtils.h
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Dima on 09-07-28.
//  Changed by Witek on 12-03-18.
//

#import <Foundation/Foundation.h>


@interface StringUtils : NSObject {
	
}

//legacy code
+(NSRange)GetStringBetween:(NSString*) text separator1:(NSString*)sep1 separator2:(NSString*)sep2 inRange:(NSRange*)inRange;
+(NSString*)TrimString:(NSString*)text;
+(NSString*)TrimString:(NSString*)text ch:(char)ch;

//new methods
+(NSString*)extractFrom:(NSString*) text bySeparator1:(NSString*)sep1 andSeparator2:(NSString*)sep2 inRange:(NSRange*)inRange;

/**
 * Returns new string in which characters listed in argument charsToRemove are removed (all of them, not only beginning, ending).
 * @param charsToRemove list of characters which are forbiden, and should be removed
 * @param str string to be processed
 * @return new string created by removing charsToRemove characters.
 */
+(NSString*)removeCharacters:(NSString*)charsToRemove from:(NSString*)str;
@end
