//
//  DTTraceController.h
//  DevToolsClient
//
//  Created by Krotkih Sergey on 27.11.12.
//  Copyright Quickoffice 2012. All rights reserved.

#import "DTTraceController.h"

@interface  DTTraceController  ()

@end

@implementation DTTraceController

@synthesize delegate;

- (id) initWithDelegate: (id<LogViewControllerDelegate>) aDelegate
{
    if ((self = [super init]))
    {
        self.delegate = aDelegate;
        devToolsMessenger = [DevToolsClientController sharedInstance];
        isTracingNow = NO;
    }
    
    return self;
}

- (void) dealloc
{
    self.delegate = nil;
    [classesForTrace release];
    
    [super dealloc];
}

- (void) parseClassesForTrace: (NSString*) aCommandString
{
    [classesForTrace release];
    classesForTrace = nil;
    
    NSInteger lenArray = 0;
    
    if (aCommandString != nil && [aCommandString length] > 0)
    {
        classesForTrace = [[aCommandString componentsSeparatedByString: @";"] retain];
        lenArray = [classesForTrace count];
    }
    else
    {
        classesForTrace = [[NSArray alloc] init];
    }
}

- (void) startTraceCodeWithCommand: (NSString*) aCommandString
{
    NSAssert(NO, @"You shouldn't call startTraceCodeWithCommand in base class!");
}

- (void) stopTraceCode
{
    NSAssert(NO, @"You shouldn't call stopTraceCode in base class!");
}

@end
