//
//  DTTraceController.h
//  DevToolsClient
//
//  Created by Krotkih Sergey on 27.11.12.
//  Copyright Quickoffice 2012. All rights reserved.

#import <UIKit/UIKit.h>
#import "DevToolsClientController.h"
#import "DevToolsClientViewController.h"

@interface DTTraceController : NSObject
{
    id <LogViewControllerDelegate> delegate;
    BOOL isTracingNow;
    DevToolsClientController* devToolsMessenger;
    NSArray* classesForTrace;    
}

@property (nonatomic, readwrite, retain) id <LogViewControllerDelegate> delegate;

- (id) initWithDelegate: (id <LogViewControllerDelegate>) aDelegate;
- (void) startTraceCodeWithCommand: (NSString*) aCommandString;
- (void) stopTraceCode;

- (void) parseClassesForTrace: (NSString*) aCommandString;

@end
