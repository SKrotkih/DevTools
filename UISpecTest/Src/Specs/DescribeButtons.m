#import "DescribeButtons.h"
#import "Constants.h"
#import <UISpec/SpecsOutputData.h>

@implementation DescribeButtons

-(void)beforeAll
{
    DTTraceLog();
	DTLog(@"DescribeButtons start");
    
    [super beforeAll];
	[[app.label.with text: @"Buttons"] flash].touch;
	[app wait: 1];

    [SpecsOutputData sendViewsMapWithName: NSStringFromClass([self class])];
}

-(void)afterAll
{
    DTTraceLog();
	[super afterAll];
	[[app.navigationItemButtonView flash] touch];

	DTLog(@"DescribeButtons finish");
}

-(void)itShouldBeTouchableByLabel
{
    DTTraceLog();
	DTLog(@"Begin");

	[[app.label text: @"Gray"] flash].touch;

	DTLog(@"End");
}

-(void)itShouldBeTouchableByImage
{
    DTTraceLog();
	DTLog(@"Begin");
    
	[[app.button.imageView image: [UIImage imageNamed: @"UIButton_custom.png"]] flash].touch;

	DTLog(@"End");
}

-(void)itShouldTouchAButtonByTitle
{
    DTTraceLog();
	DTLog(@"Begin");
    
	[[app.button.label text: @"Rounded"] flash].touch;

	DTLog(@"End");
}

-(void)itShouldBeTouchableByIndex
{
    DTTraceLog();
	DTLog(@"Begin");
    
	[[app.button index: 0] flash].touch;
	[[app.button index: 1] flash].touch;
	[[app.button index: 2] flash].touch;

	DTLog(@"End");
}

//This example fails due to a known bug in the sdk
//UIButton.buttonType always returns UIButtonTypeCustom
-(void)itShouldBeTouchableByType
{
    DTTraceLog();
	DTLog(@"Begin");
    
	[app.tableView scrollDown: 6];
	[app wait: 1];
	UIButton *detailDisclosureButton = [[app.button timeout: 1] buttonType: UIButtonTypeDetailDisclosure];
	[expectThat(detailDisclosureButton.exists) should: be(YES)];
	
	[[app.button buttonType: UIButtonTypeDetailDisclosure] flash].touch;
	[[app.button buttonType: UIButtonTypeInfoLight] flash].touch;
	[[app.button buttonType: UIButtonTypeInfoDark] flash].touch;
	[app.tableView scrollToBottom];
	[app wait: 1];
	[[app.button buttonType: UIButtonTypeContactAdd] flash].touch;

	DTLog(@"End");
}

@end

