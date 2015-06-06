#import "DescribeControls.h"
#import "Constants.h"
#import <UISpec/SpecsOutputData.h>

@implementation DescribeControls

- (void) beforeAll
{
    DTTraceLog();
    [super beforeAll];

	[[app.label.with text: @"Controls"] flash].touch;
	[app wait: 1];

    [SpecsOutputData sendViewsMapWithName: NSStringFromClass([self class])];
    
	DTLog(@"DescribeControls started");
}

- (void) afterAll
{
    DTTraceLog();
	[super afterAll];
	[[app.navigationItemButtonView flash] touch];

	DTLog(@"DescribeControls finished");
}

- (void) itShouldToggleASwitch
{
    DTTraceLog();
	DTLog(@"Begin");
	UISwitch* aSwitch = app.Switch.flash;
	[expectThat(aSwitch.on) should: be(NO)];
	aSwitch.on = YES;
	[expectThat(aSwitch.on) should: be(YES)];
	aSwitch.on = NO;
	[expectThat(aSwitch.on) should: be(NO)];
	DTLog(@"End");
}

- (void) itShouldMoveAStandardSlider
{
    DTTraceLog();
	DTLog(@"Begin");
    
	//We use index 1 because a UISwitch is actually a UISlider too
	[self moveSlider: [app.slider index: 0].flash];

	DTLog(@"End");
}

- (void) itShouldMoveACustomizedSlider
{
    DTTraceLog();
	DTLog(@"Begin");

	//We use index 2 because a UISwitch is actually a UISlider too
	[self moveSlider: [app.slider index: 1].flash];

	DTLog(@"End");
}

- (void) moveSlider:(UISlider *)slider
{
    DTTraceLog();
	DTLog(@"Begin");
    
	[slider setValue: slider.maximumValue
            animated: YES];
	[app wait: .5];
	[expectThat(slider.value) should: be(slider.maximumValue)];
	
	[slider setValue: slider.minimumValue
            animated: YES];
	[app wait: .5];
	[expectThat(slider.value) should: be(slider.minimumValue)];
    
	DTLog(@"End");
}

- (void) itShouldMoveAPageControl
{
    DTTraceLog();
	DTLog(@"Begin");

	[app.tableView scrollToBottom];
	[app wait: .5];
	UIPageControl *pageControl = app.pageControl.flash;
	int i = 1;

	while (i < pageControl.numberOfPages)
    {
		pageControl.currentPage = i;
		[app wait: .05];
		i++;
	}
	i--;

	while (i >= 0)
    {
		pageControl.currentPage = i;
		[app wait: .05];
		i--;
	}

	DTLog(@"End");
}

- (void) itShouldStopAndStartActivityIndicator
{
    DTTraceLog();
	DTLog(@"Begin");

	[app.tableView scrollToBottom];
	[app wait: .5];
	UIActivityIndicatorView *activity = app.activityIndicatorView.flash;
	[expectThat([activity isAnimating]) should:be(YES)];
	[activity stopAnimating];
	[app wait: .5];
	[expectThat([activity isAnimating]) should:be(NO)];
	[activity startAnimating];
	[app wait: .5];
	[expectThat([activity isAnimating]) should:be(YES)];

	DTLog(@"End");
}

-(void)itShouldMoveAProgressView
{
    DTTraceLog();
	DTLog(@"Begin");

	[app.tableView scrollToBottom];
	[app wait:.5];
	UIProgressView *progressView = app.progressView.flash;
	[expectThat(progressView.progress) should:be(0.5)];
	float i = 0.10;

	while (i < 1)
    {
		progressView.progress = i;
		[app wait:.05];
		i+=.10;
	}
	i-=.10;

	while (i >= 0.0)
    {
		progressView.progress = i;
		[app wait:.05];
		i-=.10;
	}

	DTLog(@"End");
}

@end

