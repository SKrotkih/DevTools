//
//  DTUDPServerController.h
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreFoundation/CFSocket.h>
#include <sys/socket.h>
#include <netinet/in.h>

@class GCDAsyncUdpSocket;

@interface DTUDPServerController : NSObject
{
	GCDAsyncUdpSocket* udpSocket;
	BOOL isRunning;
    NSMutableArray* dataForSendDict;
}

@property (nonatomic, readwrite) BOOL isRunning;

@end
