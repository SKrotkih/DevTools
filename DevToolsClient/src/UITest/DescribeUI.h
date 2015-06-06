#import <UISpec/UISpec.h>
#import <UISpec/UIQuery.h>
#import <UISpec/SpecsOutputData.h>
#import <UISpec/UIExpectation.h>

@interface DescribeUI: NSObject <UISpec>
{
	UIQuery* app;
}

- (void) beforeAll;
- (void) afterAll;

@end
