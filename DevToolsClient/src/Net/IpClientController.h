//
//  IpClientController.h
//  UniTracer
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

extern NSString* kIpReceivedDataNotification;

@interface IpClientController : NSObject
{
    BOOL connected;
    NSThread* thread;
    NSInteger sendBytesCount;
    NSInteger maxBytesCount;
}

@property (nonatomic, readwrite, assign) BOOL connected;
@property (nonatomic, readwrite, assign) NSInteger sendBytesCount;
@property (nonatomic, readwrite, assign) NSInteger maxBytesCount;

- (void) socketSendData: (const char*) strToSend;
- (void) connectToServer;

@end
