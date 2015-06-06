//
//  DTClientController.m
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import "DTClientController.h"
#import "DTConstants.h"

@implementation DTClientController

+ (void) runCommand: (NSString*) aCommand
               data: (NSString*) aData
{
    NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys: aCommand, CommandKeyForJSONdictionary,
                                                                          aData, DataKeyForJSONdictionary, nil];
    
    if ([NSJSONSerialization isValidJSONObject: dict])
    {
        NSData* data = [NSJSONSerialization dataWithJSONObject: dict
                                                       options: 0
                                                         error: nil];
        [[NSNotificationCenter defaultCenter] postNotificationName: SendDataNotificationId
                                                            object: data];
    }

    [dict release];
}

+ (void) runCommand: (NSString*) aCommand
{
    [DTClientController runCommand: aCommand
                            data: @""];
}

@end
