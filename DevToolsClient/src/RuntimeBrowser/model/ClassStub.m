/* 

ClassStub.m created by eepstein on Sat 16-Mar-2002

Author: Ezra Epstein (eepstein@prajna.com)

Copyright (c) 2002 by Prajna IT Consulting.
                      http://www.prajna.com

========================================================================

THIS PROGRAM AND THIS CODE COME WITH ABSOLUTELY NO WARRANTY.
THIS CODE HAS BEEN PROVIDED "AS IS" AND THE RESPONSIBILITY
FOR ITS OPERATIONS IS 100% YOURS.

========================================================================
This file is part of RuntimeBrowser.

RuntimeBrowser is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

RuntimeBrowser is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with RuntimeBrowser (in a file called "COPYING.txt"); if not,
write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
Boston, MA  02111-1307  USA

*/

#import "ClassStub.h"
#import "ClassDisplay.h"

#if (! TARGET_OS_IPHONE)
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#import <objc/message.h>
#endif

@interface ClassStub()
@property (nonatomic, retain) NSString* imagePath;
- (ClassStub*) initWithClass: (Class) aClass;
- (NSMutableSet*) ivarTokens; 
- (NSMutableSet*) methodsTokensForClass: (Class) aClass;
- (NSMutableSet*) methodsTokens;
- (NSMutableSet*) protocolsTokensForClass: (Class) aClass;
- (NSMutableSet*) protocolsTokensForClass: (Class) aClass
             includeSuperclassesProtocols: (BOOL)includeSuperclassesProtocols;
- (NSMutableSet*) protocolsTokens;
@end

@implementation ClassStub

@synthesize stubClassname;
@synthesize imagePath;
@synthesize subclassesStubs;

+ (ClassStub *) classStubWithClass: (Class)aClass 
{
    return [[[ClassStub alloc] initWithClass: aClass] autorelease];
}

+ (void)thisClassIsPartOfTheRuntimeBrowser 
{
/*" So the user knows when browsing this class in the RuntimeBrowser.
 We put this method last so it shows up first. "*/
}

- (ClassStub*) initWithClass: (Class) aClass 
{
    if(self = [super init])
    {
        NSString* className = NSStringFromClass(aClass);
        
        self.stubClassname = className;
        
        const char* imageName = class_getImageName(aClass);
        
        NSString* image = nil;
        if(imageName) 
        {
            image = [NSString stringWithCString: imageName 
                                       encoding: NSUTF8StringEncoding];	
        } 
        else 
        {
            NSLog(@"-- cannot find image for class %@", className);
            //image = [[NSBundle bundleForClass:aClass] bundlePath];
        }
        
        self.imagePath = image;
        
        self.subclassesStubs = [NSMutableArray array];
        subclassesAreSorted = NO;
        shouldSortSubclasses = YES;
    }

    return self;
}

- (void)dealloc 
{
	[imagePath release];
    [stubClassname release];
    [subclassesStubs release];
    [super dealloc];
}

- (NSString *)description 
{
    return stubClassname;
}

- (NSString*) header
{
	Class class = NSClassFromString(stubClassname);
	ClassDisplay* cd = [ClassDisplay createForClass: class];
    NSMutableString* dependencies = [NSMutableString string];
	NSString* header = [cd header: dependencies];

    return header;
}

- (BOOL)saveHeaderAsTxtAtPath: (NSString *)path 
{
	NSURL* pathURL = [NSURL fileURLWithPath: path];
	NSString* header = [self header];
	
	NSError* error = nil;	
	BOOL success = [header writeToURL: pathURL 
                           atomically: NO 
                             encoding: NSUTF8StringEncoding 
                                error: &error];
	if(success == NO) 
    {
		NSLog(@"-- %@", error);
	}
	
	return success;
}

#pragma mark Find string at class's interface

- (BOOL)containsSearchString: (NSString *) aSearchString 
{
    // TODO: cache searchStrings known to be in the class
    
    NSString* searchString = [aSearchString lowercaseString];
    
    if([[stubClassname lowercaseString] rangeOfString: searchString].location != NSNotFound) 
    {
        return YES;
    }
    
    for(NSString* token in [self ivarTokens]) 
    {
        if([[token lowercaseString] rangeOfString: searchString].location != NSNotFound) 
        {
            return YES;
        }
    }
    
    for(NSString* token in [self methodsTokens]) 
    {
        if([[token lowercaseString] rangeOfString: searchString].location != NSNotFound) 
        {
            return YES;
        }
    }
    
    for(NSString* token in [self protocolsTokens]) 
    {
        if([[token lowercaseString] rangeOfString: searchString].location != NSNotFound) 
        {
            return YES;
        }
    }
    
    ClassDisplay* cd = [ClassDisplay createForClass: NSClassFromString(stubClassname)];
    
    for(NSString* token in [cd ivarsTypeTokens]) 
    {
        if([[token lowercaseString] rangeOfString: searchString].location != NSNotFound) 
        {
            return YES;
        }        
    }
    
    return NO;
}

