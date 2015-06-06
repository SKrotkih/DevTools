//
//  DevToolsServerSettingsViewController.h
//  DevToolsClient
//
//  Created by Sergey Krotkih on 7/31/12.
//  Copyright (c) 2012 Quickoffice. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DevToolsServerSettingsViewController : UIViewController <UITextFieldDelegate>
{
    IBOutlet UITextField* remoteServerPortNumber;
    IBOutlet UITextField* remoteServerAddress;
    IBOutlet UILabel* isDevToolsServerConnected;
}

@end
