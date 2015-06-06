//
//  DTUIAutomationHelper.m
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import "DTUIAutomationHelper.h"
#import "DTViewInfo.h"

@interface DTUIAutomationHelper ()
- (void) fillData;
@end

@implementation DTUIAutomationHelper

- (id) initWithViewsInfoArray: (NSArray*) anArrayViewsInfo
{
    if ((self = [super init]))
    {
        arrayViewsInfo = anArrayViewsInfo;
        scripts = [[NSMutableArray alloc] init];
        [self fillData];
    }
    
    return self;
}

- (void) dealloc
{
    [scripts release];
    
    [super dealloc];
}

- (NSString*) scriptForSelect: (NSString*) aSelect
{
    NSInteger index = 0;
    
    while (index < [arrayViewsInfo count])
    {
        DTViewInfo* currViewInfo = [arrayViewsInfo objectAtIndex: index];
        
        if ([currViewInfo.content isEqualToString: aSelect])
        {
            return [scripts objectAtIndex: index];
        }
        
        index++;
    }
    
    return @"";
}


- (void) fillData
{
    NSUInteger viewsInfoCount = [arrayViewsInfo count];
    NSInteger index = 0;
    
    while (index < viewsInfoCount)
    {
        NSString* str = nil;
        
        DTViewInfo* currViewInfo = [arrayViewsInfo objectAtIndex: index];
        
        NSString* className = currViewInfo.className;
        NSString* textOnView = currViewInfo.text;
        NSString* suffixName = @"";
        
        if (textOnView != nil)
        {
            NSArray* arr = [textOnView componentsSeparatedByString: @"\n"];
            
            if ([arr count] > 1)
            {
                textOnView = [arr objectAtIndex: 0];
            }
            
            suffixName = [textOnView stringByReplacingOccurrencesOfString: @" "
                                                               withString: @"_"];
            suffixName = [suffixName stringByReplacingOccurrencesOfString: @"."
                                                               withString: @"_"];
            suffixName = [suffixName stringByReplacingOccurrencesOfString: @":"
                                                               withString: @""];
        }
        
        if ([className isEqualToString: @"UIActionSheet"])
        {
            
        }
        else if ([className isEqualToString: @"UIActivityIndicator"])
        {
            
        }
        else if ([className isEqualToString: @"UIActivityView"])
        {
            
        }
        else if ([className isEqualToString: @"UIAlert"])
        {
            
        }
        else if ([className isEqualToString: @"UIApplication"])
        {
            
        }
        else if ([className isEqualToString: @"UICollectionView"])
        {
            
        }
        else if ([className isEqualToString: @"UIEditingMenu"])
        {
            
        }
        else if ([className isEqualToString: @"UIElement"])
        {
            
        }
        else if ([className isEqualToString: @"UIElementArray"])
        {
            
        }
        else if ([className isEqualToString: @"UIHost"])
        {
            
        }
        else if ([className isEqualToString: @"UIKey"])
        {
            
        }
        else if ([className isEqualToString: @"UIKeyboard"])
        {
            
        }
        else if ([className isEqualToString: @"UILink"])
        {
        }
        else if ([className isEqualToString: @"UILogger"])
        {
            
        }
        else if ([className isEqualToString: @"UINavigationBar"])
        {
            
        }
        else if ([className isEqualToString: @"UIPageIndicator"])
        {
            
        }
        else if ([className isEqualToString: @"UIPicker"])
        {
            
        }
        else if ([className isEqualToString: @"UIPickerWheel"])
        {
            
        }
        else if ([className isEqualToString: @"UIPopover"])
        {
            
        }
        else if ([className isEqualToString: @"UIProgressIndicator"])
        {
            
        }
        else if ([className isEqualToString: @"UIScrollView"])
        {
            
        }
        else if ([className isEqualToString: @"UISearchBar"])
        {
            
        }
        else if ([className isEqualToString: @"UISecureTextField"])
        {
            
        }
        else if ([className isEqualToString: @"UISegmentedControl"])
        {
            
        }
        else if ([className isEqualToString: @"UISlider"])
        {
            NSInteger i = 0;
            
            str = [[NSString alloc] initWithFormat: @"var slider = window.sliders()[%ld];", i];
        }
        else if ([className isEqualToString: @"UIStaticText"])
        {
            
        }
        else if ([className isEqualToString: @"UIStatusBar"])
        {
            
        }
        else if ([className isEqualToString: @"UISwitch"])
        {
            NSInteger i = 0;

            str = [[NSString alloc] initWithFormat: @"var switch = window.switches()[%ld];", i];
        }
        else if ([className isEqualToString: @"UITabBar"])
        {
            
        }
        else if ([className isEqualToString: @"UITableCell"] || [className isEqualToString: @"UITableViewCell"])
        {
            if (textOnView != nil)
            {
                str = [NSString stringWithFormat: @"var cell%@ = tableView.cells()[%@];", suffixName, [NSString stringWithFormat: @"'%@'", textOnView]];
            }
            else
            {
                NSInteger i = 0;
                
                str = [NSString stringWithFormat: @"var cell%@ = tableView.cells()[%ld];", suffixName, i];
            }
        }
        else if ([className isEqualToString: @"UIPopUpButton"] || [className isEqualToString: @"UIButton"] || [className isEqualToString: @"UIButtonLabel"])
        {
            if (textOnView != nil)
            {
                str = [NSString stringWithFormat: @"var button%@ = window.buttons()[%@];", suffixName, [NSString stringWithFormat: @"'%@'", textOnView]];
            }
            else
            {
                NSInteger i = 0;
                
                str = [NSString stringWithFormat: @"var button%@ = window.buttons()[%ld];", suffixName, i];
            }
        }
        else if ([className isEqualToString: @"UITableGroup"])
        {
            
        }
        else if ([className isEqualToString: @"UITableView"])
        {
            NSInteger i = 0;
            
            str = [[NSString alloc] initWithFormat: @"var tableView = window.tableViews()[%ld];", i];
        }
        else if ([className isEqualToString: @"UITarget"])
        {
            
        }
        else if ([className isEqualToString: @"UITextField"])
        {
            NSInteger i = 0;
            
            str = [[NSString alloc] initWithFormat: @"var tableView = window.textFields()[%ld];", i];
        }
        else if ([className isEqualToString: @"UITextView"])
        {
            NSInteger i = 0;
            
            str = [[NSString alloc] initWithFormat: @"var textView = window.textViews()[%ld];", i];
        }
        else if ([className isEqualToString: @"UIToolbar"])
        {
            
        }
        else if ([className isEqualToString: @"UIWebView"])
        {
            NSInteger i = 0;
            
            str = [[NSString alloc] initWithFormat: @"var webView = window.webViews()[%ld];", i];
        }
        else if ([className isEqualToString: @"UIWindow"])
        {
            str = [[NSString alloc] initWithFormat: @"var window = UIATarget.localTarget().frontMostApp().mainWindow();"];
        }
        else if ([className isEqualToString: @"UIImageView"])
        {
            NSInteger i = 0;

            str = [[NSString alloc] initWithFormat: @"var image = window.images()[%ld];", i];
        }
        else
        {
            //str = [[NSString alloc] initWithString: className];
        }
        
        if (str == nil)
        {
            str = [[NSString alloc] initWithString: @""];
            //str = [[NSString alloc] initWithString: className];
        }
        
        [scripts addObject: str];
        
        index++;
    }
}

