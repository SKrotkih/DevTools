//
//  DTSequenceDiagramClassView.m
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import "DTSequenceDiagramClassView.h"
#import "DTSequenceDiagramViewController.h"
#import "DTConstants.h"

@implementation DTSequenceDiagramClassView

@synthesize color;
@synthesize className;

- (id) initWithFrame: (CGRect) aFrame
                text: (NSString*) aText
             bgColor: (NSColor*) aBgColor
{
    if ((self = [super initWithFrame: aFrame]))
    {
        [self setBackgroundColor: aBgColor];
        self.className = aText;

        if ([aText length] > 0)
        {
            CGFloat width = [aText sizeWithAttributes: [NSDictionary dictionaryWithObject: [NSFont systemFontOfSize: 14.0f] forKey: NSFontAttributeName]].width;
            aFrame.size.width = width;
            self.frame = aFrame;
            
            CGRect labelFrame = CGRectMake(0.0f, 0.0f, width, CGRectGetHeight(aFrame));
            DTClassNameLabel* text = [[DTClassNameLabel alloc] initWithFrame: labelFrame
                                                                        text: aText];
            text.backgroundColor = aBgColor;
            [self addSubview: text];
            [text release];
        }
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

- (void) dealloc
{
    [color release];
    color = nil;
    [className release];
    className = nil;
    [parent release];
    parent = nil;
    
    [super dealloc];
}

- (CGFloat) middleX
{
    return roundf(CGRectGetMidX(self.frame));
}

@end

#pragma mark DTLabel

@implementation DTClassNameLabel

- (id) initWithFrame: (CGRect) aFrame
                text: (NSString*) aText
{
    if ((self = [super initWithFrame: aFrame]))
    {
        [self setStringValue: aText];
        [self setEditable: NO];
        [self setBackgroundColor: [NSColor clearColor]];
        [self setTextColor: [NSColor blackColor]];
    }
    
    return self;    
}

@end
