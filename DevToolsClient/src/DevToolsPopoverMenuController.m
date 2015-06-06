//
//  DevToolsPopoverMenuController.m
//  DevToolsClient
//
//  Created by Krotkih Sergey on 27.11.12.
//  Copyright Quickoffice 2012. All rights reserved.
//

#import "DevToolsPopoverMenuController.h"
#import "DevToolsClientController.h"
#import <UISpec/SpecsOutputData.h>
#import <UISpec/UIBug.h>
#import <UISpec/UIInspector.h>

const int RowsCountApp = 5;
const int RowsCountDevTools = 3;
const float RowHeight = 44.0;
const float ViewWidth = 200.0;

@interface DevToolsPopoverMenuController()
- (BOOL) isAppCurrStatus;
@end

@implementation DevToolsPopoverMenuController

@synthesize popoverController;

#pragma mark -
#pragma mark Initialization

- (id) init
{
    if ((self = [super init]))
    {
		// Create table view
		table = [[UITableView alloc] initWithFrame: CGRectMake(0.0f, 0.0f, ViewWidth, ([self isAppCurrStatus] ? RowsCountApp : RowsCountDevTools) * RowHeight - 1)
                                             style: UITableViewStylePlain];
		
		table.delegate = self;
		table.dataSource = self;
        self.contentSizeForViewInPopover = CGSizeMake( ViewWidth, ([self isAppCurrStatus] ? RowsCountApp : RowsCountDevTools) * RowHeight - 1);
        table.rowHeight = RowHeight;
        self.view = table;
    }

    return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
    // Return the number of sections.
    return 1;
}

- (void) reloadData
{
    [table reloadData];
}

- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
    // Return the number of rows in the section.
    return [self isAppCurrStatus] ? RowsCountApp : RowsCountDevTools;
}

- (BOOL) isAppCurrStatus
{
    return ([DevToolsClientController sharedInstance].statusOfRootViewController == FrontEndApplication);
}

// Customize the appearance of table view cells.
- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: CellIdentifier] autorelease];
    }
    cell.textLabel.textColor = [UIColor blackColor];
    
    switch (indexPath.row)
    {
        case 0:
            cell.textLabel.text = [self isAppCurrStatus] ? @"Dev tools" : @"Application";
            break;
            
        case 1:
            cell.textLabel.text = @"Start the UI test";
            break;

        case 2:
            cell.textLabel.text = @"Views report";
            break;
            
        case 3:
            cell.textLabel.text = @"Open console";
            break;

        case 4:
            cell.textLabel.text = @"Enable Inspector";
            break;
            
        default:
            break;
    }

    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
    if (popoverController != nil)
    {
        [popoverController dismissPopoverAnimated: NO];
    }
    
    [DevToolsPopoverMenuController runAction: indexPath.row];
}

- (void) dealloc
{
    [super dealloc];
}

#pragma mark Run actions for menu choice

+ (void) runAction: (NSUInteger) numberOfAction
{
    switch (numberOfAction)
    {
        case 0:  // Change the app RootViewController
        {
            [[DevToolsClientController sharedInstance] changeStatusOfRootViewController];
            
            break;
        }
            
        case 1:  // Start UI testing
        {
            [[DevToolsClientController sharedInstance] runCommand: StartUITestingMessageId
                                                    contCommandID: @""
                                                             data: @""];
            
            break;
        }
            
        case 2:  // Views report
        {
            [SpecsOutputData sendCurrentViewsData];
            break;
        }
            
        case 3:  // Console
        {
			[[UIApplication sharedApplication].keyWindow addSubview: [UIBug console]];
            break;
        }
            
        case 4:  // Enable Inspector
        {
            //self.highlighted = YES;
			[UIInspector setInBrowserMode: NO];
            break;
        }
            
        default:
            break;
    }
}

@end

