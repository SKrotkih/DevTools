//
//  AppController.h
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DTPanelWithIndicator.h"
#import "DTTestScriptViewController.h"

@class DTRuntimeBrowserViewController, DTUDPServerController, DTUDPClientController, DTViewsInfoViewController, DTSequenceDiagramViewController;

@interface AppController : NSObject <NSTextViewDelegate, DTProcessIndicator, UITestingScriptController>
{
    IBOutlet NSTabView* tabView;
    IBOutlet NSWindow* mainWindow;
    BOOL isEnableToolBar;
    BOOL _isClientConnected;
    BOOL _isStartTrace;
    BOOL _isStartUITesting;
    NSTextView* logTextView;
    NSTextView* traceLogTextView;
    NSTextView* testLogTextView;
    DTRuntimeBrowserViewController* rtBrowser;
    DTPanelWithIndicator* panelWithIndicator;
    DTUDPServerController* ipSereverController;
    DTUDPClientController* ipDTClientController;
    IBOutlet NSButton* startStopServerButton;
    IBOutlet NSTextField* statusToClientConnect;
    IBOutlet NSTextField* addressOfServer;
    IBOutlet NSProgressIndicator* progressIndicator;
    NSTabView* tabViewsMap;
    DTTestScriptViewController* scriptVC;
    DTSequenceDiagramViewController* sequenceDiagram;
    DTViewsInfoViewController* uiViewsMap;
    BOOL isOperationRunTimenProcessing;
}

- (void) enableToolbar: (BOOL)enable;
- (IBAction) editOfSettings: (id) sender;
- (IBAction) help: (id)sender;
- (IBAction) prepareToTracing: (id) sender;
- (IBAction) startTrace: (id) sender;
- (IBAction) stopTrace: (id) sender;
- (IBAction) startStopLocalServer: (id)sender;
- (IBAction) openRunTimeBrowser: (id) sender;
- (IBAction) exit: (id)sender;
- (IBAction) clearLogTrace: (id)sender;
- (IBAction) startAutoUITesting: (id) sender;
- (IBAction) showCurrentViewsStateOnClient: (id) sender;
- (IBAction) switchToDevToolsClientUI: (id) sender;
- (IBAction) switchToApplicationUI: (id) sender;
- (IBAction) saveSelectedClassList: (id)sender;

@property(nonatomic, retain, readonly) NSWindow* window;
@property(nonatomic, retain) NSTabView* tabView;
@property(nonatomic, assign) NSTextView* traceLogTextView;
@property(nonatomic, assign) NSTextView* testLogTextView;
@property(nonatomic, assign) NSTextView* logTextView;
@property(nonatomic, retain) DTPanelWithIndicator* panelWithIndicator;
@property(nonatomic, assign) BOOL isClientConnected;
@property(nonatomic, assign) BOOL isStartTrace;
@property(nonatomic, assign) BOOL isStartUITesting;

-(BOOL) isTabExists: (NSString*)tabViewItemTitle;

@end
