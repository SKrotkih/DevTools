//
//  ClassDisplayViewController.h
//  RuntimeBrowser
//
//  Created by Nicolas Seriot on 31.08.08.
//  Copyright 2008 seriot.ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClassDisplayViewController : UIViewController 
{
	IBOutlet UITextView* textView;
    NSString* className;
}

@property (nonatomic, retain) IBOutlet UITextView* textView;

+ (ClassDisplayViewController*) sharedInstance;
- (void) displayHeaderOfClassName: (NSString*) aClassName;
- (IBAction) use: (id)sender;

@end
