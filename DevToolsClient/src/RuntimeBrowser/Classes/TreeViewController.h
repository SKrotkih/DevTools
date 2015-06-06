//
//  TreeViewController.h
//  RuntimeBrowser
//
//  Created by Nicolas Seriot on 17.01.09.
//  Copyright 2009 Sen:te. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AllClasses;

@interface TreeViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate> 
{
	BOOL isSubLevel;
	NSArray* classStubs;
	AllClasses* allClasses;
}

@property BOOL isSubLevel;
@property (nonatomic, retain) NSArray* classStubs;
@property (nonatomic, retain) AllClasses* allClasses;

@end
