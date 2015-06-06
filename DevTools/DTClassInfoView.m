//
//  DTClassInfoView.m
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import "DTClassInfoView.h"
#import "DTRuntimeBrowserViewController.h"
#import "DTClassesShemeView.h"
#import "DTConstants.h"

const CGFloat LineOfFrameWidth = 4.0f;
const CGFloat HorizontalLabelsSpace = 25.0f;
const CGFloat VerticalLabelsSpace = 10.0f;

@interface DTClassInfoView()
- (void) drawLineFromPoint: (CGPoint) aP1 toPoint: (CGPoint) aP2;
- (void) selectAnimation;
@end

@implementation DTClassInfoView

@synthesize color;
@synthesize lineColor;
@synthesize content;
@synthesize className;
@synthesize parentClassName;

+ (void) drawFrameOnDTClassInfoView: (DTClassInfoView*) aViewInfo withColor: (NSColor*) aLineColor
{
    aViewInfo.lineColor = aLineColor;
}

+ (NSColor*) lineOfSelectedClassColor
{
    return [NSColor redColor];
}

+ (void) selectClassInfo: (DTClassInfoView*) aDTClassInfoView
{
    [aDTClassInfoView show];
    
    [DTClassInfoView drawFrameOnDTClassInfoView: aDTClassInfoView
                                  withColor: [DTClassInfoView lineOfSelectedClassColor]];
}

+ (void) unSelectClassInfo: (DTClassInfoView*) aDTClassInfoView
{
    [DTClassInfoView drawFrameOnDTClassInfoView: aDTClassInfoView
                                  withColor: aDTClassInfoView.color];
}

#pragma mark Init

- (id) initWithFrame: (CGRect) aFrame
           className: (NSString*) aClassName
     parentClassName: (NSString*) aParentClassName
              parent: (DTRuntimeBrowserViewController*) aParent
             bgColor: (NSColor*) aBgColor
{
    if ((self = [super init]))
    {
        parent = [aParent retain];
        className = [aClassName copy];
        parentClassName = [aParentClassName copy];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(moveToOrigFrame:)
                                                     name: MoveDTClassInfoViewFrameToHomeNotificationId
                                                   object: nil];
        
        if (([aClassName length] > 0) && self.isFlexibleFrame)
        {
            NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys: [NSFont fontWithName: @"Helvetica"
                                                                                                   size: 12], NSFontAttributeName, nil];
            NSAttributedString* text = [[NSAttributedString alloc] initWithString: aClassName
                                                                       attributes: attributes];
            NSSize textSize = [text size];
            CGFloat labelWidth = textSize.width + HorizontalLabelsSpace;
            CGFloat labelHeight = textSize.height + VerticalLabelsSpace;
            
            CGRect labelFrame = CGRectMake(LineOfFrameWidth, LineOfFrameWidth, labelWidth, labelHeight);

            frameOrig = CGRectMake(CGRectGetMinX(aFrame) - LineOfFrameWidth,
                                   CGRectGetMinY(aFrame) + LineOfFrameWidth,
                                   labelWidth + 2 * LineOfFrameWidth,
                                   labelHeight + 2 * LineOfFrameWidth);

            self.frame = frameOrig;
            self.backgroundColor = aBgColor;
            
            NSTextField* textLabel = [[NSTextField alloc] initWithFrame: labelFrame];
            [textLabel setStringValue: aClassName];
            [textLabel setAlignment: NSCenterTextAlignment];
            [textLabel setBackgroundColor: aBgColor];
            [textLabel setTextColor: [NSColor blackColor]];
            [textLabel setEditable: NO];
            [self addSubview: textLabel];
            [textLabel release];
            
        }
        else
        {
            frameOrig = CGRectMake(CGRectGetMinX(aFrame) - LineOfFrameWidth,
                                   CGRectGetMinY(aFrame) + LineOfFrameWidth,
                                   CGRectGetWidth(aFrame) + 2 * LineOfFrameWidth,
                                   CGRectGetHeight(aFrame) + 2 * LineOfFrameWidth);
            
            self.frame = frameOrig;
        }
    }
    
    return self;
}

- (void) setLineColor: (NSColor*) aLineColor
{
    if (aLineColor != lineColor)
    {
        [lineColor release];
        lineColor = [aLineColor copy];
        [self setNeedsDisplay: YES];
    }
}

