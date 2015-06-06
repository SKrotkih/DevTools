//
//  DevToolsSendLog.h
//  DevToolsClient
//
//  Created by Krotkih Sergey on 27.11.12.
//  Copyright Quickoffice 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DTTraceLogDelegate <NSObject>

- (void) addTraceLog: (NSString*) aTraceLogString;

@end

@interface DevToolsSendLog: NSObject
{
    BOOL traceStarted;
    BOOL lineNumbers;
    id <DTTraceLogDelegate> traceLogDelegate;
}

@property(nonatomic, readwrite) BOOL traceStarted;
@property(nonatomic, readwrite) BOOL lineNumbers;
@property(nonatomic, readwrite, retain) id <DTTraceLogDelegate> traceLogDelegate;

+ (DevToolsSendLog*) deafultInstance;

- (void) logMessageForFunction: (const char*) aFunction
                          line: (NSInteger) aLine
                        format: (NSString*) format, ...;

- (void) traceLog: (const char*) aFunction
             line: (NSInteger) aLine;

@end
