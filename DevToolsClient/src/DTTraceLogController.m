//
//  DTTraceLogController.h
//  DevToolsClient
//
//  Created by Krotkih Sergey on 11.05.13.
//  Copyright Quickoffice 2013. All rights reserved.

#import "DTTraceLogController.h"

const NSUInteger BufferMaxLength = 3200;

@implementation DTTraceLogController
{
    NSMutableString* traceBuff;
}

- (void) dealloc
{
    [traceBuff release];
    traceBuff = nil;
    
    [super dealloc];
}

- (void) startTraceCodeWithCommand: (NSString*) aCommandString
{
    [self parseClassesForTrace: aCommandString];
    
    if (isTracingNow)
    {
        return;
    }
    
    [[DevToolsClientController sharedInstance] switchToApplication];
    
    if (!traceBuff)
    {
        traceBuff = [[NSMutableString alloc] initWithCapacity: BufferMaxLength];
    }
    
    [DevToolsSendLog deafultInstance].traceLogDelegate = self;
    [DevToolsSendLog deafultInstance].traceStarted = YES;
    isTracingNow = YES;
}

- (void) stopTraceCode
{
    if (!isTracingNow)
    {
        return;
    }
    
    [DevToolsSendLog deafultInstance].traceStarted = NO;
    isTracingNow = NO;
    
    [devToolsMessenger runCommand: StopTraceMessageId
                    contCommandID: @""
                             data: @""];
    
    [self.delegate setLog: StopTraceMessageId];
    DTLog(@"%@", StopTraceMessageId);
    
    [[DevToolsClientController sharedInstance] switchToDevToolsClient];
    
    [self showLog];    
}

#pragma mark private methods

- (void) showLog
{
    [devToolsMessenger runCommand: TraceLogMessageId
                    contCommandID: TraceLogMessageContinueId
                             data: traceBuff];
    
    [self.delegate setLog: traceBuff];
    [traceBuff setString: @""];
}

#pragma mark DTTraceLogDelegate protocol implement

- (void) addTraceLog: (NSString*) aTraceLogString
{
    if ([traceBuff length] + [aTraceLogString length] + 1 > BufferMaxLength)
    {
        [self showLog];
    }
    
    [traceBuff appendFormat: @"%@\n", aTraceLogString];
}

@end
