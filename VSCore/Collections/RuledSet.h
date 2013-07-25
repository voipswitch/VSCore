//
//  RuledSet.h
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski on 26.10.2012.
//

#import <Foundation/Foundation.h>

typedef enum {
    private_depRuleAutoInclude = 0x1,
    private_depRuleAutoExclude = 0x2,
    
    depRuleAutoIncludeOnAdd = private_depRuleAutoInclude,
    depRuleAutoExcludeOnAdd = private_depRuleAutoExclude,
    depRuleAutoIncludeOnRemove = 0x80|private_depRuleAutoInclude,
    depRuleAutoExcludeOnRemove = 0x80|private_depRuleAutoExclude,
} UnivDependencyRule;

/**
 * Class which is designed as a set of object, hovewer add/remove operations may be enriched by dependency rules.
 * For example adding some object may exclude other object, etc. refer to {@link UnivDependencyRule} for more info.
 * NOTE: Due to limitations of NSMutableDictionary object stored in this collection must conform to NSCopying. In
 * practice only simple lightweight object should be used to store in this collection, such as NSString.
 * NOTE: This class may be further extended, if you need more methods add it, however DO NOT BREAK previous contract!
 * WARNING: Avoid cycle graph in rules, it WILL lead to infinite recursion!
 */
@interface RuledSet : NSObject{
    NSMutableSet*           set;
    
    //key[object], value = UnivDepRule or NSMutableArray[UnivDepRule]
    NSMutableDictionary*    rules;
}

/**
 * Factory method, it builds empty set with default capacity, and no defined rules.
 * @return new instance of RuledSet
 */
+ (id)ruledSet;

/**
 * Adds object to set, if some rules are defined for added object then they are applied after addition is done.
 * @param object object to be added
 */
- (void)addObject:(id)object;

/**
 * Removes object from set, if some rules are defined for removed object then they are applied after removal is done.
 * @param object object to be removed
 */
- (void)removeObject:(id)object;

/**
 * @return number of objects in set
 */
- (NSUInteger)count;

/**
 * Checks if given object is part of set.
 * @param anObject object to be search in set.
 * @return YES if object is in set, otherwise NO
 */
- (BOOL)containsObject:(id)anObject;

/**
 * @return object enumerator for this set.
 */
- (NSEnumerator *)objectEnumerator;

/**
 * Define new rule for object. Rule is triggered by operation on obj argument, as a result action described by argument
 * rule is applied on set with parameter given by argument depObj. For example defining rule as:
 * obj="a", depObj="b", rule = depRuleAutoIncludeOnAdd adds following dependency to set:
 * when object "a" is added to set, then automatic "b" is also added to set.
 * @param obj object for which rule is defined
 * @param depObj second argument for this rule
 * @param rule describes action which should be executed
 */
-(void)addRuleFor:(id<NSCopying>)obj dependency:(id)depObj rule:(UnivDependencyRule)rule;

@end
