//
//  DTViewsInfoViewController.m
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import "DTViewsInfoViewController.h"
#import "DTViewsDataInfoView.h"
#import "DTUDPClientController.h"
#import "DTConstants.h"
#import "DTEnterSingleDataModalDialog.h"
#import "DTFileOperations.h"
#import "DTClientController.h"
#import "DTViewInfo.h"
#import "DTUIAutomationHelper.h"

const NSString* ViewInfoKey = @"viewInfo";

@interface DTViewsInfoViewController()
- (void) applayViewInfo;
@end

@implementation DTViewsInfoViewController

@synthesize stringViewsInfo;
@synthesize testName;
@synthesize lastUnclosedString;

- (id) initWithNibName: (NSString*) nibNameOrNil
                bundle: (NSBundle*) nibBundleOrNil
              testName: (NSString*) aTestName
                  text: (NSString*) textMap
{
    if ((self = [super initWithNibName: nibNameOrNil
                                bundle: nibBundleOrNil]))
    {
        self.stringViewsInfo = textMap;
        self.testName = aTestName;
        arrayViewsInfo = [[NSMutableArray alloc] init];
        needAnimationOnSelect = YES;
    }
    
    return self;
}

- (void) dealloc
{
    [arrayViewsInfo release];
    arrayViewsInfo = nil;
    self.lastUnclosedString = nil;
    self.stringViewsInfo = nil;
    self.testName = nil;
    [uiAutomationHelper release];
    uiAutomationHelper = nil;
    
    [super dealloc];
}

- (void) viewWillLoad
{

}

- (void) applayViewInfo
{
    if (lastUnclosedString != nil)
    {
        self.stringViewsInfo = [NSString stringWithFormat: @"%@%@", lastUnclosedString, stringViewsInfo];
        self.lastUnclosedString = nil;
    }
    
    NSArray* data = [stringViewsInfo componentsSeparatedByString: @"\n\n"];
    
    if ([data count] == 0)
    {
        return;
    }

    for (NSString* str in data)
    {
        if ([str length] > 2 && [str hasPrefix: @"#"] && [str hasSuffix: @"#"])
        {
            DTViewInfo* viewInfo = [DTViewInfo createViewInfoForData: str
                                                parentViewController: self];
            [arrayControllerViewsInfo addObject: [NSMutableDictionary dictionaryWithObject: viewInfo.content
                                                                                    forKey: ViewInfoKey]];
            [mapView addSubview: viewInfo.view];
            [arrayViewsInfo addObject: viewInfo];
            [viewInfo release];
        }
        else if (([str length] > 0) && ![str hasSuffix: @"#"])
        {
            self.lastUnclosedString = str;
        }
    }
}

- (CGFloat) parentViewHeight
{
    return CGRectGetHeight(mapView.frame);
}

- (void) viewDidLoad
{
    [titleLabel setTitle: testName];
    self.testName = nil;
    
    [self applayViewInfo];
    self.stringViewsInfo = nil;
    
    CGRect rect = CGRectZero;
    [transparentView drawBorderForRect: &rect];
    
    NSString* filePath = [[NSBundle mainBundle] pathForResource: @"readme"
                                                         ofType: @"txt"];
    NSError* error = nil;
    NSString* readmeFileContent = [NSString stringWithContentsOfFile: filePath
                                                           encoding: NSUTF8StringEncoding
                                                              error: &error];

    if (readmeFileContent)
    {
        [helpTextView setString: readmeFileContent];
    }
    
    [self performSelector: @selector(refreshMapView)
               withObject: nil
               afterDelay: 2.0f];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
        NSPoint pt = NSMakePoint(0, ((NSView*)mapsScrollView.documentView).frame.size.height - mapsScrollView.contentSize.height);
        [mapsScrollView.contentView scrollToPoint: pt];
    }];
}

- (void) refreshMapView
{
//    [transparentView setNeedsDisplay: YES];
//    [mapView setNeedsLayout: YES];
//    [mapView setNeedsDisplay: YES];
//    
//    [mapsScrollView setNeedsUpdateConstraints: YES];
//    [mapsScrollView setLineScroll: 100.00f];
    
//    mapsScrollView.verticalScroller.floatValue = -1000.0f;
    
//    [mapsScrollView scrollToPoint: NSMakePoint(0, [mapsScrollView contentView].frame.size.height - [mapsScrollView frame].size.height)];
}

- (void) insertStringMap: (NSString*) aStringMap
{
    self.stringViewsInfo = aStringMap;
    [self applayViewInfo];
    self.stringViewsInfo = nil;
}

- (void) receivingDataIsFinished
{
    uiAutomationHelper = [[DTUIAutomationHelper alloc] initWithViewsInfoArray: arrayViewsInfo];
}

- (void) showUIAutomationScriptForSelect: (NSString*) aSelect
{
    if (uiAutomationHelper)
    {
        [automationInfo setString: [uiAutomationHelper scriptForSelect: aSelect]];
    }
}

- (void) selectContent: (NSString*) aContent
{
    NSUInteger index = 0;
    
    for (NSDictionary* dict in arrayControllerViewsInfo.content)
    {
        NSString* content = [dict objectForKey: ViewInfoKey];
        
        if ([content isEqualToString: aContent])
        {
            NSIndexSet* indexSet = [NSIndexSet indexSetWithIndex: index];
            needAnimationOnSelect = NO;
            [tableview selectRowIndexes: indexSet
                   byExtendingSelection: NO];
            needAnimationOnSelect = YES;
            [tableview scrollRowToVisible: index];
        }

        index++;
    }
}

