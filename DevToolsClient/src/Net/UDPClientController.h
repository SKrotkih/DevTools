//
//  UDPClientController.h
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

@interface UDPClientController : NSObject
{
	GCDAsyncUdpSocket* udpSocket;
	long currentTag;
	long maxTag;
    long connectCommandTag;
    NSMutableDictionary* dataForSendDict;

    BOOL isConnected;
    NSData* lastDataToSend;
    NSInteger sendBytesCount;
    NSInteger maxBytesCount;
    NSLock* socketsLock;
}

@property (nonatomic, readwrite, assign) BOOL isConnected;
@property (nonatomic, readwrite, assign) NSInteger sendBytesCount;
@property (nonatomic, readwrite, assign) NSInteger maxBytesCount;

+ (UDPClientController*) sharedInstance;

- (void) runCommandOnServer: (NSString*) aCommand
                contCommand: (NSString*) aContCommand
                       data: (NSString*) aSendData;

- (void) receivedEchoFromServer: (NSString*) anEcho;

- (void) connectToServer;

@end
