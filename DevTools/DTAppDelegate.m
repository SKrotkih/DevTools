//
//  DTAppDelegate.m
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import "DTAppDelegate.h"

@implementation DTAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application 
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication*) sender
{
    return YES;
}

@end
