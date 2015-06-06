//
//  TreeViewController.m
//  RuntimeBrowser
//
//  Created by Nicolas Seriot on 17.01.09.
//  Copyright 2009 Sen:te. All rights reserved.
//

#import "TreeViewNavigationController.h"
#import "TreeViewController.h"

@implementation TreeViewNavigationController

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

- (void) viewDidLoad
{
    [super viewDidLoad];

	TreeViewController* tvc = [[TreeViewController alloc] initWithNibName: @"TreeViewController"
                                                                   bundle: gDevToolsClientResBundle];
	tvc.isSubLevel = NO;
	[self pushViewController: tvc
                    animated: NO];
	[tvc release];
}

@end
