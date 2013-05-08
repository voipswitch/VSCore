//
//  NSString+Email.m
//  Vippie
//
//  Created by Tomasz Blicharczyk on 20.08.2012.
//
//

#import "NSString+Email.h"

@implementation NSString (Email)

- (BOOL)isCorrectEmail
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
//    NSString *stricterFilterString = @"[A-Z0-9a-z]{1}[A-Z0-9a-z._-]*@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *stricterFilterString = @"[A-Z0-9a-z]{1}[A-Z0-9a-z._-]*@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return (self == nil || [self isEqualToString:@""] || [emailTest evaluateWithObject:self]);
}

@end
