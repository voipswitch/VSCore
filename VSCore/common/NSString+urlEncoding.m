//
//  NSString+urlEncoding.m
//  VSCore
//
//  Created by Bartłomiej Żarnowski [Toster] on 11.07.2013.
//  Copyright (c) 2013 Bartłomiej Żarnowski. All rights reserved.
//

#import "NSString+urlEncoding.h"

@implementation NSString (urlEncoding)

-(NSString*)encodeToPercentEscape{
    return (NSString *) CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                (CFStringRef) self,
                                                                NULL,
                                                                (CFStringRef) @"!*'();:@&=+$,/?%#[]",
                                                                kCFStringEncodingUTF8);
}

-(NSString*)decodeFromPercentEscape{
    return (NSString *) CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                            (CFStringRef) self,
                                                            CFSTR(""),
                                                            kCFStringEncodingUTF8);
}

@end
