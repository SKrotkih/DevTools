#import "DescribeWebView.h"
#import <UISpec/UIExpectation.h>
#import "Constants.h"
#import <UISpec/SpecsOutputData.h>

@implementation DescribeWebView

- (void) beforeAll
{
    DTTraceLog();
	DTLog(@"DescribeWebView start");
	[super beforeAll];
	[[app.label.with text: @"Web"] flash].touch;
	[app wait: 1];
    [SpecsOutputData sendViewsMapWithName: NSStringFromClass([self class])];
}

- (void) afterAll
{
    DTTraceLog();
	[super afterAll];
	[[app.navigationItemButtonView flash] touch];
	DTLog(@"DescribeWebView finish");
}

- (void) itShouldSetValueToURL
{
    DTTraceLog();
	DTLog(@"BEGIN");
	UITextField* textField = app.textField;
    id viewController = [textField delegate];
    
    NSString* URL = [textField text];
    //NSLog(@"%@", URL);

    [textField setText: @"http://mail.ru"];
    [expectThat(textField.text) should: be(@"http://mail.ru")];
	
    [textField becomeFirstResponder];
	[[app view: @"UIKBKeyView"].all setUserInteractionEnabled: YES];
	[[app view: @"UIKBKeyView"] index: 0].touch;  // 5 - backspace
	[[app view: @"UIKBKeyView"] index: 0].touch;  // 5 - backspace

    [viewController textFieldShouldReturn: textField];
    
    //textField app.textField setText: 'http://www.mail.ru'
    
	[app wait: 5.0f];
	DTLog(@"END");
}

-(void) itShouldSetValue
{
    DTTraceLog();
	DTLog(@"BEGIN");
    // don't work!
    [app.webView setValue: @"UISpec"
         forElementWithId: @"gbqfq"];  // query
	[app wait: 0.5];
	DTLog(@"END");
}

-(void) itShouldClickButton
{
    DTTraceLog();
	DTLog(@"BEGIN");
	[app.webView clickElementWithId: @"b"];
	DTLog(@"END");    
}

@end

