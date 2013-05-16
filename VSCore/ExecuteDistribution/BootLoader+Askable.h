//
//  BootLoader+Askable.h
//  VSCore
//
//  Created by Bartłomiej Żarnowski [Toster] on 16.05.2013.
//  Copyright (c) 2013 Bartłomiej Żarnowski. All rights reserved.
//
#import "BootLoader.h"

@interface BootLoader (Askable)

-(void)bind:(id)key intoAskable:(NSString*)askableKey;

@end
