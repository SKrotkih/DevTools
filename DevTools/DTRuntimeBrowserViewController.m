//
//  DTRuntimeBrowserViewController.m
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import "DTRuntimeBrowserViewController.h"
#import "DTRuntimeBrowserNode.h"
#import "DTUDPServerController.h"
#import "DTUDPClientController.h"
#import "DTConstants.h"
#import "DTFileOperations.h"
#import "DTClassesShemeView.h"
#import "DTEnterSingleDataModalDialog.h"
#import "DTClientController.h"

static CGFloat leftMarginOfDTClassInfoView = 10.0f;
static CGFloat horizontalSeparatorWidthOfDTClassInfoView = 20.0f;
static CGFloat verticalSeparatorWidthOfDTClassInfoView = 30.0f;
static CGFloat widthDTClassInfoView = 150.0f;
static CGFloat heightOfDTClassInfoView = 50.0f;
static CGFloat widthOfDTClassInfoViewField = 1000.0f;
static CGFloat widthOfDTClassInfoViewLine = 1.0f;

static NSMutableArray* generateESTree()
{
    int i,j,k;
    NSString* istrings[] = {@"I", @"II", @"III", @"IV"};
    NSString* jstrings[] = {@"A", @"B", @"C", @"D"};
    NSString* kstrings[] = {@"i", @"ii", @"iii", @"iv"};
    
    DTRuntimeBrowserNode* td = [[DTRuntimeBrowserNode alloc] initWithNodeName: RootNodeNameOnRunTimeBrowser];
    NSMutableArray* roots = [NSMutableArray array];
    
    for (i=0; i<4; i++) 
    {
        td = [[DTRuntimeBrowserNode alloc] initWithNodeName: istrings[i]];
        NSTreeNode *inode = [NSTreeNode treeNodeWithRepresentedObject: td];
        [td release];
        
        for (j=0; j<4; j++) 
        {
            td = [[DTRuntimeBrowserNode alloc] initWithNodeName: jstrings[j]];
            NSTreeNode *jnode = [NSTreeNode treeNodeWithRepresentedObject: td];
            [td release];            
            
            for (k=0; k<4; k++) 
            {
                td = [[DTRuntimeBrowserNode alloc] initWithNodeName: kstrings[k]];
                NSTreeNode *knode = [NSTreeNode treeNodeWithRepresentedObject: td];
                [td release];                
                
                [[jnode mutableChildNodes] addObject:knode];
            }
            
            [[inode mutableChildNodes] addObject:jnode];
        }
        
        [roots addObject:inode];
    }
    
    return roots;
}

@implementation NSTreeController (Additions)

- (NSIndexPath*) indexPathOfObject: (id) anObject
{
    return [self indexPathOfObject: anObject
                           inNodes: [[self arrangedObjects] childNodes]];
}

- (NSIndexPath*) indexPathOfObject: (id) anObject
                           inNodes: (NSArray*) nodes
{
    NSString* className = (NSString*) anObject;
    
    for (NSTreeNode* node in nodes)
    {
        NSTreeNode* currNode = [node representedObject];
        DTRuntimeBrowserNode* td = [currNode representedObject];
        
        if ([className isEqualToString: td.nodeName])
        {
            return [node indexPath];
        }

        if ([[node childNodes] count])
        {
            NSIndexPath* path = [self indexPathOfObject: anObject
                                                inNodes: [node childNodes]];
            if (path)
            {
                return path;
            }
        }
    }

    return nil;
}
@end

@interface DTRuntimeBrowserViewController ()
- (NSMutableArray*) generateTreeForClassDict: (NSDictionary*) classDict;
- (void) loadClassTree;
- (void) reloadClassTree;
- (void) clearClassTree;
- (void) clearDTClassesShemeViews;
- (void) selectCheckedClassesItem: (NSString*) anItem;
- (NSColor*) randomColor;
- (BOOL) isNewColor: (NSColor*) color;
- (void) setHomeStateOfAllClassesView;
@end

@implementation DTRuntimeBrowserViewController

@synthesize contentArray;
@synthesize isOperationInProcessing;

- (id) initWithNibName: (NSString*) nibNameOrNil bundle: (NSBundle*) nibBundleOrNil
{
    if ((self = [super initWithNibName: nibNameOrNil 
                                bundle: nibBundleOrNil])) 
    {
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(checkedNode:)
                                                     name: CheckNodeOnRunTimeBrowserNotificationId
                                                   object: nil];
        isOperationInProcessing = NO;
        isSelectInfoClassViewDisabled = NO;        
        
        arrayClassInfo = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void) dealloc
{
    [jsonStr release];
    jsonStr = nil;
    [panelWithIndicator release];
    [super dealloc];
}

#pragma mark DTProcessIndicator protocol