- (NSMutableSet*) ivarTokens 
{
	Class class = NSClassFromString(stubClassname);

	NSMutableSet* ivarTokensSet = [NSMutableSet set];
	
	unsigned int ivarListCount;
	Ivar* ivarList = class_copyIvarList(class, &ivarListCount);
	
    if (ivarList != NULL && (ivarListCount > 0)) 
    {
        NSUInteger i;
        for (i = 0; i < ivarListCount; ++i) 
        {
            Ivar rtIvar = ivarList[i];
			const char* ivarName = ivar_getName(rtIvar);
			if(ivarName) 
            {
                NSString* ivarNameString = [NSString stringWithCString: ivarName 
                                                              encoding: NSUTF8StringEncoding];

                [ivarTokensSet addObject: [ivarNameString lowercaseString]];
            }
		}
	}
	
	free(ivarList);
	
	[ivarTokensSet removeObject: @""];
	
	return ivarTokensSet;
}

- (NSMutableSet *)methodsTokensForClass: (Class) aClass 
{
	NSMutableSet* methodsTokensSet = [NSMutableSet set];
	
	unsigned int methodListCount;
	Method* methodList = class_copyMethodList(aClass, &methodListCount);
	
    NSUInteger i;
	for (i = 0; i < methodListCount; i++) 
    {
		Method currMethod = (methodList[i]);
		NSString* mName = [NSString stringWithCString: (const char *)sel_getName(method_getName(currMethod))
                                             encoding: NSASCIIStringEncoding];
		NSArray* mNameParts = [mName componentsSeparatedByString: @":"];
		for(NSString* mNamePart in mNameParts) 
        {
			[methodsTokensSet addObject: [mNamePart lowercaseString]];
		}
    }
	
	free(methodList);

	return methodsTokensSet;
}

- (NSMutableSet *) methodsTokens 
{
	Class class = NSClassFromString(stubClassname);
	Class metaClass = objc_getMetaClass(class_getName(class));

	NSMutableSet* methodsSet = [NSMutableSet set];
	
	[methodsSet addObjectsFromArray: [[self methodsTokensForClass: class] allObjects]];
	[methodsSet addObjectsFromArray: [[self methodsTokensForClass: metaClass] allObjects]];
	
	[methodsSet removeObject: @""];
	
	return methodsSet;
}

- (NSMutableSet *)protocolsTokensForClass: (Class) aClass 
{
	NSMutableSet* protocolsTokensSet = [NSMutableSet set];

	unsigned int protocolListCount;
	Protocol **protocolList = class_copyProtocolList(aClass, &protocolListCount);
	if (protocolList != NULL && (protocolListCount > 0)) 
    {
		NSUInteger i;
        for(i = 0; i < protocolListCount; i++) 
        {
			Protocol* protocolItem = protocolList[i];
			const char* protocolName = protocol_getName(protocolItem);
			if(protocolName) 
            {
                NSString* protocolNameString = [NSString stringWithCString: protocolName 
                                                                  encoding: NSUTF8StringEncoding];
                [protocolsTokensSet addObject: [protocolNameString lowercaseString]];
            }
		}
	}
	free(protocolList);

	return protocolsTokensSet;
}

- (NSMutableSet *)protocolsTokensForClass: (Class) aClass 
             includeSuperclassesProtocols: (BOOL) includeSuperclassesProtocols 
{
	NSMutableSet* protocolsTokensSet = [self protocolsTokensForClass: aClass];
	
	if (includeSuperclassesProtocols) 
    {
		Class classItem;
        for(classItem = aClass; class_getSuperclass(classItem) != classItem; classItem = class_getSuperclass(classItem)) 
        {
			NSMutableSet* ms = [self protocolsTokensForClass: classItem];
			[protocolsTokensSet unionSet: ms];
		}
	}
	
	return protocolsTokensSet;
}

- (NSMutableSet *)protocolsTokens 
{
	Class class = NSClassFromString(stubClassname);

	return [self protocolsTokensForClass: class 
            includeSuperclassesProtocols: YES]; // TODO: put includeSuperclassesProtocols in user defaults
}

#pragma mark -

- (NSString *)imagePath 
{
	return imagePath;
}

- (NSArray *)subclassesStubs 
{
    if (!subclassesAreSorted && shouldSortSubclasses) 
    {
        [subclassesStubs sortUsingSelector: @selector(compare:)];
        subclassesAreSorted = YES;
    }
    return (NSArray *)subclassesStubs;
}

- (void)addSubclassStub: (ClassStub *) classStub 
{
    [subclassesStubs addObject: classStub];
    subclassesAreSorted = NO;
}

- (NSComparisonResult)compare: (ClassStub *)otherCS 
{
    return [stubClassname compare: [otherCS stubClassname]];
}

#pragma mark BrowserNode protocol

- (NSArray *)children 
{
	return [self subclassesStubs];
}

- (NSString *)nodeName 
{
	return stubClassname;
}

- (NSString *)nodeInfo 
{
    return [NSString stringWithFormat:@"%@ (%d)", [self nodeName], [[self children] count]];
}

- (BOOL)canBeSavedAsHeader 
{
	return YES;
}

@end
