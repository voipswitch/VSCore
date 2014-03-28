//
//  NSDate+Format.m
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Tomasz Blicharczyk on 20.03.2012.
//

#import "NSDate+Format.h"

typedef enum {
    dfsShort = 0,
    dfsMedium,
    dfsLong
} DateFormatStyle;

@implementation NSDate (Format)

+ (NSDate*)todayMidnightDate
{
	NSDate* tmp = [NSDate date];
    NSTimeInterval timeIntervalSince1970 = [tmp timeIntervalSince1970];
	int t = (int) (timeIntervalSince1970 / (24 * 3600));
	return [NSDate dateWithTimeIntervalSince1970: t * 24 * 3600 - [[NSTimeZone defaultTimeZone] secondsFromGMT]];
}

- (NSString*)localUserFormatForDate:(NSDateFormatterStyle)dateStyle andTime:(NSDateFormatterStyle)timeStyle
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:dateStyle];
    [dateFormatter setTimeStyle:timeStyle];
    NSString *formattedDateString = [dateFormatter stringFromDate:self];
    [dateFormatter release];
    return formattedDateString;
}

- (NSString*)localUserFormatForDate:(NSDateFormatterStyle)dateStyle
{
    return [self localUserFormatForDate:dateStyle andTime:NSDateFormatterNoStyle];
}

- (NSString*)localUserFormatForTime:(NSDateFormatterStyle)timeStyle
{
    return [self localUserFormatForDate:NSDateFormatterNoStyle andTime:timeStyle];
}

- (NSString*)localUserLongFormatForDate
{
    return [self localUserFormatForDate:NSDateFormatterLongStyle];
}

- (NSString*)localUserMediumFormatForDate
{
    return [self localUserFormatForDate:NSDateFormatterMediumStyle];
}

- (NSString*)localUserShortFormatForDate
{
    return [self localUserFormatForDate:NSDateFormatterShortStyle];
}

- (NSString*)localUserLongFormatForTime
{
    return [self localUserFormatForTime:NSDateFormatterLongStyle];
}

- (NSString*)localUserShortFormatForTime
{
    return [self localUserFormatForTime:NSDateFormatterShortStyle];
}

- (NSString*)dateFormatForStyle:(DateFormatStyle)style
{
    NSString* format = nil;
    switch (style) {
        case dfsShort:
            format = [self localUserShortFormatForDate];
            break;
        case dfsMedium:
            format = [self localUserMediumFormatForDate];
            break;
        case dfsLong:
            format = [self localUserLongFormatForDate];
            break;
    }
    return format;
}

- (NSString*)niceFormatWithTime:(BOOL)showTime style:(DateFormatStyle)style
{
    NSString* niceFormat = @"";
    NSDate* today = [NSDate todayMidnightDate];
    NSTimeInterval timeInterval = [self timeIntervalSinceDate:today];
    int dateDay = -(int)(timeInterval/(24*3600));
    if (timeInterval >= 0) {
        if (dateDay == 0) {
            if (showTime) {
                niceFormat = [self localUserShortFormatForTime];
            } else {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
                [dateFormatter setDateStyle:NSDateFormatterLongStyle];
                [dateFormatter setDoesRelativeDateFormatting:YES];
                niceFormat = [dateFormatter stringFromDate:self];
                [dateFormatter release];
            }
        } else {
            if (showTime) {
                niceFormat = [self localUserShortFormatForTime];
            } else {
                niceFormat = [self dateFormatForStyle:style];
            }
        }
    } else if (dateDay == 0) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
        [dateFormatter setDoesRelativeDateFormatting:YES];
        niceFormat = [dateFormatter stringFromDate:self];
        [dateFormatter release];
    } else if (dateDay < 6) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEEE"];
        niceFormat = [[dateFormatter stringFromDate:self] capitalizedString];
        [dateFormatter release];
    } else {
        niceFormat = [self dateFormatForStyle:style];
    }
    return niceFormat;
}

- (NSString*)niceShortFormat
{
    return [self niceFormatWithTime:YES style:dfsShort];
}

- (NSString*)niceMediumFormat
{
    return [self niceFormatWithTime:YES style:dfsMedium];
}

- (NSString*)niceLongFormat
{
    return [self niceFormatWithTime:YES style:dfsLong];
}

- (NSString*)niceFormat
{
    return [self niceFormatWithTime:YES style:dfsLong];
}

- (NSString*)niceFormatWithoutTime
{
    return [self niceFormatWithTime:NO style:dfsLong];
}

//DateFormatters

- (NSString*)DDMMYYYY
{
	NSDateFormatter* dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:@"dd-MM-yyyy"];
	
	return [dateFormatter stringFromDate:self];
}

- (NSString*)HHMMDDMMYYYY
{
	NSDateFormatter* dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:@"HH:mm dd-MM-yyyy"];
	
	return [dateFormatter stringFromDate:self];
}

- (NSString*)format:(NSString*)format
{
	NSDateFormatter* dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:format];
	
	return [dateFormatter stringFromDate:self];
}

+ (NSString*)parseSecsToHHMMSS:(unsigned int)val
{
    long sec = val % 3600;
    NSString *value = [NSString stringWithFormat:@"%02d:%02ld:%02ld",
                       val / 3600,
                       sec / 60, sec % 60];
    return value;
}


@end
