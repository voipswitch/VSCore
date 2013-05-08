//
//  UnivListener.h
//  VSCore
//
//  Created by Bartłomiej Żarnowski on 30.10.2012.
//  Copyright (c) 2012 Bartłomiej Żarnowski. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * This is generic listener protocol which should be used with {@link AddaptiveExecutor}. Method from this protocol
 * should be called by implementation of request executor when processing of request is done.
 */
@protocol UnivListener <NSObject>

/**
 * Called by executor object, when processing od {@link QueuedRequest} is done. It's guaranteed that call will
 * be placed in this same thread from which request was scheduled. If for some reason request couldn't be compleated
 * result will be set to nil, and appropriate error object will be passed.
 * @param uid of request which has been sheduled
 * @param result of performed request or nil if request couldn't be fulfilled
 * @param context passed while scheduling request
 * @param error if request couldn't be fulfilled, or nil otherwise
 */
-(void)onRequestProccessed:(NSURL*)uid withResult:(id)result andContext:(id)context andError:(NSError*)error;

@end
