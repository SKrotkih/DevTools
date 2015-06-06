//
//  DTSequenceDiagramClassView.h
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DTSequenceDiagramViewController;

@interface DTSequenceDiagramClassView : NSView
{
    NSColor* color;
    NSString* className;
    DTSequenceDiagramViewController* parent;
}

@property (nonatomic, readwrite, copy) NSColor* color;
@property (nonatomic, readwrite, copy) NSString* className;

- (id) initWithFrame: (CGRect) aFrame
                text: (NSString*) aText
             bgColor: (NSColor*) aBgColor;

- (void) setBackgroundColor: (NSColor*) aColor;
- (CGFloat) middleX;

@end

@interface DTClassNameLabel : NSTextField
{
}

- (id) initWithFrame: (CGRect) aFrame
                text: (NSString*) aText;

@end
