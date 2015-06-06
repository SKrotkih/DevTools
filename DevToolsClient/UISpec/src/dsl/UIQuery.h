//
//  UIQuery.h
//  UISpec
//
//  Created by Brian Knorr <btknorr@gmail.com>
//  Copyright(c) 2009 StarterStep, Inc., Some rights reserved.
//
#import "ViewFilterSwizzler.h"
#import "UIQueryExpectation.h"
#import <UIKit/UIKit.h>

@class UIFilter, UIRedoer;

UIQuery * $(NSMutableString *script, ...);

@interface UIQuery : ViewFilterSwizzler {
	UIQuery *first, *last, *all, *redo;
	UIFilter *with;
	UIQueryExpectation *should;
	UIQuery *parent, *child, *descendant, *find;
	UIQuery *touch, *show, *flash, *path, *inspect;
	NSMutableArray *views;
	NSString *className;
	UIRedoer *redoer;
	int timeout;
	BOOL filter, exists;
}

@property(nonatomic, readonly) UIFilter *with;
@property(nonatomic, readonly) UIQueryExpectation *should;
@property(nonatomic, readonly) UIQuery *parent, *child, *descendant, *find;
@property(nonatomic, readonly) UIQuery *touch, *flash, *show, *path, *inspect;
@property int timeout;
@property(nonatomic, retain) NSMutableArray *views;
@property(nonatomic, retain) NSString *className;
@property(nonatomic, retain) UIRedoer *redoer;
@property(nonatomic, readonly) UIQuery *first, *last, *all, *redo;

-(UIQuery *)find;
-(UIQuery *)descendant;
-(UIQuery *)child;
-(UIQuery *)parent;
-(UIQueryExpectation *)should;
-(UIFilter *)with;
-(id)initWithViews:(NSMutableArray *)_views className:(NSString *)_className filter:(BOOL)_filter;
-(NSArray *)collect:(NSArray *)views;
-(UIQuery *)target;
-(NSArray *)targetViews;
-(UIQuery *)timeout:(int)seconds;
-(id)templateFilter;
-(UIQuery *)index:(int)index;
-(UIQuery *)first;
-(UIQuery *)last;
-(UIQuery *)all;
-(UIQuery *)view:(NSString *)className;
-(UIQuery *)marked:(NSString *)mark;
-(UIQuery *)wait:(double)seconds;
-(id)redo;
-(BOOL)exists;
-(NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector;
-(void)forwardInvocation:(NSInvocation *)anInvocation;
-(BOOL)respondsToSelector:(SEL)aSelector;
-(UIQuery *)flash;
-(UIQuery *)show;
-(UIQuery *)path;
-(UIQuery *)inspect;
- (UIQuery *)touch;
-(NSString *)description;
-(void)logRange:(NSString *)prefix range:(NSRange)range;

+(id)withApplication;
+(NSDictionary *)describe:(id)object;
+(void)show:(NSArray *)views;
+(id)withViews:(NSMutableArray *)views className:(NSString *)className;
+(id)withViews:(NSMutableArray *)views className:(NSString *)className filter:(BOOL)filter;

@end

@interface UIView (UIQuery) 

@property(nonatomic, readonly) UIFilter *with;
@property(nonatomic, readonly) UIQueryExpectation *should;
@property(nonatomic, readonly) UIQuery *parent, *child, *descendant, *find;
@property(nonatomic, readonly) UIQuery *touch, *flash, *show, *path, *inspect;
@property int timeout;
@property(nonatomic, retain) NSMutableArray *views;
@property(nonatomic, retain) NSString *className;
@property(nonatomic, retain) UIRedoer *redoer;
@property(nonatomic, readonly) UIQuery *first, *last, *all, *redo;
@property BOOL exists;

-(UIQuery *)view:(NSString *)className;
-(UIQuery *)marked:(NSString *)mark;
-(UIQuery *)index:(int)index;
-(UIQuery *)timeout:(int)seconds;
-(UIQuery *)wait:(double)seconds;
-(UIQuery *)target;

@end



#ifdef __IPHONE_6_0
@interface UITouch ()
{
    NSTimeInterval _timestamp;
    UITouchPhase _phase;
    UITouchPhase _savedPhase;
    NSUInteger _tapCount;
    
    UIWindow *_window;
    UIView *_view;
    UIView *_gestureView;
    UIView *_warpedIntoView;
    NSMutableArray *_gestureRecognizers;
    NSMutableArray *_forwardingRecord;
    
    CGPoint _locationInWindow;
    CGPoint _previousLocationInWindow;
    UInt8 _pathIndex;
    UInt8 _pathIdentity;
    float _pathMajorRadius;

    struct {
        unsigned int _firstTouchForView:1;
        unsigned int _isTap:1;
        unsigned int _isDelayed:1;
        unsigned int _sentTouchesEnded:1;
        unsigned int _abandonForwardingRecord:1;
    } _touchFlags;
}
@end
#endif



