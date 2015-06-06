//
//  DTViewsDataInfoView.m
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import "DTViewsDataInfoView.h"
#import "DTViewsInfoViewController.h"
#import "DTConstants.h"

@implementation DTViewsDataInfoView

@synthesize color;
@synthesize content;

- (id) initWithFrame: (CGRect) aFrame
                text: (NSString*) aText
             bgColor: (NSColor*) aBgColor
              parent: (DTViewsInfoViewController*) aParent
{
    if ((self = [super initWithFrame: aFrame]))
    {
        parent = [aParent retain];

        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(mouseMoving:)
                                                     name: MouseMoveEventsNotificationId
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(mouseUp:)
                                                     name: MouseUpEventsNotificationId
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(moveToOrigFrame:)
                                                     name: MoveViewsFrameToHomeNotificationId
                                                   object: nil];
        
        [self setBackgroundColor: aBgColor];

        if ([aText length] > 0)
        {
            CGRect labelFrame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(aFrame), CGRectGetHeight(aFrame));
            DTLabel* text = [[DTLabel alloc] initWithFrame: labelFrame
                                                      text: aText
                                                    parent: self];
            text.backgroundColor = aBgColor;
            [self addSubview: text];
            [text release];
        }

        frameOrig = aFrame;
    }
    
    return self;
}

- (void) drawRect: (NSRect) rect
{
    [color set];
    NSRectFill([self bounds]);
}

- (void) setBackgroundColor: (NSColor*) aColor
{
    self.color = aColor;
    [self setNeedsDisplay: YES];
}

- (BOOL) isEqualColor: (NSColor*) aColor
{
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;
    CGFloat red2;
    CGFloat green2;
    CGFloat blue2;
    CGFloat alpha2;

    [color getRed: &red
            green: &green
             blue: &blue
            alpha: &alpha];
    [aColor getRed: &red2
             green: &green2
              blue: &blue2
             alpha: &alpha2];

    return (red == red2) && (green == green2) && (blue == blue2) && (alpha == alpha2);
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: MouseMoveEventsNotificationId
                                                  object: nil];
    
	[[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: MouseUpEventsNotificationId
                                                  object: nil];
    
	[[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: MoveViewsFrameToHomeNotificationId
                                                  object: nil];
    
    [color release];
    color = nil;
    [content release];
    content = nil;
    [parent release];
    parent = nil;
    
    [super dealloc];
}

- (void) select
{
    NSColor* tempColor = tempColor = [color copy];
    
    for (int i = 0; i < 5; i++)
    {
        [self setBackgroundColor: [NSColor yellowColor]];
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, .05, false);
        [self setBackgroundColor: [NSColor blueColor]];
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, .05, false);
    }
    [self setBackgroundColor: tempColor];
    [tempColor release];
}

- (void) moveToOrigFrame: (NSNotification *) notification
{
    self.frame = frameOrig;
}

#pragma mark Mouse handle activity

- (void) mouseDown: (NSEvent*) theEvent
{
    
    NSPoint mousePointInWindow = [theEvent locationInWindow];
    NSPoint mousePointInView  = [self convertPoint: mousePointInWindow
                                          fromView: nil];
    
    NSLog(@"%@", NSStringFromPoint(mousePointInView));
    
    [parent selectContent: content];
    isMoving = YES;
    lastPoint.x = -1.0f;
    lastPoint.y = -1.0f;
}

- (void) mouseMoving: (NSNotification*) notification
{
    if (isMoving)
    {
        NSPoint newPoint = NSPointFromString([notification object]);
        
        if (lastPoint.x == -1.0f && lastPoint.y == -1.0f)
        {
            lastPoint = newPoint;
        }
        
        CGFloat dX = newPoint.x - lastPoint.x;
        CGFloat dY = newPoint.y - lastPoint.y;

        lastPoint = newPoint;
        
        if (ABS(dX) > 1.0f || ABS(dY) > 1.0f)
        {
            self.frame = CGRectMake(self.frame.origin.x + dX, self.frame.origin.y + dY, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        }
    }
}

- (void) mouseUp: (NSNotification *) notification
{
    isMoving = NO;
}

@end

#pragma mark DTLabel

@implementation DTLabel

- (id) initWithFrame: (CGRect) aFrame
                text: (NSString*) aText
              parent: (DTViewsDataInfoView*) aParent
{
    if ((self = [super initWithFrame: aFrame]))
    {
        parent = aParent;
        [self setStringValue: aText];
        [self setBackgroundColor: [NSColor clearColor]];
        [self setTextColor: [NSColor blackColor]];
    }
    
    return self;    
}

- (void) mouseDown: (NSEvent*) theEvent
{
    [parent mouseDown: theEvent];
}

@end
