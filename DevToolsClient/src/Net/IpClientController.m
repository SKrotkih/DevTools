//
//  IpClientController.m
//  UniTracer
//
//  Created by Sergey Krotkih on 7/31/12.
//  Copyright (c) 2012 Quickoffice. All rights reserved.
//

#import "IpClientController.h"

NSString* kIpReceivedDataNotification = @"kIpReceivedDataNotification";

CFSocketRef socketRef;

CFSocketNativeHandle csock;

IpClientController* ipClientControllerInstance;

@interface NSString(ForClientCategory)
- (BOOL) isEqualCommandName: (NSString*) commandName;
@end

@implementation NSString(ForClientCategory)

- (BOOL) isEqualCommandName: (NSString*) commandName
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

/*
 http://homepages.ius.edu/rwisman/C490/html/tcp.htm
 */
void receiveData(CFSocketRef s,
				 CFSocketCallBackType type,
				 CFDataRef address,
				 const void *data,
				 void *info)
{
    CFDataRef df = (CFDataRef) data;
    int len = CFDataGetLength(df);
    if (len <= 0)
    {
        return;
    }
    
    CFRange range = CFRangeMake(0, len);
    UInt8 buffer[len + 1];
    NSLog(@"Received %d bytes from socket %d\n", len, CFSocketGetNative(s));
    CFDataGetBytes(df, range, buffer);
    buffer[len] = '\0';
    //NSLog(@"As UInt8 coding: %@", df);
    NSString* receivedData = [NSString stringWithFormat: @"%s", buffer];
    
    if ([receivedData isEqualCommandName: @"connect is OK"])
    {
        NSLog(@"Client received: %s\n", buffer);
        ipClientControllerInstance.connected = YES;
    }
    else if ([receivedData isEqualCommandName: @"disconnect"])
    {
        NSLog(@"Client received: %s\n", buffer);
        ipClientControllerInstance.connected = NO;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kIpReceivedDataNotification
                                                        object: receivedData];
}

@interface IpClientController ()
- (void) runLoopThread;
@end

@implementation IpClientController

@synthesize connected;
@synthesize sendBytesCount;
@synthesize maxBytesCount;

- (IpClientController*) init
{
	if ((self = [super init]))
	{	
        ipClientControllerInstance = self;
	}

	return self;
}

- (void) socketSendData: (const char*) charData
{
    if (socketRef == nil)
    {
        return;
    }
    
    sendBytesCount += strlen(charData);

    NSLog(@"\n\n[%ld;%d;%d]\n\n", strlen(charData), sendBytesCount, maxBytesCount - sendBytesCount);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^ {
                       size_t len = strlen(charData);
                       CFDataRef data = CFDataCreate(NULL, (const UInt8 *)charData, len);
                       
                       CFSocketSendData(socketRef, NULL, data, 0);
                       CFRelease(data);
                   });
    
}

- (void) connectToServer
{
    if (connected == NO)
    {
        if (thread != nil)
        {
            [thread cancel];
            [thread release];
            thread = nil;
        }
        
        if (thread == nil)
        {
            thread = [[NSThread alloc] initWithTarget: self
                                             selector: @selector(runLoopThread)
                                               object: nil];
            [thread start];
        }
    }
}

- (void) runLoopThread
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    socketRef = CFSocketCreate(NULL, PF_INET,
                               SOCK_STREAM, IPPROTO_TCP,
                               kCFSocketDataCallBack,
                               receiveData,
                               NULL);
	struct sockaddr_in sin;
	struct hostent* host;
 	
    memset(&sin, 0, sizeof(sin));
	host = gethostbyname("localhost");
  	
    fprintf(stderr, "addr=%s", host->h_addr);
    
	memcpy(&(sin.sin_addr), host->h_addr, host->h_length);
    
    sin.sin_family = AF_INET;
    sin.sin_port = htons(1234);
    
    CFDataRef address;
    CFRunLoopSourceRef source;
    
    address = CFDataCreate(NULL, (UInt8 *)&sin, sizeof(sin));
    CFSocketConnectToAddress(socketRef, address, 0);
    
    CFRelease(address);
    
    source = CFSocketCreateRunLoopSource(NULL, socketRef, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(),
					   source,
					   kCFRunLoopDefaultMode);
    CFRelease(source);
    
	CFRunLoopRun();
    [pool release];
}

@end
