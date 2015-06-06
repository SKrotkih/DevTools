//
//  AppController.m
//  DevToolsClient
//
//  Created by Sergey Krotkih on 7/31/12.
//  Copyright (c) 2012 Quickoffice. All rights reserved.
//

#import "UDPutils.h"
#include <sys/types.h>
#include <sys/socket.h>
#include <ifaddrs.h>
#include <arpa/inet.h>

static UDPutils* sharedInstance = nil;

@interface  UDPutils()
- (NSDictionary*) ipsForInterfaces;
@end

@implementation UDPutils

+ (UDPutils*) sharedInstance
{
    if (sharedInstance == nil)
    {
        sharedInstance = [[UDPutils alloc] init];
    }

    return sharedInstance;
}

- (NSDictionary*) ipsForInterfaces
{
	struct ifaddrs* list;

	if (getifaddrs(&list) < 0)
    {
		perror("getifaddrs");
		return nil;
	}
	
	NSMutableDictionary* d = [NSMutableDictionary dictionary];
	struct ifaddrs* cur;

	for (cur = list; cur != NULL; cur = cur->ifa_next)
    {
		if (cur->ifa_addr->sa_family != AF_INET)
        {
			continue;
        }
		
		struct sockaddr_in* addrStruct = (struct sockaddr_in *)cur->ifa_addr;
		NSString* name = [NSString stringWithUTF8String: cur->ifa_name];
		NSString* addr = [NSString stringWithUTF8String: inet_ntoa(addrStruct->sin_addr)];
		[d setValue: addr
             forKey: name];
	}
	
	freeifaddrs(list);

	return d;
}

- (NSString*) getIPAddress
{
	NSString* myIP = [[[UDPutils sharedInstance] ipsForInterfaces] objectForKey: @"en0"];
	
#if TARGET_IPHONE_SIMULATOR
	if (!myIP)
    {
		myIP = [[[UDPutils sharedInstance] ipsForInterfaces] objectForKey: @"en1"];
	}
#endif
	
	return myIP;
}

+ (NSString*) getIPAddress
{
	NSMutableString* address = [[NSMutableString alloc] init];
	struct ifaddrs* interfaces = NULL;
	struct ifaddrs* temp_addr = NULL;
	int success = 0;
	
	// retrieve the current interfaces - returns 0 on success
	success = getifaddrs(&interfaces);
    
	if (success == 0)
    {
		// Loop through linked list of interfaces
		temp_addr = interfaces;
		while (temp_addr != NULL)
        {
            
			if (temp_addr->ifa_addr->sa_family == AF_INET)
            {
				NSString* ifa_name = [NSString stringWithUTF8String: temp_addr->ifa_name];
                NSString* ip = [NSString stringWithUTF8String: inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
				NSString* name = [NSString stringWithFormat: @"%@: %@ ", ifa_name, ip];
                [address appendString: name];
			}
			temp_addr = temp_addr->ifa_next;
		}
	}
	freeifaddrs(interfaces);
	
	return [address autorelease];
}

@end
