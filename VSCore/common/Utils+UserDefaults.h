//
//  Utils+UserDefaults.h
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Witold Matuszczak on 17.05.2012.
//

#import "Utils.h"

/**
 * @author Witek
 * @brief Methods for using user defaults.
 */
@interface Utils (UserDefaults)

/**
 * @author Witek
 * @brief
 * Get value from user defaults by path.
 * Path can be with dots. For example "item1.item3" means tah we get object
 * named "item1" from user defaults which is NSDictionary and from this
 * dictionary object for key "item3" is got.
 * if value not exists (nil) than method will search for value in "defaults."+path.
 */
+(id) objectFromUserDefaultsForPath:(NSString*)path;


/**
 * @author Witek
 * @brief
 * Set value in user defaults by path
 * Path can be with dots. For example "item1.item3" means tah we get object
 * named "item1" from user defaults which is NSDictionary and from this
 * dictionary object for key "item3" is set.
 * @warning synchronize is not called.
 */
+(void) setObjectFromUserDefaultsForPath:(NSString*)path value:(id) value;

/**
 * @author Witek
 * @brief
 * Remove value in user defaults by path
 * Path can be with dots. For example "item1.item3" means tah we get object
 * named "item1" from user defaults which is NSDictionary and remove from this
 * dictionary object for key "item3".
 * @warning synchronize is not called.
 */
+(void) removeObjectFromUserDefaultsForPath:(NSString*)path;
@end
