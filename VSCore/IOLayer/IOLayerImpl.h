//
//  IOLayerImpl.h
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski on 24.08.2012.
//
//

#import <Foundation/Foundation.h>
#import "IOLayer.h"

@protocol InputMessageParser;
@protocol OutputMessageParser;

@interface IOLayerImpl : NSObject<IOLayer>{
    id<InputMessageParser>  inputParser;
    id<IOSender>            sender;
    NSMutableDictionary*    chains;
    NSMutableArray*         inModules;
}

@end
