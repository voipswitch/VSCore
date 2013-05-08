//
//  AppBadgeSetter
//  Vippie
//
//  Created by Bartłomiej Żarnowski on 10.07.2012
//  Copyright (c) VoipSwitch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BadgesManager.h"

@interface AppBadgeSetter : NSObject<BadgesManagerListener> {
    BadgesManager* manager;
}

@end