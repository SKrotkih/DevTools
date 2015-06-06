//
//  UDPutils.m
//  DevTools
//
//  Created by Sergey Krotkih on 7/31/12.
//  Copyright (c) 2012 Quickoffice. All rights reserved.
//

#import "UDPutils.h"
#import <ifaddrs.h>
#import <arpa/inet.h>

@implementation UDPutils

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
