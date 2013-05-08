//
//  BadgesManager.h
//  Vippie
//
//  Created by Bartłomiej Żarnowski on 10.07.2012
//  Copyright (c) VoipSwitch. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ASK_BADGES_MANAGER @"BadgesManager.instance"

@class BadgesManager;
@protocol BadgeInfoProvider;

@protocol BadgesManagerListener
-(void)badgeUpdated:(NSString*)badgeKey newValue:(NSInteger)newVal manager:(BadgesManager*)mgr;
-(void)badgeGroupUpdated:(NSString*)badgeGroupKey newValue:(NSInteger)newVal manager:(BadgesManager*)mgr;
@end

/**
* This is main manager class for all badge manipulations. It uses mediator pattern to interact between logic objects
* which holds "badge values" and GUI layer which can visualize it. This class is thread safe.
* All calls to listeners are guaranteed to be done on main thread except situation when new listener is added and it's
* requested for current state. In this scenario notification about current state is performed on caller thread.
*/
@interface BadgesManager : NSObject {
    NSMutableDictionary* trackedProviders;
    NSMutableArray*      listeners;     //WARN: weak reference list, check creation!
    NSMutableDictionary* providersByGroup;
    NSMutableDictionary* valueForProvider;
    NSMutableDictionary* valueForGroup;
}
#pragma mark - Providers management
/**
* Registers a provider for tracking by this mechanism. Lazy init is considered as default option to make startup of
* app as fast as possible. If you want to force update call {@link forceUpdate:} method. After addition this manager
* will try to obtain old value from internal storage using {@link BadgeInfoProvider#badgeKey} uid.
* Subsequent call to this method with this same provider are quiet ignored.
* @param prv Provider to be added.
* @param useOld if YES then before obtaining current value from provider, last know stored value will be used.
*/
-(void)registerProvider:(id<BadgeInfoProvider>)prv restoreOldValue:(BOOL)useOld;

/**
* Removes provider from this manager. Last known value is preserved for future usage
*/
-(void)unregisterProvider:(id<BadgeInfoProvider>)prv;

#pragma mark - State retrieval
/**
* Request value for given badge UID. If key is unknown then value of NSNotFound will be returned
* @return value to be used or NSNotFound
*/
-(NSInteger)badgeValueForKey:(NSString*)badgeKey;
/**
* Request value for given badge group UID. If key is unknown then value of NSNotFound will be returned
* @return value to be used or NSNotFound
*/
-(NSInteger)badgeValueForGroup:(NSString*)groupKey;

#pragma mark - State changes and update request
/**
* Request recalculation of all badge values. If argument lazy is YES then this action is non atomic, and may take some
* time to traverse all providers. Return from call is instantly. At end of this process listeners will be notified about
* changes. If lazy is NO then all operation is atomic and blocking, after return values are guaranteed to be recalculated
* @param lazy type of operation please refer to description of method
*/
-(void)forceUpdate:(BOOL)lazy;

/**
* Called by outer code to notify this manager, that some provider changed value and his state should be updated.
* As a result proper listeners may be notified (if change was detected). NOTE: this method may be heavy
* @param badgeKey UID of provider which has changed
*/
-(void)signalChange:(NSString*)badgeKey;

/**
* Called by outer code to notify this manager, that some provider changed value and his state should be updated. New
* value for this provider is given as second argument, no check to corresponding provider is done as a result.
* As a result proper listeners may be notified (if change was detected)
* @param badgeKey UID of provider which has changed
* @param newVal new value for provider which should be used
*/
-(void)signalChange:(NSString*)badgeKey value:(NSInteger)newVal;

/**
* Called by outer code to notify this manager, that some provider changed value and his state should be updated.
* This triggers lazy update on whole group, and as a result proper listeners may be notified (if change was detected)
* @param groupKey UID of providers group which has changed
*/
-(void)signalGroupChange:(NSString*)groupKey;

#pragma mark - Listeners management
/**
* Adds listener of badge changes. If curState == YES then after addition newly added listener will be notified about
* current state of all tracked providers. Subsequent call to this method with this same listener are quiet ignored.
* @param listener to be added
* @param curState if YES then actual state of manager is passed to listener
*/
-(void)addListener:(id<BadgesManagerListener>)listener requestCurrentState:(BOOL)curState;

/**
* Removes listener from this manager.
* @param listener to be removed
*/
-(void)removeListener:(id<BadgesManagerListener>)listener;

/**
* Returns cumulative value for badge of all tracked providers. This method uses cached data, consider using
* {@link forceUpdate:} if you expected that data may be inaccurate for your case.
* @return sum of all badges from currently tracked providers
*/
-(NSInteger)cumulativeValue;
@end