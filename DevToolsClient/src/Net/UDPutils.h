//
//  UDPutils.h
//  DevToolsClient
//
//  Created by Sergey Krotkih on 7/31/12.
//  Copyright (c) 2012 Quickoffice. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UDPutils : NSObject
{
    
}

+ (UDPutils*) sharedInstance;
- (NSDictionary*) ipsForInterfaces;
- (NSString*) getIPAddress;

@end
