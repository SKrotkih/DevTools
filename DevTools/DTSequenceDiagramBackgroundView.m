//
//  DTSequenceDiagramBackgroundView.m
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import "DTSequenceDiagramBackgroundView.h"
#import "DTClassInfoView.h"

const CGFloat SDLengthOfSidePoint = 15.0f;
const CGFloat SDAngleOfPoint = 0.5f;
const CGFloat SDLineWidthByDefault = 3.0f;

@interface DTSequenceDiagramBackgroundView()

- (void) drawDirectFrom: (CGPoint) point1
                     to: (CGPoint) point2
              withColor: (NSColor*) aColor;

- (void) drawLineFrom: (CGPoint) point1
              toPoint: (CGPoint) point2
            withColor: (NSColor*) aColor;
@end

@implementation DTSequenceDiagramBackgroundView

@synthesize timeLineColor;
@synthesize dependencyLineColor;
@synthesize lineWidth;

- (void) dealloc
{
    [pointsTimeLine release];
    pointsTimeLine = nil;
    [sequenceLines release];
    sequenceLines = nil;
    [methodLines release];
    methodLines = nil;
    
    [super dealloc];
}

- (void) redrawAllLinesOfColor: (NSColor*) aColor
{
    if (aColor != color)
    {
        [color release];
        color = [aColor copy];
    }
    redrawBackground = YES;
    [self setNeedsDisplay: YES];
}

- (void) removeAllObjects
{
    redrawBackground = NO;
    [pointsTimeLine removeAllObjects];
    [sequenceLines removeAllObjects];
    [methodLines removeAllObjects];
}

#pragma mark Properties

- (NSColor*) timeLineColor
{
    if (timeLineColor)
    {
        return timeLineColor;
    }
    
    return [NSColor blackColor];
}

- (NSColor*) dependencyLineColor
{
    if (dependencyLineColor)
    {
        return dependencyLineColor;
    }

    return [NSColor redColor];
}

- (void) setDependencyLineColor: (NSColor*) aColor
{
    if (aColor != dependencyLineColor)
    {
        [dependencyLineColor release];
        dependencyLineColor = [aColor copy];
        [self setNeedsDisplay: YES];
    }
}

- (void) setInheritLineColor: (NSColor*) aColor
{
    if (aColor != timeLineColor)
    {
        [timeLineColor release];
        timeLineColor = [aColor copy];
        [self setNeedsDisplay: YES];
    }
}

- (void) setLineWidth: (CGFloat) aLineWidth
{
    lineWidth = aLineWidth;
}

- (CGFloat) lineWidth
{
    return (lineWidth <= 0.0 ? SDLineWidthByDefault : lineWidth);
}

#pragma mark

- (void) drawRect: (NSRect) dirtyRect
{
    for (NSDictionary* dict in pointsTimeLine)
    {
        CGPoint point1 = CGPointMake([(NSNumber*)[dict objectForKey: @"x"] floatValue], [(NSNumber*)[dict objectForKey: @"minY"] floatValue]);
        CGPoint point2 = CGPointMake([(NSNumber*)[dict objectForKey: @"x"] floatValue], [(NSNumber*)[dict objectForKey: @"y"] floatValue]);
        [self drawLineFrom: point1
                   toPoint: point2
                 withColor: self.timeLineColor];
    }

    for (NSDictionary* dict in sequenceLines)
    {
        CGPoint point1 = CGPointMake([(NSNumber*)[dict objectForKey: @"x1"] floatValue], [(NSNumber*)[dict objectForKey: @"y1"] floatValue]);
        CGPoint point2 = CGPointMake([(NSNumber*)[dict objectForKey: @"x2"] floatValue], [(NSNumber*)[dict objectForKey: @"y2"] floatValue]);
        
        [self drawLineFrom: point1
                   toPoint: point2
                 withColor: self.timeLineColor];

        [self drawDirectFrom: point2
                          to: point1
                   withColor: self.timeLineColor];
        
    }
    
    for (NSDictionary* dict in methodLines)
    {
        CGPoint point1 = CGPointMake([(NSNumber*)[dict objectForKey: @"x1"] floatValue], [(NSNumber*)[dict objectForKey: @"y1"] floatValue]);
        CGPoint point2 = CGPointMake([(NSNumber*)[dict objectForKey: @"x2"] floatValue], [(NSNumber*)[dict objectForKey: @"y2"] floatValue]);
        
        [self drawLineFrom: point1
                   toPoint: point2
                 withColor: self.timeLineColor];
    }
}

