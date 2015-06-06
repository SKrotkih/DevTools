//
//  AppController.m
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import "AppController.h"
#import "DTRuntimeBrowserViewController.h"
#import "DTUDPServerController.h"
#import "DTUDPClientController.h"
#import "DTSettingsController.h"
#import "DTConstants.h"
#import "DTViewsInfoViewController.h"
#import "DTEnterSingleDataModalDialog.h"
#import "DTFileOperations.h"
#import <UDP/UDPutils.h>
#import "DTClientController.h"
#import "DTPrepareToTracing.h"
#import "DTSequenceDiagramViewController.h"

@interface AppController ()
- (void) receiveData: (NSNotification *) notification;
- (void) createTraceLogTabView;
- (void) createAutoUITestingTabView;
- (void) startServer;
- (void) stopServer;
- (void) addNewViewsMapForText: (NSString*) aText
                  withContinue: (BOOL) withContinue;
- (void) createLogTabView;
- (void) runCommand: (NSDictionary*) aCommandDict;
- (void) startProgress;
- (void) stopProgress;
@end

@implementation AppController

@synthesize window = mainWindow;
@synthesize tabView;
@synthesize traceLogTextView;
@synthesize panelWithIndicator;
@synthesize testLogTextView;
@synthesize logTextView;

- (AppController*) init
{
	if ((self = [super init]))
	{
        isEnableToolBar = YES;
        self.isClientConnected = NO;
        self.isStartTrace = NO;
        self.isStartUITesting = NO;
        isOperationRunTimenProcessing = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(receiveData:)
                                                     name: ReceivedDataNotificationId
                                                   object: nil];
        
        ipSereverController = [[DTUDPServerController alloc] init];
        
        ipDTClientController = [[DTUDPClientController alloc] init];
        
        
        [ipSereverController addObserver: self
                              forKeyPath: @"isRunning"
                                 options: (NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                                 context: NULL];
        
        [self performSelector: @selector(startServer)
                   withObject: nil
                   afterDelay: 1.0f];
        
	}
    
	return self;
}

