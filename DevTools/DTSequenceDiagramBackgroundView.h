//
//  DTSequenceDiagramBackgroundView.h
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DTClassInfoView;

@interface DTSequenceDiagramBackgroundView : NSView
{
@private
    NSColor* color;
    NSColor* timeLineColor;
    NSColor* dependencyLineColor;
    NSMutableArray* pointsTimeLine;
    NSMutableArray* sequenceLines;
    NSMutableArray* methodLines;
    CGFloat lineWidth;
    BOOL redrawBackground;
}

@property (nonatomic, readwrite, assign) NSColor* timeLineColor;
@property (nonatomic, readwrite, assign) NSColor* dependencyLineColor;
@property (nonatomic, readwrite, assign) CGFloat lineWidth;

- (void) drawTimeLineBetween: (CGPoint) point1
                    andPoint: (CGPoint) point2;

- (void) drawSequenceLineBetween: (CGPoint) point1
                        andPoint: (CGPoint) point2;

- (void) drawMethodLineInPoint: (CGPoint) point;

- (void) redrawAllLinesOfColor: (NSColor*) aColor;
- (void) removeAllObjects;

@end

