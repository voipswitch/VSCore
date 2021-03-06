//
//  Transform.m
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski on 06.11.2012.
//

#import "Transform.h"
static NSMutableDictionary* regTransformers;

@interface BlockTransformer: NSObject<Transformer>{
    TransformerBlock executor;
}
@end

@implementation BlockTransformer

-(id)initWithBlock:(TransformerBlock)blk{
    self = [super init];
    if (self != nil){
        executor = Block_copy(blk);
    }
    return self;
}

-(void)dealloc{
    Block_release(executor);
    [super dealloc];
}

-(id)transform:(id)what into:(NSString*)purpose{
    return executor(what, nil);
}

-(id)transform:(id)what into:(NSString*)purpose withData:(id)obj{
    return executor(what, obj);
}

@end

@implementation Transform

+(void)initialize{
    regTransformers = [[NSMutableDictionary alloc] init];
}

+(void)registerTransformBlock:(TransformerBlock)block forPurpouse:(NSString*)purpose{
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0), ^{
        BlockTransformer* transformer = [[[BlockTransformer alloc] initWithBlock:block] autorelease];
        [regTransformers setObject:transformer forKey:purpose];
        DDLogVerbose(@"Registering block transformer for purpose %@", purpose);
    });
}

+(void)registerTransformer:(id<Transformer>)transformer forPurpouse:(NSString*)purpose{
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0), ^{
        [regTransformers setObject:transformer forKey:purpose];
        DDLogVerbose(@"Registering transformer %@ for purpose %@", transformer, purpose);
    });
}

+(void)unregisterTransformerForPurpouse:(NSString*)purpose{
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0), ^{
        [regTransformers removeObjectForKey:purpose];
        DDLogVerbose(@"Unregistering transformer for purpose %@", purpose);
    });
}

+(id)transform:(id)what into:(NSString*)purpose{
    __block id result;
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0), ^{
        id<Transformer> tr = [regTransformers objectForKey:purpose];
        result = [tr transform:what into:purpose];
    });
    return result;
}

+(id)transform:(id)what into:(NSString*)purpose withData:(id)obj{
    __block id result;
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0), ^{
        id<Transformer> tr = [regTransformers objectForKey:purpose];
        result = [tr transform:what into:purpose withData:obj];
    });
    return result;
}

@end
