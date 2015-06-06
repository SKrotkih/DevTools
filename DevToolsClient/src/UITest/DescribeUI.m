#import "DescribeUI.h"

@implementation DescribeUI

-(void) beforeAll
{
	app = [[UIQuery withApplication] retain];
}

- (void) afterAll
{
	[app release];
}

@end