- (void) drawLineFrom: (CGPoint) point1
              toPoint: (CGPoint) point2
            withColor: (NSColor*) aColor
{
    NSBezierPath* line = [NSBezierPath bezierPath];
    
    [line moveToPoint: point1];
    [line lineToPoint: point2];
    [line setLineWidth: self.lineWidth];
    
    [aColor set];
    [line stroke];
}

- (void) drawDirectFrom: (CGPoint) point1
                     to: (CGPoint) point2
              withColor: (NSColor*) aColor
{
    CGFloat p1x = point2.x;
    CGFloat p1y = point2.y;
    CGFloat p2x = point1.x;
    CGFloat p2y = point1.y;
    
    CGFloat alpha = (p2y < p1y ? -1.0f : 1.0f) * pi / 2.0f;
    
    if (fabs(p2x - p1x) > 0.00001)
    {
        alpha = atan2((p2y - p1y), (p2x - p1x));
    }
    
    CGFloat angle1 = alpha + (pi - SDAngleOfPoint);
    CGFloat angle2 = alpha - (pi - SDAngleOfPoint);
    
    CGPoint point3 = CGPointMake(p2x + SDLengthOfSidePoint * cos(angle1), p2y + SDLengthOfSidePoint * sin(angle1));
    CGPoint point4 = CGPointMake(p2x + SDLengthOfSidePoint * cos(angle2), p2y + SDLengthOfSidePoint * sin(angle2));
    
    [self drawLineFrom: point1
               toPoint: point3
             withColor: aColor];
    
    [self drawLineFrom: point1
               toPoint: point4
             withColor: aColor];
}

- (void) drawTimeLineBetween: (CGPoint) point1
                    andPoint: (CGPoint) point2
{
    if (pointsTimeLine == nil)
    {
        pointsTimeLine = [[NSMutableArray alloc] init];
    }
    
    BOOL needAddNewValue = YES;

    for (NSDictionary* dict in pointsTimeLine)
    {
        if ([(NSNumber*)[dict objectForKey: @"x"] floatValue] == point1.x)
        {
            [dict setValue: [NSNumber numberWithFloat: point2.y] forKey: @"y"];
            needAddNewValue = NO;
        }
    }

    if (needAddNewValue)
    {
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                              [NSNumber numberWithFloat: point1.x], @"x",
                              [NSNumber numberWithFloat: point2.y], @"y",
                              [NSNumber numberWithFloat: point1.y], @"minY",
                              nil];
        [pointsTimeLine addObject: dict];
        [dict release];
    }
}

- (void) drawSequenceLineBetween: (CGPoint) point1
                        andPoint: (CGPoint) point2
{
    if (sequenceLines == nil)
    {
        sequenceLines = [[NSMutableArray alloc] init];
    }

    NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          [NSNumber numberWithFloat: point1.x], @"x1",
                          [NSNumber numberWithFloat: point1.y], @"y1",
                          [NSNumber numberWithFloat: point2.x], @"x2",
                          [NSNumber numberWithFloat: point2.y], @"y2",
                          nil];
    [sequenceLines addObject: dict];
    [dict release];
}

- (void) drawMethodLineInPoint: (CGPoint) aPoint
{
    if (methodLines == nil)
    {
        methodLines = [[NSMutableArray alloc] init];
    }

    CGPoint point1 = aPoint;
    point1.x = point1.x - 5.0f;
    CGPoint point2 = aPoint;
    
    NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          [NSNumber numberWithFloat: point1.x], @"x1",
                          [NSNumber numberWithFloat: point1.y], @"y1",
                          [NSNumber numberWithFloat: point2.x], @"x2",
                          [NSNumber numberWithFloat: point2.y], @"y2",
                          nil];
    [methodLines addObject: dict];
    [dict release];
}

@end
