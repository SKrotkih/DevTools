//
//  DevToolsClientController.m
//  DevToolsClient
//
//  Created by Krotkih Sergey on 27.11.12.
//  Copyright Quickoffice 2012. All rights reserved.
//

#import "DevToolsClientController.h"
#import "UDPClientController.h"
#import "RuntimeBrowserWebServer.h"
#import "DevToolsClientViewController.h"
#import "InfoViewController.h"
#import "TreeViewNavigationController.h"
#import "ListTableViewController.h"
#import "FrameworksTableViewController.h"
#import "SearchViewController.h"
#import "SettingsNavigationController.h"
#import "SettingsTableViewController.h"
#import "DevToolsClientController.h"
#import "UIPopUpButton.h"
#import <UISpec/UISpec.h>
#import <UISpec/UIBug.h>
#import "AllClasses.h"
#import <UISpec/SpecsOutputData.h>
#import "ClassDisplay.h"

#import "DTTraceController.h"
#import "DTTraceObjcMsgsController.h"
#import "DTTraceLogController.h"

#define DTSimpleTRaceLog

static DevToolsClientController* sharedInstance = nil;

#pragma mark Specific for application
// For sample FM:
//static NSString* ParentBundlePath = @"SampleFileManagerRes";

// For new FM:
//static NSString* ParentBundlePath = @"QuickfilesRes_iPad";

// For test client:
static NSString* ParentBundlePath = @"";
#pragma mark -

NSBundle* gDevToolsClientResBundle = nil;
NSString* gDevToolsClientResBundlePath;

@interface  DevToolsClientController  ()
- (void) connectToServerHandlerOfTimer;
- (void) sendingUITestError: (NSNotification *) notification;
- (void) sendingUITestLog: (NSNotification *) notification;
- (void) sendingLog: (NSNotification*) notification;
- (void) sendingCommandToServer: (NSNotification*) notification;
- (void) switchToDevToolsClientController;
- (void) switchToApplicationController;
- (void) startTraceCodeWithCommand: (NSString*) aCommandString;
- (void) stopTraceCode;
- (void) requestOfRunTimeBrowserData;
- (void) startAutoUITesting;
- (void) testsWasFinished: (NSNotification*) notification;
- (void) sendClassHeaderForReceivedData: (NSString*) receivedData;
- (void) sendClassDependenciesForReceivedData: (NSString*) receivedData;
@end

@implementation DevToolsClientController

@synthesize tabBarController = _tabBarController;
@synthesize statusOfRootViewController;
@synthesize actionsTestViewController = _actionsTestViewController;
@synthesize appRootViewController =_appRootViewController;
@synthesize window;

+ (DevToolsClientController*) sharedInstance
{
    if (sharedInstance == nil)
    {
        sharedInstance = [[DevToolsClientController alloc] init];
    }
    
    return sharedInstance;
}

- (id) init
{
	if ((self = [super init]))
	{
    }
    
	return self;
}

