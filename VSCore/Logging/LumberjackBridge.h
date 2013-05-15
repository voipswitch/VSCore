//
//  LumberjackBridge.h
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski on 16.03.2012.
//

#import <Foundation/Foundation.h>

/** Flag used to turnon console output for logger */
#define LJB_CONSOLE             0x1

///Flag used to turnon output for apple system logger */
#define LJB_APPLE_SYSTEM_LOGGER 0x2

/** Flag used to turnon output into filesystem */
#define LJB_FILE                0x4

/** Flag used to turnon live output to server which recieves logs */
#define LJB_LIVE_NETWORK        0x8

/**/
#define LJB_CUSTOM_FILE_LOGGER  0x10

/** Default flag setup. Probably best for common use. */
#define LJB_DEFAULT (LJB_CONSOLE | LJB_APPLE_SYSTEM_LOGGER)

@interface LumberjackBridge : NSObject

/**
 * This method setup and init logging facility. It should be called only once, preferable in didFinishLaunching.
 * @note Setup proper values to LOG_SERVER_HOST and LOG_SERVER_PORT if you include LJB_LIVE_NETWORK flag.
 * @note Flags passed in argument to this method has only meaning in debug mode, in release target they are overriden.
 * @warning To setup logging level please go to pch file and search constant ddLogLevel.
 * @param flags configuration flags, usualy this will be LJB_DEFAULT.
 */
+(void)setupLogger:(NSInteger)flags;

@end
