//
//  DTSelectClassesPopUpButton.m
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import "DTSelectClassesPopUpButton.h"
#import "DTFileOperations.h"
#import "DTConstants.h"

@implementation DTSelectClassesPopUpButton

- (void) awakeFromNib
{
}

- (void) refreshListData
{
    if (!titles)
    {
        titles = [[NSMutableArray alloc] initWithCapacity: 1];
    }
    else
    {
        [titles removeAllObjects];
    }

    [titles addObject: @""];

    NSString* schemesPath = [DTFileOperations documentPathAppendDirectory: DirectoryNameForRunTimeClassesSelect];
    NSArray* filelist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: schemesPath
                                                                            error: nil];
    for (NSString* fileName in filelist)
    {
        if( [[fileName pathExtension] compare: @"classes"] == NSOrderedSame)
        {
            [titles addObject: [[NSString alloc] initWithString: fileName]];
        }
    }
    
    [self removeAllItems];
    [self addItemsWithTitles: titles];
    
    [self selectItemWithTitle: @""];
}

- (void) dealloc
{
    [titles release];
    [super dealloc];
}

@end
