//
//  DTUIAutomationHelper.h
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DTUIAutomationHelper : NSObject
{
    NSArray* arrayViewsInfo;
    NSMutableArray* scripts;
}

- (id) initWithViewsInfoArray: (NSArray*) arrayViewsInfo;
- (NSString*) scriptForSelect: (NSString*) aSelect;

@end
