//
//  DTSequenceDiagramViewController.m
//  DevTools
//
//  Created by Sergey Krotkih on 05/12/13.
//  Copyright (c) 2013 Doctormobile. All rights reserved.
//

#import "DTSequenceDiagramViewController.h"
#import "DTConstants.h"
#import "DTFileOperations.h"
#import "DTClientController.h"
#import "DTSequenceDiagramClassView.h"

const CGFloat BordersLeftMargin = 20.0f;
const CGFloat BordersUpMargin = 10.0f;
const CGFloat ClassViewHeight = 25.0f;
const CGFloat StepByY = 25.0f;
const CGFloat Angle = 0.5f;
const CGFloat LengthSidePoint = 15.0f;

@interface DTSequenceDiagramViewController()
- (void) drawClassItemName: (NSString*) aClassName
                methodName: (NSString*) aMethodName
           isClassInstance: (BOOL) aIsClassInstance;
- (BOOL) parseOfTracingString: (NSString*) aTracingStrng
              isClassInstance: (BOOL*) aIsClassInstance
                    className: (NSString**) outClassName
                   methodName: (NSString**) outMethodName;
@end

@implementation DTSequenceDiagramViewController
{
}

@synthesize currentClassView;

- (void) dealloc
{
    [arrayViewsInfo release];
    arrayViewsInfo = nil;
    
    [super dealloc];
}

- (void) viewWillLoad
{

}

- (CGFloat) parentViewHeight
{
    return CGRectGetHeight(contentView.frame);
}

- (void) viewDidLoad
{
    if ([contentScrollView hasVerticalScroller])
    {
        contentScrollView.verticalScroller.floatValue = 0;
    }
    [classesNameScrollView setSynchronizedScrollView: contentScrollView];
    
    [contentScrollView.contentView scrollToPoint: NSMakePoint(0, ((NSView*)contentScrollView.documentView).frame.size.height - contentScrollView.contentSize.height)];
}

- (void) loadView
{
    [self viewWillLoad];
    [super loadView];
    [self viewDidLoad];
}

- (void) initDiagramm
{
    if (arrayViewsInfo)
    {
        for (DTSequenceDiagramClassView* viewInfo in arrayViewsInfo)
        {
            [viewInfo removeFromSuperview];
        }
        
        [arrayViewsInfo removeAllObjects];
    }
    
    NSArray* arrSubviews = [[contentView subviews] copy];

    for (NSView* view in arrSubviews)
    {
        [view removeFromSuperview];
    }
    [arrSubviews release];
    
    [contentView removeAllObjects];
    self.currentClassView = nil;
    self.beginOfreviousString = nil;

    currentY = [self parentViewHeight] - BordersUpMargin;

    [contentView setLineWidth: 2.0f];
    contentView.timeLineColor = [NSColor blueColor];

    [[NSOperationQueue mainQueue] addOperationWithBlock:
     ^{
         [contentView setNeedsDisplay: YES];
     }];
}

- (void) parseOfTricingData: (NSString*) aData
{
    NSLog(@"%@", aData);
    
    NSArray* arrTrace = [aData componentsSeparatedByString: @"\n"];
    
    if ([arrTrace count] == 0)
    {
        return;
    }
    
    for (NSString* currTraceString in arrTrace)
    {
        NSString* className;
        NSString* methodName;
        BOOL isClassInstance;
    
        if ([currTraceString length] == 0)
        {
            continue;
        }
        else if ([self parseOfTracingString: currTraceString
                            isClassInstance: &isClassInstance
                                  className: &className
                                 methodName: &methodName])
        {
            [self drawClassItemName: className
                         methodName: methodName
                    isClassInstance: isClassInstance];
        }
        else if ([[currTraceString substringWithRange: NSMakeRange(0, 1)] isEqualToString: @"-"] || [[currTraceString substringWithRange: NSMakeRange(0, 1)] isEqualToString: @"+"])
        {
            self.beginOfreviousString = currTraceString;
        }
        else
        {
            currTraceString = [NSString stringWithFormat: @"%@%@", beginOfreviousString, currTraceString];

            if ([self parseOfTracingString: currTraceString
                           isClassInstance: &isClassInstance
                                 className: &className
                                methodName: &methodName])
            {
                [self drawClassItemName: className
                             methodName: methodName
                        isClassInstance: isClassInstance];
            }
        }
    }
}

- (BOOL) parseOfTracingString: (NSString*) aTracingStrng
              isClassInstance: (BOOL*) aIsClassInstance
                    className: (NSString**) outClassName
                   methodName: (NSString**) outMethodName
{
    NSRange range1 = {0, 1};
    NSString* firstSymb = [aTracingStrng substringWithRange: range1];

    if (([firstSymb isEqualToString: @"-"] || [firstSymb isEqualToString: @"+"]) && [aTracingStrng length] > 1)
    {
        NSRange range2 = {[aTracingStrng length] - 1, 1};

        if ([[aTracingStrng substringWithRange: range2] isEqualToString: @"]"])
        {
            *aIsClassInstance = [[aTracingStrng substringToIndex: 1] isEqualToString: @"+"];
            NSRange range = {2, [aTracingStrng length] - 3};
            NSString* str = [aTracingStrng substringWithRange: range];
            *outClassName = [[[str componentsSeparatedByString: @" "] objectAtIndex: 0] copy];
            *outMethodName = [[[str componentsSeparatedByString: @" "] objectAtIndex: 1] copy];

            return YES;
        }
    }

    return NO;
}

