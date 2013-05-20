//
//  Device.h
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Andrzej Górski on 12/17/10.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIDevice(machine)
/**
 * @return Textual representation of device model name.
 **/
- (NSString *)machine;
@end
