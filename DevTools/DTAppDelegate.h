//
//  DTAppDelegate.h
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DTAppDelegate : NSObject <NSApplicationDelegate>
{
    NSWindow* window;
}

@property (assign) IBOutlet NSWindow* window;

@end
