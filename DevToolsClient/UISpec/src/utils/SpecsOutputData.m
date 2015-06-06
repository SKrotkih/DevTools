#import "SpecsOutputData.h"
#import "SpecConstants.h"
#import "UISpec.h"
#import "UIQuery.h"
#import "UIDescendants.h"
#import "UIConsoleLog.h"

NSArray* textField;
NSArray* navigationBar;
NSArray* label;
NSArray* button;
NSArray* navigationButton;
NSArray* alertView;
NSArray* textView;
NSArray* tableView;
NSArray* tableViewCell;
NSArray* toolbar;
NSArray* toolbarButton;
NSArray* tabBar;
NSArray* tabBarButton;
NSArray* datePicker;
NSArray* window;
NSArray* webView;
NSArray* views;
NSArray* Switch;
NSArray* slider;
NSArray* segmentedControl;
NSArray* searchBar;
NSArray* scrollView;
NSArray* progressView;
NSArray* pickerView;
NSArray* pageControl;
NSArray* imageView;
NSArray* control;
NSArray* actionSheet;
NSArray* activityIndicatorView;
NSArray* threePartButton;
NSArray* navigationItemButtonView;
NSArray* navigationItemView;
NSArray* removeControlMinusButton;
NSArray* pushButton;

BOOL flagOfArraysFill;

@interface SpecsOutputData()
+ (NSArray*) contentFromString: (NSString*) aString fromSym: (NSString*) aFromSym toSym: (NSString*) aToSym;
@end

@implementation SpecsOutputData

+ (NSArray*) contentFromString: (NSString*) aString fromSym: (NSString*) aFromSym toSym: (NSString*) aToSym
{
    NSInteger ind = 0;
    NSInteger lenStr = [aString length];
    NSMutableArray* retVals = [NSMutableArray array];
    
    while (ind < lenStr)
    {
        if ([[aString substringWithRange: NSMakeRange(ind, 1)] isEqualToString: aFromSym])
        {
            NSMutableString* contStr = [NSMutableString string];

            ind++;

            while (ind < lenStr)
            {
                if ([[aString substringWithRange: NSMakeRange(ind, 1)] isEqualToString: aToSym])
                {
                    break;
                }
                [contStr appendString: [aString substringWithRange: NSMakeRange(ind, 1)]];

                ind++;
            }
            
            if ([contStr length] > 0)
            {
                [retVals addObject: contStr];
            }
        }

        ind++;
    }

    return retVals;
}

+ (void) sendCurrentViewsData
{
    dispatch_queue_t main_queue = dispatch_get_main_queue();
    dispatch_async(main_queue, ^{
        [SpecsOutputData sendViewsMapWithName: @"Current state"];
    });
}

+ (NSString*) property: (NSString*) aPropertyName forObject: (id) object
{
    id objValue;
    int intValue;
    long longValue;
    char *charPtrValue;
    char charValue;
    short shortValue;
    float floatValue;
    double doubleValue;
	NSString* property = @"";

    SEL selector = NSSelectorFromString(aPropertyName);
    if ([object respondsToSelector:selector])
    {
        NSMethodSignature *sig = [object methodSignatureForSelector:selector];
        //NSLog(@"sig = %@", sig);
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
        [invocation setSelector:selector];
        //NSLog(@"invocation selector = %@", NSStringFromSelector([invocation selector]));
        [invocation setTarget:object];
        
        @try
        {
            [invocation invoke];
        }
        @catch (NSException *exception)
        {
            NSLog(@"UIQuery.describe caught %@: %@", [exception name], [exception reason]);
        }
        
        const char* type = [[invocation methodSignature] methodReturnType];
        NSString *returnType = [NSString stringWithFormat:@"%s", type];
        const char* trimmedType = [[returnType substringToIndex:1] cStringUsingEncoding:NSASCIIStringEncoding];
        //NSLog(@"return type = %@", returnType);
        switch(*trimmedType)
        {
            case '@':
                [invocation getReturnValue:(void **)&objValue];
                if (objValue == nil) {
                    property = [NSString stringWithFormat:@"%@", objValue];
                } else {
                    property = objValue;
                }
                break;
            case 'i':
                [invocation getReturnValue:(void **)&intValue];
                property = [NSString stringWithFormat:@"%i", intValue];
                break;
            case 's':
                [invocation getReturnValue:(void **)&shortValue];
                property = [NSString stringWithFormat:@"%ud", shortValue];
                break;
            case 'd':
                [invocation getReturnValue:(void **)&doubleValue];
                property = [NSString stringWithFormat:@"%lf", doubleValue];
                break;
            case 'f':
                [invocation getReturnValue:(void **)&floatValue];
                property = [NSString stringWithFormat:@"%f", floatValue];
                break;
            case 'l':
                [invocation getReturnValue:(void **)&longValue];
                property = [NSString stringWithFormat:@"%ld", longValue];
                break;
            case '*':
                [invocation getReturnValue:(void **)&charPtrValue];
                property = [NSString stringWithFormat:@"%s", charPtrValue];
                break;
            case 'c':
                [invocation getReturnValue:(void **)&charValue];
                property = [NSString stringWithFormat:@"%d", charValue];
                break;
            case '{':
            {
                unsigned int length = [[invocation methodSignature] methodReturnLength];
                void *buffer = (void *)malloc(length);
                [invocation getReturnValue:buffer];
                NSValue* value = [[[NSValue alloc] initWithBytes:buffer objCType:type] autorelease];
                //CGRect frame = [value CGRectValue];
                property = [value description];
                break;
            }
        }
    }
    
    return [property copy];
}

