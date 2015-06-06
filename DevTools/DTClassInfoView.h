//
//  DTClassInfoView.h
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DTRuntimeBrowserViewController;
@class DTClassesShemeView;
@class ClassInfoLabel;

@interface DTClassInfoView : NSView
{
@private
    NSColor* color;
    NSColor* lineColor;
    NSString* content;
    NSString* parentClassName;
    NSString* className;
    DTRuntimeBrowserViewController* parent;
    BOOL isMoving;
    CGPoint lastPoint;
    CGRect frameOrig;
}

@property (nonatomic, readwrite, copy) NSColor* color;
@property (nonatomic, readwrite, copy) NSString* content;
@property (nonatomic, readonly, assign) NSString* className;
@property (nonatomic, readonly, assign) NSString* parentClassName;
@property (nonatomic, readonly, assign) BOOL isFlexibleFrame;
@property (nonatomic, readwrite, assign) NSColor* lineColor;

+ (void) drawFrameOnDTClassInfoView: (DTClassInfoView*) aViewInfo
                   withColor: (NSColor*) aLineColor;

+ (void) selectClassInfo: (DTClassInfoView*) aDTClassInfoView;

+ (void) unSelectClassInfo: (DTClassInfoView*) aDTClassInfoView;

- (id) initWithFrame: (CGRect) aFrame
           className: (NSString*) aClassName
     parentClassName: (NSString*) aParentClassName
              parent: (DTRuntimeBrowserViewController*) aParent
             bgColor: (NSColor*) aBgColor;

- (void) setBackgroundColor: (NSColor*) aColor;
- (BOOL) isEqualColor: (NSColor*) aColor;
- (CGFloat) width;
- (void) hide;
- (void) show;
- (BOOL) isNotHide;
- (BOOL) isNotSelected;
- (void) movetoPoint: (CGPoint) aPoint;

@end
