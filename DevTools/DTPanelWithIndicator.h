//
//  DTPanelWithIndicator.h
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CCBModalSheetController.h"

@protocol DTProcessIndicator <NSObject>
- (void) cancelled;
@end

@interface DTPanelWithIndicator : CCBModalSheetController
{
    IBOutlet NSPanel* panel;
    IBOutlet NSProgressIndicator* progress;
    IBOutlet NSTextFieldCell* label;
    id<DTProcessIndicator> delegate;
    NSString* title;
}

@property (nonatomic, readwrite, copy) NSString* title;

- (id) initWithDelegate: (id<DTProcessIndicator>) aDelegate title: (NSString*) aTitle;
- (void) withParentWindow: (NSWindow*) aParentWindow;
- (void) startProgress;
- (void) stopProgress;
- (IBAction) onPressedCancel: (id)sender;

@end
