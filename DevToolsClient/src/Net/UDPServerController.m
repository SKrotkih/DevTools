//
//  UDPServerController.m
//  DevToolsClient
//
//  Created by Sergey Krotkih on 7/31/12.
//  Copyright (c) 2012 Quickoffice. All rights reserved.
//

#import "UDPServerController.h"
#import "GCDAsyncUdpSocket.h"

const NSInteger kServerPortNumber = 1235;

static UDPServerController* sharedInstance;

@interface UDPServerController ()
- (void) setupSocket;
@end

@implementation UDPServerController

@synthesize isRunning;

+ (UDPServerController*) sharedInstance
{
	if (sharedInstance == nil)
    {
		sharedInstance = [[UDPServerController alloc] init];
	}
	
	return sharedInstance;
}

- (id) init
{
	if ((self = [super init]))
	{	
        [self setupSocket];
        
        sharedInstance = self;
	}

	return self;
}

- (void) dealloc
{
    
    [super dealloc];
}

- (void) setupSocket
{
    udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate: self
                                              delegateQueue: dispatch_get_main_queue()];
}

- (void) startServer
{
	if (isRunning)
	{
		// STOP udp echo server
        
		[udpSocket close];
        
        NSLog(@"UDP server has been stopped!");
	}
	else
	{
		// START udp echo server
        
		int port = 0;
        
        NSString* portNumber = [[NSUserDefaults standardUserDefaults] objectForKey: @"LocalServerPortNumber"];
        
        if (portNumber == nil || [portNumber length] == 0)
        {
            port = kServerPortNumber;
        }
        else
        {
            port = [portNumber intValue];
        }
        
		NSError* error = nil;
        
		if (![udpSocket bindToPort: port
                             error: &error])
		{
			NSLog(@"Error starting server (bind): %@", error);
            
			return;
		}
        
		if (![udpSocket beginReceiving: &error])
		{
			[udpSocket close];
            
			NSLog(@"Error starting server (recv): %@", error);
            
			return;
		}
        
		isRunning = YES;
        
        NSLog(@"Server binding to port %d\n", port);
	}
}

#pragma mark Receive data

- (void) udpSocket: (GCDAsyncUdpSocket*) sock
    didReceiveData: (NSData*) data
       fromAddress: (NSData*) address
 withFilterContext: (id) filterContext
{
    [[NSNotificationCenter defaultCenter] postNotificationName: ReceivedDataNotificationId
                                                        object: data];

    [udpSocket sendData: [data retain]
              toAddress: [address retain]
            withTimeout: -1
                    tag: 0];
}

@end
