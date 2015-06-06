//
//  ClassCell.m
//  RuntimeBrowser
//
//  Created by Nicolas Seriot on 13.08.08.
//  Copyright 2008 seriot.ch. All rights reserved.
//

#import "ClassCell.h"

@implementation ClassCell

@synthesize label;
@synthesize button;
@synthesize parentTableView;

- (IBAction) onPressButton: (id)sender 
{
    if (parentTableView != nil) 
    {
        [parentTableView performSelector: @selector(onSelectCell:) 
                              withObject: label.text];	
    }
}

- (void) dealloc 
{
	[label release];
	[button release];
	[super dealloc];
}

@end
