//
//  DevToolsClientController.h
//  DevToolsClient
//
//  Created by Krotkih Sergey on 27.11.12.
//  Copyright Quickoffice 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UDPClientController;
@class RuntimeBrowserWebServer;
@class ActionsTestViewController;
@class DevToolsClientViewController;
@class DTTraceController;

typedef enum
{
	FrontEndApplication = 0,
	DevToolsClient
}  StatusOfRootViewController;

@protocol DevToolsMessenger <NSObject>

- (BOOL) isConnected;

- (void) connect;

- (void) disConnect;

- (void) beginToSendMessageWithLength: (NSUInteger) aLength;

- (void)  runCommand: (NSString*) aCommandID
       contCommandID: (NSString*) aContCommandID
                data: (NSString*) aData;

- (void) endToSendMessage;

- (void) receivedEchoFromServer: (NSString*) anEcho;

@end

@interface DevToolsClientController : NSObject <DevToolsMessenger, UITabBarControllerDelegate>
{
    UDPClientController* clientController;
    NSTimer* connectTimer;
    RuntimeBrowserWebServer* runtimeBrowserWebServer;
    UITabBarController* _tabBarController;
    StatusOfRootViewController statusOfRootViewController;
    ActionsTestViewController* _actionsTestViewController;
    UIViewController* _appRootViewController;
    UIWindow* window;
    DevToolsClientViewController* mainViewController;
    DTTraceController* traceController;
    BOOL isTestingNow;
    NSOperationQueue* operationQueue;    
}

@property (nonatomic, readwrite, assign) UITabBarController* tabBarController;
@property (nonatomic, readonly, assign) StatusOfRootViewController  statusOfRootViewController;
@property (nonatomic, readwrite, assign) ActionsTestViewController* actionsTestViewController;
@property (nonatomic, readwrite, retain) UIViewController* appRootViewController;
@property (nonatomic, readwrite, assign) UIWindow* window;

+ (DevToolsClientController*) sharedInstance;

- (void) initWithAppRootViewController: (UIViewController*) anAppRootViewController
                          andMainWidow: (UIWindow*) aWindow;

- (void) changeStatusOfRootViewController;
- (void) switchToApplication;
- (void) switchToDevToolsClient;

@end