+ (void) convertToWindowCoordineteForView: (UIView*) view point: (CGPoint*) point
{
    CGPoint newPoint = view.bounds.origin;
    newPoint = [view convertPoint: newPoint
                           toView: nil];
    
    
//    while (view.superview != nil)
//    {
//        newPoint = [view convertPoint: newPoint
//                               toView: view.superview];
//
////        if ([view.superview isKindOfClass: [UIWindow class]])
////        {
////            break;
////        }
//        
//        view = view.superview;
//    }

    *point = newPoint;
}

+ (void) appendInfoForView: (UIQuery*) view
                 outputStr: (NSMutableString*) str
                   onLevel: (NSUInteger) level
{
    NSMutableString* describeView = [NSMutableString string];
    
    [describeView appendString: [NSString stringWithFormat: @"%@", [view description]]];
    
    NSDictionary* extDescribe = [UIQuery describe: view];
    
    if ([[extDescribe allKeys] count] > 0)
    {
        Class clazz = [view class];
        [describeView appendString: [NSString stringWithFormat: @"\n=====\n%@%@", NSStringFromClass(clazz), [extDescribe description]]];
    }
    
    if ([view respondsToSelector: @selector(frame)])
    {
//        NSString* value = [self property: @"frame"
//                               forObject: view];
//        
//        CGRect frame = CGRectFromString(value);
//        [value release];

        UIView* v = (UIView*) view;
        CGRect bounds = v.bounds;
        
//        CGPoint newPoint;  // = [v convertPoint: v.bounds.origin toView: nil];
//        [SpecsOutputData convertToWindowCoordineteForView: v point: &newPoint];
        
        CGPoint newCoord = [v convertPoint: v.bounds.origin
                                    toView: nil];
        CGRect newFrame = CGRectMake(newCoord.x, newCoord.y, CGRectGetWidth(bounds), CGRectGetHeight(bounds));

        NSString* strNewFrame = NSStringFromCGRect(newFrame);
        
        CGFloat loc = [describeView rangeOfString: @"frame = (" options: NSCaseInsensitiveSearch].location;
        
        if (loc != NSNotFound)
        {
            NSString* ss = [describeView substringFromIndex: loc];
            CGFloat loc2 = [ss rangeOfString: @")" options: NSCaseInsensitiveSearch].location;
            NSRange range = {loc, loc2 + 1.0f};
            NSString* oldFrame = [describeView substringWithRange: range];
            NSString* frame = [NSString stringWithFormat: @"absframe = %@; %@", strNewFrame, oldFrame];
            describeView = [NSMutableString stringWithString: [describeView stringByReplacingOccurrencesOfString: oldFrame
                                                                                                      withString: frame]];
        }
    }
    
    NSString* strLevel = [NSString stringWithFormat: @"%d-%@", level, [@"" stringByPaddingToLength: level * 1
                                                                                       withString: @"-"
                                                                                  startingAtIndex: 0]];
    NSString* typeView = [self typeView: view];
    
    [str appendString: [NSString stringWithFormat: @"#%@%@;%@#\n\n", strLevel, describeView, typeView]];
}

