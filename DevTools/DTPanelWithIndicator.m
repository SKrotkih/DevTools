//
//  DTPanelWithIndicator.m
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import "DTPanelWithIndicator.h"

@implementation DTPanelWithIndicator

@synthesize title;

- (id) init
{
	if ((self = [self initWithDelegate: nil title: nil])) 
    {
	}
	
	return self;
}

- (id) initWithDelegate: (id<DTProcessIndicator>) aDelegate title: (NSString*) aTitle
{
	if ((self = [super initWithWindowNibName: @"DTPanelWithIndicator"])) 
    {
        delegate = aDelegate;
        self.title = aTitle;
	}
	
	return self;
}

- (void) dealloc
{
    [title release];
    title = nil;

    [super dealloc];
}

- (void) windowDidLoad 
{
    [self startProgress];
}

- (void) windowDidUnLoad 
{
}

- (void) startProgress 
{
    DTAppDelegate* appDelegate = (DTAppDelegate*) [[NSApplication sharedApplication] delegate];
    [self withParentWindow: appDelegate.window];

    [progress startAnimation: nil];
    label.title = title;
}

- (void) stopProgress 
{
    [progress stopAnimation: nil];
    [[self window] orderOut: nil];
    [NSApp stopModal];
}

- (void) withParentWindow: (NSWindow*) aParentWindow
{
    //[[self window] setParentWindow: aParentWindow];
    
    [aParentWindow addChildWindow: [self window] ordered: NSWindowAbove];
}

- (void) showWindow: (id)sender
{
    
}

- (void) onPressedCancel: (id)sender
{
    [self stopProgress];
    [delegate cancelled];
}

@end
