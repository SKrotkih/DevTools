#import "DescribeUICatalog.h"
#import <UISpec/UIExpectation.h>

@implementation DescribeUICatalog

-(void) beforeAll
{
    DTTraceLog();
	app = [[UIQuery withApplication] retain];
}

- (void) afterAll
{
    DTTraceLog();
	[app release];
}

@end

