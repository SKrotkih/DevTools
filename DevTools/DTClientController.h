//
//  DTClientController.h
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DTClientController : NSObject
{
}

+ (void) runCommand: (NSString*) aCommand
               data: (NSString*) aData;

+ (void) runCommand: (NSString*) aCommand;

@end
