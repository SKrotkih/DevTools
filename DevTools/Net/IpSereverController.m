//
//  UDPSereverController.m
//  UniTracer
//
//  Created by Sergey Krotkih on 7/31/12.
//  Copyright (c) 2012 Quickoffice. All rights reserved.
//

#import "UDPSereverController.h"
#import <UDP/GCDAsyncUdpSocket.h>

NSString* kAcceptConnectionNotification = @"kAcceptConnectionNotification";
NSString* kReceivedDataNotification = @"kReceivedDataNotification";
NSString* kStartServerNotification = @"kStartServerNotification";
NSString* kSendDataNotification = @"kSendDataNotification";

CFSocketNativeHandle csock;
const BOOL echoBackToClient = NO;

@interface UDPSereverController ()
- (void) sendData: (NSNotification*) notification;
- (void) startServer:  (NSNotification*) notification;
-(void) connectThread;
@end

@implementation UDPSereverController

- (UDPSereverController*) init
{
	if ((self = [super init]))
	{	
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(startServer:)
                                                     name: kStartServerNotification
                                                   object: nil];
        

        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(sendData:)
                                                     name: kSendDataNotification
                                                   object: nil];
        
        // Setup our socket.
        // The socket will invoke our delegate methods using the usual delegate paradigm.
        // However, it will invoke the delegate methods on a specified GCD delegate dispatch queue.
        //
        // Now we can configure the delegate dispatch queues however we want.
        // We could simply use the main dispatch queue, so the delegate methods are invoked on the main thread.
        // Or we could use a dedicated dispatch queue, which could be helpful if we were doing a lot of processing.
        //
        // The best approach for your application will depend upon convenience, requirements and performance.
        //
        // For this simple example, we're just going to use the main thread.
        
        udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate: self
                                                  delegateQueue: dispatch_get_main_queue()];
	}

	return self;
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: kStartServerNotification
                                                  object: nil];

	[[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: kSendDataNotification
                                                  object: nil];
    
    [super dealloc];
}

- (void) startServer:  (NSNotification *) notification
{
    NSThread* thread = [[NSThread alloc] initWithTarget: self
                                               selector: @selector(connectThread)
                                                 object: nil];
    [thread start];
}

void acceptConnection(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info)
{
	csock = *(CFSocketNativeHandle*) data;

    NSString* message = [NSString stringWithFormat: NSLocalizedString(@"Server socket %d received connection socket %d\n", @"Message about accept connection"),  CFSocketGetNative(s), csock];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kAcceptConnectionNotification 
                                                        object: message];
}

void receiveData(CFSocketRef s, CFSocketCallBackType type, 
                 CFDataRef address, const void *data, void *info)
{
    CFDataRef df = (CFDataRef) data;
	int len = CFDataGetLength(df);

	if (len <= 0)
    {
        return;
    }

	UInt8 buffer[len + 1];
	CFRange range = CFRangeMake(0, len);
	NSLog(@"Server received %d bytes from socket %d\n", len, CFSocketGetNative(s));
	CFDataGetBytes(df, range, buffer);
    buffer[len] = '\0';
    //NSString* str = [NSString stringWithUTF8String: buffer];
    NSString* strReceivedData = [NSString stringWithFormat: @"%s", buffer];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kReceivedDataNotification 
                                                        object: strReceivedData];
	if (echoBackToClient == YES)
    {
        CFSocketSendData(s, address, df, 0);
    }
}

- (void) sendData: (NSNotification*) notification
{
    NSString* strToSend = [notification object];

    const char* charData = [strToSend UTF8String];
    
    CFSocketRef sn;
    CFRunLoopSourceRef source;
    sn = CFSocketCreateWithNative(NULL, csock, kCFSocketDataCallBack, receiveData, NULL);
    source = CFSocketCreateRunLoopSource(NULL, sn, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
    
    size_t len = strlen(charData);
    
    CFDataRef dataRef = CFDataCreate(NULL, (const UInt8 *)charData, len);
    CFSocketSendData(sn, NULL, dataRef, 0);
    
    CFRelease(dataRef);
    CFRelease(source);
    CFRelease(sn);
}

-(void) connectThread
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init]; 
	struct sockaddr_in sin;
	int sock, yes = 1;
	CFSocketRef s;
	CFRunLoopSourceRef source;
	
	sock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
	memset(&sin, 0, sizeof(sin));
	sin.sin_family = AF_INET;
	sin.sin_port = htons(1234);
	setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(yes));
	setsockopt(sock, SOL_SOCKET, SO_REUSEPORT, &yes, sizeof(yes));
	bind(sock, (struct sockaddr *)&sin, sizeof(sin));
	listen(sock, 5);
	
	s = CFSocketCreateWithNative(NULL, sock, kCFSocketAcceptCallBack, acceptConnection, NULL);
	
	source = CFSocketCreateRunLoopSource(NULL, s, 0);
	CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
	CFRelease(source);
	CFRelease(s);
    [pool release];
    
	CFRunLoopRun();
}

@end
