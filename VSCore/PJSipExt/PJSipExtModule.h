//
//  PJSipExtModule.h
//  VSCore
//
//  Created by Bartłomiej Żarnowski on 17.10.2012.
//  Copyright (c) 2012 Bartłomiej Żarnowski. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * This is proxt protocol. Class which implements it should behave as a entry point to PJSIP module which will be
 * registered in PJSIP. Object will be probably just a facade for low level pjsip Module (struct pjsip_module) which
 * should be registered.
 */
@protocol PJSipExtModule <NSObject>

/**
 * Called by PJSIP engine when it's started. PJSip dependent module should integrate with engine.
 */
-(void)doRegister;

/**
 * Called when PJSIP engine is stopping.
 */
-(void)doUnregister;

@end
