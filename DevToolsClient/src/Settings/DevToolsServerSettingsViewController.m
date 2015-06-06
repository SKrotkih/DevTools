//
//  DevToolsServerSettingsViewController.m
//  DevToolsClient
//
//  Created by Sergey Krotkih on 7/31/12.
//  Copyright (c) 2012 Quickoffice. All rights reserved.
//

#import "DevToolsServerSettingsViewController.h"
#import "UDPutils.h"
#import "UDPServerController.h"
#import "UDPClientController.h"

@implementation DevToolsServerSettingsViewController

- (id) init
{
    if ((self = [super initWithNibName: @"DevToolsServerSettingsViewController"
                                bundle: gDevToolsClientResBundle]))
    {
    }
    
    return self;
}

- (void) viewDidLoad
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSString* ipServer = [defaults objectForKey: @"DevToolsServerHostName"];
    
    if (ipServer != nil)
    {
        remoteServerAddress.text = ipServer;
    }
    
    NSString* portNumber = [defaults objectForKey: @"DevToolsServerPortNumber"];
    
    if (portNumber != nil)
    {
        remoteServerPortNumber.text = portNumber;
    }

    self.navigationItem.title = @"DevTools server";
    
    [super viewDidLoad];
}

- (void) viewDidAppear: (BOOL)animated
{
    UDPClientController* clientController = [UDPClientController sharedInstance];
    
    if (clientController.isConnected)
    {
        isDevToolsServerConnected.text = @"Connected";
        isDevToolsServerConnected.textColor = [UIColor greenColor];
    }
    else
    {
        isDevToolsServerConnected.text = @"Didn't connect";
        isDevToolsServerConnected.textColor = [UIColor redColor];
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
    
    NSString* address = remoteServerAddress.text;
    [defaults setObject: address
                 forKey: @"DevToolsServerHostName"];
    
    NSString* port = remoteServerPortNumber.text;
    [defaults setObject: port
                 forKey: @"DevToolsServerPortNumber"];
    
    [defaults synchronize];
}

@end
