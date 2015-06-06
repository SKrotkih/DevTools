//
//  DTClassesShemeView.m
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import "DTClassesShemeView.h"
#import "DTClassInfoView.h"

const CGFloat LengthOfSidePoint = 15.0f;
const CGFloat AngleOfPoint = 0.5f;
const CGFloat LineWidthByDefault = 3.0f;

@interface DTClassesShemeView()

- (void) drawDirectFrom: (CGPoint) point1
                     to: (CGPoint) point2
              withColor: (NSColor*) aColor;

- (void) drawLineFrom: (CGPoint) point1
              toPoint: (CGPoint) point2
            withColor: (NSColor*) aColor;
@end

@implementation DTClassesShemeView

@synthesize inheritLineColor;
@synthesize dependencyLineColor;
@synthesize lineWidth;

- (void) dealloc
{
    [pointsInheritLine release];
    pointsInheritLine = nil;
    [pointsDependencyLine release];
    pointsDependencyLine = nil;
    
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
    [pointsInheritLine removeAllObjects];
    [pointsDependencyLine removeAllObjects];
}

#pragma mark Properties

- (NSColor*) inheritLineColor
{
    if (inheritLineColor)
    {
        return inheritLineColor;
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
    if (aColor != inheritLineColor)
    {
        [inheritLineColor release];
        inheritLineColor = [aColor copy];
        [self setNeedsDisplay: YES];
    }
}

- (void) setLineWidth: (CGFloat) aLineWidth
{
    lineWidth = aLineWidth;
}

- (CGFloat) lineWidth
{
    return (lineWidth <= 0.0 ? LineWidthByDefault : lineWidth);
}

#pragma mark

- (void) drawRect: (NSRect) dirtyRect
{
    NSUInteger index = 0;
    
    while (index < [pointsInheritLine count])
    {
        DTClassInfoView* viewInfo1 = [pointsInheritLine objectAtIndex: index];
        DTClassInfoView* viewInfo2 = [pointsInheritLine objectAtIndex: index + 1];

        CGPoint point1 = CGPointMake(CGRectGetMidX(viewInfo1.frame), CGRectGetMinY(viewInfo1.frame));
        CGPoint point2 = CGPointMake(CGRectGetMidX(viewInfo2.frame), CGRectGetMaxY(viewInfo2.frame));
        
        [self drawLineFrom: point1
                   toPoint: point2
                 withColor: self.inheritLineColor];
        
        [self drawDirectFrom: point1
                          to: point2
                   withColor: self.inheritLineColor];
        
        index += 2;
    }
    
    index = 0;
    
    while (index < [pointsDependencyLine count])
    {

        // CFXPreferencesPropertyListSource
        
        DTClassInfoView* srcDTClassInfoView = [pointsDependencyLine objectAtIndex: index + 1];
        DTClassInfoView* dstDTClassInfoView = [pointsDependencyLine objectAtIndex: index];
        
        CGFloat srcX = (CGRectGetMaxX(dstDTClassInfoView.frame) <= CGRectGetMaxX(srcDTClassInfoView.frame)) ? CGRectGetMinX(srcDTClassInfoView.frame) : CGRectGetMaxX(srcDTClassInfoView.frame);
        CGFloat srcY = CGRectGetMidY(srcDTClassInfoView.frame);
        
        CGFloat dstX = (CGRectGetMaxX(srcDTClassInfoView.frame) <= CGRectGetMaxX(dstDTClassInfoView.frame)) ? CGRectGetMinX(dstDTClassInfoView.frame) : CGRectGetMaxX(dstDTClassInfoView.frame);
        CGFloat dstY = CGRectGetMidY(dstDTClassInfoView.frame);

        CGPoint srcPoint = CGPointMake(srcX, srcY);
        CGPoint dstPoint = CGPointMake(dstX, dstY);
        
        [self drawLineFrom: dstPoint
                   toPoint: srcPoint
                 withColor: self.dependencyLineColor];
        
        [self drawDirectFrom: dstPoint
                          to: srcPoint
                   withColor: self.dependencyLineColor];
        
        index += 2;
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
    
    CGFloat angle1 = alpha + (pi - AngleOfPoint);
    CGFloat angle2 = alpha - (pi - AngleOfPoint);
    
    CGPoint point3 = CGPointMake(p2x + LengthOfSidePoint * cos(angle1), p2y + LengthOfSidePoint * sin(angle1));
    CGPoint point4 = CGPointMake(p2x + LengthOfSidePoint * cos(angle2), p2y + LengthOfSidePoint * sin(angle2));
    
    [self drawLineFrom: point1
               toPoint: point3
             withColor: aColor];
    
    [self drawLineFrom: point1
               toPoint: point4
             withColor: aColor];
}

- (void) drawInheritLineBetween: (DTClassInfoView*) viewInfo1
                            and: (DTClassInfoView*) viewInfo2
{
    if (pointsInheritLine == nil)
    {
        pointsInheritLine = [[NSMutableArray alloc] init];
    }
    
    [pointsInheritLine addObject: viewInfo1];
    [pointsInheritLine addObject: viewInfo2];
}

- (void) drawDependenciesLineBetween: (DTClassInfoView*) viewInfo1
                                 and: (DTClassInfoView*) viewInfo2
{
    if (pointsDependencyLine == nil)
    {
        pointsDependencyLine = [[NSMutableArray alloc] init];
    }
    
    [pointsDependencyLine addObject: viewInfo1];
    [pointsDependencyLine addObject: viewInfo2];
}

@end
