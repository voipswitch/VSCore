//
//  Askable.h
//  AddOnsModule
//
//  Created by Bartłomiej Żarnowski on 05.10.2012.
//  Copyright (c) 2012 Bartłomiej Żarnowski. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Static interface ment to be place to obtain various data by using access key. It's designed
 * to be tunel betwean various modules/subsystems for fast data accessing without need to
 * obtain object and his API from some distant places.
 */
@interface Askable : NSObject

/**
 * Registers target-selector par for given key. Each time sombody will ask for value for 
 * this key, associated call to selector will be performed. Beacuse of this fact only fast
 * lightweighted methods should be regisetered in this mode. Any type of data me be returned
 * by selecter, both object & primitive type.
 * @param source object on which selector should be called
 * @param selector which will be executed when data should be retrieved
 * @param key which will be used to access data
 */
+(void)registerAsDirectSource:(id)source withSelector:(SEL)selector forKey:(NSString*)key;

/**
 * Registers value which may be asked in other parts of application. This is NSDictionary like
 * behavior.
 * @param key used to access value
 * @param value bound to key
 */
+(void)registerConstValue:(id)value forKey:(NSString*)key;

/**
 * Removes given key from mapping. It will release all resources bound to it.
 */
+(void)unregisterKey:(NSString*)key;

/**
 * Checks if given key is already registered in Askable interface.
 * @return YES if key is registered, otherwise NO
 */
+(BOOL)keyRegistered:(NSString*)key;

/**
 * Request for data for given key. If no source is associated with key this method returns NO,
 * otherwise it returns YES. Retrieved data are passed whrought out parameter result. The type
 * of result must match resulting type expected for this key. Example of ussage:
 * BOOL res;
 * [Askable askFor:@"someBoolValue" result:&res];
 * @param key identifier for which value should be obtained
 * @param result out value for given key, or unchanged if key not associated
 * @return YES if key is registered otherwise NO
 */
+(BOOL)askFor:(NSString*)key result:(void*)result;

/**
 * Request for bool value for given key. If key doesn't exist valupe passed as def argument is
 * returned. This method will hard cast any result value to BOOL, so if returning type for key
 * is not BOOL then it may lead to strange results!
 * @param key identifier for which value should be obtained
 * @param def default value returned if key not exists
 * @return value for given key or def if key is unknown
 */
+(BOOL)askForBool:(NSString*)key defaultValue:(BOOL)def;

/**
 * Request for NSInteger value for given key. If key doesn't exist valupe passed as def argument is
 * returned. This method will hard cast any result value to NSInteger, so if returning type for key
 * is not NSInteger then it may lead to strange results!
 * @param key identifier for which value should be obtained
 * @param def default value returned if key not exists
 * @return value for given key or def if key is unknown
 */
+(NSInteger)askForInt:(NSString*)key defaultValue:(NSInteger)def;

/**
 * Request for float value for given key. If key doesn't exist valupe passed as def argument is
 * returned. This method will hard cast any result value to float, so if returning type for key
 * is not folat then it may lead to strange results!
 * @param key identifier for which value should be obtained
 * @param def default value returned if key not exists
 * @return value for given key or def if key is unknown
 */
+(float)askForFloat:(NSString*)key defaultValue:(float)def;

/**
 * Request for object value for given key. If key doesn't exist valupe passed as def argument is
 * returned. This method will hard cast any result value to object, so if returning type for key
 * is not object then it may lead to strange results!
 * @param key identifier for which value should be obtained
 * @param def default value returned if key not exists
 * @return value for given key or def if key is unknown
 */
+(id)askForObject:(NSString*)key defaultValue:(id)def;

@end
