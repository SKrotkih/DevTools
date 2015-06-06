#import "UIDescendants.h"

@implementation UIDescendants

+ (id) withTraversal
{
	return [[[self alloc] init] autorelease];
}

- (NSArray*) collect: (NSArray*) views
{
	NSMutableArray *array = [NSMutableArray array];

	for (UIView *view in views)
    {
		[self collectDescendantsOnView:view inToArray: array];
	}

	return array;
}

- (void) collectDescendantsOnView: (UIView*) view
                        inToArray: (NSMutableArray*) array
{
	NSArray* subViews = nil;

    if ([view isKindOfClass: [UIApplication class]])
    {
        subViews = [view performSelector: @selector(windows)];
    }
    else
    {
        subViews = [view subviews];
    }
    
	for (UIView * v in [subViews reverseObjectEnumerator])
    {
		[array addObject: v];
	}

	for (UIView * v in [subViews reverseObjectEnumerator])
    {
		[self collectDescendantsOnView: v
                             inToArray: array];
	}
}

@end
