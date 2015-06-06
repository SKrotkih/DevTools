//
//  DTUDPClientController.h
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreFoundation/CFSocket.h>
#import <mach-o/nlist.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>

@class GCDAsyncUdpSocket;

@interface DTUDPClientController : NSObject
{
	GCDAsyncUdpSocket* udpSocket;
	long tag;
    NSMutableDictionary* dataForSendDict;
    
    BOOL connected;
    NSInteger sendBytesCount;
    NSInteger maxBytesCount;
}

@property (nonatomic, readwrite, assign) BOOL connected;

- (void) connectToServer;

@end
