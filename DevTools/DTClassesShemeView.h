//
//  DTClassesShemeView.h
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DTClassInfoView;

@interface DTClassesShemeView : NSView
{
@private
    NSColor* color;
    NSColor* inheritLineColor;
    NSColor* dependencyLineColor;
    NSMutableArray* pointsInheritLine;
    NSMutableArray* pointsDependencyLine;
    CGFloat lineWidth;
    BOOL redrawBackground;
}

@property (nonatomic, readwrite, assign) NSColor* inheritLineColor;
@property (nonatomic, readwrite, assign) NSColor* dependencyLineColor;
@property (nonatomic, readwrite, assign) CGFloat lineWidth;

- (void) drawInheritLineBetween: (DTClassInfoView*) viewInfo1
                            and: (DTClassInfoView*) viewInfo2;

- (void) drawDependenciesLineBetween: (DTClassInfoView*) viewInfo1
                                 and: (DTClassInfoView*) viewInfo2;

- (void) redrawAllLinesOfColor: (NSColor*) aColor;
- (void) removeAllObjects;

@end

