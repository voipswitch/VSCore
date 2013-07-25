//
//  NSDate+Format.h
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Tomasz Blicharczyk on 20.03.2012.
//

#import <Foundation/Foundation.h>

@interface NSDate (Format)

/**
 * @return NSDate object which points into today midnight.
 */
+ (NSDate*)todayMidnightDate;

- (NSString*)DDMMYYYY;
- (NSString*)HHMMDDMMYYYY;
- (NSString*)format:(NSString*)format;
+ (NSString*)parseSecsToHHMMSS:(unsigned int) val;

/**
 * Returns date represented as relative date to today. If it's in last 24 hours then only time part is returned.
 * If date is in range -48..-24 hours from now it's represented as 'yesterday' (localized)
 * If date is in previout week day name (localized) is returned.
 * If none of conditions are met then MM.dd.yyyy is returned
 * @return date formated according to above specified rules. 
 */
- (NSString*)niceFormat;

@end
