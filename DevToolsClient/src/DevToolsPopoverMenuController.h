//
//  DevToolsPopoverMenuController.h
//  DevToolsClient
//
//  Created by Krotkih Sergey on 27.11.12.
//  Copyright Quickoffice 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DevToolsPopoverMenuController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
	UITableView* table;
    UIPopoverController* popoverController;
}

+ (void) runAction: (NSUInteger) numberOfAction;

- (void) reloadData;

@property(nonatomic, readwrite, assign) UIPopoverController* popoverController;

@end
