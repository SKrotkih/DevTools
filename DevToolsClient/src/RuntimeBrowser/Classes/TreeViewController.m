//
//  TreeViewController.m
//  RuntimeBrowser
//
//  Created by Nicolas Seriot on 17.01.09.
//  Copyright 2009 Sen:te. All rights reserved.
//

#import "TreeViewController.h"
#import "AllClasses.h"
#import "ClassCell.h"
#import "ClassStub.h"
#import "ClassDisplayViewController.h"

@implementation TreeViewController

@synthesize classStubs;
@synthesize isSubLevel;
@synthesize allClasses;

- (id) initWithNibName: (NSString*) nibNameOrNil
                bundle: (NSBundle*) nibBundleOrNil
{
    if ((self = [super initWithNibName: nibNameOrNil
                                bundle: nibBundleOrNil]))
    {
        self.title = NSLocalizedString(@"Tree", @"Tab bar item title");
        self.tabBarItem.image = [UIImage imageNamed: [NSString stringWithFormat: @"%@tab_tree", gDevToolsClientResBundlePath]];
		self.navigationItem.title = @"Root Classes";
    }
    
    return self;
}

- (void) onSelectCell: (NSString *)className 
{
    ClassDisplayViewController* classDisplayVC = [[ClassDisplayViewController sharedInstance] retain]; 
	[self.navigationController pushViewController: classDisplayVC
                                         animated: YES];
    [classDisplayVC displayHeaderOfClassName: className]; 
}

- (void) viewDidLoad 
{
    [super viewDidLoad];
    
	self.allClasses = [AllClasses sharedInstance];
	if(!isSubLevel) 
    {
		self.classStubs = [allClasses rootClasses];
	}
}

- (void) viewWillAppear:(BOOL)animated 
{
	if(!isSubLevel) 
    {
		self.classStubs = [allClasses rootClasses]; // classes might have changed because of dynamic loading
	}

    [super viewWillAppear: animated];
}

#pragma mark Table view methods

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView 
{
    return 1;
}

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section 
{
	return [classStubs count];
}

- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath 
{
	
	static NSString* ClassCellIdentifier = @"ClassCell";
	
	ClassCell* cell = (ClassCell*)[tableView dequeueReusableCellWithIdentifier:ClassCellIdentifier];
	if(cell == nil) 
    {
        [ClassCell class];
        
		cell = (ClassCell*)[[gDevToolsClientResBundle loadNibNamed: @"ClassCell" 
                                                             owner: self 
                                                           options: nil] lastObject];
	}
	
	// Set up the cell
	ClassStub* cs = [classStubs objectAtIndex: indexPath.row];
	cell.label.text = cs.stubClassname;
	cell.accessoryType = [[cs subclassesStubs] count] > 0 ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    cell.parentTableView = self;
    
	return cell;
}

- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath 
{
	ClassStub* cs = [classStubs objectAtIndex: indexPath.row];
	
	if([[cs subclassesStubs] count] == 0)
    {
        [self onSelectCell: cs.stubClassname];
        
        return;
    }
	
	TreeViewController* tvc = [[TreeViewController alloc] initWithNibName: @"TreeViewController" 
                                                                   bundle: gDevToolsClientResBundle];
	tvc.isSubLevel = YES;
	tvc.classStubs = [cs subclassesStubs];
	tvc.title = cs.stubClassname;
	[self.navigationController pushViewController: tvc
                                         animated: YES];
	[tvc release];
}

- (void)dealloc 
{
	[allClasses release];
	[classStubs release];
    [super dealloc];
}

@end
