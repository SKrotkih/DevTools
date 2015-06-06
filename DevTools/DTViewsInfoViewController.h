//
//  DTViewsInfoViewController.h
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DTTransparentView.h"

@class DTViewsDataInfoView, DTUIAutomationHelper;

@interface DTViewsInfoViewController : NSViewController
{
    IBOutlet NSView* mapView;
    IBOutlet NSScrollView* mapsScrollView;
    IBOutlet DTTransparentView* transparentView;
    IBOutlet NSTextFieldCell* titleLabel;
    IBOutlet NSArrayController* arrayControllerViewsInfo;
    IBOutlet NSArrayController* arrayControllerScript;
    IBOutlet NSTableView* tableview;
    IBOutlet NSTableView* scriptTableview;
    IBOutlet NSTextView* textInfo;
    IBOutlet NSTextView* automationInfo;
    IBOutlet NSTextView* scriptTextView;
    IBOutlet NSTextView* helpTextView;
    NSString* stringViewsInfo;
    NSString* testName;
    NSString* lastUnclosedString;
    NSMutableArray* arrayViewsInfo;
    BOOL needAnimationOnSelect;
    DTUIAutomationHelper* uiAutomationHelper;
}

@property (nonatomic, readwrite, copy) NSString* stringViewsInfo;
@property (nonatomic, readwrite, copy) NSString* testName;
@property (nonatomic, readwrite, copy) NSString* lastUnclosedString;

- (id) initWithNibName: (NSString*) nibNameOrNil
                bundle: (NSBundle*) nibBundleOrNil
              testName: (NSString*) aTestName
                  text: (NSString*) textMap;

- (void) insertStringMap: (NSString*) aStringMap;
- (void) selectContent: (NSString*) aContent;
- (void) receivingDataIsFinished;

- (IBAction) runScriptItemButton: (id) sender;
- (IBAction) runAllScriptsItemButton: (id) sender;
- (IBAction) addScriptItem: (id) sender;
- (IBAction) goViewsToHome: (id) sender;

- (IBAction) saveScriptToFile: (id) sender;
- (IBAction) loadScriptFromFile: (id) sender;
- (IBAction) saveAsPDF: (id) sender;

- (CGFloat) parentViewHeight;

@end
