//
//  UDPSereverController.h
//  UniTracer
//
//  Created by Sergey Krotkih on 7/31/12.
//  Copyright (c) 2012 Quickoffice. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreFoundation/CFSocket.h>
#include <sys/socket.h>
#include <netinet/in.h>

extern NSString* kAcceptConnectionNotification;
extern NSString* kReceivedDataNotification;
extern NSString* kStartServerNotification;
extern NSString* kSendDataNotification;

@class GCDAsyncUdpSocket;

@interface UDPSereverController : NSObject
{
	GCDAsyncUdpSocket* udpSocket;
	BOOL isRunning;    
}

@end
