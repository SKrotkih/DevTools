//
//  UDPClientController.m
//  DevToolsClient
//
//  Created by Sergey Krotkih on 7/31/12.
//  Copyright (c) 2012 Quickoffice. All rights reserved.
//

#import "UDPClientController.h"
#import "GCDAsyncUdpSocket.h"
#import "UDPutils.h"

const NSInteger kDefaultRemoteServerPortNumber = 1234;
const NSInteger MaxLenDataForSendToServer = 1024;

static UDPClientController* sharedInstance;

@interface UDPClientController ()
- (void) setupSocket;
- (void) sendCommand: (NSString*) aCommand
                data: (NSString*) aStr;
- (void) socketSendData: (NSData*) dataToSend;
- (void) timerExpired: (NSTimer*) timer;
@end

@implementation UDPClientController

@synthesize isConnected;
@synthesize sendBytesCount;
@synthesize maxBytesCount;

+ (UDPClientController*) sharedInstance
{
	if (sharedInstance == nil)
    {
		sharedInstance = [[UDPClientController alloc] init];
	}
	
	return sharedInstance;
}

- (id) init
{
	if ((self = [super init]))
	{	
        sharedInstance = self;

        dataForSendDict = [[NSMutableDictionary alloc] init];
        currentTag = 0;
        maxTag = 0;
        connectCommandTag = -1;
        
		socketsLock  = [[NSLock alloc] init];
		[self setupSocket];
	}

	return self;
}

- (void) dealloc
{
    [dataForSendDict release];
    [socketsLock release];

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
    if (isConnected == NO)
    {
        NSString* host = [[UDPutils sharedInstance] getIPAddress];
        
        if (!host)
        {
            host = @"127.0.0.1";
        }
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSString* portNumber = [defaults objectForKey: @"LocalServerPortNumber"];
        
        if ((host != nil) && ([host length] > 0) && (portNumber != nil) && ([portNumber length] > 0))
        {
            NSString* sendData = [NSString stringWithFormat: @"%@|%@", host, portNumber];
            [self runCommandOnServer: ConnectToServerMessageId
                         contCommand: @""
                                data: sendData];
        }
        
    }
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
        // We received echo from server
//        NSString* key = @"data=";
//        NSUInteger dataIndex = [receivedData rangeOfString: key].location;
//        NSArray* receivedArray;
//        
//        if (dataIndex != NSNotFound)
//        {
//            receivedArray = [[receivedData substringFromIndex: dataIndex + [key length]] componentsSeparatedByString: @"|"];
//        }
//        else
//        {
//            receivedArray = [receivedData componentsSeparatedByString: @"|"];
//        }
//
//        NSString* commandReceived = [receivedArray objectAtIndex: 0];
//
//        if ([commandReceived isEqual: ConnectToServerMessageId])
//        {
//            NSLog(@"Client received: %@\n", receivedData);
//
//            [[NSNotificationCenter defaultCenter] postNotificationName: ReceivedDataNotificationId
//                                                                object: ConnectToServerMessageId];
//            
//            isConnected = YES;
//        }

        [receivedData release];
	}
	else
	{
		NSString* host = nil;
		uint16_t port = 0;
		[GCDAsyncUdpSocket getHost: &host
                              port: &port
                       fromAddress: address];
		
        NSLog(@"Client received unknown message from: %@:%hu", host, port);
	}
}


#pragma mark Send data

- (void) udpSocket: (GCDAsyncUdpSocket*) sock
didSendDataWithTag: (long) aTag
{
    //NSLog(@"Send tag =%ld was succesfully!", aTag);
	// You could add checks here
}

- (void)    udpSocket: (GCDAsyncUdpSocket*) sock
didNotSendDataWithTag: (long) aTag
           dueToError: (NSError*) error
{
    //NSLog(@"Got an error: %@[tag=%ld]", error, aTag);
    // You could add checks here
}

- (void) runCommandOnServer: (NSString*) aCommand
                contCommand: (NSString*) aContCommand
                       data: (NSString*) aSendData
{
    if ([aCommand isEqualToString: ConnectToServerMessageId] && connectCommandTag == -1)
    {
        connectCommandTag = maxTag;
    }
    
    NSUInteger length = [aSendData length];
    
    if (length > MaxLenDataForSendToServer)
    {
        NSUInteger iters = length / MaxLenDataForSendToServer;
        NSUInteger lenLastIter = length - iters * MaxLenDataForSendToServer;
        int offset = 0;
        
        for (NSUInteger iter = 0; iter <= iters; iter++)
        {
            int lenIter = (iter == iters) ? lenLastIter : MaxLenDataForSendToServer;
            NSRange range = NSMakeRange(offset, lenIter);
            NSString* currStr = [aSendData substringWithRange: range];
            
            if ((iter == 0) && [aCommand length] > 0)
            {
                [self sendCommand: aCommand
                             data: currStr];
            }
            else if ((iter != 0) && [aContCommand length] > 0)
            {
                [self sendCommand: aContCommand
                             data: currStr];
            }
            
            offset += lenIter;
        }
    }
    else
    {
        NSAssert([aCommand length] > 0, @"Wrong command for send to server!");
        
        [self sendCommand: aCommand
                     data: aSendData];
    }
}

