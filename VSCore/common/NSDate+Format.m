//
//  NSDate+Format.m
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Tomasz Blicharczyk on 20.03.2012.
//

#import "NSDate+Format.h"

@implementation NSDate (Format)

+ (NSDate*)todayMidnightDate
{
	NSDate* tmp = [NSDate date];
	int t = (int) ([tmp timeIntervalSince1970] / (24 * 3600));
	return [NSDate dateWithTimeIntervalSince1970: t * 24 * 3600];
}

- (NSString*)niceFormat
{
    NSString* niceFormat = @"";
    NSDate* today = [NSDate todayMidnightDate];
    NSTimeInterval timeInterval = [self timeIntervalSinceDate:today]; 
    int dateDay = -(int)(timeInterval/(24*3600));
    if (timeInterval >= 0) {
        NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
        [formatter setDateFormat:@"HH:mm"];
        NSString* dateFormat = [formatter stringFromDate:self];
        niceFormat = dateFormat;
    } else if (dateDay == 0) {
        niceFormat = NSLocalizedString(@"Yesterday", @"Yesterday");
    } else if (dateDay < 6) {
        NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
        NSDateComponents *components = [gregorian components:NSWeekdayCalendarUnit fromDate:self];
        int dayOfWeek = [components weekday];
        switch (dayOfWeek) {
            case 2: niceFormat = NSLocalizedString(@"Monday", @"Monday"); break;
            case 3: niceFormat = NSLocalizedString(@"Tuesday", @"Tuesday"); break;
            case 4: niceFormat = NSLocalizedString(@"Wednesday", @"Wednesday"); break;
            case 5: niceFormat = NSLocalizedString(@"Thursday", @"Thursday"); break;
            case 6: niceFormat = NSLocalizedString(@"Friday", @"Friday"); break;
            case 7: niceFormat = NSLocalizedString(@"Saturday", @"Saturday"); break;
            case 1: niceFormat = NSLocalizedString(@"Sunday", @"Sunday"); break;
            default: break;
        }
    } else {
        NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
        [formatter setDateFormat:@"MM.dd.YYYY"];
        NSString* dateFormat = [formatter stringFromDate:self];
        niceFormat = dateFormat;
    }
    return niceFormat;
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
+ (NSString*)parseSecsToHHMMSS:(unsigned int) val{
    long sec = val % 3600;
    NSString *value = [NSString stringWithFormat:@"%02d:%02d:%02d",
                       val / 3600,
                       sec / 60, sec % 60];
    return value;
}


@end