- (void) automationScript: (NSString*) aSelect
{
    NSInteger index = 0;
    
    while (index < [arrayViewsInfo count])
    {
        DTViewInfo* currViewInfo = [arrayViewsInfo objectAtIndex: index];
        
        if ([currViewInfo.content isEqualToString: aSelect])
        {
            break;
        }
        
        index++;
    }
    
    NSInteger oldLevel = [DTViewInfo level: aSelect];
    
    NSMutableArray* resultArray = [[NSMutableArray alloc] init];
    
    
    while ((index < [arrayViewsInfo count]) && (index >= 0))
    {
        DTViewInfo* currViewInfo = [arrayViewsInfo objectAtIndex: index];
        NSInteger currentLevel = currViewInfo.level;
        
        if (currentLevel >= 0 && currentLevel <= oldLevel)
        {
//            NSString* className = currViewInfo.className;
//            NSString* textOnView = currViewInfo.text;
//            NSString* suffixName = @"";
            
        }
        
        oldLevel = currentLevel;
        
        index--;
    }
    
    NSMutableString* automation = [[NSMutableString alloc] init];
    
    index = [resultArray count] - 1;
    
    while (index >= 0)
    {
        [automation appendString: [NSString stringWithFormat: @"%@\n", [resultArray objectAtIndex: index]]];
        index--;
    }
    
    //    [automation appendString: [NSString stringWithFormat: @" %@",
    //                               [@"" stringByPaddingToLength: currentLevel * 2
    //                                                 withString: @" "
    //                                            startingAtIndex: 0]]];
    
    
    [automation release];
}

@end