- (void) initWithAppRootViewController: (UIViewController*) anAppRootViewController
                          andMainWidow: (UIWindow*) aWindow
{
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(receiveData:)
                                                 name: ReceivedDataNotificationId
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(sendingUITestError:)
                                                 name: UITestErrorNotificationId
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(sendingUITestLog:)
                                                 name: UITestLogNotificationId
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(sendingUITestMap:)
                                                 name: ViewsMapNotificationId
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(sendingLog:)
                                                 name: SendLogNotificationId
                                               object: nil];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(sendingCommandToServer:)
                                                 name: kSendCommandToServerNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(testsWasFinished:)
                                                 name: UITestFinishedNotificationId
                                               object: nil];
    
    self.appRootViewController = anAppRootViewController;
    self.window = aWindow;
    
    NSBundle* parentBundle;

    if ([ParentBundlePath length] > 0)
    {
        NSString* parentBundlePath = [[NSBundle mainBundle] pathForResource: ParentBundlePath
                                                                     ofType: @"bundle"];
        parentBundle = [NSBundle bundleWithPath: parentBundlePath];
        gDevToolsClientResBundlePath = [[NSString alloc] initWithFormat: @"%@.bundle/DevToolsClientRes.bundle/", ParentBundlePath];
    }
    else
    {
        parentBundle = [NSBundle mainBundle];
        gDevToolsClientResBundlePath = [[NSString alloc] initWithString: @"DevToolsClientRes.bundle/"];
    }
    
    NSString* bundlePath = [parentBundle pathForResource: @"DevToolsClientRes"
                                                  ofType: @"bundle"];
    gDevToolsClientResBundle = [[NSBundle bundleWithPath : bundlePath] retain];
    
    mainViewController = [[[DevToolsClientViewController alloc] initWithNibName: @"DevToolsClientViewController"
                                                                         bundle: gDevToolsClientResBundle] autorelease];
    UIViewController* viewController2 = [[[InfoViewController alloc] initWithNibName: @"InfoViewController"
                                                                              bundle: gDevToolsClientResBundle] autorelease];
    UIViewController* viewController3 = [[[TreeViewNavigationController alloc] initWithNibName: @"TreeViewNavigationController"
                                                                                        bundle: gDevToolsClientResBundle] autorelease];
    UIViewController* viewController4 = [[[ListTableViewController alloc] initWithNibName: @"ListTableViewController"
                                                                                   bundle: gDevToolsClientResBundle] autorelease];
    UIViewController* viewController5 = [[[FrameworksTableViewController alloc] init] autorelease];
    UIViewController* viewController6 = [[[SearchViewController alloc] initWithNibName: @"SearchViewController"
                                                                                bundle: gDevToolsClientResBundle] autorelease];

    UIViewController* viewController7;
    
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        viewController7 = [[[SettingsNavigationController alloc] initWithNibName: @"SettingsNavigationController"
                                                                          bundle: gDevToolsClientResBundle] autorelease];
    }
    else
    {
        viewController7 = [[[SettingsTableViewController alloc] initWithNibName: @"SettingsTableViewController"
                                                                         bundle: gDevToolsClientResBundle] autorelease];
    }
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects: mainViewController, viewController2, viewController3, viewController4, viewController5, viewController6, viewController7, nil];
    
    runtimeBrowserWebServer = [[RuntimeBrowserWebServer alloc] init];
    
    NSString* defaultsPath = [gDevToolsClientResBundle pathForResource: @"Defaults"
                                                                ofType: @"plist"];
    NSDictionary* defaults = [NSDictionary dictionaryWithContentsOfFile: defaultsPath];
    [[NSUserDefaults standardUserDefaults] registerDefaults: defaults];
    
    [UIPopUpButton buttonAtPoint: CGPointMake(320.0f - 40.0f, 30.0f)];
    [UIPopUpButton bringButtonToFront];
    
    statusOfRootViewController = FrontEndApplication;
    operationQueue = [[NSOperationQueue alloc] init];
    
    [self connect];   
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: ReceivedDataNotificationId
                                                  object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UITestErrorNotificationId
                                                  object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UITestLogNotificationId
                                                  object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: ViewsMapNotificationId
                                                  object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: SendLogNotificationId
                                                  object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: kSendCommandToServerNotification
                                                  object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UITestFinishedNotificationId
                                                  object: nil];
    [operationQueue cancelAllOperations];
    [operationQueue release];
    [clientController release];
    clientController = nil;
    [connectTimer invalidate];
    [_tabBarController release];
    _tabBarController = nil;
    
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

#pragma mark Run command

- (void) runCommand: (NSDictionary*) aCommandDict
{
    NSString* command = [aCommandDict objectForKey: CommandKeyForJSONdictionary];
    NSString* commandData = [aCommandDict objectForKey: DataKeyForJSONdictionary];
    
    if (![command isEqualToString: EchoFromServerNotificationId])
    {
        mainViewController.log = command;
    }
    
    if ([command isEqualToString: StartTraceMessageId])
    {
        [self startTraceCodeWithCommand: commandData];
    }
    else if ([command isEqualToString: StopTraceMessageId])
    {
        [self stopTraceCode];
    }
    else if ([command isEqualToString: RequestToRunTimeBrowserDataNotificationId])
    {
        [self performSelectorOnMainThread: @selector(requestOfRunTimeBrowserData)
                               withObject: nil
                            waitUntilDone: NO];
    }
    else if ([command isEqualToString: StartUITestingMessageId])
    {
        [self performSelectorOnMainThread: @selector(startAutoUITesting)
                               withObject: nil
                            waitUntilDone: NO];
    }
    else if ([command isEqualToString: RunUITestScriptMessageId])
    {
        NSArray* commands = [commandData componentsSeparatedByString: @"\n"];
        [UISpec runScriptForCommandsArray: commands];
    }
    else if ([command isEqualToString: RunViewScriptMessageId])
    {
        [UISpec runScriptItem: commandData];
    }
    else if ([command isEqualToString: CurrentViewsMessageId])
    {
        [operationQueue addOperationWithBlock: ^{
            [SpecsOutputData sendCurrentViewsData];
        }];
    }
    else if ([command isEqualToString: SwitchToDevToolsMessageId])
    {
        [[DevToolsClientController sharedInstance] switchToDevToolsClient];
    }
    else if ([command isEqualToString: SwitchToApplicationMessageId])
    {
        [[DevToolsClientController sharedInstance] switchToApplication];
    }
    else if ([command isEqualToString: ClassInterfaceRequestMessageId])
    {
        [self sendClassHeaderForReceivedData: commandData];
    }
    else if ([command isEqualToString: ClassDependenciesRequestMessageId])
    {
        [self sendClassDependenciesForReceivedData: commandData];
    }
    else if ([command isEqualToString: EchoFromServerNotificationId])
    {
        [self receivedEchoFromServer: commandData];
    }
    else if ([command isEqualToString: DisconnectToServerMessageId])
    {
        [self disConnect];
    }
}