- (void) dealloc
{
    [DTClientController runCommand: DisconnectToServerMessageId];
    
	[[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: ReceivedDataNotificationId
                                                  object: nil];
    
    [ipSereverController release];
    [ipDTClientController release];
    [rtBrowser release];
    [panelWithIndicator release];
    [traceLogTextView release];
    traceLogTextView = nil;
    [testLogTextView release];
    testLogTextView = nil;
    [scriptVC release];
    
    [super dealloc];
}

- (void) receiveData: (NSNotification *) notification
{
    NSData* receivedData = [notification object];
    
    NSError* error = nil;
    NSDictionary* dict = [NSJSONSerialization JSONObjectWithData: receivedData
                                                         options: NSJSONReadingMutableContainers
                                                           error: &error];
    
    if (!dict)
    {
        NSLog(@"Error parsing JSON: %@", error);
        
        return;
    }
    
    if (![dict isKindOfClass: [NSDictionary class]])
    {
        NSLog(@"Error!!!");
        
        return;
    }
    
    [self runCommand: dict];
    
}

#pragma mark Run Commands

- (void) runCommand: (NSDictionary*) aCommandDict
{
    NSString* command = [aCommandDict objectForKey: CommandKeyForJSONdictionary];
    NSString* data = [aCommandDict objectForKey: DataKeyForJSONdictionary];
    
    //NSLog(@"%@", aCommand);
    
    if ([command isEqualTo: ConnectToServerMessageId])
    {
        NSArray* arr = [data componentsSeparatedByString: @"|"];
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults setObject: [arr objectAtIndex: 0]
                     forKey: ClientHostNameUserDefaultId];
        
        [defaults setObject: [arr objectAtIndex: 1]
                     forKey: ClientPortNumberUserDefaultId];
        
        [defaults synchronize];
        
        self.isClientConnected = YES;
        
        return;
    }
    else if ([command isEqualTo: StartTraceMessageId])
    {
        [self createTraceLogTabView];
        [self startTrace: nil];
    }
    else if ([command isEqualTo: StopTraceMessageId])
    {
        self.isStartTrace = NO;
    }
    else if ([command isEqualTo: StartUITestingMessageId])
    {
        [self createAutoUITestingTabView];
        [self startAutoUITesting: nil];
    }
    else if ([command isEqualTo: ViewsMapMessageId] || [command isEqualTo: ViewsMapMessageContinueId])
    {
        [self createAutoUITestingTabView];
        [self addNewViewsMapForText: data
                       withContinue: [command isEqualTo: ViewsMapMessageContinueId]];
    }
    else if ([command isEqualTo: ViewsMapFinishedMessageId])
    {
        [self viewsMapFinished];
        
        [self stopProgress];
    }
    else if ([command isEqualTo: UITestErrorMessageId])
    {
        [self createAutoUITestingTabView];
        NSString* text = [[NSString alloc] initWithFormat: @"%@\n", data];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:
         ^{
             [self.testLogTextView insertText: text];
             [text release];
         }];
    }
    else if ([command isEqualTo: UITestLogMessageId])
    {
        [self createAutoUITestingTabView];
        NSString* text = [[NSString alloc] initWithFormat: @"%@\n", data];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:
         ^{
             [self.testLogTextView insertText: text];
             [text release];
         }];
    }
    else if ([command isEqualTo: MainLogMessageId])
    {
        [self createLogTabView];
        NSString* text = [[NSString alloc] initWithFormat: @"%@\n", data];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:
         ^{
             [self.logTextView insertText: text];
             [text release];
         }];
    }
    else if ([command isEqualTo: ClassInterfaceResponceMessageId] || [command isEqualTo: ClassInterfaceResponceMessageContinueId])
    {
        BOOL isContinue = [command isEqualTo: ClassInterfaceResponceMessageContinueId];
        [rtBrowser classInterfaceInfoMessageResponse: data
                                          isContinue: isContinue];
    }
    else if ([command isEqualTo: ClassDependenciesResponceMessageId])
    {
        [rtBrowser classDependenciesInfoMessageResponse: data];
    }
    else if ([command isEqualTo: RunCommandOnServerMessageId])
    {
        if ([data isEqualTo: UITestWasFinishedMessageId])
        {
            self.isStartUITesting = NO;
            NSBeginAlertSheet(NSLocalizedString(@"Warning", @"Warning"), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil,
                              NSLocalizedString(@"UI test is finished!\n", @"UI test is finished!\n"));
        }
    }
    else if ([command isEqualTo: TraceLogMessageId] || [command isEqualTo: TraceLogMessageContinueId])
    {
        [self createTraceLogTabView];
        [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
            if ([command isEqualTo: TraceLogMessageId])
            {
                [self.traceLogTextView setString: @""];
                [sequenceDiagram initDiagramm];
            }
            
            [self.traceLogTextView insertText: [data stringByReplacingOccurrencesOfString: @"?"
                                                                               withString: @"\n"]];
            
            [sequenceDiagram parseOfTricingData: data];
        }];
    }
    else if ([command isEqualTo: ResponseRTBrowserDataMessageId])
    {
        [rtBrowser startJSONdata];
        [rtBrowser fillingJSONdata: data];
    }
    else if ([command isEqualTo: ResponseRTBrowserDataMessageContinueId])
    {
        [rtBrowser fillingJSONdata: data];
    }
    else if ([command isEqualTo: ResponseRTBrowserDataMessageFinishedId])
    {
        [rtBrowser finishJSONdata];
    }
}

- (void) startServer
{
    //[self startProgressWindowWithTitle:  NSLocalizedString(@"Waiting for client connect", @"Title on panel with indicator")];
    [[NSNotificationCenter defaultCenter] postNotificationName: StartServerNotificationId
                                                        object: nil];
}