- (void) cancelled
{

    self.isOperationInProcessing = NO;

    NSBeginAlertSheet(@"Operation was cancelled!", nil, nil, nil, MAINWINDOW, nil, nil, nil, nil,
                      @"But operation is continue!");
}

#pragma mark -

- (void) awakeFromNib
{
    [self reloadClassTree];
}

- (void) loadView
{
    [self viewWillLoad];
    [super loadView];
    [self viewDidLoad];
}

- (void) viewWillLoad
{
}

- (void) viewDidLoad
{
}

- (void) scrollClassesShemeToTop
{
    [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
        NSPoint pt = NSMakePoint(0, ((NSView*)classesShemeScrollView.documentView).frame.size.height - classesShemeScrollView.contentSize.height);
        [classesShemeScrollView.contentView scrollToPoint: pt];
    }];
}

- (void) scrollToDTClassInfoView: (DTClassInfoView*) aDTClassInfoView
{
    [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
        NSPoint pointForScroll = aDTClassInfoView.frame.origin;
        [[classesShemeScrollView contentView] scrollToPoint: pointForScroll];
        [classesShemeScrollView reflectScrolledClipView: [classesShemeScrollView contentView]];
    }];
}

- (void) reloadClassTree
{
    [self clearDTClassesShemeViews];
    
    [self clearClassTree];
    
    [self loadClassTree];

    [selectSchemePopUpButton refreshListData];
}

- (void) loadClassTree
{
    if (!isOperationInProcessing)
    {
        self.isOperationInProcessing = YES;
        [DTClientController runCommand: RequestToRunTimeBrowserDataNotificationId];
    }
}

- (void) startJSONdata
{
    if (jsonStr == nil)
    {
        jsonStr = [[NSMutableString alloc] init];
    }
    else
    {
        NSRange range = NSMakeRange(0, [jsonStr length]);
        [jsonStr deleteCharactersInRange: range];
    }
    
    [checkBoxTree setState: NSOffState];
    
    [selectUnselectCheckBox setState: NSOffState];
    
    [refreshButton setEnabled: NO];
}

- (void) fillingJSONdata: (NSString*) aJSONdata
{
    [jsonStr appendString: aJSONdata];    
}

- (void) finishJSONdata
{
    NSData* jsonData = [jsonStr dataUsingEncoding: NSUTF8StringEncoding];
    NSRange range = NSMakeRange(0, [jsonStr length]);
    [jsonStr deleteCharactersInRange: range];
    
    NSError* jsonError = nil;
    
    id parsedData = [NSJSONSerialization JSONObjectWithData: jsonData
                                                    options: NSJSONReadingMutableLeaves
                                                      error: &jsonError];
    if (parsedData == nil)
    {
        NSLog(@"Got an error: %@", jsonError);
        
        self.contentArray = [NSMutableArray array];
        [treeController setContent: self.contentArray];
        
        [outlineView reloadData];
    }
    else if ([parsedData isKindOfClass: [NSDictionary class]])
    {
        NSDictionary* classDict = (NSDictionary*) parsedData;
        self.contentArray = [self generateTreeForClassDict: classDict];
        [self visualizeOfClassDict: classDict];
        [treeController setContent: self.contentArray];
        
        [outlineView reloadData];
        
        [self scrollClassesShemeToTop];
    }
    
    [checkBoxTree setState: NSOnState];
    
    [selectUnselectCheckBox setState: NSOffState];
    
    [refreshButton setEnabled: YES];

    self.isOperationInProcessing = NO;
}

- (void) addClassDict: (NSDictionary*) classDict
               toNode: (NSTreeNode*) aNnode
{
    NSArray* classesNameArr = [classDict allKeys];
    
    for (NSString* className in classesNameArr) 
    {
        DTRuntimeBrowserNode* td = [[DTRuntimeBrowserNode alloc] initWithNodeName: className];
        NSTreeNode* treeNode = [NSTreeNode treeNodeWithRepresentedObject: td];
        [td release];
        
        id childClassesNameArr = [classDict objectForKey: className];
        
        if (childClassesNameArr == nil) 
        {
            NSLog(@"Got an error!");
        }
        else if ([childClassesNameArr isKindOfClass: [NSArray class]])
        {
            for (NSDictionary* classDict in childClassesNameArr) 
            {
                [self addClassDict: classDict toNode: treeNode];
            }
        }
        
        [[aNnode mutableChildNodes] addObject: treeNode];
    }
}

- (NSMutableArray*) generateTreeForClassDict: (NSDictionary*) classDict
{
    NSMutableArray* roots = [NSMutableArray array];
    
    NSArray* classesNameArr = [classDict allKeys];
    
    for (NSString* className in classesNameArr) 
    {
        DTRuntimeBrowserNode* td = [[DTRuntimeBrowserNode alloc] initWithNodeName: className];
        NSTreeNode* treeNode = [NSTreeNode treeNodeWithRepresentedObject: td];
        [td release];
        
        id childClassesNameArr = [classDict objectForKey: className];
        
        if (childClassesNameArr == nil) 
        {
            NSLog(@"Got an error!");
        }
        else if ([childClassesNameArr isKindOfClass: [NSArray class]])
        {
            for (NSDictionary* classDict in childClassesNameArr) 
            {
                [self addClassDict: classDict
                            toNode: treeNode];
            }
        }
        
        [roots addObject: treeNode];
    }
    
    return roots;
}

