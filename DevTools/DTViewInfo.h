//
//  DTViewInfo.h
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DTViewsDataInfoView, DTViewsInfoViewController;

@interface DTViewInfo : NSObject
{
    DTViewsDataInfoView* view;
    NSInteger level;
    NSString* className;
    NSString* text;
    NSString* content;
}

+ (DTViewInfo*) createViewInfoForData: (NSString*) aData
               parentViewController: (DTViewsInfoViewController*) aParentViewController;

+ (NSInteger) level: (NSString*) anInfo;
+ (NSString*) className: (NSString*) anInfo;
+ (NSString*) property: (NSString*) aPropertyName
            defaultVal: (NSString*) aDefault
            ofViewData: (NSString*) aStrData;


@property (nonatomic, readwrite, assign) DTViewsDataInfoView* view;
@property (nonatomic, readwrite) NSInteger level;
@property (nonatomic, readwrite, copy) NSString* className;
@property (nonatomic, readwrite, copy) NSString* text;
@property (nonatomic, readwrite, copy) NSString* content;

@end
