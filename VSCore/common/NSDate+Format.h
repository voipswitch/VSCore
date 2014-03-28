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
+ (NSString*)parseSecsToHHMMSS:(unsigned int)val;

/**
 * Returns date represented as relative date to today. If it's in last 24 hours then only time part is returned.
 * If date is in range -48..-24 hours from now it's represented as 'yesterday' (localized)
 * If date is in previous week day name (localized) is returned.
 * If none of conditions are met then date with local phone format is returned
 * @return date formated according to above specified rules. 
 */
- (NSString*)niceFormat;

/**
 * Returns date represented as relative date to today.
 * If date is in range -48..-24 hours from now it's represented as 'yesterday' (localized)
 * If date is in previous week day name (localized) is returned.
 * If none of conditions are met then date with local phone format is returned
 * @return date formated according to above specified rules.
 */
- (NSString*)niceFormatWithoutTime;

/**
 * Returns long format of date without time.
 * Example: “November 23, 1937”
 * Format may depend on phone settings.
 */
- (NSString*)localUserLongFormatForDate;

/**
 * Returns medium format of date without time.
 * Example: “Nov 23, 1937”
 * Format may depend on phone settings.
 */
- (NSString*)localUserMediumFormatForDate;

/**
 * Returns short format of date without time.
 * Example: “11/23/37”
 * Format may depend on phone settings.
 */
- (NSString*)localUserShortFormatForDate;

/**
 * Returns short format of time without day, month, year.
 * Example: “3:30:32pm”
 * Format may depend on phone settings.
 */
- (NSString*)localUserLongFormatForTime;

/**
 * Returns short format of time without day, month, year.
 * Example: “3:30pm”
 * Format may depend on phone settings.
 */
- (NSString*)localUserShortFormatForTime;

- (NSString*)niceShortFormat;

- (NSString*)niceMediumFormat;

- (NSString*)niceLongFormat;

@end