#pragma mark -

- (void) checkNode: (NSTreeNode*) aNode
       forNodeName: (NSString*) aNodeName
          wasFound: (BOOL) wasFound
{
    for (NSTreeNode* nodeItem in [aNode childNodes])
    {
        DTRuntimeBrowserNode* td = [nodeItem representedObject];
        
        if (wasFound || [aNodeName isEqualToString: td.nodeName])
        {
            td.check = (td.check == 0) ? 1 : 0;
            
            [self checkNode: nodeItem 
                forNodeName: aNodeName 
                   wasFound: YES];
        }
        
        [self checkNode: nodeItem 
            forNodeName: aNodeName 
               wasFound: NO];
    }
}

- (void) checkedNode: (NSNotification *) notification
{
	if (contentArray == nil) 
    {
        return;
    }

    if (lockChangeCheck == YES) 
    {
        return;
    }
    
    lockChangeCheck = YES;
    
    NSString* nodeName = [notification object];
    
    for (NSTreeNode* nodeItem in contentArray)
    {
        [self checkNode: nodeItem
            forNodeName: nodeName
               wasFound: NO];
    }

    lockChangeCheck = NO;
    
    [outlineView reloadData];
}

- (void) selectCheckedClassesItem: (NSString*) anItem
{
    if (checkBoxTree.state == NSOnState)
    {
        NSBeginAlertSheet(@"Operation wasn't done!", nil, nil, nil, MAINWINDOW, nil, nil, nil, nil,
                          @"Please uncheck 'Tree' checkbox!");
        
        return;
    }
    
    NSArray* checkedNodes = [DTFileOperations contentOfSchemesFileName: anItem];
    
    if (checkedNodes)
    {
        for (NSTreeNode* nodeItem in contentArray)
        {
            DTRuntimeBrowserNode* td = [nodeItem representedObject];
            NSString* currNodeName = td.nodeName;
            
            for (NSString* nodeName in checkedNodes)
            {
                if ([nodeName isEqualToString: currNodeName])
                {
                    td.check = (td.check == 0) ? 1 : 0;
                }
            }
        }
    }
}

- (void) scanChildTreeNode: (NSArray*) childNodes resultArray: (NSMutableArray*) aResultArray
{
    for (NSTreeNode* treeNode in childNodes)
    {
        DTRuntimeBrowserNode* td = [treeNode representedObject];
        NSTreeNode* newTreeNode = [NSTreeNode treeNodeWithRepresentedObject: td];
        [aResultArray addObject: newTreeNode];
        [self scanChildTreeNode: [treeNode childNodes]
                    resultArray: aResultArray];
    }
}

- (IBAction) treeSwitch: (id) sender
{
    if (checkBoxTree.state == NSOnState)
    {
        [self reloadClassTree];
    }
    else 
    {
        NSMutableArray* arrayClasses = [[NSMutableArray alloc] init];
        
        for (NSTreeNode* treeNode in contentArray)
        {
            DTRuntimeBrowserNode* td = [treeNode representedObject];
            NSTreeNode* newTreeNode = [NSTreeNode treeNodeWithRepresentedObject: td];
            [arrayClasses addObject: newTreeNode];
            NSArray* childNodes = [treeNode childNodes];
            [self scanChildTreeNode: childNodes resultArray: arrayClasses];
        }

        [self clearClassTree];
        
        if ([arrayClasses count] > 0)
        {
            NSArray* array = [arrayClasses sortedArrayUsingComparator:(NSComparator)^(id obj1, id obj2){
                DTRuntimeBrowserNode* td1 = [obj1 representedObject];
                DTRuntimeBrowserNode* td2 = [obj2 representedObject];
                NSString* className1 = td1.nodeName;
                NSString* className2 = td2.nodeName;
                return [className1 caseInsensitiveCompare: className2]; }];
            
            self.contentArray = [array mutableCopy];
        }
        
        [arrayClasses release];
        [treeController setContent: self.contentArray];
        [outlineView reloadData];
    }
}

#pragma mark Select/Unselect tree nodes

- (void) scanChildTreeNodeForSelect: (NSArray*) childNodes
{
    for (NSTreeNode* treeNode in childNodes)
    {
        DTRuntimeBrowserNode* td = [treeNode representedObject];
        td.check = (selectUnselectCheckBox.state == NSOnState) ? 1 : 0;
        NSArray* childNodes = [treeNode childNodes];
        [self scanChildTreeNodeForSelect: childNodes];
    }
}

