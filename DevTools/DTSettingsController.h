//
//  DTSettingsController.h
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CCBModalSheetController.h"

@interface DTSettingsController : CCBModalSheetController <NSApplicationDelegate>
{
    IBOutlet NSTextField* myIP;
    IBOutlet NSTextField* serverPortNumber;
}

@end
