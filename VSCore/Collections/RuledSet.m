//
//  RuledSet.m
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski on 26.10.2012.
//

#import "RuledSet.h"
#import "CommonDefines.h"

@interface UnivDepRule:NSObject{
    @public
    id obj, depObj;
    UnivDependencyRule rule;
}
-(id)initWithObj:(id)obj andDep:(id)depObj andRule:(UnivDependencyRule)rule;
@end

@implementation UnivDepRule

-(id)initWithObj:(id)aObj andDep:(id)aDepObj andRule:(UnivDependencyRule)aRule{
    self = [super init];
    if (self != nil){
        self->obj = [aObj retain];
        self->depObj = [aDepObj retain];
        self->rule = aRule;
    }
    return self;
}

-(void)dealloc{
    releaseAndNil(obj);
    releaseAndNil(depObj);
    [super dealloc];
}

@end

@implementation RuledSet

+ (id)ruledSet{
    return [[[RuledSet alloc] init] autorelease];
}

-(id)init{
    self = [super init];
    if (self != nil){
        set = [[NSMutableSet alloc] init];
        rules = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)dealloc{
    releaseAndNil(set);
    releaseAndNil(rules);
    [super dealloc];
}

-(void)applyRule:(UnivDepRule*)rule match:(UnivDependencyRule)mask{
    if ( (rule->rule & mask) == 0){
        //nothing to do
        return;
    }
    
    if ((rule->rule & private_depRuleAutoExclude) != 0){
        [set removeObject:rule->depObj];
        return;
    }
    
    if ((rule->rule & private_depRuleAutoInclude) != 0){
        [set addObject:rule->depObj];
        return;
    }
}

- (void)addObject:(id)object{
    [set addObject:object];

    id rule = [rules objectForKey:object];
    if (rule == nil){
        return;
    }
    if ([rule isKindOfClass:[UnivDepRule class]] == YES){
        [self applyRule:rule match:depRuleAutoIncludeOnAdd|depRuleAutoExcludeOnAdd];
    } else {
        for(UnivDepRule* r in (NSArray*)rule){
            [self applyRule:r match:depRuleAutoIncludeOnAdd|depRuleAutoExcludeOnAdd];
        }
    }
}

- (void)removeObject:(id)object{
    [set addObject:object];

    id rule = [rules objectForKey:object];
    if (rule == nil){
        return;
    }
    if ([rule isKindOfClass:[UnivDepRule class]] == YES){
        [self applyRule:rule match:depRuleAutoIncludeOnRemove|depRuleAutoExcludeOnRemove];
    } else {
        for(UnivDepRule* r in (NSArray*)rule){
            [self applyRule:r match:depRuleAutoIncludeOnRemove|depRuleAutoExcludeOnRemove];
        }
    }
}

- (NSUInteger)count{
    return [set count];
}

- (BOOL)containsObject:(id)anObject{
    return [set containsObject:anObject];
}

- (NSEnumerator *)objectEnumerator{
    return [set objectEnumerator];
}

-(void)addRuleFor:(id<NSCopying>)obj dependency:(id)depObj rule:(UnivDependencyRule)rule{
    id content = [rules objectForKey:obj];
    UnivDepRule* ruleObj = [[UnivDepRule alloc] initWithObj:obj andDep:depObj andRule:rule];

    if (content == nil){
        [rules setObject:ruleObj forKey:obj];
    } else {
        if ([content isKindOfClass:[UnivDepRule class]] == YES){
            //single rule, need to extend to dictionary
            NSMutableArray* tmp = [NSMutableArray arrayWithObjects:content, ruleObj, nil];
            [rules setObject:tmp forKey:obj];
        } else {
            //already dictionary
            [content setObject:ruleObj forKey:depObj];
        }
    }
    releaseAndNil(ruleObj);
}

-(NSString*)description{
    return [set description];
}
@end
