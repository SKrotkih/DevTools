//
//  LocalServerSettingsViewController.h
//  DevToolsClient
//
//  Created by Sergey Krotkih on 7/31/12.
//  Copyright (c) 2012 Quickoffice. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocalServerSettingsViewController : UIViewController <UITextFieldDelegate>
{
    IBOutlet UITextField* localServerPortNumber;
    IBOutlet UITextField* localServerHostName;
    IBOutlet UILabel* isLocalServerRunning;
}

@end