- (void) drawClassItemName: (NSString*) aClassName
                methodName: (NSString*) aMethodName
           isClassInstance: (BOOL) aIsClassInstance
{
    CGFloat offset = 0.0f;
    BOOL needNewView = YES;
    
    for (DTSequenceDiagramClassView* viewInfo in arrayViewsInfo)
    {
        if ([viewInfo.className isEqualToString: aClassName])
        {
            
            NSLog(@"!!!!!!!!!!!!!!! %@", aMethodName);
            
            [self drawingMethodForClassView: viewInfo
                                         method: aMethodName];
            needNewView = NO;
            
            break;
        }

        offset = offset + CGRectGetWidth(viewInfo.frame) + 10.0f;
    }

    if (needNewView)
    {
        CGRect frame = CGRectMake(offset, 0.0f, 0.0f, ClassViewHeight);
        CGFloat x = CGRectGetMinX(frame);
        frame.origin = CGPointMake(BordersLeftMargin + x, 5.0f);
        DTSequenceDiagramClassView* viewInfo = [[DTSequenceDiagramClassView alloc] initWithFrame: frame
                                                                                            text: aClassName
                                                                                         bgColor: [NSColor blueColor]];
        [contentClassNameView addSubview: viewInfo];
        
        if (!arrayViewsInfo)
        {
            arrayViewsInfo = [[NSMutableArray alloc] init];
        }
        

        NSLog(@"+++++++++++++++++ %@: %@", aClassName, aMethodName);
        
        
        
        [arrayViewsInfo addObject: viewInfo];
        [self drawingMethodForClassView: viewInfo
                                     method: aMethodName];
        [viewInfo release];
    }
    
    [aClassName release];
    [aMethodName release];
}

- (void) drawingMethodForClassView: (DTSequenceDiagramClassView*) viewInfo
                            method: (NSString*) aMethodName
{
    NSString* className = viewInfo.className;
    NSLog(@"[%@] [%@]", className, aMethodName);

    CGFloat oldY = currentY;
    currentY = currentY - StepByY;
    
    if (!self.currentClassView || viewInfo == self.currentClassView)
    {
        CGPoint point1 = CGPointMake([viewInfo middleX], oldY);
        CGPoint point2 = CGPointMake([viewInfo middleX], currentY);
        
        [contentView drawTimeLineBetween: point1
                                andPoint: point2];
        
        // Делаем петлю на viewInfo
        [self drawMethodName: aMethodName
                     atPoint: point2];

        [contentView drawMethodLineInPoint: point2];
        
    }
    else
    {
        CGPoint point1 = CGPointMake([self.currentClassView middleX], oldY);
        CGPoint point2 = CGPointMake([self.currentClassView middleX], currentY);
        [contentView drawTimeLineBetween: point1
                                andPoint: point2];
        
        CGPoint point3 = CGPointMake([viewInfo middleX], oldY);
        CGPoint point4 = CGPointMake([viewInfo middleX], currentY);
        [contentView drawTimeLineBetween: point3
                                andPoint: point4];
        
        // Соединяем self.currentClassView и viewInfo
        
        point1.y = point1.y - 10.0f;
        point3.y = point3.y - 10.0f;
        [contentView drawSequenceLineBetween: point1
                                    andPoint: point3];
        
        CGPoint point = CGPointMake([viewInfo middleX], currentY);
        [self drawMethodName: aMethodName
                     atPoint: point];
        
        [contentView setNeedsDisplay: YES];
    }
    
    self.currentClassView = viewInfo;
}

- (void) drawMethodName: (NSString*) aMethodName
                atPoint: (CGPoint) aPoint
{
    NSFont* font = [NSFont fontWithName: @"Helvetica"
                                  size: 12];
    NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys: font, NSFontAttributeName, nil];
    NSAttributedString* text = [[NSAttributedString alloc] initWithString: aMethodName
                                                               attributes: attributes];
    NSSize textSize = [text size];
    CGFloat labelWidth = textSize.width;
    CGFloat labelHeight = textSize.height;
    
    CGRect labelFrame = CGRectMake(aPoint.x, aPoint.y - (labelHeight / 2.0f + 4.0f), labelWidth + 10.0f, labelHeight + 5.0f);
    
    NSTextField* textLabel = [[NSTextField alloc] initWithFrame: labelFrame];
    [textLabel setFont: font];
    [textLabel setBordered: NO];
    [textLabel setStringValue: aMethodName];
    [textLabel setAlignment: NSLeftTextAlignment];
    [textLabel setBackgroundColor: [NSColor clearColor]];
    [textLabel setTextColor: [NSColor blackColor]];
    [textLabel setEditable: NO];
    [contentView addSubview: textLabel];
    [textLabel release];
}

@end
