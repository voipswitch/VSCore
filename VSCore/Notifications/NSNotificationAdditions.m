/**
 *  Colloquy Project - A Mac OS X Internet Chat Client 
 *  Copyright (C) Colloquy <http://colloquy.info/index.html>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along
 *  with this program; if not, write to the Free Software Foundation, Inc.,
 *  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 * 
 * http://www.cocoadev.com/index.pl?NotificationsAcrossThreads
 */

#import "NSNotificationAdditions.h"
#import <pthread.h>
#import "AdaptiveDispatcher.h"

#define USE_ADAPTIVE_DISPATCHER  1

#if defined (USE_ADAPTIVE_DISPATCHER) && USE_ADAPTIVE_DISPATCHER == 1
static AdaptiveDispatcher* dispatcher = nil;
#endif

@implementation NSNotificationCenter (NSNotificationCenterAdditions)
- (void) postNotificationOnMainThread:(NSNotification *) notification
{
  if( pthread_main_np() ) return [self postNotification:notification];
  [self postNotificationOnMainThread:notification waitUntilDone:NO];
}

- (void) postNotificationOnMainThread:(NSNotification *) notification waitUntilDone:(BOOL) wait
{
  if( pthread_main_np() ) return [self postNotification:notification];
  [[self class] performSelectorOnMainThread:@selector( _postNotification: ) withObject:notification waitUntilDone:wait];
}

+ (void) _postNotification:(NSNotification *) notification
{
  [[self defaultCenter] postNotification:notification];
}

- (void) postNotificationOnMainThreadWithName:(NSString *) name object:(id) object
{
#if defined (USE_ADAPTIVE_DISPATCHER) && USE_ADAPTIVE_DISPATCHER == 1
  [self postNotificationOnMainThreadWithName:name object:object userInfo:nil waitUntilDone:NO];
#else
  if( pthread_main_np() ) return [self postNotificationName:name object:object userInfo:nil];
  [self postNotificationOnMainThreadWithName:name object:object userInfo:nil waitUntilDone:NO];
#endif
}

- (void) postNotificationOnMainThreadWithName:(NSString *) name object:(id) object userInfo:(NSDictionary *) userInfo
{
#if defined (USE_ADAPTIVE_DISPATCHER) && USE_ADAPTIVE_DISPATCHER == 1
  [self postNotificationOnMainThreadWithName:name object:object userInfo:userInfo waitUntilDone:NO];
#else
  if( pthread_main_np() ) return [self postNotificationName:name object:object userInfo:userInfo];
  [self postNotificationOnMainThreadWithName:name object:object userInfo:userInfo waitUntilDone:NO];
#endif
}

- (void) postNotificationOnMainThreadWithName:(NSString *) name object:(id) object userInfo:(NSDictionary *) userInfo waitUntilDone:(BOOL) wait
{    
#if defined (USE_ADAPTIVE_DISPATCHER) && USE_ADAPTIVE_DISPATCHER == 1
    NSAssert(wait == NO, @"wait = YES not supported!");
    @synchronized(self){
        if (dispatcher == nil) {
            dispatcher = [[AdaptiveDispatcher alloc] init];
        }
    }
    NSMutableDictionary *info = [[[NSMutableDictionary allocWithZone:nil] initWithCapacity:3] autorelease];
    if( name ) [info setObject:name forKey:@"name"];
    if( object ) [info setObject:object forKey:@"object"];
    if( userInfo ) [info setObject:userInfo forKey:@"userInfo"];
    [dispatcher addToQueue:info];
    
#else
  //old version
  if( pthread_main_np() ) return [self postNotificationName:name object:object userInfo:userInfo];

  NSMutableDictionary *info = [[NSMutableDictionary allocWithZone:nil] initWithCapacity:3];
  if( name ) [info setObject:name forKey:@"name"];
  if( object ) [info setObject:object forKey:@"object"];
  if( userInfo ) [info setObject:userInfo forKey:@"userInfo"];
  [[self class] performSelectorOnMainThread:@selector( _postNotificationName: ) withObject:info waitUntilDone:wait];
#endif
}

+ (void) _postNotificationName:(NSDictionary *) info
{
  NSString *name = [info objectForKey:@"name"];
  id object = [info objectForKey:@"object"];
  NSDictionary *userInfo = [info objectForKey:@"userInfo"];

  [[self defaultCenter] postNotificationName:name object:object userInfo:userInfo];

  [info release];
}
@end
