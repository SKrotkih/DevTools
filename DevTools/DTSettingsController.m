//
//  DTSettingsController.m
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import "DTSettingsController.h"
#import <UDP/UDPutils.h>
#import "DTConstants.h"

@implementation DTSettingsController

- (void) awakeFromNib
{
    myIP.stringValue = [UDPutils getIPAddress];
    
    NSString* portNumber = [[NSUserDefaults standardUserDefaults] objectForKey: LocalServerPortNumberUserDefaultId];

    if (portNumber != nil)
    {
        serverPortNumber.stringValue = portNumber;
    }
}

- (BOOL) windowShouldClose: (id) sender
{
    return YES;
}

- (BOOL) sheetIsValid
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject: serverPortNumber.stringValue
                 forKey: LocalServerPortNumberUserDefaultId];
    
    [defaults synchronize];
    
    if ([[NSApplication sharedApplication] modalWindow] != nil)
    {
        [[NSApplication sharedApplication] stopModal];
    }
    
    [self autorelease];

    return YES;
}

- (void) windowWillClose: (NSNotification*) notification
{

}

@end
