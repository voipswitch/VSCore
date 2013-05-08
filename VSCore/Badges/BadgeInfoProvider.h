//
//  BadgeInfoProvider
//  Vippie
//
//  Created by Bartłomiej Żarnowski on 10.07.2012
//  Copyright (c) VoipSwitch. All rights reserved.
//

//Value informing that this badge provider is not ready to work as designed. Old state should be used.
#define BADGE_PROVIDER_NOT_READY (-0xFFFF)

/**
* Introduces contract between any logic class and {@link BadgesManager} about providing information of badge values
* which should be presented in GUI.
*/
@protocol BadgeInfoProvider <NSObject>

@required
/**
* Used to determine UID which is used to obtain this provider, or to bind it to GUI.
* @return this provider identification
*/
-(NSString*)badgeKey;

/**
* Returns current value which should be show on badge. If provider for some reason is not ready it may return
* BADGE_PROVIDER_NOT_READY
* @return vale to present on badge or BADGE_PROVIDER_NOT_READY
*/
-(NSInteger)currentBadgeValue;

@optional
/**
* Returns UID which may be used to group several providers. For example Social Networks may consist several providers
* for different links. However on GUI item may be presented cumulative value from all this providers. This is purpose
* of group key.
* @return UID for this group
*/
-(NSString*)badgeGroupKey;

@end