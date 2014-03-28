//
//  IOLayer.h
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski on 24.08.2012.
//
//

#import <Foundation/Foundation.h>

//Holds NSString which identifies chain used to encode out message when sending throught
//sendMessage:withContext
#define CONTEXT_CHAIN_ID @"chID"

//Holds value (NSNumber) created from MessageCenter.primaryKey This introduces some kind of coupling,
//maybe it will be resolved later...
#define CONTEXT_PRIMARY_KEY @"pk"

//Used by IOSended to determine destination to which data should be delivered
#define CONTEXT_DESTINATION @"des"

//Used by IOSended to determine destination call id refer to SIP SendSMS method
#define CONTEXT_CALL_ID_STR @"call_idStr"

//Used by IOSended to determine which account should be used to send it (must be pj_acc_id or nil or -1 to use default)
#define CONTEXT_PJ_ACC_ID_STR @"pj_accId_Str"
//Id from members manager, which is later translated pjsip account index
#define CONTEXT_ACC_ID_STR @"accId_Str"

//Used to mark text came from/t
#define CONTEXT_TEXTUAL_CONTENT @"msgTxt"

//Used to mark common part of context
#define CONTEXT_COMMON_PART @"shrCtx"

@protocol IOLayer;

@protocol InputMessageParser <NSObject>

- (NSArray*)parseInMessage:(NSString*)msg;

@end

@protocol IOOutModule <NSObject>
- (NSString*) processOut:(NSString*)msg context:(NSMutableDictionary*)context;
@end

//Should be used for modules which should be called as first in processing order
#define IOMODULE_PRI_HIGH   200

//Should be used for modules which should be called as standard handlers processing order
#define IOMODULE_PRI_NORMAL 1000

//Should be used for modules which are unsed and msg shouldn't be on dialer msg list
#define IOMODULE_PRI_UNUSED 8999

//Should be used for modules which should be called as final handlers, usually to catch all what left
#define IOMODULE_PRI_LOW    9000

@protocol IOInModule <NSObject>

/**
 * Use for setup in modules chain, lower priority value means that module will be called earlier.
 * You may use IOMODULE_PRI_NORMAL as default.
 */
@property (nonatomic, readonly) NSInteger priority;
- (BOOL) processIn:(NSObject*)msg context:(NSMutableDictionary*)context ioLayer:(id<IOLayer>)ioLayer;

@end

@protocol IOSender <NSObject>

-(void)ioSend:(NSString*)msg withContext:(NSMutableDictionary*)context;

@end


/** 
 * May be used by IOInModule as a destination of processed message. For example this can be storage
 * or any other class which is interesed in having message which is fully processed. Each IOInModule
 * may decide to use it depends of their design/function
 */
@protocol IOInSink <NSObject>

-(void)ioAddMessage:(NSObject*)msg;

@end

@protocol IOLayer <NSObject>

@property (nonatomic, retain) id<InputMessageParser> inputParser;
@property (nonatomic, retain) id<IOSender> sender;
@property (nonatomic, retain) id<IOInSink> inSink;

- (void) addInModule:(id<IOInModule>)inModule;
- (void) addOutChain:(NSArray*)chain withId:(NSString*)chainId;
- (void) processInMessage:(NSString*)msg context:(NSMutableDictionary*)context;
- (void) sendMessage:(NSString*)msg withContext:(NSMutableDictionary*)context;

@end
