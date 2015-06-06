//
//  DTPrepareToTracing.h
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DTPrepareToTracing : NSWindowController
{
    IBOutlet NSTextField* pathToProject;
    IBOutlet NSTextField* pathToTemplateProject;
    IBOutlet NSProgressIndicator* progressIndicator;
}

- (IBAction) startScanProject: (id) sender;
- (IBAction) openDirectory: (id)sender;

@end
