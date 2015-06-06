//
//  DTSendLog.m
//  DevToolsClient
//
//  Created by Krotkih Sergey on 27.11.12.
//  Copyright Quickoffice 2012. All rights reserved.
//

#import "DTSendLog.h"

@implementation DTSendLog

+ (void) logMessage: (NSString*) format, ...
{
    va_list args;
    va_start(args, format);
    NSString* message = [[[NSString alloc] initWithFormat: format
                                                arguments: args] autorelease];
    [[NSNotificationCenter defaultCenter] postNotificationName: @"kSendLogNotification"
                                                        object: message];
    va_end(args);
}

@end
