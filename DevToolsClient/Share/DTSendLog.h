//
//  DTSendLog.h
//  DevToolsClient
//
//  Created by Krotkih Sergey on 27.11.12.
//  Copyright Quickoffice 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DTSendLog: NSObject
{
}

+ (void) logMessage: (NSString*) format, ...;

@end