- (void) stopServer
{
    if (self.isClientConnected)
    {
        self.isClientConnected = NO;
        
        [DTClientController runCommand: DisconnectToServerMessageId];
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName: StopServerNotificationId
                                                        object: nil];
    
}

- (void) startProgress
{
    [progressIndicator startAnimation: nil];
}

- (void) stopProgress
{
    [progressIndicator stopAnimation: nil];
}

- (void) startProgressWindowWithTitle: (NSString*) aTitle
{
    if (panelWithIndicator == nil)
    {
        panelWithIndicator = [[DTPanelWithIndicator alloc] initWithDelegate: self
                                                                      title: aTitle];
    }
    
    [panelWithIndicator startProgress];
}

- (void) stopProgressWindow
{
    [panelWithIndicator performSelectorOnMainThread: @selector(stopProgress)
                                         withObject: nil
                                      waitUntilDone: YES];
}


- (void) observeValueForKeyPath: (NSString*) keyPath
                       ofObject: (id) object
                         change: (NSDictionary*) change
                        context: (void*) context
{
    if ([keyPath isEqual: @"isRunning"])
    {
        if ([[change objectForKey: NSKeyValueChangeNewKey] integerValue] == 1)
        {
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            addressOfServer.stringValue = [NSString stringWithFormat: @"%@::%@", [UDPutils getIPAddress], [defaults objectForKey: LocalServerPortNumberUserDefaultId]];
            [startStopServerButton setTitle: @"Stop"];
        }
        else
        {
            addressOfServer.stringValue = @"Not running";
            [startStopServerButton setTitle: @"Start"];
        }
    }
    else if ([keyPath isEqualToString: @"isOperationInProcessing"])
    {
        BOOL newValue = [[change objectForKey: NSKeyValueChangeNewKey] boolValue];
        
        if (newValue)
        {
            [self startProgressWindowWithTitle: NSLocalizedString(@"Waiting for build of the classes tree", @"Title on panel with indicator")];
            [self startProgress];
        }
        else
        {
            [self stopProgressWindow];
            [self stopProgress];
        }
        
        isOperationRunTimenProcessing = newValue;
    }
}

#pragma mark DTProcessIndicator protocol

- (void) cancelled
{
    //    [self stopProgressWindow];
    NSBeginAlertSheet(NSLocalizedString(@"Warning", @"Warning"), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil,
                      NSLocalizedString(@"Waiting is stoped\n", @"Waiting is stoped\n"));
}

#pragma mark TabView Controller

- (void) createLogTabView
{
    if (logTextView == nil)
    {
        NSScrollView* scrollView = [[NSScrollView alloc] init];
        [scrollView setHasHorizontalScroller: YES];
        [scrollView setHasVerticalScroller: YES];
        self.logTextView = [[NSTextView alloc] initWithFrame: NSMakeRect(0, 0, 1.0e7, 1.0e7)];
        [logTextView setMaxSize: NSMakeSize(1.0e7, 1.0e7)];
        [logTextView setSelectable: YES];
        [logTextView setEditable: YES];
        [logTextView setRichText: YES];
        [logTextView setImportsGraphics: YES];
        [logTextView setUsesFontPanel: YES];
        [logTextView setUsesRuler: YES];
        [logTextView setAllowsUndo: YES];
        [logTextView setDelegate: self];
        [scrollView setDocumentView: logTextView];
        
        logTextView.frame = NSMakeRect(0, 0, 1.0e7, 1.0e7);
        
        NSTabViewItem* tabViewItem = [[NSTabViewItem alloc] init];
        [tabViewItem setLabel: @"Log"];
        
        [tabViewItem setView: scrollView];
        [scrollView release];
        
        [tabView addTabViewItem: tabViewItem];
        [tabViewItem release];
    }
}

