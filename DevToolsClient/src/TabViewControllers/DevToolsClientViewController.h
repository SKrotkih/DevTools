//
//  DevToolsClientViewController.h
//  DevToolsClient
//
//  Created by Sergey Krotkih on 7/31/12.
//  Copyright (c) 2012 Quickoffice. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LogViewControllerDelegate <NSObject>
- (void) setLog: (NSString*) aLogString;
@end

@protocol DevToolsMessenger;
@class UDPServerController;

@interface DevToolsClientViewController : UIViewController <LogViewControllerDelegate>
{
    id <DevToolsMessenger> devToolsMessenger;
	IBOutlet UITextView* mReceiveTextView;
}

@property (nonatomic, assign, readwrite) NSString* log;

- (IBAction) startSerevr: (id) sender;
- (IBAction) connectToDevToolsServer: (id) sender;
- (IBAction) clearLog: (id) sender;
- (IBAction) startTrace: (id) sender;
- (IBAction) startTest: (id) sender;

@end
