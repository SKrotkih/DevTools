//
//  DTTestScriptViewController.h
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol UITestingScriptController <NSObject>
- (void) runScript: (NSString*) aScript;
@end

@interface DTTestScriptViewController : NSViewController
{
    IBOutlet NSTextView* textView;
    id <UITestingScriptController> delegate;
}

- (id) initWithNibName: (NSString*) nibNameOrNil
                bundle: (NSBundle*) nibBundleOrNil
              delegate: (id <UITestingScriptController>) aDelegate;

@end
