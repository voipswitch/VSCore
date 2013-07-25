//
//  NSString+urlEncoding.h
//  VSCore
//
//  Created by Bartłomiej Żarnowski [Toster] on 11.07.2013.
//  Copyright (c) 2013 Bartłomiej Żarnowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (urlEncoding)

-(NSString*)encodeToPercentEscape;
-(NSString*)decodeFromPercentEscape;
@end