- (void) createTraceLogTabView
{
    if (traceLogTextView == nil)
    {
        NSTabViewItem* tabViewItem = [[NSTabViewItem alloc] init];
        [tabViewItem setLabel: @"Code tracing"];
        [tabView addTabViewItem: tabViewItem];
        [tabViewItem release];
        
        NSTabView* tabViewTracing = [[NSTabView alloc] init];
        [tabViewTracing setAutoresizingMask: (NSViewWidthSizable | NSViewHeightSizable)];
        [tabViewItem setView: tabViewTracing];
        [tabView selectTabViewItem: tabViewItem];
        [tabViewTracing release];
        
        NSScrollView* scrollView = [[NSScrollView alloc] init];
        [scrollView setHasHorizontalScroller: YES];
        [scrollView setHasVerticalScroller: YES];
        self.traceLogTextView = [[NSTextView alloc] initWithFrame: NSMakeRect(0, 0, 1.0e7, 1.0e7)];
        [traceLogTextView setMaxSize: NSMakeSize(1.0e7, 1.0e7)];
        [traceLogTextView setSelectable: YES];
        [traceLogTextView setEditable: YES];
        [traceLogTextView setRichText: YES];
        [traceLogTextView setImportsGraphics: YES];
        [traceLogTextView setUsesFontPanel: YES];
        [traceLogTextView setUsesRuler: YES];
        [traceLogTextView setAllowsUndo: YES];
        [traceLogTextView setDelegate: self];
        [scrollView setDocumentView: traceLogTextView];
        
        NSTabViewItem* tabViewItemLog = [[NSTabViewItem alloc] init];
        [tabViewItemLog setLabel: @"Log"];
        [tabViewItemLog setView: scrollView];
        [scrollView release];
        [tabViewTracing addTabViewItem: tabViewItemLog];
        [tabViewItemLog release];
        
        NSTabViewItem* tabViewItemDiagram = [[NSTabViewItem alloc] init];
        [tabViewItemDiagram setLabel: @"Sequence diagram"];
        
        sequenceDiagram = [[DTSequenceDiagramViewController alloc] initWithNibName: @"DTSequenceDiagramViewController"
                                                                            bundle: [NSBundle mainBundle]];
        [tabViewItemDiagram setView: sequenceDiagram.view];
        
        [tabViewTracing addTabViewItem: tabViewItemDiagram];
        [tabViewTracing selectTabViewItem: tabViewItemDiagram];
        
        [tabViewItemDiagram release];
    }
}

- (void) createAutoUITestingTabView
{
    if (testLogTextView == nil)
    {
        NSTabViewItem* tabViewItem = [[NSTabViewItem alloc] init];
        [tabViewItem setLabel: @"UI testing"];
        [tabView addTabViewItem: tabViewItem];
        [tabViewItem release];
        
        NSTabView* tabViewTesting = [[NSTabView alloc] init];
        [tabViewTesting setAutoresizingMask: (NSViewWidthSizable | NSViewHeightSizable)];
        [tabViewItem setView: tabViewTesting];
        [tabViewTesting release];
        
        NSScrollView* scrollView = [[NSScrollView alloc] init];
        [scrollView setHasHorizontalScroller: YES];
        [scrollView setHasVerticalScroller: YES];
        self.testLogTextView = [[NSTextView alloc] initWithFrame: NSMakeRect(0, 0, 1.0e7, 1.0e7)];
        [testLogTextView setMaxSize: NSMakeSize(1.0e7, 1.0e7)];
        [testLogTextView setSelectable: YES];
        [testLogTextView setEditable: YES];
        [testLogTextView setRichText: YES];
        [testLogTextView setImportsGraphics: YES];
        [testLogTextView setUsesFontPanel: YES];
        [testLogTextView setUsesRuler: YES];
        [testLogTextView setAllowsUndo: YES];
        [testLogTextView setDelegate: self];
        [scrollView setDocumentView: testLogTextView];
        
        NSTabViewItem* tabViewItemLog = [[NSTabViewItem alloc] init];
        [tabViewItemLog setLabel: @"Log"];
        [tabViewItemLog setView: scrollView];
        [scrollView release];
        [tabViewTesting addTabViewItem: tabViewItemLog];
        [tabViewItemLog release];
        
        NSTabViewItem* tabViewItemMaps = [[NSTabViewItem alloc] init];
        [tabViewItemMaps setLabel: @"Views Map"];
        [tabViewTesting addTabViewItem: tabViewItemMaps];
        [tabViewItemMaps release];
        
        tabViewsMap = [[NSTabView alloc] init];
        [tabViewsMap setAutoresizingMask: (NSViewWidthSizable | NSViewHeightSizable)];
        [tabViewItemMaps setView: tabViewsMap];
        [tabViewsMap release];
        
        NSTabViewItem* tabViewItemScript = [[NSTabViewItem alloc] init];
        [tabViewItemScript setLabel: @"Script"];
        scriptVC = [[DTTestScriptViewController alloc] initWithNibName: @"DTTestScriptViewController"
                                                                bundle: [NSBundle mainBundle]
                                                              delegate: self];
        [tabViewItemScript setView: scriptVC.view];
        
        [tabViewTesting addTabViewItem: tabViewItemScript];
        [tabViewItemScript release];
        
    }
}

