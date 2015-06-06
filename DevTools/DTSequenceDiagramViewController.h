//
//  DTSequenceDiagramViewController.h
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DTTransparentView.h"
#import "DTSequenceDiagramBackgroundView.h"
#import "DTSynchroScrollView.h"

@class DTSequenceDiagramClassView;

@interface DTSequenceDiagramViewController : NSViewController
{
    IBOutlet DTSequenceDiagramBackgroundView* contentView;
    IBOutlet DTSynchroScrollView* classesNameScrollView;
    IBOutlet NSView* contentClassNameView;
    IBOutlet NSScrollView* contentScrollView;
    NSMutableArray* arrayViewsInfo;
    DTSequenceDiagramClassView* currentClassView;
    CGFloat currentY;
    NSString* beginOfreviousString;
}

@property(nonatomic, readwrite, assign) DTSequenceDiagramClassView* currentClassView;
@property(nonatomic, readwrite, copy) NSString* beginOfreviousString;

- (void) parseOfTricingData: (NSString*) aData;
- (void) initDiagramm;

@end
