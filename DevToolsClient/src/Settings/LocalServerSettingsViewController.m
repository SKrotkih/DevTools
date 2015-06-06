//
//  LocalServerSettingsViewController.m
//  DevToolsClient
//
//  Created by Sergey Krotkih on 7/31/12.
//  Copyright (c) 2012 Quickoffice. All rights reserved.
//

#import "LocalServerSettingsViewController.h"
#import "UDPutils.h"
#import "UDPServerController.h"
#import "UDPClientController.h"

@implementation LocalServerSettingsViewController

- (void) viewDidLoad
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSString* localHostName = [[UDPutils sharedInstance] getIPAddress];

    if ([localHostName length] == 0)
    {
        localHostName = @"localhost";
    }
    
    localServerHostName.text = localHostName;
    
    NSString* localPortNumber = [defaults objectForKey: @"LocalServerPortNumber"];
    
    if (localPortNumber != nil)
    {
        localServerPortNumber.text = localPortNumber;
    }

    self.navigationItem.title = @"Local server";    
    
    [super viewDidLoad];
}

- (void) viewDidAppear: (BOOL)animated
{
    UDPServerController* serverController = [UDPServerController sharedInstance];
    
    if (serverController.isRunning)
    {
        isLocalServerRunning.text = @"Started";
        isLocalServerRunning.textColor = [UIColor greenColor];
    }
    else
    {
        isLocalServerRunning.text = @"Not started";
        isLocalServerRunning.textColor = [UIColor redColor];
    }
}

- (BOOL) textFieldShouldReturn: (UITextField*) textField
{
    [textField resignFirstResponder];
    
    return NO;
}

- (void) textFieldDidEndEditing: (UITextField*) textField
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSString* localPort = localServerPortNumber.text;
    [defaults setObject: localPort
                 forKey: @"LocalServerPortNumber"];
    
    [defaults synchronize];
}

@end
