//
//  DTUDPServerController.m
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import "DTUDPServerController.h"
#import <UDP/GCDAsyncUdpSocket.h>
#import "DTConstants.h"
#import "DTClientController.h"

@interface DTUDPServerController ()
- (void) setupSocket;
- (void) startServer:  (NSNotification*) notification;
- (void) stopServer: (NSNotification*) notification;
@end

@implementation DTUDPServerController

@synthesize isRunning;

- (DTUDPServerController*) init
{
	if ((self = [super init]))
	{	
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(startServer:)
                                                     name: StartServerNotificationId
                                                   object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(stopServer:)
                                                     name: StopServerNotificationId
                                                   object: nil];
        
        dataForSendDict = [[NSMutableArray alloc] init];
        
        [self setupSocket];
	}

	return self;
}

- (void) dealloc
{
    [dataForSendDict release];

	[[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: StartServerNotificationId
                                                  object: nil];
	[[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: StopServerNotificationId
                                                  object: nil];
    
    [super dealloc];
}

- (void) setupSocket
{
    udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate: self
                                              delegateQueue: dispatch_get_main_queue()];
}

- (void) startServer: (NSNotification*) notification
{
	if (!isRunning)
	{
		// START udp echo server

		int port = DefaultServerPortNumber;

        NSString* portNumber = [[NSUserDefaults standardUserDefaults] objectForKey: LocalServerPortNumberUserDefaultId];
        
        if (portNumber != nil)
        {
            port = [portNumber intValue];
        }
        
		NSError* error = nil;

		if (![udpSocket bindToPort: port
                             error: &error])
		{
            NSBeginAlertSheet(@"Error starting server (bind)", nil, nil, nil, MAINWINDOW, nil, nil, nil, nil, @"%@", error);

			return;
		}

		if (![udpSocket beginReceiving: &error])
		{
			[udpSocket close];

            NSBeginAlertSheet(@"Error starting server (recv)", nil, nil, nil, MAINWINDOW, nil, nil, nil, nil, @"%@", error);

			return;
		}

		self.isRunning = YES;
        
        NSLog(@"Server binding to port %d\n", port);
	}
}

- (void) stopServer: (NSNotification*) notification
{
	if (isRunning)
	{
		// STOP udp echo server
        
		[udpSocket close];
        
        NSLog(@"UDP server has been stopped!");
        
        self.isRunning = NO;
	}
}

#pragma mark Receive data

- (void) udpSocket: (GCDAsyncUdpSocket*) sock
    didReceiveData: (NSData*) aData
       fromAddress: (NSData*) anAddress
 withFilterContext: (id) filterContext
{
    if (aData == nil)
    {
        return;
    }

    
    NSString* str = [[NSString alloc] initWithData: aData
                                          encoding: NSUTF8StringEncoding];
    
    NSLog(@"%@", str);
    
    
    NSError* error = nil;
    NSDictionary* dict = [NSJSONSerialization JSONObjectWithData: aData
                                                         options: NSJSONReadingMutableContainers
                                                           error: &error];
    
    if (!dict)
    {
        NSLog(@"Error parsing JSON: %@", error);
        
        return;
    }
    
    if (![dict isKindOfClass: [NSDictionary class]])
    {
        NSLog(@"Error!!!");
        
        return;
    }
    
    NSString* command = [dict objectForKey: CommandKeyForJSONdictionary];
    NSString* tag = [dict objectForKey: TagKeyForJSONdictionary];
    NSUInteger len = [[dict objectForKey: LenDataKeyForJSONdictionary] integerValue];
    
    if ([command isEqualToString: ConnectToServerMessageId])
    {
        [dataForSendDict removeAllObjects];
    }
    
    if ([dataForSendDict indexOfObject: tag] == NSNotFound)
    {
        [dataForSendDict addObject: tag];
        [[NSNotificationCenter defaultCenter] postNotificationName: ReceivedDataNotificationId
                                                            object: aData];
    }

    NSString* echo = [NSString stringWithFormat: @"tag=%@;len=%li", tag, len];
    
    NSLog(@"\n === ECHO:%@", echo);
    
    [DTClientController runCommand: EchoFromServerNotificationId
                            data: echo];
    
    // ECHO message
    NSLog(@"Server has sent echo.\n");

    [udpSocket sendData: [aData retain]
              toAddress: [anAddress retain]
            withTimeout: -1
                    tag: 0];
}

@end
