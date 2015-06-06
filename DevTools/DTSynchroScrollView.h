//
//  DTSynchroScrollView.h
//  DevTools
//
//  Created by Sergey Krotkih on 5/15/13.
//
//

#import <Cocoa/Cocoa.h>

@interface DTSynchroScrollView : NSScrollView
{
    NSScrollView* synchronizedScrollView; // not retained
}

- (void)setSynchronizedScrollView: (NSScrollView*) scrollview;
- (void)stopSynchronizing;
- (void)synchronizedViewContentBoundsDidChange: (NSNotification*) notification;

@end
