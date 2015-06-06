//
//  DTFileOperations.m
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//
#import "DTFileOperations.h"
#import "DTConstants.h"

@implementation DTFileOperations

+ (NSString*) documentPathAppendDirectory: (NSString*) aDirectoryName
{
    NSArray* documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* appName = [[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleName"];
    NSString* retVal = [NSString stringWithFormat: @"%@/%@/%@", [documentsPath objectAtIndex: 0], appName, aDirectoryName];
    NSFileManager* fileManager = [NSFileManager defaultManager];

    if ([fileManager fileExistsAtPath: retVal] == NO)
    {
        [fileManager createDirectoryAtPath : retVal
                withIntermediateDirectories: YES
                                 attributes: nil
                                      error: nil];
    }
    
    return retVal;
}

+ (NSArray*) contentOfSchemesFileName: (NSString*) aFileName
{
    NSArray* documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* appName = [[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleName"];
    NSString* fullPath = [NSString stringWithFormat: @"%@/%@/%@/%@", [documentsPath objectAtIndex: 0], appName, DirectoryNameForRunTimeClassesSelect, aFileName];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath: fullPath])
    {
        NSError* error = nil;
        NSString* str = [NSString stringWithContentsOfFile: fullPath
                                                  encoding: NSUTF16StringEncoding
                                                     error: &error];
        return [str componentsSeparatedByString: @"\n"];
    }
    
    return nil;
}

@end