- (IBAction) selectSwitch: (id) sender
{
    for (NSTreeNode* treeNode in contentArray)
    {
        DTRuntimeBrowserNode* td = [treeNode representedObject];
        td.check = (selectUnselectCheckBox.state == NSOnState) ? 1 : 0;
        NSArray* childNodes = [treeNode childNodes];
        [self scanChildTreeNodeForSelect: childNodes];
    }
    
}

#pragma mark

- (void) clearDTClassesShemeViews
{
    [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
        [classesShemeView setSubviews: [NSArray array]];
        [classesShemeView removeAllObjects];
        [classesShemeView setNeedsDisplay: YES];
        NSIndexSet* indexSet = [NSIndexSet indexSetWithIndexesInRange: NSMakeRange(0, [[arrayControllerClassesInfo arrangedObjects] count])];
        [arrayControllerClassesInfo removeObjectsAtArrangedObjectIndexes: indexSet];
        [arrayClassInfo removeAllObjects];
    }];
}

- (void) clearClassTree
{
    self.contentArray = nil;
    [outlineView reloadData];
}

- (IBAction) refreshSelectSchemes: (id) sender
{
    [selectSchemePopUpButton refreshListData];
}

- (IBAction) refreshSwitch: (id) sender
{
    [self reloadClassTree];
}

- (IBAction) selectLineInCheckedShemePopUp: (id) sender
{
    NSString* selectedFileName = [selectSchemePopUpButton titleOfSelectedItem];
    [self selectCheckedClassesItem: selectedFileName];
}

#pragma mark Search bar delegate protocol method

- (void) controlTextDidChange: (NSNotification*) notification
{
    id object = [notification object];

    if ([object isKindOfClass: [NSTextField class]] && ([contentArray count] > 0))
    {
        NSTextField* sender_object = object;
        NSString* searchString = [sender_object stringValue];
        NSInteger lenString = [searchString length];
        
        if (checkBoxTree.state == NSOffState)
        {
            if (lenString == 0)
            {
                NSIndexPath* indexPath = [[NSIndexPath alloc] initWithIndex: 0];
                [treeController setSelectionIndexPath: indexPath];
            }
            else
            {
                NSRange range = NSMakeRange(0, lenString);
                NSInteger index = 0;
                
                for (NSTreeNode* treeNode in contentArray)
                {
                    DTRuntimeBrowserNode* td = [treeNode representedObject];
                    NSString* nodeName = td.nodeName;
                    
                    if ([nodeName length] >= lenString && [[nodeName substringWithRange:range] isEqualToString: searchString])
                    {
                        NSIndexPath* indexPath = [[NSIndexPath alloc] initWithIndex: index];
                        [treeController setSelectionIndexPath: indexPath];

                        break;
                    }
                    
                    index++;
                }
            }
        }
        else
        {
            [self searchAndSelectNodeWithClassName: searchString];
        }
    }
}

#pragma mark -

- (NSArray*) selectedClassNames
{
    NSMutableArray* selectedClassNames = [NSMutableArray array];
    
    for (NSTreeNode* treeNode in contentArray)
    {
        DTRuntimeBrowserNode* td = [treeNode representedObject];
        
        if (td.check == 1)
        {
            [selectedClassNames addObject: td.nodeName];
        }
    }
    
    return selectedClassNames;
}

// Select tree item handler
// Get class info
- (void) outlineViewSelectionDidChange: (NSNotification*) aNotification
{
    NSArray* selectedObjects = [treeController selectedObjects];
    NSTreeNode* treeNode = [selectedObjects objectAtIndex: 0];
    
    DTRuntimeBrowserNode* td = [treeNode representedObject];
    NSString* className = td.nodeName;
    
    if (![className isEqualToString: RootNodeNameOnRunTimeBrowser])
    {
        [DTClientController runCommand: ClassInterfaceRequestMessageId
                                data: className];
        
        [DTClientController runCommand: ClassDependenciesRequestMessageId
                                data: className];
        
        if (!isSelectInfoClassViewDisabled)
        {
            //[self setHomeStateOfAllClassesView];
            
            for (DTClassInfoView* currDTClassInfoView in arrayClassInfo)
            {
                if ([currDTClassInfoView.className isEqualToString: className])
                {
                    [self selectDTClassInfoView: currDTClassInfoView];
                    
                    [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
                        [self selectedOnly];
                    }];
                    
                    break;
                }
            }
        }
    }
}

#pragma mark Handling of response for the ClassInterfaceRequestMessageId request

