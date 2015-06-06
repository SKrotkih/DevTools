//
//  SearchViewController.m
//  RuntimeBrowser
//
//  Created by Nicolas Seriot on 18.01.09.
//  Copyright 2009 Sen:te. All rights reserved.
//

#import "SearchViewController.h"
#import "ClassDisplayViewController.h"
#import "ClassStub.h"
#import "ClassCell.h"
#import "AllClasses.h"

@implementation SearchViewController

@synthesize tableView;
@synthesize theSearchBar;
@synthesize foundClasses;
@synthesize allClasses;

- (id) initWithNibName: (NSString*) nibNameOrNil
                bundle: (NSBundle*) nibBundleOrNil
{
    if ((self = [super initWithNibName: nibNameOrNil
                                bundle: nibBundleOrNil]))
    {
        self.title = NSLocalizedString(@"Search", @"Tab bar item title");
        self.tabBarItem.image = [UIImage imageNamed: [NSString stringWithFormat: @"%@tab_hand", gDevToolsClientResBundlePath]];
    }
    
    return self;
}

- (void) viewDidLoad 
{
	self.title = @"Search";
	self.allClasses = [AllClasses sharedInstance];
	self.foundClasses = [NSMutableArray array];

	//theSearchBar.keyboardType = UIKeyboardTypeASCIICapable;
	theSearchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	theSearchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	theSearchBar.showsCancelButton = YES;

    [super viewDidLoad];
}

- (void) didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
	self.foundClasses = [NSMutableArray array];
}

- (void) dealloc 
{
	[allClasses release];
	[foundClasses release];
	[theSearchBar release];
	[tableView release];
    [super dealloc];
}

#pragma mark TableViewDataSouce protocol

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView 
{
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section 
{
    return [foundClasses count];
}

// Customize the appearance of table view cells.
- (UITableViewCell*) tableView: (UITableView*) aTableView cellForRowAtIndexPath: (NSIndexPath*) indexPath 
{
    
	static NSString* ClassCellIdentifier = @"ClassCell";
	
	ClassCell* cell = (ClassCell*)[aTableView dequeueReusableCellWithIdentifier: ClassCellIdentifier];

	if(cell == nil)
    {
		cell = (ClassCell *)[[gDevToolsClientResBundle loadNibNamed: @"ClassCell" 
                                                              owner: self 
                                                            options: nil] lastObject];
	}
	
	// Set up the cell
	ClassStub* cs = [foundClasses objectAtIndex: indexPath.row];
	cell.label.text = cs.stubClassname;
	cell.accessoryType = UITableViewCellAccessoryNone;
    cell.parentTableView = self;
	
    return cell;
}

- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
	ClassStub* cs = [foundClasses objectAtIndex: indexPath.row];
    [self onSelectCell: cs.stubClassname];
}

- (void) onSelectCell: (NSString *)className 
{
    ClassDisplayViewController* classDisplayVC = [[ClassDisplayViewController sharedInstance] retain]; 
	[self.navigationController pushViewController: classDisplayVC
                                         animated: YES];
    [classDisplayVC displayHeaderOfClassName: className]; 
}

#pragma mark UISearchBarDelegate protocol

- (void)searchBar: (UISearchBar*) searchBar textDidChange: (NSString *)searchText 
{
	//NSLog(@"textDidChange:%@", searchText);	

	if([searchBar.text length] == 0) 
    {
		[foundClasses removeAllObjects];
		[tableView reloadData];
	}
}

- (BOOL) searchBarShouldBeginEditing: (UISearchBar*) searchBar 
{
	return YES;
}

- (BOOL) searchBarShouldEndEditing: (UISearchBar *)searchBar 
{
	//NSLog(@"searchBarShouldEndEditing:");
	return YES;
}

- (void) searchBarCancelButtonClicked: (UISearchBar *)searchBar 
{
	[searchBar resignFirstResponder];
}

- (void) searchBarSearchButtonClicked: (UISearchBar *)searchBar 
{
	[searchBar resignFirstResponder];
	
	[foundClasses removeAllObjects];
	
	NSRange range;
	for(ClassStub *cs in [allClasses sortedClassStubs]) 
    {
		range = [[cs description] rangeOfString: searchBar.text 
                                        options: NSCaseInsensitiveSearch];
		if(range.location != NSNotFound) 
        {
			//NSLog(@"-- add %@", cs);
			[foundClasses addObject:cs];
		}
	}
	
	NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey: @"description" 
                                                       ascending: YES];
	[foundClasses sortUsingDescriptors: [NSArray arrayWithObject: sd]];
	[sd release];
	
	[tableView reloadData];
}

@end
