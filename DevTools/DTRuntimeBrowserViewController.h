//
//  DTRuntimeBrowserViewController.h
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DTPanelWithIndicator.h"
#import "DTSelectClassesPopUpButton.h"
#import "DTClassInfoView.h"

@interface DTRuntimeBrowserViewController : NSViewController <DTProcessIndicator, NSOutlineViewDelegate>
{
    IBOutlet DTClassesShemeView* classesShemeView;
    IBOutlet NSScrollView* classesShemeScrollView;
    IBOutlet NSTreeController* treeController;
    IBOutlet NSOutlineView* outlineView;
    IBOutlet NSButtonCell* refreshButton;
    IBOutlet NSButton* checkBoxTree;
    IBOutlet NSButton* selectUnselectCheckBox;
    IBOutlet NSButton* applyDependencies;
    IBOutlet NSSearchField* searchField;
    IBOutlet NSView* classInterfaceInfoView;
    IBOutlet NSScrollView* classInterfaceInfoScrollView;
    IBOutlet NSTextView* classInterfaceInfoTextView;
    IBOutlet DTSelectClassesPopUpButton* selectSchemePopUpButton;
    IBOutlet NSArrayController* arrayControllerClassesInfo;
 
@private
    DTPanelWithIndicator* panelWithIndicator;
    NSMutableString* jsonStr;
    BOOL isOperationInProcessing;
    BOOL lockChangeCheck;
    NSMutableArray* contentArray;
    NSInteger fullLengthOfJsonStr;
    NSMutableArray* arrayClassInfo;
    CGFloat currLeftMarginOfDTClassInfoView;
    CGFloat currTopMarginOfDTClassInfoView;
    BOOL isSelectInfoClassViewDisabled;
}

@property (nonatomic, readwrite, retain) NSMutableArray* contentArray;
@property (nonatomic, readwrite, assign) BOOL isOperationInProcessing;

- (IBAction) treeSwitch: (id) sender;
- (IBAction) refreshSwitch: (id) sender;
- (IBAction) refreshSelectSchemes: (id) sender;
- (IBAction) selectLineInCheckedShemePopUp: (id) sender;
- (IBAction) homeButtonPressed: (id) sender;
- (IBAction) selectedOnlyButtonPressed: (id) sender;
- (IBAction) saveAsPDF: (id) sender;
- (IBAction) dependencies: (id) sender;

- (void) startJSONdata;
- (void) fillingJSONdata: (NSString*) aJSONdata;
- (void) finishJSONdata;

- (NSArray*) selectedClassNames;
- (void) classInterfaceInfoMessageResponse: (NSString*) aClassHeader isContinue: (BOOL) aIsContinue;
- (void) classDependenciesInfoMessageResponse: (NSString*) aClassDependencies;
- (void) reloadClassTree;
- (void) selectDTClassInfoView: (DTClassInfoView*) aDTClassInfoView;
- (void) mouseDownOnDTClassInfoView: (DTClassInfoView*) aDTClassInfoView;

@end