- (void) addVewsMapOnNewTabWithTitle: (NSString*) aTitle view: (NSView*) aView
{
    NSUInteger cntTitles = 0;
    
    for (NSTabViewItem* tabViewItem in [tabViewsMap tabViewItems])
    {
        if ([tabViewItem.label hasPrefix: aTitle])
        {
            cntTitles++;
        }
    }
    
    if (cntTitles > 0)
    {
        aTitle = [NSString stringWithFormat: @"%@_%ld", aTitle, cntTitles + 1];
    }
    
    NSTabViewItem* tabViewItem = [[NSTabViewItem alloc] init];
    [tabViewItem setLabel: aTitle];
    
    [tabViewItem setView: aView];
    
    [tabViewsMap addTabViewItem: tabViewItem];
    [tabViewsMap selectTabViewItem: tabViewItem];
    
    [tabViewItem release];
}

#pragma mark Fill map's views data

- (void) addNewViewsMapForText: (NSString*) aText
                  withContinue: (BOOL) withContinue
{
    if (withContinue)
    {
        if (uiViewsMap != nil)
        {
            [uiViewsMap insertStringMap: aText];
        }
    }
    else
    {
        NSArray* arr = [aText componentsSeparatedByString: @"~"];
        NSString* title = [arr objectAtIndex: 0];
        
        if (uiViewsMap != nil)
        {
            [uiViewsMap release];
            uiViewsMap = nil;
        }
        
        uiViewsMap = [[DTViewsInfoViewController alloc] initWithNibName: @"DTViewsInfoViewController"
                                                                 bundle: [NSBundle mainBundle]
                                                               testName: title
                                                                   text: [arr objectAtIndex: 1]];
        
        [self addVewsMapOnNewTabWithTitle: title
                                     view: uiViewsMap.view];
    }
}

- (void) viewsMapFinished
{
    if (uiViewsMap != nil)
    {
        [uiViewsMap receivingDataIsFinished];
    }
}


#pragma mark NSToolbarItemValidation and NSMenuItemValidation Protocol implementation

- (BOOL) enableToolBarItemTag: (NSInteger)tag
{
    BOOL enableToolBarItem = YES;
    
    switch (tag)
    {
        case 10: // Start trace
            enableToolBarItem = !self.isStartTrace && self.isClientConnected;
            break;
            
        case 11: // Stop trace
            enableToolBarItem = self.isStartTrace;
            break;
            
        case 12: // Runtime browser
            enableToolBarItem = (!isOperationRunTimenProcessing && self.isClientConnected) ? YES: NO;
            break;
            
        case 14: // Run Test
            enableToolBarItem = !self.isStartUITesting && self.isClientConnected;
            break;
            
        case 15:
        case 16:
        case 17:
            enableToolBarItem = !self.isStartUITesting && self.isClientConnected;
            break;
    }
    
    return enableToolBarItem;
}

