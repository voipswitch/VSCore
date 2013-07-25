//
//  AppBadgeSetter
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski on 10.07.2012
//

#import <Foundation/Foundation.h>
#import "BadgesManager.h"

@interface AppBadgeSetter : NSObject<BadgesManagerListener> {
    BadgesManager* manager;
}

@end