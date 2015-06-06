//
//  UIPopUpButton.h
//  DevToolsClient
//
//  Created by Krotkih Sergey on 27.11.12.
//  Copyright Quickoffice 2012. All rights reserved.
//

@interface UIPopUpButton : UIImageView <UIPopoverControllerDelegate, UIActionSheetDelegate>
{
    UIPopoverController* popoverController;
	Class popoverClass;
}

- (id) initWithPoint: (CGPoint) point;
- (void) touchesBegan: (NSSet*) touches
            withEvent: (UIEvent*) event;

+ (id) buttonAtPoint: (CGPoint) point;
+ (id) buttonAtOriginalPoint;
+ (void) unhighlight;
+ (void) bringButtonToFront;

@property (nonatomic, retain) UIPopoverController* popoverController;
@property (nonatomic, assign) Class popoverClass;

@end
