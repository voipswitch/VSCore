//
//  BadgesManager
//  Vippie
//
//  Created by Bartłomiej Żarnowski on 10.07.2012
//  Copyright (c) VoipSwitch. All rights reserved.
//

#import "BadgesManager.h"
#import "BadgeInfoProvider.h"
#import "FileHelper.h"
#import "NSMutableArray+WeakReferences.h"
#import "CommonDefines.h"

@interface BadgesManager ()
- (void)notifyAboutProviderChange:(NSString const*)badgeKey newVal:(NSInteger)newVal;

- (void)notifyAboutGroupChange:(NSString*)groupKey newVal:(NSInteger)newVal;

- (void)cachedSignalGroupChange:(NSString*)groupKey;

@end

@implementation BadgesManager
- (void)saveLastState {

    NSString* path = [NSString stringWithFormat:@"%@%@", [FileHelper libraryPath:nil], @"badges_p.dic"];
    [valueForProvider writeToFile:path atomically:YES];

    path = [NSString stringWithFormat:@"%@%@", [FileHelper libraryPath:nil], @"badges_g.dic"];
    [valueForGroup writeToFile:path atomically:YES];
}

- (void)loadLastState {
    NSString* path = [NSString stringWithFormat:@"%@%@", [FileHelper libraryPath:nil], @"badges_p.dic"];
    NSDictionary* old = [NSDictionary dictionaryWithContentsOfFile:path];
    if ([old count] != 0){
        [valueForProvider addEntriesFromDictionary:old];
    }

    path = [NSString stringWithFormat:@"%@%@", [FileHelper libraryPath:nil], @"badges_g.dic"];
    old = [NSDictionary dictionaryWithContentsOfFile:path];
    if ([old count] != 0){
        [valueForGroup addEntriesFromDictionary:old];
    }
}

- (id)init {
    self = [super init];
    if (self) {
        trackedProviders = [[NSMutableDictionary alloc] init];
        listeners = [[NSMutableArray mutableArrayUsingWeakReferences] retain];
        providersByGroup = [[NSMutableDictionary alloc] init];
        valueForProvider = [[NSMutableDictionary alloc] init];
        valueForGroup = [[NSMutableDictionary alloc] init];
        [self loadLastState];
    }

    return self;
}

- (void)dealloc {
    releaseAndNil(trackedProviders);
    releaseAndNil(listeners);
    releaseAndNil(providersByGroup);
    releaseAndNil(valueForGroup);
    releaseAndNil(valueForProvider);

    [super dealloc];
}

/**
* Finds proper group and adds new provider. If already in group, call is ignored. This method DOES NOT recalculate
* values!
* @param prv provider to be put into group
*/
- (void)addToProperGroup:(id <BadgeInfoProvider>)prv {
    NSMutableArray* group = [providersByGroup objectForKey:[prv badgeGroupKey]];
    if (group == nil){
        group = [NSMutableArray arrayWithCapacity:1];
        [providersByGroup setValue:group forKey:[prv badgeGroupKey]];
    }
    if ([group containsObject:prv] == NO){
        [group addObject:prv];
    }
}

- (void)registerProvider:(id <BadgeInfoProvider>)prv restoreOldValue:(BOOL)useOld {
    @synchronized (self) {
        if ([trackedProviders objectForKey:[prv badgeKey]] != nil){
            return;
        }
        [trackedProviders setValue:prv forKey:[prv badgeKey]];

        if ([prv respondsToSelector:@selector(badgeGroupKey)] == YES){
            [self addToProperGroup:prv];
        }
    }
    if (useOld == NO){
        [self signalChange:[prv badgeKey]];
    } else {
        //perform update after one sec
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC),
                       dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
             [self signalChange:[prv badgeKey]];
        });
    }
}

//should be called from synchronized section
- (BOOL)removeFromProperGroup:(id <BadgeInfoProvider>)prv {
    NSMutableArray* group = [providersByGroup objectForKey:[prv badgeGroupKey]];
    if (group == nil){
        return NO;
    }
    if ([group containsObject:prv] == NO){
        [group removeObject:prv];
        return YES;
    }
    return NO;
}

//should be called from synchronized section
- (void)decreaseGroupComponent:(id <BadgeInfoProvider>)prv {
    NSInteger i = [[valueForProvider objectForKey:[prv badgeKey]] integerValue];
    if (i == 0){
        return;
    }
    NSString* grKey = [prv badgeGroupKey];

    i = [[valueForGroup objectForKey:grKey] integerValue] - i;
    [valueForGroup setObject:[NSNumber numberWithInt:i] forKey:grKey];
    [self notifyAboutGroupChange:grKey newVal:i];
}

- (void)unregisterProvider:(id <BadgeInfoProvider>)prv {
    [prv retain];
    @synchronized (self) {
        [trackedProviders removeObjectForKey:[prv badgeKey]];

        if ([prv respondsToSelector:@selector(badgeGroupKey)] == YES){
            if ([self removeFromProperGroup:prv] == YES){
                [self decreaseGroupComponent:prv];
            }
        }
    }
    [prv release];
}

- (NSInteger)badgeValueForKey:(NSString*)badgeKey {
    @synchronized (self) {
        NSNumber* val = [valueForProvider objectForKey:badgeKey];
        return val == nil ? NSNotFound : [val integerValue];
    }
}

- (NSInteger)badgeValueForGroup:(NSString*)groupKey {
    @synchronized (self) {
        NSNumber* val = [valueForGroup objectForKey:groupKey];
        return val == nil ? NSNotFound : [val integerValue];
    }
}

