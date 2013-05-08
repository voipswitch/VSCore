//
//  DDUDPLogger.h
//  Tosters Core
//
//  Created by Bartłomiej Żarnowski on 19.03.2012.
//  Copyright (c) 2012 The Tosters. All rights reserved.
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
