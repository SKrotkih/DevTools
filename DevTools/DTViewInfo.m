//
//  DTViewInfo.m
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import "DTViewInfo.h"
#import "DTViewsDataInfoView.h"
#import "DTViewsInfoViewController.h"

const CGFloat LeftMargin = 20.0f;
const CGFloat UpMargin = 60.0f;

@implementation DTViewInfo

@synthesize view;
@synthesize level;
@synthesize className;
@synthesize text;
@synthesize content;

+ (NSInteger) level: (NSString*) anInfo
{
    NSInteger level = -1;
    
    if (anInfo && [anInfo length] > 0)
    {
        // 6------<UITableViewCellContentView:
        NSUInteger index = [anInfo rangeOfString: @"-" options: NSCaseInsensitiveSearch].location;
        
        if (index > 0)
        {
            level = [[anInfo substringToIndex: index] integerValue];
        }
    }
    
    return level;
}

+ (NSString*) className: (NSString*) anInfo
{
    if (anInfo && [anInfo length] > 0)
    {
        // 6------<UITableViewCellContentView:
        NSUInteger index = [anInfo rangeOfString: @"<" options: NSCaseInsensitiveSearch].location;
        
        if (index > 0)
        {
            NSString* str = [anInfo substringFromIndex: index + 1];
            
            index = [str rangeOfString: @":" options: NSCaseInsensitiveSearch].location;
            
            if (index > 0)
            {
                NSString* className = [[NSString alloc] initWithString: [str substringToIndex: index]];
                
                return [className autorelease];
            }
        }
    }
    
    return nil;
}

+ (NSString*) property: (NSString*) aPropertyName
            defaultVal: (NSString*) aDefault
            ofViewData: (NSString*) aStrData
{
    // <UINavigationBar: 0x8112c10; frame = {{0, 40}, {320, 44}}; autoresize = W; layer = <CALayer: 0x8113510>>
    if ([aStrData length] > 2)
    {
        NSRange range = {1, [aStrData length] - 2};
        NSString* describeView = [aStrData substringWithRange: range];
        NSArray* arr = [describeView  componentsSeparatedByString: @"; "];
        
        for (NSString* str in arr)
        {
            NSArray* arrProps = [str componentsSeparatedByString: @" = "];
            
            if ([arrProps count] == 2)
            {
                NSString* prop = [arrProps objectAtIndex: 0];
                
                if ([prop isEqualTo: aPropertyName])
                {
                    return [NSString stringWithString: [arrProps objectAtIndex: 1]];
                }
            }
        }
    }
    
    return [NSString stringWithString: aDefault];
}

+ (NSColor*) randomColor
{
    float rand_max = RAND_MAX;
    float red = (float)rand() / rand_max;
    float green = (float)rand() / rand_max;
    float blue = (float)rand() / rand_max;
    
    return [NSColor colorWithCalibratedRed: red
                                     green: green
                                      blue: blue
                                     alpha: 1.0f];
}

+ (BOOL) isNewColor: (NSColor*) color
{
    //    for (DTViewInfo* currViewInfo in arrayViewsInfo)
    //    {
    //        if ([currViewInfo.view isEqualColor: color])
    //        {
    //            return NO;
    //        }
    //    }
    
    return YES;
}

+ (DTViewInfo*) createViewInfoForData: (NSString*) aData
                 parentViewController: (DTViewsInfoViewController*) aParentViewController
{
    DTViewInfo* viewInfo = [[DTViewInfo alloc] init];
    
    NSRange range = NSMakeRange(1, [aData length] - 2);
    viewInfo.content = [aData substringWithRange: range];
    
    NSString* text = [DTViewInfo property: @"text"
                               defaultVal: @""
                               ofViewData: aData];
    
    if ([text length] > 0)
    {
        NSRange range = NSMakeRange(1, [text length] - 2);
        text = [text substringWithRange: range];
    }
    
    viewInfo.text = text;
    viewInfo.level = [DTViewInfo level: viewInfo.content];
    viewInfo.className = [DTViewInfo className: viewInfo.content];
    
    CGFloat alpha = [[DTViewInfo property: @"alpha"
                               defaultVal: @"1.0f"
                               ofViewData: aData] floatValue];
    if (alpha > 0.0f)
    {
        NSRect frame = NSRectFromString([DTViewInfo property: @"absframe"
                                                  defaultVal: @""
                                                  ofViewData: aData]);
        CGFloat x = CGRectGetMinX(frame);
        CGFloat y = CGRectGetMinY(frame);
        CGFloat h = CGRectGetHeight(frame);
        
        frame.origin = CGPointMake(LeftMargin + x, [aParentViewController parentViewHeight] - (y + h + UpMargin));
        
        NSColor* color;
        BOOL newColor = NO;
        
        while (!newColor)
        {
            color = [DTViewInfo randomColor];
            newColor = [DTViewInfo isNewColor: color];
        }
        
        viewInfo.view = [[DTViewsDataInfoView alloc] initWithFrame: frame
                                                              text: text
                                                           bgColor: color
                                                            parent: aParentViewController];
        viewInfo.view.content = viewInfo.content;
    }
    
    return viewInfo;
}

@end