- (void) classInterfaceInfoMessageResponse: (NSString*) aClassHeader isContinue: (BOOL) aIsContinue
{
    if (aIsContinue)
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
            NSMutableString* currText = [NSMutableString stringWithString: [classInterfaceInfoTextView string]];
            [currText appendString: aClassHeader];
            [classInterfaceInfoTextView setString: currText];
            [classInterfaceInfoTextView setNeedsDisplay: YES];
            [classInterfaceInfoView setNeedsLayout: YES];
            [classInterfaceInfoView setNeedsDisplay: YES];
            
            NSPoint pt = NSMakePoint(0, ((NSView*) classInterfaceInfoScrollView.documentView).frame.size.height - classInterfaceInfoScrollView.contentSize.height);
            [classInterfaceInfoScrollView.contentView scrollToPoint: pt];
        }];
    }
    else
    {
        NSArray* tmpArr = [aClassHeader componentsSeparatedByString: HeaderOfClassSeparator];
        
        if ([tmpArr count] == 2)
        {
            NSString* className = [tmpArr objectAtIndex: 0];
            
            // TODO:: Check class name
            
            NSString* classHeader = [tmpArr objectAtIndex: 1];
            
            NSLog(@"\n=============\n%@:[%ld]\n%@\n=====================\n", className, (unsigned long)[classHeader length], classHeader);
            
            [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
                    [classInterfaceInfoTextView setString: classHeader];
                [classInterfaceInfoTextView setNeedsDisplay: YES];
                [classInterfaceInfoView setNeedsLayout: YES];
                [classInterfaceInfoView setNeedsDisplay: YES];
                
                NSPoint pt = NSMakePoint(0, ((NSView*) classInterfaceInfoScrollView.documentView).frame.size.height - classInterfaceInfoScrollView.contentSize.height);
                [classInterfaceInfoScrollView.contentView scrollToPoint: pt];
            }];
        }
        else
        {
            NSLog(@"Did received wrong data about class info!");
        }
    }
}

- (void) classDependenciesInfoMessageResponse: (NSString*) aClassDependencies
{
    NSArray* tmpArr = [aClassDependencies componentsSeparatedByString: DependencySeparator];
    
    if ([tmpArr count] == 2)
    {
        if (applyDependencies.state == NSOnState)
        {
            NSString* className = [tmpArr objectAtIndex: 0];
            NSArray* typeDatas = [[tmpArr objectAtIndex: 1] componentsSeparatedByString: @","];
            NSMutableArray* tmpArr2 = [NSMutableArray array];
            [tmpArr2 addObject: className];
            
            for (NSString* str in typeDatas)
            {
                if ([str length] > 0)
                {
                    str = [str stringByReplacingOccurrencesOfString: @"*"
                                                         withString: @""];
                    str = [str stringByReplacingOccurrencesOfString: @" "
                                                         withString: @""];
                    [tmpArr2 addObject: str];
                }
            }
            NSString* dependencies = [tmpArr2 componentsJoinedByString: @","];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
                [self applyDependencies: dependencies];
            }];
        }
    }
    else
    {
        NSLog(@"Did received wrong data about class dependencies!");
    }
}

#pragma mark -

- (NSPoint) pointForClassName: (NSString*) aClassName
{
    for (DTClassInfoView* currDTClassInfoView in arrayClassInfo)
    {
        if ([aClassName isEqualToString: currDTClassInfoView.className])
        {
            return currDTClassInfoView.frame.origin;
        }
    }
    
    return CGPointZero;
}

- (NSColor*) randomColor
{
    float rand_max = RAND_MAX;
    float red = (float)rand() / rand_max;
    float green = (float)rand() / rand_max;
    float blue = (float)rand() / rand_max;
    
    return [NSColor colorWithCalibratedRed: red
                                     green: green
                                      blue: blue
                                     alpha: 1.0f];
}

