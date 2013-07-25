//
//  UIView+FirstResponder.m
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Kamil Rzeźnicki on 25.01.2013.
//

#import "UIView+FirstResponder.h"

@implementation UIView (FirstResponder)

- (UIView *)findFirstResponder
{
    if ([self isFirstResponder])
        return self;
    
    for (UIView * subView in self.subviews)
    {
        UIView * fr = [subView findFirstResponder];
        if (fr != nil)
            return fr;
    }
    
    return nil;
}

@end