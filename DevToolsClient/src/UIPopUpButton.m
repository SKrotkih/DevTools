//
//  UIPopUpButton.m
//  DevToolsClient
//
//  Created by Krotkih Sergey on 27.11.12.
//  Copyright Quickoffice 2012. All rights reserved.
//

#import "UIPopUpButton.h"
#import "DevToolsClientController.h"
#import "DevToolsPopoverMenuController.h"

@implementation UIPopUpButton

static UIPopUpButton* button = nil;
static CGPoint originalPoint;

@synthesize popoverClass;
@synthesize popoverController;

+ (id) buttonAtPoint: (CGPoint) point
{
	if (button == nil)
    {
		button = [[UIPopUpButton alloc] initWithPoint: point];
		originalPoint = point;
        button.popoverClass = [UIPopoverController class];
	}
    else
    {
		button.frame = CGRectMake(point.x, point.y, button.frame.size.width, button.frame.size.height);
	}

	return button;
}

+ (id) buttonAtOriginalPoint
{
	return [self buttonAtPoint: originalPoint];
}

+ (void) unhighlight
{
	button.highlighted = NO;
}

+ (void) bringButtonToFront
{
    id<UIApplicationDelegate> appDelegate = [UIApplication sharedApplication].delegate;
    UIViewController* rootViewController = appDelegate.window.rootViewController;
    [rootViewController.view addSubview: [self buttonAtOriginalPoint]];
}

- (id) initWithPoint: (CGPoint) point
{
    UIImage* image1 = [UIImage imageNamed: [NSString stringWithFormat: @"%@uibug.png", gDevToolsClientResBundlePath]];
    UIImage* image2 = [UIImage imageNamed: [NSString stringWithFormat: @"%@uibug2.png", gDevToolsClientResBundlePath]];

    if ((self = [super initWithImage: image1
                    highlightedImage: image2]))
    {
		self.userInteractionEnabled = YES;
		self.frame = CGRectMake(point.x, point.y, self.frame.size.width, self.frame.size.height);
        self.multipleTouchEnabled = NO;
	}

	return self;
}

- (BOOL) isAppCurrStatus
{
    return ([DevToolsClientController sharedInstance].statusOfRootViewController == FrontEndApplication);
}

- (void) touchesBegan: (NSSet*) touches withEvent: (UIEvent*) event
{
	UITouch* touch = [touches anyObject];
    
	if(touch.view == self)
	{
        if (self.popoverController == nil)
        {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            {
                NSArray* actions;
                
                if ([self isAppCurrStatus])
                {
                    actions = [[NSArray alloc] initWithObjects:
                               @"Dev tools",
                               @"Start the UI test",
                               @"Views report",
                               nil];
                }
                else
                {
                    actions = [[NSArray alloc] initWithObjects:
                               @"Application",
                               @"Start the UI test",
                               @"Views report",
                               @"Open console",
                               @"Enable Inspector",
                               nil];
                }
                
                UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle: @"Please choice operation:"
                                                                        delegate: self
                                                               cancelButtonTitle: nil
                                                          destructiveButtonTitle: nil
                                                               otherButtonTitles: nil];
                [actionSheet addButtonWithTitle: @"Cancel"];
                actionSheet.cancelButtonIndex = 0;
                
                for (int i = 1; i <= [actions count]; i++)
                {
                    [actionSheet addButtonWithTitle: [actions objectAtIndex: i - 1]];
                }
                
                actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
                [actionSheet setTag: 0];
                [actionSheet setDelegate: self];
                [actionSheet showInView: [self superview]];
                [actionSheet release];
                [actions release];
            }
            else
            {
                DevToolsPopoverMenuController* contentViewController = [[DevToolsPopoverMenuController alloc] init];
                self.popoverController = [[UIPopoverController alloc] initWithContentViewController: contentViewController];
                popoverController.delegate = self;
                [popoverController presentPopoverFromRect: CGRectMake(10.0f, 10.0f, 5.0f, 5.0f)
                                                   inView: self
                                 permittedArrowDirections: UIPopoverArrowDirectionAny
                                                 animated: YES];
                contentViewController.popoverController = self.popoverController;
                [contentViewController reloadData];
            }
        }
        else
        {
            [self.popoverController dismissPopoverAnimated:YES];
            self.popoverController = nil;
        }
    }
    
    [super touchesBegan: touches withEvent: event];
}



#pragma mark UIActionSheetDelegate implementation

-(void) actionSheet: (UIActionSheet*) actionSheet clickedButtonAtIndex: (NSInteger) buttonIndex
{
    NSNumber* indexAction = [[[NSNumber alloc] initWithInt: buttonIndex - 1] autorelease];
    [self performSelectorOnMainThread: @selector(runAction:)
                           withObject: indexAction
                        waitUntilDone: NO];
}

- (void) runAction: (NSNumber*) indexAction
{
    [DevToolsPopoverMenuController runAction: [indexAction integerValue]];
}

#pragma mark -
#pragma mark UIPopoverControllerDelegate implementation

- (void) popoverControllerDidDismissPopover: (UIPopoverController*) thePopoverController
{
    if (self.popoverController != nil)
    {
        self.popoverController = nil;
    }
}

- (BOOL) popoverControllerShouldDismissPopover: (UIPopoverController*) thePopoverController
{
	//The popover is automatically dismissed if you click outside it, unless you return NO here
	return YES;
}

@end
