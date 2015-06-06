//
//  DTUDPClientController.m
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import "DTUDPClientController.h"
#import "DTConstants.h"
#import <UDP/GCDAsyncUdpSocket.h>

@interface NSString(ForClientCategory)
- (BOOL) isEqualForCommandName: (NSString*) commandName;
@end

@implementation NSString(ForClientCategory)

- (BOOL) isEqualForCommandName: (NSString*) commandName
{
    NSInteger len = [commandName length];

    if ((len > 0) && (len <= [self length]))
    {
        NSRange range = NSMakeRange(0, len);

        return [[self substringWithRange: range] isEqualToString: commandName];
    }
    
    return NO;
}

@end

@interface DTUDPClientController ()
- (void) sendData: (NSNotification*) notification;
- (void) setupSocket;
- (void) socketSendData: (NSData*) dataForSend;
@end

@implementation DTUDPClientController

@synthesize connected;

- (id) init
{
    if ((self = [super init]))
    {	
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(sendData:)
                                                     name: SendDataNotificationId
                                                   object: nil];
        dataForSendDict = [[NSMutableDictionary alloc] init];
		
        [self setupSocket];
	}

	return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: SendDataNotificationId
                                                  object: nil];
    
    [dataForSendDict release];
    
    [super dealloc];
}

- (void) setupSocket
{
	udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate: self
                                              delegateQueue: dispatch_get_main_queue()];
	
	NSError *error = nil;
	
	if (![udpSocket bindToPort: 0
                         error: &error])
	{
		NSLog(@"Error binding: %@", error);
		return;
	}

	if (![udpSocket beginReceiving: &error])
	{
		NSLog(@"Error receiving: %@", error);
		return;
	}
	
	NSLog(@"Ready");
}

- (void) connectToServer
{
    if (connected == NO)
    {
        NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys: ConnectToServerMessageId, CommandKeyForJSONdictionary, @"", DataKeyForJSONdictionary, nil];
        
        if ([NSJSONSerialization isValidJSONObject: dict])
        {
            NSData* data = [NSJSONSerialization dataWithJSONObject: dict
                                                           options: 0
                                                             error: nil];
            NSData* dataForSend = [[NSData alloc] initWithData: data];

            [self socketSendData: dataForSend];
        }
    }
}

#pragma mark Send data

- (void) sendData: (NSNotification*) notification
{
    NSData* data = [notification object];
    NSData* dataForSend = [[NSData alloc] initWithData: data];
    [self socketSendData: dataForSend];
}

- (void) socketSendData: (NSData*) dataForSend
{
    [dataForSendDict setObject: dataForSend
                        forKey: [NSString stringWithFormat: @"%ld", tag]];
    [dataForSend release];
    
    NSString* host = [[NSUserDefaults standardUserDefaults] objectForKey: ClientHostNameUserDefaultId];
    
    if (host == nil || [host length] == 0)
    {
        host = [NSString stringWithString: DefaultClientHostName];
    }
    
    NSString* portNumber = [[NSUserDefaults standardUserDefaults] objectForKey: ClientPortNumberUserDefaultId];
    
    NSInteger port;
    
    if (portNumber == nil || [portNumber length] == 0)
    {
        port = DefaultClientPortNumber;
    }
    else
    {
        port = [portNumber intValue];
    }

    {
        NSString* str = [[NSString alloc] initWithData: dataForSend
                                              encoding: NSUTF8StringEncoding];
        
        NSLog(@"\n === SEND DATA:%@", (([str length] > 50) ? [str substringToIndex: 50] : str));
    }
    
    [udpSocket sendData: dataForSend
                 toHost: host
                   port: port
            withTimeout: -1
                    tag: tag];
    
    tag++;
}

- (void) udpSocket: (GCDAsyncUdpSocket*) sock didSendDataWithTag: (long) aTag
{
    NSString* key = [NSString stringWithFormat: @"%ld", aTag];
    [dataForSendDict removeObjectForKey: key];
    
    NSLog(@"Send tag = %ld was succesfully!", aTag);
	// You could add checks here
}

- (void) udpSocket: (GCDAsyncUdpSocket*) sock
didNotSendDataWithTag: (long) aTag
        dueToError: (NSError*) error
{
    NSString* key = [NSString stringWithFormat: @"%ld", aTag];
    [dataForSendDict removeObjectForKey: key];

    NSLog(@"Got an error: %@[tag=%ld]", error, aTag);
	// You could add checks here
}

#pragma mark Receive data

- (void) udpSocket: (GCDAsyncUdpSocket*) sock
    didReceiveData: (NSData*) data
       fromAddress: (NSData*) address
 withFilterContext: (id) filterContext
{
	if (udpSocket != sock)
    {
        return;
    }
    
    NSString* receivedData = [[NSString alloc] initWithData: data
                                                   encoding: NSUTF8StringEncoding];
	if (receivedData)
	{
        if ([receivedData isEqualForCommandName: ConnectToServerMessageId])
        {
            NSLog(@"Client received: %@\n", receivedData);
            connected = YES;
        }

        [receivedData release];
	}
	else
	{
		NSString* host = nil;
		uint16_t port = 0;
		[GCDAsyncUdpSocket getHost: &host
                              port: &port
                       fromAddress:address];
		
        NSLog(@"RECV: Unknown message from: %@:%hu", host, port);
	}
}

@end
