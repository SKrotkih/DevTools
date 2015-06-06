//
//  DTSelectClassesPopUpButton.h
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DTSelectClassesPopUpButton : NSPopUpButton <NSMenuDelegate>
{
    NSMutableArray* titles;
}

- (void) refreshListData;


@end
