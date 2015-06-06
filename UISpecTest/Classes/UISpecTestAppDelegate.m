//
//  UISpecTestAppDelegate.m
//  DevToolsClient
//
//  Created by Sergey Krotkih on 7/31/12.
//  Copyright (c) 2012 Quickoffice. All rights reserved.
//

#import "UISpecTestAppDelegate.h"
#import <DevToolsClient/DevToolsClientController.h>
#import "MainViewController.h"

@implementation UISpecTestAppDelegate

- (BOOL) application: (UIApplication*) application didFinishLaunchingWithOptions: (NSDictionary*) launchOptions
{
    DTTraceLog();
    self.window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    
    MainViewController* appMainViewController = [[MainViewController alloc] init];
    appMainViewController.title = @"UICatalog";
    UINavigationController* appNavigationController = [[UINavigationController alloc] initWithRootViewController: appMainViewController];
    [appMainViewController release];
    
    self.window.rootViewController = appNavigationController;
    [self.window makeKeyAndVisible];
    
    [[DevToolsClientController sharedInstance] initWithAppRootViewController: appNavigationController
                                                                andMainWidow: self.window];
    
    [appNavigationController release];
    
    return YES;
}

@end

