//
//  ListTableViewController.h
//  RuntimeBrowser
//
//  Created by Nicolas Seriot on 18.01.09.
//  Copyright 2009 Sen:te. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate> 
{
	NSMutableArray* classStubsDictionaries;     // [{'A':classStubs}, {'B':classStubs}]
	NSArray* classStubs;
	NSString* frameworkName;                    // nil to display all classes
}

@property (nonatomic, retain) NSMutableArray* classStubsDictionaries;
@property (nonatomic, retain) NSArray* classStubs;
@property (nonatomic, retain) NSString* frameworkName;

@end
