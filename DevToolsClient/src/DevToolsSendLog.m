//
//  DevToolsSendLog.m
//  DevToolsClient
//
//  Created by Krotkih Sergey on 27.11.12.
//  Copyright Quickoffice 2012. All rights reserved.
//
// You should insert next macro to the pch:
//#ifdef __DEBUG__
//#import <DevToolsClient/DevToolsSendLog.h>
//#define DTLog(A, ...)  [[DevToolsSendLog deafultInstance] logMessageForFunction: __FUNCTION__ line: __LINE__ format: (A), ##__VA_ARGS__]
//#define DTTraceLog() [[DevToolsSendLog deafultInstance] traceLog: __FUNCTION__ line: __LINE__]
//#else
//#define DTLog(A, ...)
//#define DTTraceLog()
//#endif
//
// And use like that:
// DTLog(@"%d", i);
//

#import "DevToolsSendLog.h"
#import "DTConstants.h"

@implementation DevToolsSendLog

@synthesize traceStarted, traceLogDelegate, lineNumbers;

+ (DevToolsSendLog*) deafultInstance
{
    static DevToolsSendLog* instance;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        instance = [[DevToolsSendLog alloc] init];
        instance.traceStarted = NO;
    });
    
    return instance;
}

- (void) logMessageForFunction: (const char*) aFunction
                          line: (NSInteger) aLine
                        format: (NSString*) format, ...
{
    va_list args;
    va_start(args, format);
    
    const char* signatureFunction = [[[NSString stringWithUTF8String : aFunction] lastPathComponent] UTF8String];
    NSString* entryPointString = [NSString stringWithFormat: @"%s : %d", signatureFunction, aLine];
    
    NSString* string = [[NSString alloc] initWithFormat: format
                                              arguments: args];
    va_end(args);

    NSString* message;

    if ([string length] > 0)
    {
        message = [[NSString alloc] initWithFormat: @"%@ : %@", entryPointString, string];
    }
    else
    {
        message = [[NSString alloc] initWithFormat: @"%@", entryPointString];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName: SendLogNotificationId
                                                        object: message];
}

- (void) traceLog: (const char*) aFunction
             line: (NSInteger) aLine
{
    if (self.traceStarted == NO)
    {
        return;
    }
    
    const char* signatureFunction = [[[NSString stringWithUTF8String : aFunction] lastPathComponent] UTF8String];
    NSString* message;

    if (self.lineNumbers)
    {
        message = [[NSString alloc] initWithFormat: @"%s : %d", signatureFunction, aLine];
    }
    else
    {
        message = [[NSString alloc] initWithFormat: @"%s", signatureFunction];
    }
    
    [traceLogDelegate addTraceLog: message];
}

@end
