//
//  DTTransparentView.h
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DTTransparentView  : NSView
{
    CGRect _rect;
}

- (void) drawBorderForRect: (NSRect*) aRect;

@end