+ (void) arangeViews: (UIQuery*) aView onLevel: (NSUInteger) aLevel output: (NSMutableString*) outputStr
{
    for (UIView* subView in [(UIView*)aView subviews])
    {
        [SpecsOutputData appendInfoForView: (UIQuery*) subView
                                 outputStr: outputStr
                                   onLevel: aLevel];
        [SpecsOutputData arangeViews: (UIQuery*) subView
                             onLevel: aLevel + 1
                              output: outputStr];
    }
}

+ (void) sendViewsMapWithName: (NSString*) aMapName
{
    NSMutableString* str = [NSMutableString stringWithString: @""];
    [str appendString: [NSString stringWithFormat: @"%@~", aMapName]];
    UIQuery* app = [UIQuery withApplication];
    NSArray* targetViews = app.find.target.views;
    flagOfArraysFill = YES;
    
    for (UIQuery* view in targetViews)
    {
        if ([view isKindOfClass: [UIWindow class]])
        {
            [SpecsOutputData appendInfoForView: view
                                     outputStr: str
                                       onLevel: 0];
            [SpecsOutputData arangeViews: view
                                 onLevel: 1
                                  output: str];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName: ViewsMapNotificationId
                                                        object: str];
}

+ (BOOL) isView: (UIQuery*) aView
 kindOfUIObject: (NSArray*) anViewArray
{
	for (UIQuery* view in anViewArray)
    {
        if (aView == view)
        {
            return YES;
        }
    }
    
    return NO;
}

+ (NSString*) typeView: (UIQuery*) aView
{
    if (flagOfArraysFill)
    {
        flagOfArraysFill = NO;
        
        UIQuery* app = [UIQuery withApplication];
        
        textField = app.textField.target.views;
        navigationBar = app.navigationBar.target.views;
        label = app.label.target.views;
        button = app.button.target.views;
        navigationButton = app.navigationButton.target.views;
        alertView = app.alertView.target.views;
        textView = app.textView.target.views;
        tableView = app.tableView.target.views;
        tableViewCell = app.tableViewCell.target.views;
        toolbar = app.toolbar.target.views;
        toolbarButton = app.toolbarButton.target.views;
        tabBar = app.tabBar.target.views;
        tabBarButton = app.tabBarButton.target.views;
        datePicker = app.datePicker.target.views;
        window = app.window.target.views;
        webView = app.webView.target.views;
        views = app.view.target.views;
        Switch = app.Switch.target.views;
        slider = app.slider.target.views;
        segmentedControl = app.segmentedControl.target.views;
        searchBar = app.searchBar.target.views;
        scrollView = app.scrollView.target.views;
        progressView = app.progressView.target.views;
        pickerView = app.pickerView.target.views;
        pageControl = app.pageControl.target.views;
        imageView = app.imageView.target.views;
        control = app.control.target.views;
        actionSheet = app.actionSheet.target.views;
        activityIndicatorView = app.activityIndicatorView.target.views;
        threePartButton = app.threePartButton.target.views;
        navigationItemButtonView = app.navigationItemButtonView.target.views;
        navigationItemView = app.navigationItemView.target.views;
        removeControlMinusButton = app.removeControlMinusButton.target.views;
        pushButton = app.pushButton.target.views;
    }
	
    NSMutableString* typeView = [NSMutableString string];
    
    if ([SpecsOutputData isView: aView kindOfUIObject: navigationBar])
    {
        [typeView appendString: @"_navigationBar,"];
    }
    if ([SpecsOutputData isView: aView kindOfUIObject: label])
    {
        NSString* title = [(UILabel*) aView text];
        
        if ([title length] > 0)
        {
            [typeView appendString: [NSString stringWithFormat: @"check label with text '%@',", title]];  // [[app.label text: @"Gray"] flash].touch;
        }
        else
        {
            [typeView appendString: @"_label,"];
        }
    }
    if ([SpecsOutputData isView: aView kindOfUIObject: button])
    {
        NSString* title = [((UIButton*) aView).titleLabel text];
        
        if (title)
        {
            [typeView appendString: [NSString stringWithFormat: @"touch button with text '%@',", title]];  // [[app.button.label text: @"Rounded"] flash].touch;
        }
        else
        {
            [typeView appendString: @"_button,"];
        }
    }
    if ([SpecsOutputData isView: aView kindOfUIObject: navigationButton])
    {
        [typeView appendString: [NSString stringWithFormat: @"touch navigation button,"]];  // [[app.navigationButton flash] touch];
    }
    if ([SpecsOutputData isView: aView kindOfUIObject: alertView])
    {
        [typeView appendString: @"_alertView,"];
    }
    if ([SpecsOutputData isView: aView kindOfUIObject: textField])
    {
        NSString* placeholder = [(UITextField*) aView placeholder];
        
        if ([placeholder length] > 0)
        {
            [typeView appendString: [NSString stringWithFormat: @"enter text 'Hello' to UITextField with placeholder '%@',", placeholder]];
        }
        else
        {
            [typeView appendString: @"_textField,"];
        }
    }
    if ([SpecsOutputData isView: aView kindOfUIObject: textView])
    {
        [typeView appendString: @"_textView,"];
    }
    if ([SpecsOutputData isView: aView kindOfUIObject: tableView])
    {
        [typeView appendString: @"scroll to bottom on UITableView,"];  // [app.tableView scrollToBottom];
        [typeView appendString: @"scroll to top on UITableView,"];     // [app.tableView scrollToTop];
        [typeView appendString: @"scroll on 1 row on UITableView,"];   // [app.tableView scrollDown: 1];
        [typeView appendString: @"scroll on 1 row on UITableView,wait 1 sec,scroll on 1 row on UITableView,wait 1 sec,scroll on 1 row on UITableView,"];  // [app.tableView scrollDown: 1];
    }
    if ([SpecsOutputData isView: aView kindOfUIObject: tableViewCell])
    {
        [typeView appendString: @"_tableViewCell,"];
    }
    if ([SpecsOutputData isView: aView kindOfUIObject: toolbar])
    {
        [typeView appendString: @"_toolbar,"];
    }
    if ([SpecsOutputData isView: aView kindOfUIObject: toolbarButton])
    {
        [typeView appendString: @"_toolbarButton,"];
    }
    if ([SpecsOutputData isView: aView kindOfUIObject: tabBar])
    {
        [typeView appendString: @"_tabBar,"];
    }
    if ([SpecsOutputData isView: aView kindOfUIObject: tabBarButton])
    {
        [typeView appendString: @"_tabBarButton,"];
    }
    if ([SpecsOutputData isView: aView kindOfUIObject: datePicker])
    {
        [typeView appendString: @"_datePicker,"];
    }
    if ([SpecsOutputData isView: aView kindOfUIObject: window])
    {
        [typeView appendString: @"_window,"];
    }
    if ([SpecsOutputData isView: aView kindOfUIObject: webView])
    {
        [typeView appendString: @"_webView,"];
    }
    if ([SpecsOutputData isView: aView kindOfUIObject: views])
    {
        [typeView appendString: @"_view,"];
    }
    if ([SpecsOutputData isView: aView kindOfUIObject: Switch])
    {
        [typeView appendString: [NSString stringWithFormat: @"UISwith on,is UISwitch on?,UISwith off,is UISwitch off?,"]];
    }
    if ([SpecsOutputData isView: aView kindOfUIObject: slider])
    {
        [typeView appendString: @"_slider,"];
    }
    if ([SpecsOutputData isView: aView kindOfUIObject: segmentedControl])
    {
        [typeView appendString: @"_segmentedControl,"];
    }
    if ([SpecsOutputData isView: aView kindOfUIObject: searchBar])
    {
        [typeView appendString: @"_searchBar,"];
    }
    if ([SpecsOutputData isView: aView kindOfUIObject: scrollView])
    {
        [typeView appendString: @"_scrollView,"];
    }
    if ([SpecsOutputData isView: aView kindOfUIObject: progressView])
    {
        [typeView appendString: @"_progressView,"];
    }
    if ([SpecsOutputData isView: aView kindOfUIObject: pickerView])
    {
        [typeView appendString: @"_pickerView,"];
    }
    if ([SpecsOutputData isView: aView kindOfUIObject: pageControl])
    {
        [typeView appendString: @"_pageControl,"];
    }
    if ([SpecsOutputData isView: aView kindOfUIObject: imageView])
    {
        [typeView appendString: @"_imageView,"];
    }
    if ([SpecsOutputData isView: aView kindOfUIObject: control])
    {
        [typeView appendString: @"_control,"];
    }
    if ([SpecsOutputData isView: aView kindOfUIObject: actionSheet])
    {
        [typeView appendString: @"_actionSheet,"];
    }
    if ([SpecsOutputData isView: aView kindOfUIObject: activityIndicatorView])
    {
        [typeView appendString: @"_activityIndicatorView,"];
    }
    if ([SpecsOutputData isView: aView kindOfUIObject: threePartButton])
    {
        [typeView appendString: @"_threePartButton,"];
    }
    if ([SpecsOutputData isView: aView kindOfUIObject: navigationItemButtonView])
    {
        [typeView appendString: [NSString stringWithFormat: @"touch navigation item button,"]];  // [[app.navigationItemButtonView flash] touch];
    }
    if ([SpecsOutputData isView: aView kindOfUIObject: navigationItemView])
    {
        [typeView appendString: @"_navigationItemView,"];
    }
    if ([SpecsOutputData isView: aView kindOfUIObject: removeControlMinusButton])
    {
        [typeView appendString: @"_removeControlMinusButton,"];
    }
    if ([SpecsOutputData isView: aView kindOfUIObject: pushButton])
    {
        [typeView appendString: @"_pushButton,"];
    }
    
    return typeView;
}

+ (void) runScriptItem: (NSString*) aScriptItem
{
    NSArray* items = [aScriptItem componentsSeparatedByString: @";"];
    
    if ([items count] > 0)
    {
        UIConsoleLog* logger = [[UIConsoleLog alloc] init];
        [logger onExample: @"Test session"];
		
        @try
        {
            UIQuery* app = [UIQuery withApplication];
            
            [logger onSpec: (UISpec*)[SpecsOutputData class]];
            
            for (NSString* item in items)
            {
                
                NSLog(@"%@", item);
                
                [logger onBefore: item];
                
                if ([item isEqualToString: @"touch navigation item button"])
                {
                    [[app.navigationItemButtonView flash] touch];
                }
                else if ([item isEqualToString: @"is UISwitch on?"])
                {
                    UISwitch* aSwitch = (UISwitch*) app.Switch.flash;
                    [expectThat(aSwitch.on) should: be(YES)];
                }
                else if ([item isEqualToString: @"UISwith on"])
                {
                    UISwitch* aSwitch = (UISwitch*) app.Switch.flash;
                    aSwitch.on = YES;
                }
                else if ([item isEqualToString: @"is UISwitch off?"])
                {
                    UISwitch* aSwitch = (UISwitch*) app.Switch.flash;
                    [expectThat(aSwitch.on) should: be(NO)];
                }
                else if ([item isEqualToString: @"UISwith off"])
                {
                    UISwitch* aSwitch = (UISwitch*) app.Switch.flash;
                    aSwitch.on = NO;
                }
                else if ([item isEqualToString: @"scroll to bottom on UITableView"])
                {
                    [app.tableView scrollToBottom];
                }
                else if ([item isEqualToString: @"scroll to top on UITableView"])
                {
                    [app.tableView scrollToTop];
                }
                else if ([item isEqualToString: @"scroll on 1 row on UITableView"])
                {
                    [app.tableView scrollDown: 1];
                }
                else if ([item hasPrefix: @"wait "] && [item hasSuffix: @" sec"])
                {
                    CGFloat secs = [[[self contentFromString: item fromSym: @" " toSym: @" "] objectAtIndex: 0] floatValue];
                    [app wait: secs];
                }
                else if ([item rangeOfString: @"to UITextField with placeholder"].location != NSNotFound)
                {
                    // enter text 'Hello' to UITextField with placeholder '%@'
                    NSString* text = [[self contentFromString: item fromSym: @"'" toSym: @"'"] objectAtIndex: 0];
                    NSString* placeholder = [[self contentFromString: item fromSym: @"'" toSym: @"'"] objectAtIndex: 1];
                    
                    UITextField* textFieldNormal = [[app.textField placeholder: placeholder] flash];
                    [textFieldNormal becomeFirstResponder];
                    [app wait: 1];
                    [textFieldNormal setText: @""];
                    [expectThat(textFieldNormal.text) should: be(@"")];
                    [textFieldNormal setText: text];
                    [expectThat(textFieldNormal.text) should: be(text)];
                }
                else if ([item hasPrefix: @"check label with text"])
                {
                    // check label with text '%@'
                    NSString* text = [[self contentFromString: item fromSym: @"'" toSym: @"'"] objectAtIndex: 0];
                    [[app.label text: text] flash].touch;
                }
                else if ([item hasPrefix: @"touch button with text"])
                {
                    NSString* text = [[self contentFromString: item fromSym: @"'" toSym: @"'"] objectAtIndex: 0];
                    [[app.button.label text: text] flash].touch;
                }
            }
		}
        @catch (NSException* exception)
        {
			[logger onExampleException: exception];
		}
        
        [logger onFinish: 1];
        [logger release];
    }
}

@end