- (void) sendCommand: (NSString*) aCommand
                data: (NSString*) aStr
{
    NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          aCommand, CommandKeyForJSONdictionary,
                          [NSString stringWithFormat: @"%ld", maxTag], TagKeyForJSONdictionary,
                          [NSNumber numberWithLong: [aStr length]], LenDataKeyForJSONdictionary,
                          aStr, DataKeyForJSONdictionary, nil];
    
    if ([NSJSONSerialization isValidJSONObject: dict])
    {
        NSData* data = [NSJSONSerialization dataWithJSONObject: dict
                                                       options: 0
                                                         error: nil];
        
        [dataForSendDict setObject: data
                            forKey: [NSString stringWithFormat: @"%ld", maxTag]];
        maxTag++;
        
        if ([dataForSendDict count] == 1)
        {
            [self socketSendData: data];
        }
    }
    
    [dict release];
}

- (void) socketSendData: (NSData*) dataToSend
{
    if (dataToSend == nil)
    {
        return;
    }
    
    NSString* host = [[NSUserDefaults standardUserDefaults] objectForKey: @"DevToolsServerHostName"];

    if (host == nil || [host length] == 0)
    {
        return;
    }
    
    NSString* portNumber = [[NSUserDefaults standardUserDefaults] objectForKey: @"DevToolsServerPortNumber"];
    
    if (portNumber == nil || [portNumber length] == 0)
    {
        return;
    }

    int port = [portNumber intValue];
    
    currentTag++;

    {
        NSString* str = [[NSString alloc] initWithData: dataToSend
                                              encoding: NSUTF8StringEncoding];
        NSLog(@"\n === SEND DATA:%@", (([str length] > 150) ? [str substringToIndex: 150] : str));
    }


    lastDataToSend = dataToSend;
    
    // send data to the DevTools server
    [udpSocket sendData: dataToSend
                 toHost: host
                   port: port
            withTimeout: -1
                    tag: currentTag];
    
    [NSTimer scheduledTimerWithTimeInterval: 3.0f
                                     target: self
                                   selector: @selector(timerExpired:)
                                   userInfo: nil
                                    repeats: NO];
    
    
}

- (void) timerExpired: (NSTimer*) timer
{
    if (lastDataToSend != nil)
    {

        NSLog(@"\n=== TIMER SEND DATA!!!");
        
        [self socketSendData: lastDataToSend];
    }
}

- (void) receivedEchoFromServer: (NSString*) anEcho
{

    NSLog(@"\n === ECHO:%@", (([anEcho length] > 150) ? [anEcho substringToIndex: 150] : anEcho));
    
    NSArray* arr = [anEcho componentsSeparatedByString: @";"];
    NSString* sTag = [[[arr objectAtIndex: 0] componentsSeparatedByString: @"="] objectAtIndex: 1];
    
    if (sTag != nil)
    {

        if (lastDataToSend != nil)
        {
            lastDataToSend = nil;
        }

        NSUInteger rLen = [[[[arr objectAtIndex: 1] componentsSeparatedByString: @"="] objectAtIndex: 1] integerValue];
        NSData* dataToSend = [dataForSendDict objectForKey: sTag];
        
        if (dataToSend == nil)
        {
            NSLog(@"\n===>ALREADY RECEIVED TAG !!! lenDict=%d;tag=%@", [[dataForSendDict allKeys] count], sTag);
        }
        else
        {
            
            NSError* error = nil;
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData: dataToSend
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
            
            NSUInteger lenToSend = [[dict objectForKey: LenDataKeyForJSONdictionary] integerValue];
            
            if (lenToSend == rLen)
            {
                
                if (connectCommandTag == [sTag longLongValue])
                {
                    [dataForSendDict removeAllObjects];
                    connectCommandTag = -1;
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName: ReceivedDataNotificationId
                                                                        object: [ConnectToServerMessageId dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    isConnected = YES;
                    
                    NSLog(@"=== CLEAR BUFFER dataForSendDict=%i", [[dataForSendDict allKeys] count]);
                    
                }
                else
                {
                    [socketsLock lock];
                    
                    NSLog(@"=== REMOVE OBJECT %@ from dataForSendDict", sTag);
                    
                    [dataForSendDict removeObjectForKey: sTag];
                    [socketsLock unlock];
                }
                
                NSLog(@"Send tag = %@ was succesfully!", sTag);
                long nextTagValue = [sTag longLongValue] + 1;
                
                NSString* nextTag = [NSString stringWithFormat: @"%li", nextTagValue];
                NSData* nextDataForSend = [dataForSendDict objectForKey: nextTag];
                
                if (nextDataForSend != nil)
                {
                    [self socketSendData: nextDataForSend];
                }
            }
            else
            {
                // repead send data
                NSLog(@"Repeat to send tag = %@!", sTag);
                [self socketSendData: dataToSend];
            }
        }
    }
}

@end
