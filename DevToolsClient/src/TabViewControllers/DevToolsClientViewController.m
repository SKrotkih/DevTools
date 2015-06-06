//
//  DevToolsClientViewController.m
//  DevToolsClient
//
//  Created by Sergey Krotkih on 7/31/12.
//  Copyright (c) 2012 Quickoffice. All rights reserved.
//

#import "DevToolsClientViewController.h"
#import <foundation/foundation.h>
#import "UDPServerController.h"
#import "UDPutils.h"
#import <UISpec/UISpec.h>
#import "DevToolsClientController.h"

@interface  DevToolsClientViewController()
@end

@implementation DevToolsClientViewController

- (id) initWithNibName: (NSString*) nibNameOrNil
                bundle: (NSBundle*) nibBundleOrNil
{
    if ((self = [super initWithNibName: nibNameOrNil
                                bundle: nibBundleOrNil]))
    {
        NSString* revisionFile = [gDevToolsClientResBundle pathForResource: @"revision"
                                                                    ofType: @"txt"];
        NSError* error = nil;
        NSString* revisionString = [NSString stringWithContentsOfFile: revisionFile
                                                             encoding: NSISOLatin1StringEncoding
                                                                error: &error];
        if (!revisionString)
        {
            revisionString = @"";
        }
        self.title = [NSString stringWithFormat: @"DevTools %@", revisionString];

        self.tabBarItem.image = [UIImage imageNamed: [NSString stringWithFormat: @"%@Attachment", gDevToolsClientResBundlePath]];
        devToolsMessenger = [DevToolsClientController sharedInstance];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(sendingUITestError:)
                                                     name: UITestErrorNotificationId
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(sendingUITestLog:)
                                                     name: UITestLogNotificationId
                                                   object: nil];
        
        [[UDPServerController sharedInstance] startServer];
    }
    
    return self;
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UITestErrorNotificationId
                                                  object: nil];

    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UITestLogNotificationId
                                                  object: nil];

    [super dealloc];
}

- (NSString*) log
{
    return mReceiveTextView.text;
}

- (void) setLog: (NSString*) aLogText
{
    if (aLogText && [aLogText length] > 0)
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:
         ^{
             mReceiveTextView.text = [mReceiveTextView.text stringByAppendingString: [NSString stringWithFormat: @"%@\n", aLogText]];
         }];
    }
}

#pragma mark UI testing logging

- (void) sendingUITestError: (NSNotification*) notification
{
    NSString* errorMessage = [notification object];
    
    self.log = errorMessage;
}

- (void) sendingUITestLog: (NSNotification*) notification
{
    NSString* logMessage = [notification object];
    
    self.log = logMessage;
}

#pragma mark Actions

- (IBAction) startSerevr: (id) sender
{
    [[UDPServerController sharedInstance] startServer];
}

- (IBAction) connectToDevToolsServer: (id) sender
{
    [devToolsMessenger connect];
}

- (IBAction) clearLog: (id) sender
{
    mReceiveTextView.text = @"";
}

- (IBAction) startTrace: (id) sender
{
    [devToolsMessenger runCommand: StartTraceMessageId
                    contCommandID: @""
                             data: @""];
}

- (IBAction) startTest: (id) sender
{
    [devToolsMessenger runCommand: StartUITestingMessageId
                    contCommandID: @""
                             data: @""];
}

#pragma mark -

@end