-(BOOL) validateToolbarItem: (NSToolbarItem* )toolbarItem
{
    return [self enableToolBarItemTag: [toolbarItem tag]];
}

-(BOOL) validateMenuItem: (NSMenuItem* )menuItem
{
    return [self enableToolBarItemTag: [menuItem tag]];
}

- (void) enableToolbar: (BOOL) enable
{
    isEnableToolBar = enable;
}

#pragma mark Properties

- (BOOL) isClientConnected
{
    return _isClientConnected;
}

- (void) setIsClientConnected: (BOOL) anIsClientConnected
{
    _isClientConnected = anIsClientConnected;
    
    if (anIsClientConnected)
    {
        [self stopProgress];
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        
        statusToClientConnect.stringValue = [NSString stringWithFormat: @"Client: %@::%@",
                                             [defaults objectForKey: ClientHostNameUserDefaultId],
                                             [defaults objectForKey: ClientPortNumberUserDefaultId]];
        
        NSString* message = [NSString stringWithFormat: NSLocalizedString(@"Client %@::%@ is connected!", @"Connect Succeeded"),
                             [defaults objectForKey: ClientHostNameUserDefaultId],
                             [defaults objectForKey: ClientPortNumberUserDefaultId]];
        
        NSBeginAlertSheet(message, nil, nil, nil, MAINWINDOW, nil, nil, nil, nil,
                          NSLocalizedString(@"Device is on line", @"Device is on line"));
    }
    else
    {
        statusToClientConnect.stringValue = NSLocalizedString(@"Waiting for client connect...", @"Waiting for client connect...");
        [self startProgress];
    }
}

- (BOOL) isStartTrace
{
    return _isStartTrace;
}

- (void) setIsStartTrace: (BOOL) anIsStartTrace
{
    _isStartTrace = anIsStartTrace;
    
    if (anIsStartTrace)
    {
        [self startProgress];
    }
    else
    {
        [self stopProgress];
    }
}

- (BOOL) isStartUITesting
{
    return _isStartUITesting;
}

- (void) setIsStartUITesting: (BOOL) anIsStartUITesting
{
    _isStartUITesting = anIsStartUITesting;
    
    if (anIsStartUITesting)
    {
        [self startProgress];
    }
    else
    {
        [self stopProgress];
    }
}

#pragma mark -

-(BOOL) isTabExists: (NSString*) tabViewItemTitle
{
    return YES;
}

#pragma mark IB Actions

- (IBAction) clearLogTrace: (id) sender
{
    [self.traceLogTextView setString: @""];
}

- (IBAction) startStopLocalServer: (id) sender
{
    if (ipSereverController.isRunning)
    {
        [self stopServer];
    }
    else
    {
        [self startServer];
    }
}

- (IBAction) prepareToTracing: (id) sender
{
    DTPrepareToTracing* prepareToTracing = [[DTPrepareToTracing alloc] initWithWindowNibName: @"DTPrepareToTracing"];
    [prepareToTracing showWindow: self];
    [[NSApplication sharedApplication] runModalForWindow: [prepareToTracing window]];
}

- (IBAction) startTrace: (id) sender
{
    NSArray* selectedClassNames = [NSArray array];
    
    if (rtBrowser != nil)
    {
        selectedClassNames = [rtBrowser selectedClassNames];
    }
    self.isStartTrace = YES;
    
    [DTClientController runCommand: StartTraceMessageId
                              data: [selectedClassNames componentsJoinedByString: @";"]];
}

- (IBAction) stopTrace: (id) sender
{
    [DTClientController runCommand: StopTraceMessageId];
    self.isStartTrace = NO;
}

