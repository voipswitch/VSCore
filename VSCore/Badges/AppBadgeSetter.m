//
//  AppBadgeSetter
//  Vippie
//
//  Created by Bartłomiej Żarnowski on 10.07.2012
//  Copyright (c) VoipSwitch. All rights reserved.
//

#import "AppBadgeSetter.h"
#import <UIKit/UIKit.h>

@implementation AppBadgeSetter

-(void)badgeUpdated:(NSString*)badgeKey newValue:(NSInteger)newVal manager:(BadgesManager*)mgr{
    manager = mgr;
    //perform lazy change... in case of several updates or so...
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(setValueToApp) withObject:nil afterDelay:0.25];
}

-(void)badgeGroupUpdated:(NSString*)badgeGroupKey newValue:(NSInteger)newVal manager:(BadgesManager*)mgr{
    //we don't care
}

-(void)setValueToApp{
    NSInteger badgeValue = [manager cumulativeValue];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeValue];
    DDLogInfo(@"New badge value is: %d", badgeValue);
}

@end