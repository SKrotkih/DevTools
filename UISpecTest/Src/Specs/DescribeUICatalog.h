#import <UISpec/UISpec.h>
#import <UISpec/UIQuery.h>

@interface DescribeUICatalog : NSObject <UISpec>
{
	UIQuery *app;
}

- (void) beforeAll;
- (void) afterAll;

@end
