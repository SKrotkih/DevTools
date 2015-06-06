//
//  UDPServerController.h
//  DevToolsClient
//
//  Created by Sergey Krotkih on 7/31/12.
//  Copyright (c) 2012 Quickoffice. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreFoundation/CFSocket.h>
#import <mach-o/nlist.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>

@class GCDAsyncUdpSocket;

@interface UDPServerController : NSObject
{
	GCDAsyncUdpSocket* udpSocket;
	BOOL isRunning;
}

+ (UDPServerController*) sharedInstance;

- (void) startServer;

@property(nonatomic, readonly) BOOL isRunning;

@end