- (IBAction) saveSelectedClassList: (id)sender
{
    if (rtBrowser != nil)
    {
        if ([[rtBrowser selectedClassNames] count] > 0)
        {
            DTEnterSingleDataModalDialog* dlg = [[DTEnterSingleDataModalDialog alloc] initWithTitle: NSLocalizedString(@"Save checked classes list", @"Save checked classes list")
                                                                                               text: NSLocalizedString(@"File name:", @"File name:")
                                                                                             sender: self
                                                                                             target: self
                                                                                              okSel: @selector(saveClassesList:)
                                                                                          cancelSel: nil];
            [dlg showModalDialog];
        }
        else
        {
            NSBeginAlertSheet(NSLocalizedString(@"Operation can't be done!", @"Operation can't be done!"), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil,
                              NSLocalizedString(@"Please uncheck tree and than check some classes.", @"Please uncheck tree and than check some classes."));
        }
    }
}

- (void) saveClassesList: (id) aFileName
{
    NSString* fileName = (NSString*) aFileName;
    
    NSLog(@"%@", fileName);
    
    NSString* schemesPath = [DTFileOperations documentPathAppendDirectory: DirectoryNameForRunTimeClassesSelect];
    NSString* fullFileName = [NSString stringWithFormat: @"%@/%@.%@", schemesPath, fileName, ExtentionFileNameOfRunTimeClassesSelect];
    
    NSArray* selectedClassNames = [rtBrowser selectedClassNames];
    NSString* str = [selectedClassNames componentsJoinedByString: @"\n"];
    
    NSError* error = nil;
    
    [str writeToFile: fullFileName
          atomically: YES
            encoding: NSUTF16StringEncoding
               error: &error];
}

- (IBAction) startAutoUITesting: (id) sender
{
    [DTClientController runCommand: StartUITestingMessageId];
    self.isStartUITesting = YES;
}

- (IBAction) editOfSettings: (id) sender
{
    DTSettingsController* settings = [[DTSettingsController alloc] initWithWindowNibName: @"DTSettingsController"];

    DTAppDelegate* appDelegate = (DTAppDelegate*) [[NSApplication sharedApplication] delegate];
    
    [settings runModalSheetForWindow: appDelegate.window];
    
//    [settings showWindow: self];
//    [[NSApplication sharedApplication] runModalForWindow: [settings window]];
}

- (IBAction) help: (id)sender
{
}

- (IBAction) exit : (id)sender
{
    [DTClientController runCommand: DisconnectToServerMessageId];
    
    [[NSApplication sharedApplication] terminate: self];
}

- (IBAction) openRunTimeBrowser: (id) sender
{
    if (rtBrowser == nil)
    {
        rtBrowser = [[DTRuntimeBrowserViewController alloc] initWithNibName: @"DTRuntimeBrowserViewController"
                                                                     bundle: [NSBundle mainBundle]];
        
        [rtBrowser addObserver: self
                    forKeyPath: @"isOperationInProcessing"
                       options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                       context: nil];
        
        NSTabViewItem* tabViewItem = [[NSTabViewItem alloc] init];
        [tabViewItem setLabel: @"Runtime browser"];
        [tabViewItem setView: rtBrowser.view];
        
        [tabView addTabViewItem: tabViewItem];
        [tabViewItem release];
    }
    else
    {
        [rtBrowser reloadClassTree];
    }
}

- (IBAction) showCurrentViewsStateOnClient: (id) sender
{
    [self startProgress];
    
    [DTClientController runCommand: CurrentViewsMessageId];
}

- (IBAction) switchToDevToolsClientUI: (id) sender
{
    [DTClientController runCommand: SwitchToDevToolsMessageId];
}

- (IBAction) switchToApplicationUI: (id) sender
{
    [DTClientController runCommand: SwitchToApplicationMessageId];
}

- (void) runScript: (NSString*) aScript
{
    [DTClientController runCommand: RunUITestScriptMessageId
                              data: aScript];
}

@end
