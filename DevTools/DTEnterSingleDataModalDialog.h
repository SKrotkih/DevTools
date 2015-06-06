//
//  DTEnterSingleDataModalDialog.h
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DTEnterSingleDataModalDialog : NSWindowController <NSApplicationDelegate>
{
    IBOutlet NSTextField* singleData;
    IBOutlet NSTextFieldCell* label;
    id target;
    id sender;
    SEL okSelector;
    SEL cancelSelector;
    NSString* title;
    NSString* textOnlabel;
}

@property (nonatomic, readwrite, copy) NSString* title;
@property (nonatomic, readwrite, copy) NSString* textOnlabel;

- (id) initWithTitle: (NSString*) aTitle
                text: (NSString*) aText
              sender: (id) aSender
              target: (id) aTarget
               okSel: (SEL) anOkSel
           cancelSel: (SEL) aCanelSel;

- (void) showModalDialog;

- (IBAction) pressOK: (id) sender;

@end
