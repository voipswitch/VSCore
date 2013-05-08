#import <Foundation/Foundation.h>
@interface NSDictionary (Additions)

- (BOOL)boolForKey:(NSString *)defaultName;
- (NSString *)stringForKey:(NSString *)defaultName;
- (NSInteger)integerForKey:(NSString *)defaultName;

@end