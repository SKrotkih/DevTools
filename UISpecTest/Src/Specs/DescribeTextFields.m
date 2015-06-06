#import "DescribeTextFields.h"
#import "Constants.h"
#import <UISpec/SpecsOutputData.h>

@implementation DescribeTextFields

- (void) beforeAll
{
    DTTraceLog();
    [super beforeAll];
	[[app.label.with text: @"TextFields"] flash].touch;
	[app wait: 1];

    [SpecsOutputData sendViewsMapWithName: NSStringFromClass([self class])];

	DTLog(@"DescribeTextFields did start");
}

- (void) afterAll
{
    DTTraceLog();
	[super afterAll];

	[[app.navigationItemButtonView flash] touch];
	DTLog(@"DescribeTextFields did finish");
}

- (void) itShouldSetAndClearText
{
    DTTraceLog();
	DTLog(@"Begin");

	UITextField* textFieldNormal = [[app.textField placeholder: @"<enter text>"] flash];
	[textFieldNormal becomeFirstResponder];
	[app wait: 1];
	[expectThat(textFieldNormal.text) should: be(@"")];
	[textFieldNormal setText: @"Hello"];
	[expectThat(textFieldNormal.text) should: be(@"Hello")];
	
	//app.pushButton.touch;
	[app wait: 3];

	DTLog(@"End");
}

- (void) itShouldUseKeyboardToEnterText
{
    DTTraceLog();
	DTLog(@"Begin");

	UITextField* textFieldNormal = [[app.textField placeholder: @"<enter text>"] flash];
	[textFieldNormal becomeFirstResponder];
	[expectThat(textFieldNormal.text) should: be(@"")];
	
	app.imageView.all.show;

    UIQuery* keyPlane = [app view: @"UIKeyboardImpl"];
    UIView* kbKeyView = [[app view: @"UIKBKeyView"] index: 0];
    [keyPlane touchDownWithKey: [kbKeyView key] atPoint: CGPointMake(0, 0)];
    kbKeyView = [[app view: @"UIKBKeyView"] index: 0];
    [keyPlane touchDownWithKey: [kbKeyView key] atPoint: CGPointMake(0, 0)];
    
    // Press Done
	[[app view: @"UIKBKeyView"].all setUserInteractionEnabled: YES];
	[[app view: @"UIKBKeyView"] index: 0].touch;
	[[app view: @"UIKBKeyView"] index: 0].touch;
    
    //[keyPlane toggleShift];

	[app wait: 3];

	DTLog(@"End");
}

@end