- (void)forceUpdate:(BOOL)lazy {
    dispatch_block_t execBlock = ^{
        NSMutableSet* groups = [NSMutableSet set];
        //this loop is thread unsafe, but assuming no unregister of providers is done at this time
        //(considered as rarely situation)
        for (id<BadgeInfoProvider> prv in trackedProviders){
            NSInteger nv = [prv currentBadgeValue];
            if (nv == BADGE_PROVIDER_NOT_READY){
                continue;
            }
            NSString* bk = [prv badgeKey];
            @synchronized (self) {
                NSNumber* n = [valueForProvider objectForKey:bk];
                if (nv == [n integerValue]){
                    continue;
                }
            }
            [self notifyAboutProviderChange:bk newVal:nv];
            if ([prv respondsToSelector:@selector(badgeGroupKey)] == YES){
                [groups addObject:[prv badgeGroupKey]];
            }
        }

        [groups enumerateObjectsUsingBlock:^(id obj, BOOL *stop){
            [self cachedSignalGroupChange:obj];
            *stop = NO;
        }];
        [self saveLastState];
    };

    if (lazy == YES){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), execBlock);
    } else {
        execBlock();
    }
}

-(void)signalChange:(NSString*)badgeKey value:(NSInteger)newVal{
    if (newVal == BADGE_PROVIDER_NOT_READY){
        return;
    }
    id<BadgeInfoProvider> prv;
    @synchronized (self) {
        NSNumber* n = [valueForProvider objectForKey:badgeKey];
        if ([n integerValue] == newVal){
            return;
        }
        n = [NSNumber numberWithInt:newVal];
        [valueForProvider setValue:n forKey:badgeKey];
        //update group if provider is tracked
        prv = [trackedProviders objectForKey:badgeKey];
        if (prv == nil){
            return;
        }
    }

    [self notifyAboutProviderChange:badgeKey newVal:newVal];

    if ([prv respondsToSelector:@selector(badgeGroupKey)] == YES){
        [self cachedSignalGroupChange:[prv badgeGroupKey]];
    }
    [self saveLastState];
}

- (void)signalChange:(NSString*)badgeKey {
    id<BadgeInfoProvider> prv;
    @synchronized (self) {
        prv = [trackedProviders objectForKey:badgeKey];
        if (prv == nil){
            return;
        }
    }
    NSInteger r = [prv currentBadgeValue];
    if (r != BADGE_PROVIDER_NOT_READY){
        [self signalChange:badgeKey value:r];
    }
}

//This method will execute on main thread!
- (void)notifyAboutProviderChange:(NSString*)badgeKey newVal:(NSInteger)newVal {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray* cpy;
        @synchronized (self) {
            cpy = [listeners copy];
        }
        for(id<BadgesManagerListener> lst in cpy){
            [lst badgeUpdated:badgeKey newValue:newVal manager:self];
        }
        [cpy release]; cpy = nil;
    });
}

//This method will execute on main thread!
- (void)notifyAboutGroupChange:(NSString*)groupKey newVal:(NSInteger)newVal {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray* cpy;
        @synchronized (self) {
            cpy = [listeners copy];
        }
        for(id<BadgesManagerListener> lst in cpy){
            [lst badgeGroupUpdated:groupKey newValue:newVal manager:self];
        }
        [cpy release]; cpy = nil;
    });
}

- (void)cachedSignalGroupChange:(NSString*)groupKey {
    NSInteger newVal = 0;
    @synchronized (self) {
        NSArray* prvs = [providersByGroup objectForKey:groupKey];
        if (prvs == nil){
            return;
        }
        NSInteger oldVal = [[valueForGroup objectForKey:groupKey] integerValue];
        for (id<BadgeInfoProvider> prv in prvs){
            newVal += [[valueForProvider objectForKey:[prv badgeKey]] integerValue];
        }
        if (newVal == oldVal){
            return;
        }
        [valueForGroup setValue:[NSNumber numberWithInt:newVal] forKey:groupKey];
    }
    [self notifyAboutGroupChange:groupKey newVal:newVal];
}

- (void)signalGroupChange:(NSString*)groupKey {
    NSArray* providers = [providersByGroup objectForKey:groupKey];
    BOOL change = NO;
    for (id<BadgeInfoProvider> prv in providers ){
        NSInteger newVal = [prv currentBadgeValue];
        if (newVal == BADGE_PROVIDER_NOT_READY){
            continue;
        }
        NSString* bk = [prv badgeKey];
        @synchronized (self) {
            NSNumber* n = [valueForProvider objectForKey:bk];
            if (newVal == [n integerValue]) {
                continue;
            }
            [valueForProvider setValue:[NSNumber numberWithInt:newVal] forKey:bk];
        }
        [self notifyAboutProviderChange:bk newVal:newVal];
    }
    if (change == YES){
        [self cachedSignalGroupChange:groupKey];
        [self saveLastState];
    }
}

- (void)addListener:(id <BadgesManagerListener>)listener requestCurrentState:(BOOL)curState {
    @synchronized (self) {
        if ([listeners containsObject:listener] == YES){
            return;
        }
        [listeners addObject:listener];
        if (curState == NO){
            return;
        }
    }

    //return current state for providers
    [valueForProvider enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        [listener badgeUpdated:key newValue:[obj integerValue] manager:self];
        *stop = NO;
    }];

    //return current state for groups
    [valueForGroup enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        [listener badgeGroupUpdated:key newValue:[obj integerValue] manager:self];
        *stop = NO;
    }];
}

- (void)removeListener:(id <BadgesManagerListener>)listener {
    @synchronized (self) {
        [listeners removeObject:listener];
    }
}

- (NSInteger)cumulativeValue {
    NSInteger res = 0;
    for (id<BadgeInfoProvider> prv in [trackedProviders allValues]){
        NSNumber* n = [valueForProvider objectForKey:[prv badgeKey]];
        res += [n integerValue];
    }
    return res;
}

@end