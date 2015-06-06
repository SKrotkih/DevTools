//
//  SettingsNavigationController.m
//  RuntimeBrowser
//
//  Created by Nicolas Seriot on 17.01.09.
//  Copyright 2009 Sen:te. All rights reserved.
//

#import "SettingsNavigationController.h"
#import "SettingsTableViewController.h"

@implementation SettingsNavigationController

- (id) initWithNibName: (NSString*) nibNameOrNil
                bundle: (NSBundle*) nibBundleOrNil
{
    if ((self = [super initWithNibName: nibNameOrNil
                                bundle: nibBundleOrNil]))
    {
        self.title = NSLocalizedString(@"Settings", @"Tab bar item title");
        self.tabBarItem.image = [UIImage imageNamed: [NSString stringWithFormat: @"%@tab_settings", gDevToolsClientResBundlePath]];
		self.navigationItem.title = @"Settings";        
    }
    
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];

	SettingsTableViewController* tvc = [[SettingsTableViewController alloc] initWithNibName: @"SettingsTableViewController"
                                                                                     bundle: gDevToolsClientResBundle];
	[self pushViewController: tvc
                    animated: NO];
}

@end