- (BOOL) isNewColor: (NSColor*) color
{
    for (DTClassInfoView* currDTClassInfoView in arrayClassInfo)
    {
        if ([currDTClassInfoView isEqualColor: color])
        {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark Dependencies

- (void) applyDependencies: (NSString*) aDependencies
{
    NSArray* deps = [aDependencies componentsSeparatedByString: @","];
    NSString* className = [deps objectAtIndex: 0];
    
    for (DTClassInfoView* currDTClassInfoView in arrayClassInfo)
    {
        if ([className isEqualToString: currDTClassInfoView.className])
        {
            NSRect rect = [self currentFrameClassesView];
            CGPoint dstPoint = CGPointMake(leftMarginOfDTClassInfoView, CGRectGetMinY(rect) - (heightOfDTClassInfoView + verticalSeparatorWidthOfDTClassInfoView));
            
            for (NSUInteger index = 1; index < [deps count]; index++)
            {
                NSString* currDepClassName = [deps objectAtIndex: index];

                for (DTClassInfoView* depDTClassInfoView in arrayClassInfo)
                {
                    if ([currDepClassName isEqualToString: depDTClassInfoView.className])
                    {
                        if ([depDTClassInfoView isNotSelected])
                        {
                            [depDTClassInfoView show];
                            [DTClassInfoView selectClassInfo: depDTClassInfoView];
                            [depDTClassInfoView movetoPoint: dstPoint];
                            dstPoint.x = dstPoint.x + horizontalSeparatorWidthOfDTClassInfoView;
                        }
                        
                        [classesShemeView drawDependenciesLineBetween: depDTClassInfoView
                                                                  and: currDTClassInfoView];
                    }
                }
            }
            [classesShemeView setNeedsDisplay: YES];
            
            break;
        }
    }
}

#pragma mark Vizualize of class sheme

- (void) vizualizeClassName: (NSString*) aClassName
            parentClassName: (NSString*) aParentClassName
{
    
    CGFloat y = CGRectGetHeight(classesShemeView.frame) - currTopMarginOfDTClassInfoView;
    
    CGRect frame = CGRectMake(currLeftMarginOfDTClassInfoView, y, widthDTClassInfoView, heightOfDTClassInfoView);
    
    NSColor* color;
    BOOL newColor = NO;
    
    while (!newColor)
    {
        color = [self randomColor];
        newColor = [self isNewColor: color];
    }

    DTClassInfoView* classInfoView = [[DTClassInfoView alloc] initWithFrame: frame
                                                              className: aClassName
                                                        parentClassName: aParentClassName
                                                                 parent: self
                                                                bgColor: color];

    [arrayControllerClassesInfo addObject: [NSMutableDictionary dictionaryWithObject: aClassName
                                                                              forKey: @"classInfo"]];
    classInfoView.content = aClassName;
    [classesShemeView addSubview: classInfoView];
    [arrayClassInfo addObject: classInfoView];
    [classInfoView release];
    
    currLeftMarginOfDTClassInfoView = currLeftMarginOfDTClassInfoView + classInfoView.width + horizontalSeparatorWidthOfDTClassInfoView;
    
    if (currLeftMarginOfDTClassInfoView > widthOfDTClassInfoViewField)
    {
        currLeftMarginOfDTClassInfoView = leftMarginOfDTClassInfoView;
        currTopMarginOfDTClassInfoView = currTopMarginOfDTClassInfoView + heightOfDTClassInfoView + verticalSeparatorWidthOfDTClassInfoView;
    }
    
}

- (void) visualizeOfInheritedClass: (NSDictionary*) classDict
                   parentClassName: (NSString*) aParentClassName
{
    NSArray* classesNameArr = [classDict allKeys];
    
    for (NSString* className in classesNameArr)
    {
        [self vizualizeClassName: className parentClassName: aParentClassName];
        id childClassesNameArr = [classDict objectForKey: className];
        
        if (childClassesNameArr == nil)
        {
            NSLog(@"Got an error!");
        }
        else if ([childClassesNameArr isKindOfClass: [NSArray class]])
        {
            for (NSDictionary* classDict in childClassesNameArr)
            {
                [self visualizeOfInheritedClass: classDict
                                parentClassName: className];
            }
        }
    }
}

- (void) visualizeOfClassDict: (NSDictionary*) classDict
{
    NSArray* classesNameArr = [classDict allKeys];
    
    currLeftMarginOfDTClassInfoView = leftMarginOfDTClassInfoView;
    currTopMarginOfDTClassInfoView = heightOfDTClassInfoView + verticalSeparatorWidthOfDTClassInfoView;
    
    for (NSString* className in classesNameArr)
    {
        id childClassesNameArr = [classDict objectForKey: className];
        
        if (childClassesNameArr == nil)
        {
            NSLog(@"Got an error!");
        }
        else if ([childClassesNameArr isKindOfClass: [NSArray class]])
        {
            for (NSDictionary* classDict in childClassesNameArr)
            {
                [self visualizeOfInheritedClass: classDict parentClassName: className];
            }
        }
    }
}

#pragma mark Save as PDF

- (NSRect) currentFrameClassesView
{
    CGFloat minX = CGRectGetWidth(classesShemeView.frame);
    CGFloat maxX = 0.0f;
    CGFloat minY = CGRectGetHeight(classesShemeView.frame);
    CGFloat maxY = 0.0f;
    
    for (DTClassInfoView* currDTClassInfoView in arrayClassInfo)
    {
        if ([currDTClassInfoView isNotHide])
        {
            CGRect frameViewInfo = currDTClassInfoView.frame;
            minX = MIN(minX, CGRectGetMinX(frameViewInfo));
            maxX = MAX(maxX, CGRectGetMaxX(frameViewInfo));
            minY = MIN(minY, CGRectGetMinY(frameViewInfo));
            maxY = MAX(maxY, CGRectGetMaxY(frameViewInfo));
        }
    }
    
    return CGRectMake(minX, minY, maxX - minX, maxY - minY);
}

- (NSData*) dataWithPDF
{
    NSRect rect = [self currentFrameClassesView];

    return [classesShemeView dataWithPDFInsideRect: rect];
}

- (void) saveContentToPDFfile: (id) aFileName
{
    NSString* fileName = (NSString*) aFileName;
    NSString* schemesPath = [DTFileOperations documentPathAppendDirectory: DirectoryNameForPDFUMLClassesSheme];
    NSString* fullFileName = [NSString stringWithFormat: @"%@/%@.PDF", schemesPath, fileName];
    
    NSData* data = [self dataWithPDF];
    
    [data writeToFile: fullFileName
           atomically: YES];
    
    NSBeginAlertSheet(NSLocalizedString(@"Warning", @"Warning"), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil,
                      @"Data saved to '%@'\n", fullFileName);
}

#pragma mark Select of Class info view handler. 

- (void) upToNSObjectForClassInfo: (DTClassInfoView*) aClassInfo
{
    for (DTClassInfoView* currClassInfo in arrayClassInfo)
    {
        if ([aClassInfo.parentClassName isEqualToString: currClassInfo.className])
        {
            [DTClassInfoView selectClassInfo: currClassInfo];
            
            [classesShemeView drawInheritLineBetween: currClassInfo
                                                 and: aClassInfo];
            
            [self upToNSObjectForClassInfo: currClassInfo];
        }
    }
}

- (void) selectClassInfoForParenClass: (NSString*) aParentClassName
{
    for (DTClassInfoView* currDTClassInfoView in arrayClassInfo)
    {
        if ([aParentClassName isEqualToString: currDTClassInfoView.parentClassName])
        {
            [DTClassInfoView selectClassInfo: currDTClassInfoView];
            [self selectClassInfoForParenClass: currDTClassInfoView.className];
        }
    }
}

- (void) scanParentClassesForDTClassInfoView: (DTClassInfoView*) currDTClassInfoView
{
    for (DTClassInfoView* currDTClassInfoView2 in arrayClassInfo)
    {
        if ([currDTClassInfoView.className isEqualToString: currDTClassInfoView2.parentClassName])
        {
            [classesShemeView drawInheritLineBetween: currDTClassInfoView
                                                 and: currDTClassInfoView2];
            
            [self scanParentClassesForDTClassInfoView: currDTClassInfoView2];
        }
    }
}

- (void) selectDTClassInfoView: (DTClassInfoView*) aDTClassInfoView
{
    NSString* aClassName = aDTClassInfoView.className;
    
    for (DTClassInfoView* currDTClassInfoView in arrayClassInfo)
    {
        [DTClassInfoView unSelectClassInfo: currDTClassInfoView];
    }

    [classesShemeView redrawAllLinesOfColor: [NSColor whiteColor]];
    [classesShemeView setNeedsDisplay: YES];
    
    for (DTClassInfoView* currDTClassInfoView in arrayClassInfo)
    {
        if ([aClassName isEqualToString: currDTClassInfoView.className])
        {
            [DTClassInfoView selectClassInfo: currDTClassInfoView];
            [self selectClassInfoForParenClass: currDTClassInfoView.className];
            [self scrollToDTClassInfoView: currDTClassInfoView];
        }
    }
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [classesShemeView removeAllObjects];
        [classesShemeView setLineWidth: widthOfDTClassInfoViewLine];
        
        for (DTClassInfoView* currDTClassInfoView in arrayClassInfo)
        {
            if ([aClassName isEqualToString: currDTClassInfoView.className])
            {
                [self scanParentClassesForDTClassInfoView: currDTClassInfoView];
                
                [self upToNSObjectForClassInfo: currDTClassInfoView];
                
                break;
            }
        }
        [classesShemeView setNeedsDisplay: YES];
    }];
}

- (void) searchAndSelectNodeWithClassName: (NSString*) aClassName
{
    NSIndexPath* indexPath = [treeController indexPathOfObject: aClassName];

    if (indexPath)
    {
        isSelectInfoClassViewDisabled = YES;
        [treeController setSelectionIndexPath: indexPath];
        isSelectInfoClassViewDisabled = NO;
    }
}

- (void) mouseDownOnDTClassInfoView: (DTClassInfoView*) aDTClassInfoView
{
    [self searchAndSelectNodeWithClassName: aDTClassInfoView.className];
}

- (void) setHomeStateOfAllClassesView
{
    for (DTClassInfoView* currDTClassInfoView in arrayClassInfo)
    {
        [currDTClassInfoView show];
    }
    
    [self scrollClassesShemeToTop];
    [classesShemeView setNeedsDisplay: YES];    
}

#pragma mark Show of selected Class info views only

- (DTClassInfoView*) rootInSelectedViewsInfo: (NSMutableArray*) aSelectedViewsInfo
{
    DTClassInfoView* rootViewInfo = nil;
    
    for (DTClassInfoView* currDTClassInfoView in aSelectedViewsInfo)
    {
        NSInteger cnt = 0;
        
        for (DTClassInfoView* currDTClassInfoView2 in aSelectedViewsInfo)
        {
            if ([currDTClassInfoView.parentClassName isEqualToString: currDTClassInfoView2.className])
            {
                cnt++;
            }
        }

        if (cnt == 0)
        {
            rootViewInfo = currDTClassInfoView;

            break;
        }
    }

    return rootViewInfo;
}

- (void) showNextLevelOfSElectedInfoViews: (NSArray*) currLevelOfInfoViews
                        selectedInfoViews: (NSArray*) aSelectedInfoViews
{
    if ([currLevelOfInfoViews count] == 0)
    {
        return;
    }
    
    NSMutableArray* nextRootLevelInfoViews = [NSMutableArray arrayWithCapacity: 0];
    
    currLeftMarginOfDTClassInfoView = leftMarginOfDTClassInfoView;
    currTopMarginOfDTClassInfoView = currTopMarginOfDTClassInfoView + heightOfDTClassInfoView + verticalSeparatorWidthOfDTClassInfoView;
    
    for (DTClassInfoView* currRootViewInfo in currLevelOfInfoViews)
    {
        NSString* rootClassName = [currRootViewInfo className];
        
        for (DTClassInfoView* currDTClassInfoView in aSelectedInfoViews)
        {
            if ([rootClassName isEqualToString: currDTClassInfoView.parentClassName])
            {
                CGPoint point = CGPointMake(currLeftMarginOfDTClassInfoView, CGRectGetHeight(classesShemeView.frame) - currTopMarginOfDTClassInfoView);
                [currDTClassInfoView movetoPoint: point];
                
                [nextRootLevelInfoViews addObject: currDTClassInfoView];
                
                currLeftMarginOfDTClassInfoView = currLeftMarginOfDTClassInfoView + currDTClassInfoView.width + horizontalSeparatorWidthOfDTClassInfoView;
                
                if (currLeftMarginOfDTClassInfoView > CGRectGetWidth(classesShemeView.frame))
                {
                    currLeftMarginOfDTClassInfoView = leftMarginOfDTClassInfoView;
                    currTopMarginOfDTClassInfoView = currTopMarginOfDTClassInfoView + heightOfDTClassInfoView + verticalSeparatorWidthOfDTClassInfoView;
                }
            }
        }
    }
    
    [self showNextLevelOfSElectedInfoViews: nextRootLevelInfoViews
                         selectedInfoViews: aSelectedInfoViews];
}

- (void) selectedOnly
{
    NSMutableArray* selectedViews = [NSMutableArray arrayWithCapacity: 0];
    
    for (DTClassInfoView* currDTClassInfoView in arrayClassInfo)
    {
        if ([currDTClassInfoView isNotSelected])
        {
            [currDTClassInfoView hide];
        }
        else
        {
            [selectedViews addObject: currDTClassInfoView];
        }
    }
    
    if ([selectedViews count] > 0)
    {
        DTClassInfoView* rootViewInfo = [self rootInSelectedViewsInfo: selectedViews];
        
        currLeftMarginOfDTClassInfoView = leftMarginOfDTClassInfoView;
        currTopMarginOfDTClassInfoView = heightOfDTClassInfoView + verticalSeparatorWidthOfDTClassInfoView;
        NSMutableArray* currLevelInfoViews = [NSMutableArray arrayWithCapacity: 0];

        if (rootViewInfo)
        {
            NSPoint point = CGPointMake(currLeftMarginOfDTClassInfoView, CGRectGetHeight(classesShemeView.frame) - currTopMarginOfDTClassInfoView);
            [rootViewInfo movetoPoint: point];
            [currLevelInfoViews addObject: rootViewInfo];
        }
        else
        {
            for (DTClassInfoView* currDTClassInfoView in selectedViews)
            {
                [currLevelInfoViews addObject: currDTClassInfoView];
            }
        }
        
        [self showNextLevelOfSElectedInfoViews: currLevelInfoViews
                             selectedInfoViews: selectedViews];
        
        [classesShemeView setNeedsDisplay: YES];
        [self scrollClassesShemeToTop];        
    }
}

#pragma mark -
#pragma mark Action handlers

- (IBAction) homeButtonPressed: (id) sender
{
    [self setHomeStateOfAllClassesView];
}

- (IBAction) selectedOnlyButtonPressed: (id) sender
{
    [self selectedOnly];
}

- (IBAction) saveAsPDF: (id) sender
{
    DTEnterSingleDataModalDialog* dlg = [[DTEnterSingleDataModalDialog alloc] initWithTitle: @"Save of classes sheme to PDF file"
                                                                                   text: @"File name:"
                                                                                 sender: self
                                                                                 target: self
                                                                                  okSel: @selector(saveContentToPDFfile:)
                                                                              cancelSel: nil];
    [dlg showModalDialog];
}

- (IBAction) dependencies: (id) sender
{
    
}

@end
