//
//  StringUtils.m
//  Join
//
//  Created by Dima on 09-07-28.
// Changed by Witek on 12-03-18.
//  Copyright 2009 Voipswitch. All rights reserved.
//

#import "StringUtils.h"

@implementation StringUtils
+(NSString*)TrimString:(NSString*)text
{
	return [StringUtils TrimString:[NSString stringWithString:text] ch:' '];
}

+(NSRange)GetStringBetween:(NSString*) text separator1:(NSString*)sep1 separator2:(NSString*)sep2 inRange:(NSRange*)inRange
{
	NSRange ret;
	NSRange r_sep1 = [text rangeOfString:sep1 options:NSCaseInsensitiveSearch range:*inRange]; 
	if ( r_sep1.location == NSNotFound)
	{
		r_sep1.location = inRange->location;
		r_sep1.length = 0;
	}
	ret.location = r_sep1.location + r_sep1.length;
	ret.length = inRange->location + inRange->length - ret.location;
	NSRange r_sep2 = [text rangeOfString:sep2 options:NSCaseInsensitiveSearch range:ret];
	if ( r_sep2.location == NSNotFound )
	{
		inRange->location = inRange->location + inRange->length;		
		inRange->length = 0;
		return ret;
	}
	else 
	{
		ret.length = r_sep2.location - ret.location;
		inRange->length = inRange->location + inRange->length - ( r_sep2.location + r_sep2.length );
		inRange->location = r_sep2.location + r_sep2.length;
		return ret;
	}

}

+(NSString*)TrimString:(NSString*)text ch:(char)ch
{
	NSRange range;
	range.location = 0;
	while ( [text characterAtIndex:range.location] == ch && range.location < [text length] ) 
		range.location ++;
	range.length = [text length] - range.location;
	while ( [text characterAtIndex: ( range.location + range.length - 1 ) ] == ch && range.length != 0 ) 
		range.length --;
	
	text = [text substringWithRange:range];
	return text;	
}

+(NSString*)extractFrom:(NSString*) text bySeparator1:(NSString*)sep1 andSeparator2:(NSString*)sep2 inRange:(NSRange*)inRange{
    if (inRange == nil){
        NSRange r = NSMakeRange(0, [text length]);
        inRange = &r;
    }
    NSRange r = [self GetStringBetween:text separator1:sep1 separator2:sep2 inRange:inRange];
    return [text substringWithRange:r];
}

+(NSString*)removeCharacters:(NSString*)charsToRemove from:(NSString*)str{
    NSCharacterSet* numch = [[NSCharacterSet characterSetWithCharactersInString:charsToRemove] invertedSet];
    return [[str componentsSeparatedByCharactersInSet:numch] componentsJoinedByString:@""];
}

@end
