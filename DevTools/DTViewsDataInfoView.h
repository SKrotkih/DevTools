//
//  DTViewsDataInfoView.h
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DTViewsInfoViewController;

@interface DTViewsDataInfoView : NSView
{
    NSColor* color;
    NSString* content;
    DTViewsInfoViewController* parent;
    BOOL isMoving;
    CGPoint lastPoint;
    CGRect frameOrig;
}

@property (nonatomic, readwrite, copy) NSColor* color;
@property (nonatomic, readwrite, copy) NSString* content;

- (id) initWithFrame: (CGRect) aFrame
                text: (NSString*) aText
             bgColor: (NSColor*) aBgColor
              parent: (DTViewsInfoViewController*) aParent;

- (void) setBackgroundColor: (NSColor*) aColor;
- (BOOL) isEqualColor: (NSColor*) aColor;
- (void) select;

@end

@interface DTLabel : NSTextField
{
    DTViewsDataInfoView* parent;
}

- (id) initWithFrame: (CGRect) aFrame
                text: (NSString*) aText
              parent: (DTViewsDataInfoView*) aParent;

@end