- (void) tableViewSelectionDidChange: (NSNotification*) aNotification
{
    NSTableView* theTable = [aNotification object];
    
    if (theTable == tableview)
    {
        if ([arrayViewsInfo count] > 0)
        {
            NSInteger selectedRow = [tableview selectedRow];
            
            if (selectedRow != -1)
            {
                NSArray* selected = arrayControllerViewsInfo.selectedObjects;
                
                if ([selected count] >0)
                {
                    NSDictionary* dictSelect = [selected objectAtIndex: 0];
                    NSString* select = [dictSelect objectForKey: ViewInfoKey];
                    
                    [textInfo setString: select];
                    
                    [self showUIAutomationScriptForSelect: select];
                    
                    for (DTViewInfo* currViewInfo in arrayViewsInfo)
                    {
                        
                        if ([currViewInfo.content isEqualToString: select])
                        {
                            if (needAnimationOnSelect)
                            {
                                [currViewInfo.view select];
                            }
                            CGRect frameSelectedView = currViewInfo.view.frame;
                            [transparentView drawBorderForRect: &frameSelectedView];
                            
                            break;
                        }
                    }
                    
                    NSArray* arr = [select componentsSeparatedByString: @";"];
                    NSString* scriptText = [arr objectAtIndex: [arr count] - 1];
                    arr = [scriptText componentsSeparatedByString: @","];
                    NSUInteger len = [[arrayControllerScript content] count];
                    
                    if (len > 0)
                    {
                        [arrayControllerScript removeObjectsAtArrangedObjectIndexes: [NSIndexSet indexSetWithIndexesInRange: NSMakeRange(0, len)]];
                    }
                    
                    for (NSString* currViewName in arr)
                    {
                        if ([currViewName length] > 0)
                        {
                            [arrayControllerScript addObject: [NSMutableDictionary dictionaryWithObject: [NSString stringWithFormat: @"%@", currViewName]
                                                                                                 forKey: @"scriptitem"]];
                        }
                    }
                }
            }
        }
    }
}

- (void) loadView
{
    [self viewWillLoad];
    [super loadView];
    [self viewDidLoad];
}

- (NSData*) dataWithPDF
{
    CGFloat minX = CGRectGetWidth(mapView.frame);
    CGFloat maxX = 0.0f;
    CGFloat minY = CGRectGetHeight(mapView.frame);
    CGFloat maxY = 0.0f;
    
    for (DTViewInfo* currView in arrayViewsInfo)
    {
        CGRect frameView = currView.view.frame;
        minX = MIN(minX, CGRectGetMinX(frameView));
        maxX = MAX(maxX, CGRectGetMaxX(frameView));
        minY = MIN(minY, CGRectGetMinY(frameView));
        maxY = MAX(maxY, CGRectGetMaxY(frameView));
    }
    NSRect r = CGRectMake(minX, minY, maxX - minX, maxY - minY);
    
    return [mapView dataWithPDFInsideRect: r];
}

- (void) saveContentToPDFfile: (id) aFileName
{
    NSString* fileName = (NSString*) aFileName;
    NSString* schemesPath = [DTFileOperations documentPathAppendDirectory: @"views"];
    NSString* fullFileName = [NSString stringWithFormat: @"%@/%@.PDF", schemesPath, fileName];
    
    NSData* data = [self dataWithPDF];
    
    [data writeToFile: fullFileName
           atomically: YES];

    NSBeginAlertSheet(NSLocalizedString(@"Warning", @"Warning"), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil,
                      @"Data saved to '%@'\n", fullFileName);
}

- (void) runScriptItemButton: (id) sender
{
    NSInteger selectedRow = [scriptTableview selectedRow];
    
    if (selectedRow != -1)
    {
        NSArray* selected = arrayControllerScript.selectedObjects;
        
        for (NSDictionary* dictSelect in selected)
        {
            NSString* select = [dictSelect objectForKey: @"scriptitem"];
            
            if (([select length] > 0) && ([select hasPrefix: @"_"] ==  NO))
            {
                NSLog(@"%@", select);
                
                [DTClientController runCommand: RunViewScriptMessageId
                                        data: select];
            }
        }
    }
}

- (IBAction) runAllScriptsItemButton: (id) sender
{
    for (NSDictionary* dictSelect in arrayControllerScript.content)
    {
        NSString* select = [dictSelect objectForKey: @"scriptitem"];
        
        if ([select hasPrefix: @"_"] ==  NO)
        {
            NSLog(@"%@", select);
            
            [DTClientController runCommand: RunViewScriptMessageId
                                    data: select];
        }
    }
}

- (IBAction) addScriptItem: (id) sender
{
    [arrayControllerScript addObject: [NSMutableDictionary dictionaryWithObject: @""
                                                                         forKey: @"scriptitem"]];
}

- (IBAction) goViewsToHome: (id) sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName: MoveViewsFrameToHomeNotificationId
                                                        object: nil];
}

- (IBAction) saveAsPDF: (id) sender
{
    DTEnterSingleDataModalDialog* dlg = [[DTEnterSingleDataModalDialog alloc] initWithTitle: @"Save of view sheme to PDF file"
                                                                                   text: @"File name:"
                                                                                 sender: self
                                                                                 target: self
                                                                                  okSel: @selector(saveContentToPDFfile:)
                                                                              cancelSel: nil];
    [dlg showModalDialog];
}

- (IBAction) saveScriptToFile: (id) sender
{
    
}

- (IBAction) loadScriptFromFile: (id) sender
{
    
}

@end
