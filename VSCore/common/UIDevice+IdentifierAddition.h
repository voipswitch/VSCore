//
//  UIDevice(Identifier).h
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski on 12/17/10.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIDevice (IdentifierAddition)

/*
 * @method uniqueDeviceIdentifier
 * @description use this method when you need a unique identifier in one app.
 * It generates random number and store it in keyChain. It should be constant accross
 * several application reinstalations. It's quasiunique for this application.
 */
- (NSString*)uniqueDeviceIdentifier;

/*
 * @method uniqueGlobalDeviceIdentifier
 * @description use this method when you need a unique global identifier to track a device
 * with multiple apps. 
 */
- (NSString*)uniqueGlobalDeviceIdentifier;

/**
 * Returns MAC address of en0 interface for this device in form xx:xx:xx:xx:xx:xx
 * @return MAC address or nil if something goes wrong.
 * @deprecated This method will not work correctly in iOS 7.0
 */
- (NSString*)macAddress DEPRECATED_ATTRIBUTE;
@end
