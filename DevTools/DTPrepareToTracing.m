//
//  DTPrepareToTracing.m
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import "DTPrepareToTracing.h"
#import "DTConstants.h"

@implementation DTPrepareToTracing

- (void) awakeFromNib
{
}

- (BOOL) windowShouldClose: (id) sender
{
    return YES;
}

- (void) windowWillClose: (NSNotification*) notification
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject: pathToProject.stringValue
                 forKey: PathToProjectOfTracingDefaultId];
    
    [defaults synchronize];

    if ([[NSApplication sharedApplication] modalWindow] != nil)
    {
        [[NSApplication sharedApplication] stopModal];
    }

    [self autorelease];
}

- (IBAction) openDirectory: (id)sender
{
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    [openPanel setTreatsFilePackagesAsDirectories: NO];
    [openPanel setAllowsMultipleSelection: NO];
    [openPanel setCanChooseDirectories: YES];
    [openPanel setCanChooseFiles: NO];
    [openPanel beginSheetModalForWindow: [self window] completionHandler: ^(NSInteger result)
     {
         if (result == NSOKButton)
         {
             [openPanel orderOut: self]; // close panel before we might present an error
             if ([sender tag] == 0)
             {
                 [pathToProject setStringValue: [[openPanel URL] absoluteString]];
             }
             else if ([sender tag] == 1)
             {
                 [pathToTemplateProject setStringValue: [[openPanel URL] absoluteString]];
             }
         }
     }];
}

- (IBAction) startScanProject: (id) sender
{
    NSString* path = pathToProject.stringValue;

    if ([path length] == 0)
    {
        [self.window close];
        NSBeginAlertSheet(NSLocalizedString(@"Task of the prepare to tracing couldn't be done.", @"Text on alert window"), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil,
                          NSLocalizedString(@"Please enter path to the project.", @"Text on alert window"));
    }
    else
    {
        [progressIndicator startAnimation: self];
        
        [self parseDirectory: path
             resultDirectory: pathToTemplateProject.stringValue];
        
        [progressIndicator stopAnimation: self];
        [self.window close];
        
        NSBeginAlertSheet(NSLocalizedString(@"Task of the prepare to tracing was done.", @"Text on alert window"), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil,
                          NSLocalizedString(@"You can start of the tracing!", @"Text on alert window"));
    }
}

- (BOOL) isDirectory: (NSString*) path
{
    NSDictionary* attribs = [[NSFileManager defaultManager] attributesOfItemAtPath: path
                                                                             error: NULL];
    NSString* fileType = [attribs objectForKey: NSFileType];
    return [fileType isEqual: NSFileTypeDirectory];
}

- (BOOL) isFirstSymbolOfString: (NSString*) aString
                      eqSymbol: (NSString*) aSymbol
{
    for (NSInteger i = 0; i < [aString length]; i++)
    {
        NSRange range = {i, 1};
        NSString* symb = [aString substringWithRange: range];

        if ([symb isEqualToString: @" "])
        {
            continue;
        }
        else if ([symb isEqualToString: aSymbol])
        {
            return YES;
        }
        else
        {
            break;
        }
    }
    
    return NO;
}

- (void) parseDirectory: (NSString*) aSourcesDir
        resultDirectory: (NSString*) aRootResultDirectory
{
    NSString* dir = [NSString stringWithFormat: @"%@/", aSourcesDir];
    NSArray* filelist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: dir
                                                                            error: NULL];
    for (int i = 0; i < [filelist count]; i++)
    {
        NSString* currFileName = [NSString stringWithFormat: @"%@%@", dir, [filelist objectAtIndex: i]];

        if ([[currFileName pathExtension] isEqualToString: @"m"] || [[currFileName pathExtension] isEqualToString: @"mm"])
        {
            NSError* error = nil;
            NSString* contentOfFile = [NSString stringWithContentsOfFile: currFileName
                                                                encoding: NSUTF8StringEncoding
                                                                   error: &error];

            NSArray* srcLines = [contentOfFile componentsSeparatedByString: @"\n"];
            NSEnumerator* srcStream = [srcLines objectEnumerator];
            NSString* currStr;
            BOOL isMethodFound = NO;
            NSMutableString* outpuString = [[NSMutableString alloc] initWithCapacity: [contentOfFile length] + 100];
            
            while ((currStr = [srcStream nextObject]) != nil)
            {
                if ([currStr length] > 0)
                {
                    if ([currStr rangeOfString: DTTraceLogMacroName].location != NSNotFound)
                    {
                        continue;
                    }
                    else if ([self isFirstSymbolOfString: currStr
                                           eqSymbol: @"-"])
                    {
                        NSRange rng = [currStr rangeOfString: @"-"];
                        if ([self isFirstSymbolOfString: [currStr substringFromIndex: rng.location + 1]
                                               eqSymbol: @"("])
                        {
                            isMethodFound = YES;
                        }
                    }
                    else if ([self isFirstSymbolOfString: currStr
                                                eqSymbol: @"+"])
                    {
                        NSRange rng = [currStr rangeOfString: @"+"];
                        if ([self isFirstSymbolOfString: [currStr substringFromIndex: rng.location + 1]
                                               eqSymbol: @"("])
                        {
                            isMethodFound = YES;
                        }
                    }
                    
                    if (isMethodFound)
                    {
                        if ([currStr rangeOfString: @"{"].location != NSNotFound)
                        {
                            currStr =[currStr stringByReplacingOccurrencesOfString: @"{"
                                                                        withString: [NSString stringWithFormat: @"{\n    %@;", DTTraceLogMacroName]];
                            isMethodFound = NO;
                        }
                    }
                }

                [outpuString appendFormat: @"%@\n", currStr];
            }
            
            NSFileHandle* outputHandle = [NSFileHandle fileHandleForWritingAtPath: currFileName];
            [outputHandle writeData: [outpuString dataUsingEncoding: NSUTF8StringEncoding]];
            [outpuString release];
        }
        else if ([self isDirectory: currFileName] == YES)
        {
            [self parseDirectory: currFileName
                 resultDirectory: aRootResultDirectory];
        }
    }
}

@end