- (void) startTraceCodeWithCommand: (NSString*) aCommandString
{
    if (!traceController)
    {
        
#ifdef DTSimpleTRaceLog
        traceController = [[DTTraceLogController alloc] initWithDelegate: mainViewController];
#else
        traceController = [[DTTraceObjcMsgsController alloc] initWithDelegate: mainViewController];
#endif

    }
    
    [traceController startTraceCodeWithCommand: aCommandString];
}

- (void) stopTraceCode
{
    if (traceController)
    {
        [traceController stopTraceCode];
    }
}

- (void) requestOfRunTimeBrowserData
{
    AllClasses* allClasses = [AllClasses sharedInstance];
    NSString* jsonDescription = [allClasses createDescription];
    
    [self runCommand: ResponseRTBrowserDataMessageId
       contCommandID: ResponseRTBrowserDataMessageContinueId
                data: jsonDescription];
    
    [self runCommand: ResponseRTBrowserDataMessageFinishedId
       contCommandID: @""
                data: @""];
}

- (void) startAutoUITesting
{
    if (isTestingNow == YES)
    {
        return;
    }
    
    [self switchToApplication];
    
    [UISpec runSpecsAfterDelay: 2];
    //[UISpec runSpec: @"DescribeTextFields" afterDelay: 2];
    
    isTestingNow = YES;
}

- (void) testsWasFinished: (NSNotification*) notification
{
    isTestingNow = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kSendCommandToServerNotification
                                                        object: UITestWasFinishedMessageId];
}

- (void) sendClassHeaderForReceivedData: (NSString*) className
{
    if ([className length] > 0)
    {
        ClassDisplay* classDisplay = [ClassDisplay createForClass: NSClassFromString(className)];
        NSMutableString* classDependencies = [NSMutableString string];
        NSString* classHeader = [classDisplay header: classDependencies];
        
        if ([classHeader length] > 0)
        {
            // TODO::
            
            NSString* responseBody = [NSString stringWithFormat: @"%@%@%@", className, HeaderOfClassSeparator, classHeader];
            
            [self runCommand: ClassInterfaceResponceMessageId
               contCommandID: ClassInterfaceResponceMessageContinueId
                        data: responseBody];
        }
    }
}

- (void) sendClassDependenciesForReceivedData: (NSString*) className
{
    if ([className length] > 0)
    {
        ClassDisplay* classDisplay = [ClassDisplay createForClass: NSClassFromString(className)];
        NSMutableString* classDependencies = [NSMutableString string];
        NSString* classHeader = [classDisplay header: classDependencies];
        
        if ([classHeader length] > 0 && [classDependencies length] > 0)
        {
            NSString* classInfo = [NSString stringWithFormat: @"%@%@%@", className, DependencySeparator, classDependencies];
            
            [self runCommand: ClassDependenciesResponceMessageId
               contCommandID: @""
                        data: classInfo];
        }
    }
}

- (void) changeStatusOfRootViewController
{
    if (statusOfRootViewController == FrontEndApplication)
    {
        [self switchToDevToolsClient];
    }
    else
    {
        [self switchToApplication];
    }
}

