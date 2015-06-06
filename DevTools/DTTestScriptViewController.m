//
//  DTTestScriptViewController.m
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import "DTTestScriptViewController.h"

@interface DTTestScriptViewController()
- (IBAction) onRunScript: (id) sender;
@end

@implementation DTTestScriptViewController

- (id) initWithNibName: (NSString*) nibNameOrNil
                bundle: (NSBundle*) nibBundleOrNil
              delegate: (id <UITestingScriptController>) aDelegate
{
    if ((self = [super initWithNibName: nibNameOrNil
                                bundle: nibBundleOrNil]))
    {
        delegate = aDelegate;
    }
    
    return self;
}

- (IBAction) onRunScript: (id) sender
{
    NSString* script = [textView string];
    [delegate runScript: script];
}


@end
