//
//  Transform.h
//  VSCore
//
//  Created by Bartłomiej Żarnowski on 06.11.2012.
//  Copyright (c) 2012 Bartłomiej Żarnowski. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id(^TransformerBlock)(id inObject, id extraData);

/**
 * This protocol must be implemented by any object which want to be added to {@link Transform}.
 * It's allows to transform object of one type into another.
 */
@protocol Transformer <NSObject>

/**
 * Request transformation of object passed as argument to new one which fulfils requested
 * purpouse. Example of usage passing Contact object with purpose sip url should return
 * proper representation of sip url bond with given Contact.
 * @param what object to be transformed
 * @param purpose "rule" which describes transformation
 * @return transformed object or nil if nothing can be done.
 */
-(id)transform:(id)what into:(NSString*)purpose;

/**
 * Same as transform:into: however extra object obj is passed to this method. Usually it holds
 * some extra information which may be help/suggestion/need in transformation process.
 * @param what object to be transformed
 * @param purpose "rule" which describes transformation
 * @param obj extra object usefull in transformation process
 * @return transformed object or nil if nothing can be done.
 */
-(id)transform:(id)what into:(NSString*)purpose withData:(id)obj;
@end

/**
 * Main entry point for all object transformation. It exposes interface which allows other classes
 * to register as {@link Transformer} and requesting transformations.
 */
@interface Transform : NSObject

/**
 * Registers new {@link Transformer} for given purpose. Each prupose is unique, trying to add
 * different transformers for this same purpose will overwrite it (only last one will be used).
 * @param transformer to be registerd
 * @param purpose which should be handled by given transforemer
 */
+(void)registerTransformer:(id<Transformer>)transformer forPurpouse:(NSString*)purpose;

/**
 * Registers new block for given purpose. Each prupose is unique, trying to add
 * different transformer/block for this same purpose will overwrite it (only last one will be used).
 * @param block which should be used to transform object
 * @param purpose which should be handled by given transforemer
 */
+(void)registerTransformBlock:(TransformerBlock)block forPurpouse:(NSString*)purpose;

/**
 * Unbinds given purpose from transform mechanism.
 * @param purpose which should be unregistered
 */
+(void)unregisterTransformerForPurpouse:(NSString*)purpose;

/**
 * Request transformation of object passed as argument to new one which fulfils requested
 * purpouse. Request will be dispatched synchronous to one of registered {@link Transformer}
 * object, if no transformer found nil will be returned.
 *
 * @param what object to be transformed
 * @param purpose "rule" which describes transformation
 * @return transformed object or nil if nothing can be done.
 */
+(id)transform:(id)what into:(NSString*)purpose;

/**
 * Request transformation of object passed as argument to new one which fulfils requested
 * purpouse. Request will be dispatched synchronous to one of registered {@link Transformer}
 * object, if no transformer found nil will be returned.
 *
 * @param what object to be transformed
 * @param purpose "rule" which describes transformation
 * @param obj extra object usefull in transformation process
 * @return transformed object or nil if nothing can be done.
 */
+(id)transform:(id)what into:(NSString*)purpose withData:(id)obj;

@end
