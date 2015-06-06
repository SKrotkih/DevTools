//
//  ClassDisplayViewController.m
//  RuntimeBrowser
//
//  Created by Nicolas Seriot on 31.08.08.
//  Copyright 2008 seriot.ch. All rights reserved.
//

#import "ClassDisplayViewController.h"
#import "ClassDisplay.h"
#import "ObjectWithMethodsViewController.h"

static ClassDisplayViewController* _sharedInstance; 

@implementation ClassDisplayViewController

@synthesize textView;

+ (ClassDisplayViewController*) sharedInstance
{
    if (_sharedInstance == nil) 
    {
		_sharedInstance = [[ClassDisplayViewController alloc] initWithNibName: @"ClassDisplayViewController" 
                                                                       bundle: gDevToolsClientResBundle];
    }
    
    return _sharedInstance;
}

- (void) viewDidLoad
{
	textView.font = [UIFont systemFontOfSize: [UIFont smallSystemFontSize]];
	UIBarButtonItem* useBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCompose 
                                                                                      target: self 
                                                                                      action: @selector(use:)];
    useBarButtonItem.title = @"Use";
    self.navigationItem.rightBarButtonItem = useBarButtonItem;
    [useBarButtonItem release];
}

- (void) displayHeaderOfClassName: (NSString*) aClassName
{
    self.navigationItem.title = aClassName;
    className = aClassName;
	ClassDisplay* cd = [ClassDisplay createForClass: NSClassFromString(className)];
    NSMutableString* dependencies = [NSMutableString string];
	textView.text = [cd header: dependencies];
    
	//NSArray* forbiddenClasses = [NSArray arrayWithObjects: @"NSMessageBuilder", /*, @"NSObject", @"NSProxy", */@"Object", @"_NSZombie_", nil];
	//useButton.enabled = ![forbiddenClasses containsObject: className];
}

- (void)dealloc 
{
	[textView release];
	[super dealloc];
}

- (IBAction) use: (id)sender 
{
    ObjectWithMethodsViewController* objectWithMethodsVC = [[ObjectWithMethodsViewController sharedInstance] retain]; 
	objectWithMethodsVC.object = NSClassFromString(className);
	[self.navigationController pushViewController: objectWithMethodsVC
                                         animated: YES];
}

@end