- (void) drawLineFromPoint: (CGPoint) aP1 toPoint: (CGPoint) aP2
{
    NSBezierPath* line = [NSBezierPath bezierPath];
    [line moveToPoint: aP1];
    [line lineToPoint: aP2];
    [line setLineWidth: LineOfFrameWidth];
    [lineColor set];
    [line stroke];
}

- (void) drawRect: (NSRect) dirtyRect
{
    [color set];
    NSRectFill([self bounds]);
    
    if (lineColor == nil)
    {
        return;
    }

// This is not work. Where is mistake?
//#import <QuartzCore/QuartzCore.h>
//    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
//    CGContextSaveGState(context);
//    
//    CGContextSetLineWidth(context, LineOfFrameWidth);
//    
//    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
//    CGContextSetFillColorWithColor(context, lineColor.CGColor);
//    
//    CGContextAddRect(context, self.bounds);
//    CGContextDrawPath(context, kCGPathFillStroke);
//    
//    CGContextStrokePath(context);
//    CGContextRestoreGState(context);
    
    
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    CGFloat w = CGRectGetWidth(self.frame);
    CGFloat h = CGRectGetHeight(self.frame);

    CGPoint p1 = CGPointMake(x, y);
    CGPoint p2 = CGPointMake(x + w, y);
    [self drawLineFromPoint: p1 toPoint: p2];

    p1 = CGPointMake(x + w, y);
    p2 = CGPointMake(x + w, y + h);
    [self drawLineFromPoint: p1 toPoint: p2];

    p1 = CGPointMake(x + w, y + h);
    p2 = CGPointMake(x, y + h);
    [self drawLineFromPoint: p1 toPoint: p2];
    
    p1 = CGPointMake(x, y + h);
    p2 = CGPointMake(x, y);
    [self drawLineFromPoint: p1 toPoint: p2];
}

- (CGFloat) width
{
    return CGRectGetWidth(self.frame);
}

- (void) setBackgroundColor: (NSColor*) aColor
{
    self.color = aColor;
    [self setNeedsDisplay: YES];
}

- (BOOL) isFlexibleFrame
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey: IsFlexibleFrameOfDTClassInfoViewUserDefaultId])
    {
        return [[defaults objectForKey: IsFlexibleFrameOfDTClassInfoViewUserDefaultId] boolValue];
    }
    
    return YES;
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
                                                    name: MoveDTClassInfoViewFrameToHomeNotificationId
                                                  object: nil];
    
    [color release];
    color = nil;
    [content release];
    content = nil;
    [parent release];
    parent = nil;
    [parentClassName release];
    parentClassName = nil;
    [className release];
    className = nil;
    
    [super dealloc];
}

- (void) selectAnimation
{
    NSColor* tmpColor = [color copy];
    
    for (int i = 0; i < 5; i++)
    {
        [self setBackgroundColor: [NSColor yellowColor]];
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.05, false);
        [self setBackgroundColor: [NSColor blueColor]];
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.05, false);
    }
    [self setBackgroundColor: tmpColor];
    [tmpColor release];
}

- (void) moveToOrigFrame: (NSNotification *) notification
{
    [self show];
}

- (void) show
{
    self.frame = frameOrig;
}

- (void) hide
{
    self.frame = CGRectZero;
}

- (BOOL) isNotHide
{
    return (CGRectGetWidth(self.frame) > 0.0f);
}

- (BOOL) isNotSelected
{
    return ([color isEqualTo: lineColor] || lineColor == nil);
}

- (void) movetoPoint: (CGPoint) aPoint
{
    self.frame = CGRectMake(aPoint.x, aPoint.y, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
}

#pragma mark Touches handle

- (void) mouseDown: (NSEvent*) theEvent
{
    if ([self isNotSelected])
    {
        [parent selectDTClassInfoView: self];
    }

    [parent mouseDownOnDTClassInfoView: self];
    
    isMoving = YES;
    lastPoint.x = -1.0f;
    lastPoint.y = -1.0f;
}

- (void) mouseDragged: (NSEvent*) theEvent
{
    if (isMoving)
    {
        NSPoint mousePointInWindow = [theEvent locationInWindow];
        NSPoint newPoint  = [self convertPoint: mousePointInWindow
                                      fromView: self];
        
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
        
        [self.superview setNeedsDisplay: YES];
    }
}

- (void) mouseUp: (NSEvent*) theEvent
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:
     ^{
         [self selectAnimation];
         
         [self setNeedsDisplay: YES];
     }];
    
    isMoving = NO;
}

#pragma mark -

@end