- (void) switchToApplication
{
    if (statusOfRootViewController == DevToolsClient)
    {
        statusOfRootViewController = FrontEndApplication;
        
        [self performSelectorOnMainThread: @selector(switchToApplicationController)
                               withObject: nil
                            waitUntilDone: NO];
    }
}

- (void) switchToApplicationController
{
    [UIView transitionFromView: self.tabBarController.view
                        toView: self.appRootViewController.view
                      duration: 0.5
                       options: UIViewAnimationOptionTransitionFlipFromRight |
     UIViewAnimationOptionAllowUserInteraction    |
     UIViewAnimationOptionBeginFromCurrentState
                    completion: ^(BOOL finished)
     {
         self.window.rootViewController = self.appRootViewController;
         [UIBug bugAtPoint: CGPointMake(10, 30)];
         [UIPopUpButton bringButtonToFront];
         [self.window makeKeyAndVisible];
     }];
}

- (void) switchToDevToolsClient
{
    if (statusOfRootViewController == FrontEndApplication)
    {
        statusOfRootViewController = DevToolsClient;
        
        [self performSelectorOnMainThread: @selector(switchToDevToolsClientController)
                               withObject: nil
                            waitUntilDone: NO];
    }
}

- (void) switchToDevToolsClientController
{
    [UIView transitionFromView: self.appRootViewController.view
                        toView: self.tabBarController.view
                      duration: 0.5
                       options: UIViewAnimationOptionTransitionFlipFromRight |
     UIViewAnimationOptionAllowUserInteraction |
     UIViewAnimationOptionBeginFromCurrentState
                    completion: ^(BOOL finished)
     {
         self.window.rootViewController = self.tabBarController;
         [UIPopUpButton bringButtonToFront];
         [self.window makeKeyAndVisible];
     }];
}

- (void) disConnect
{
    clientController.isConnected = NO;
}

- (void) connect
{
    if ([self isConnected])
    {
        return;
    }
    
    if ((connectTimer == nil) || ([connectTimer isValid] == NO))
    {
        connectTimer = [NSTimer scheduledTimerWithTimeInterval: 3.0
                                                        target: self
                                                      selector: @selector(connectToServerHandlerOfTimer)
                                                      userInfo: nil
                                                       repeats: YES];
    }
}

- (BOOL) isConnected
{
    if (clientController == nil)
    {
        return NO;
    }
    
    return [clientController isConnected];
}

- (void) connectToServerHandlerOfTimer
{
    if (!clientController)
    {
        clientController = [[UDPClientController alloc] init];
    }
    
    [clientController connectToServer];
}

- (void) beginToSendMessageWithLength: (NSUInteger) aLength
{
    if ([self isConnected])
    {
        clientController.sendBytesCount = 0;
        clientController.maxBytesCount = aLength;
    }
}

- (void)  runCommand: (NSString*) aCommandID
       contCommandID: (NSString*) aContCommandID
                data: (NSString*) aData
{
    if ([self isConnected])
    {
        [clientController runCommandOnServer: aCommandID
                                 contCommand: aContCommandID
                                        data: aData];
    }
}

- (void) receivedEchoFromServer: (NSString*) anEcho
{
    [clientController receivedEchoFromServer: anEcho];
}

- (void) endToSendMessage
{
}

#pragma mark Logging

- (void) sendingLog: (NSNotification*) notification
{
    [self runCommand: MainLogMessageId
       contCommandID: @""
                data: [notification object]];
}

#pragma mark UI testing logging

- (void) sendingUITestError: (NSNotification*) notification
{
    [self runCommand: UITestErrorMessageId
       contCommandID: @""
                data: [notification object]];
}
  
- (void) sendingUITestLog: (NSNotification*) notification
{
    [self runCommand: UITestLogMessageId
       contCommandID: @""
                data: [notification object]];
}

#pragma mark Send map views

- (void) sendingUITestMap: (NSNotification*) notification
{
    [self runCommand: ViewsMapMessageId
       contCommandID: ViewsMapMessageContinueId
                data: [notification object]];

    [self runCommand: ViewsMapFinishedMessageId
       contCommandID: @""
                data: [notification object]];
}

#pragma mark Send command

- (void) sendingCommandToServer: (NSNotification*) notification
{
    [self runCommand: RunCommandOnServerMessageId
       contCommandID: @""
                data: [notification object]];
}

#pragma mark -

- (void) closeRuntimeBrowser
{
    [[RuntimeBrowserWebServer sharedInstance] stopWebServer];
}

@end
