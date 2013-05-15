//
//  DDUDPLogger.h
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski on 19.03.2012.
//

#import <Foundation/Foundation.h>
#import "DDLog.h"
#import "GCDAsyncUdpSocket.h"

@interface DDUDPLogger : DDAbstractLogger <DDLogger>{
    GCDAsyncUdpSocket* sock;
    NSDateFormatter* dateFrm;
}

- (id)initWithHost:(NSString*)host andPort:(NSInteger)port;

@end
