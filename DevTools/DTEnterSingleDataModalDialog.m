//
//  DTEnterSingleDataModalDialog.m
//  DevTools
//
//  Created by Sergey Krotkih on 12/09/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import "DTEnterSingleDataModalDialog.h"

@implementation DTEnterSingleDataModalDialog

@synthesize title, textOnlabel;

- (id) initWithTitle: (NSString*) aTitle
                text: (NSString*) aText
              sender: (id) aSender
              target: (id) aTarget
               okSel: (SEL) anOkSel
           cancelSel: (SEL) aCanelSel
{
	if ((self = [super initWithWindowNibName: @"DTEnterSingleDataModalDialog"]))
    {
        okSelector = anOkSel;
        cancelSelector = aCanelSel;
        sender = aSender;
        target = aTarget;
        self.title = aTitle;
        self.textOnlabel = aText;
    }
	
	return self;
}

- (void) dealloc
{
    self.title = nil;
    self.textOnlabel = nil;
    
	[super dealloc];
}

- (void) showModalDialog
{
    [self.window setTitle: title];
    [label setTitle: textOnlabel];
    
    DTAppDelegate* appDelegate = (DTAppDelegate*) [[NSApplication sharedApplication] delegate];
    [self showWindow: appDelegate.window];
    [[NSApplication sharedApplication] runModalForWindow: self.window];
}

- (BOOL) windowShouldClose: (id) sender
{

    return YES;
}

- (IBAction) pressOK: (id) sender
{
    [[self window] orderOut: nil];
    [NSApp stopModal];
    
    NSString* data = singleData.stringValue;
    
    if (([data length] > 0) && (target != nil) && (okSelector != nil))
    {
        [target performSelector: okSelector
                     withObject: data
                     afterDelay: 0.0f];
    }

}

-(void) windowWillClose: (NSNotification*) notification
{
    [[self window] orderOut: nil];
    [NSApp stopModal];

    if ((target != nil) && (cancelSelector != nil))
    {
        [target performSelector: cancelSelector
                     withObject: nil
                     afterDelay: 0.0f];
    }
}

@end
