//
//  DTTransparentView.m
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import "DTTransparentView.h"
#import "DTConstants.h"

const CGFloat LineWidth = 3.0f;
const CGFloat RedComponent = 1.0f;       // red line
const CGFloat GreenComponent = 0.0f;
const CGFloat BlueComponent = 0.0f;
const CGFloat AphaComponent = 1.0f;

@implementation DTTransparentView

- (void) drawRect: (NSRect) rect
{
    if (CGRectGetHeight(_rect) == 0.0f && CGRectGetWidth(_rect) == 0.0f)
    {
        return;
    }
    
    NSGraphicsContext* nsGraphicsContext = [NSGraphicsContext currentContext];
    CGContextRef context = (CGContextRef) [nsGraphicsContext graphicsPort];
    
    CGContextSetRGBStrokeColor(context, RedComponent, GreenComponent, BlueComponent, AphaComponent);
    
    CGContextBeginPath(context);
    
    CGFloat x = CGRectGetMinX(_rect);
    CGFloat y = CGRectGetMinY(_rect);
    CGFloat w = CGRectGetWidth(_rect);
    CGFloat h = CGRectGetHeight(_rect);
    
    CGContextMoveToPoint(context, x, y);
    CGContextAddLineToPoint(context, x + w, y);
    CGContextAddLineToPoint(context, x + w, y + h);
    CGContextAddLineToPoint(context, x, y + h);
    
    CGContextSetLineWidth(context, LineWidth); // this is set from now on until you explicitly change it
    CGContextClosePath(context);         // close path
    CGContextStrokePath(context);        // do actual stroking
}

- (void) drawBorderForRect: (NSRect*) aRect
{
    NSView* superView = [self superview];
    [superView addSubview: self];
    
    _rect = *aRect;
    
    [self setNeedsDisplay: YES];
}

- (void) mouseDragged: (NSEvent*) theEvent
{
    NSPoint mousePointInWindow = [theEvent locationInWindow];
    NSPoint mousePointInView  = [self convertPoint: mousePointInWindow
                                          fromView: nil];

	NSString* strReceivedData = NSStringFromPoint(mousePointInView);
    [[NSNotificationCenter defaultCenter] postNotificationName: MouseMoveEventsNotificationId
                                                        object: strReceivedData];
}

- (void) mouseUp: (NSEvent*) theEvent
{
    [[NSNotificationCenter defaultCenter] postNotificationName: MouseUpEventsNotificationId
                                                        object: nil];
}

@end
