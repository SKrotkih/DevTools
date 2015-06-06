//
//  DTFileOperations.h
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DTFileOperations : NSObject
{
}

+ (NSString*) documentPathAppendDirectory: (NSString*) aDirectoryName;
+ (NSArray*) contentOfSchemesFileName: (NSString*) aFileName;

@end
