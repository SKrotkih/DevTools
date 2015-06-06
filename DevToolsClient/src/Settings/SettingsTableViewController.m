//
//  SettingsTableViewController.m
//  DevToolsClient
//
//  Created by Sergey Krotkih on 7/31/12.
//  Copyright (c) 2012 Quickoffice. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "LocalServerSettingsViewController.h"
#import "DevToolsServerSettingsViewController.h"

@implementation SettingsTableViewController

- (id) initWithNibName: (NSString*) nibNameOrNil
                bundle: (NSBundle*) nibBundleOrNil
{
    if ((self = [super initWithNibName: nibNameOrNil
                                bundle: nibBundleOrNil]))
    {
        self.title = NSLocalizedString(@"Settings", @"Tab bar item title");
        self.tabBarItem.image = [UIImage imageNamed: [NSString stringWithFormat: @"%@tab_settings", gDevToolsClientResBundlePath]];
		self.navigationItem.title = NSLocalizedString(@"Settings", @"Tab bar item title");
    }
    
    return self;
}


#pragma mark Table view methods

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
	return 1;
}

- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
	return 2;
}

- (UITableViewCell*) tableView: (UITableView*) tableView
         cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
	static NSString* ClassCellIdentifier = @"SettingsCell";
	
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: ClassCellIdentifier];
    
	if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                      reuseIdentifier: ClassCellIdentifier];
	}

    switch (indexPath.row)
    {
        case 0:
        {
            cell.textLabel.text = @"Local server";
            cell.imageView.image = [UIImage imageNamed: [NSString stringWithFormat: @"%@Attachment", gDevToolsClientResBundlePath]];
            break;
        }
            
        case 1:
        {
            cell.textLabel.text = @"DevTools server";
            cell.imageView.image = [UIImage imageNamed: [NSString stringWithFormat: @"%@Attachment", gDevToolsClientResBundlePath]];
            break;
        }
    }

	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}

- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
    switch (indexPath.row)
    {
        case 0:
        {
            LocalServerSettingsViewController* lsViewController = [[LocalServerSettingsViewController alloc] initWithNibName: @"LocalServerSettingsViewController"
                                                                                                                      bundle: gDevToolsClientResBundle];

            UINavigationController* navControler = self.navigationController;
            
            [navControler pushViewController: lsViewController
                                                 animated: YES];
            
            break;
        }
            
        case 1:
        {
            DevToolsServerSettingsViewController* dtViewController = [[DevToolsServerSettingsViewController alloc] init];
            [self.navigationController pushViewController: dtViewController
                                                 animated: YES];

            break;
        }
    }
}

@end
