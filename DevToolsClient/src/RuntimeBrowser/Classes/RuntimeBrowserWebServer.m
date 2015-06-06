//
//  RuntimeBrowserWebServer.m
//  DevToolsClient
//
//  Created by Nicolas Seriot on 17.01.09.
//  Copyright Sen:te 2009. All rights reserved.
//

#import "RuntimeBrowserWebServer.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#import "ClassDisplay.h"
#import "ClassStub.h"
#import "RTBHTTPServer.h"
#import "HTTPResponse.h"
#import "RTBHTTPDataResponse.h"
#import "AllClasses.h"
#import "UDPutils.h"

static RuntimeBrowserWebServer* _sharedInstance;

@interface RuntimeBrowserWebServer()
- (void) startWebServer;
@end

@implementation RuntimeBrowserWebServer

@synthesize allClasses;

+ (RuntimeBrowserWebServer*) sharedInstance
{
    return _sharedInstance;
}

- (id) init
{
	if ((self = [super init]))
    {
        NSString* defaultsPath = [gDevToolsClientResBundle pathForResource: @"Defaults"
                                                                    ofType: @"plist"];
        NSDictionary* defaults = [NSDictionary dictionaryWithContentsOfFile: defaultsPath];
        [[NSUserDefaults standardUserDefaults] registerDefaults: defaults];
        
        self.allClasses = [AllClasses sharedInstance];
        
        BOOL startWebServer = [[NSUserDefaults standardUserDefaults] boolForKey: @"StartWebServer"];
        
        if (startWebServer) 
        {
            [self startWebServer];
        }
	}
	
    _sharedInstance = self;
    
    return self;
}

- (void) stopWebServer
{
	if(httpServer)
    {
		[httpServer stop];
	}
}

- (void)dealloc 
{
	[allClasses release];
	[httpServer release];

    [super dealloc];
}

- (RTBHTTPServer*) httpServer
{
	return httpServer;
}

- (NSObject<HTTPResponse>*) htmlIndex
{
	NSMutableString* xhtml = [[NSMutableString alloc] init];
	
	[xhtml appendString:@"<HTML>\n<HEAD>\n<TITLE>iPhone OS Runtime Browser</TITLE>\n</HEAD>\n<BODY>\n"];
	
	NSArray *classes = [allClasses sortedClassStubs];
	for(ClassStub *cs in classes) 
    {
		[xhtml appendFormat: @"<A HREF=\"%@.h\">%@.h</A><BR />\n", cs.stubClassname, cs.stubClassname];
	}

	[xhtml appendString: @"</BODY>\n</HTML>\n"];

	NSData *data = [xhtml dataUsingEncoding: NSISOLatin1StringEncoding];
	[xhtml release];
	
	return [[[RTBHTTPDataResponse alloc] initWithData: data] autorelease];
}

- (NSObject<HTTPResponse>*) responseForPath: (NSString *)path 
{
	if([path isEqualToString:@"/"]) 
    {
		return [self htmlIndex];
	}
	
	NSString *fileName = [path length] ? [path substringFromIndex: 1] : @"";
	NSString *className = [fileName stringByDeletingPathExtension];
	
	ClassDisplay *cd = [ClassDisplay createForClass:NSClassFromString(className)];
    NSMutableString* dependencies = [NSMutableString string];
	
	NSString* header = [cd header: dependencies];
	
	NSData *data = [header dataUsingEncoding:NSISOLatin1StringEncoding];
	
	return [[[RTBHTTPDataResponse alloc] initWithData: data] autorelease];	
}

- (void) startWebServer 
{
	NSDictionary *ips = [[UDPutils sharedInstance] ipsForInterfaces];
	BOOL isConnectedThroughWifi = [ips objectForKey: @"en0"] != nil;
	
	if(isConnectedThroughWifi || TARGET_IPHONE_SIMULATOR) 
    {
		httpServer = [[RTBHTTPServer alloc] init];
		[httpServer setType:@"_http._tcp."];
		[httpServer setPort:10000];
		
		NSError *error;
		BOOL success = [httpServer start: &error];
		
		if(success == NO) 
        {
			NSLog(@"Error starting HTTP Server.");
			
			if(error) 
            {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error starting HTTP Server" 
																message: [error localizedDescription]
															   delegate: nil 
													  cancelButtonTitle: @"OK" 
													  otherButtonTitles: nil];
				[alert show];
				[alert release];	
			}
			[httpServer stop];
			[httpServer release];
			httpServer = nil;
		} 
        else 
        {
			[UIApplication sharedApplication].idleTimerDisabled = YES; // prevent sleep
		}
	} 
    else 
    {
		// TODO: allow USB connection..
		NSLog(@"Not connected through wifi, don't start web server.");
	}
}

- (UInt16) serverPort 
{
	return [httpServer port];
}

/*
+ (NSString *)hardwareModel
{
    static NSString *hardwareModel = nil;
    if (!hardwareModel) {
        char buffer[128];
        size_t length = sizeof(buffer);
        if (sysctlbyname("hw.model", &buffer, &length, NULL, 0) == 0) {
            hardwareModel = [[NSString allocWithZone:NULL] initWithCString:buffer encoding:NSASCIIStringEncoding];
        }
        if (!hardwareModel || [hardwareModel length] == 0) {
            hardwareModel = @"Unknown";
        }
    }
    return hardwareModel;    
}

+ (NSString *)computerModel
{
    static NSString *computerModel = nil;
    if (!computerModel) {
        NSString *path, *hardwareModel = [self hardwareModel];
        if ((path = [[NSBundle mainBundle] pathForResource:@"Macintosh" ofType:@"dict"])) {
            computerModel = [[[NSDictionary dictionaryWithContentsOfFile:path] objectForKey:hardwareModel] copy];
        }
        if (!computerModel) {
            char buffer[128];
            size_t length = sizeof(buffer);
            if (sysctlbyname("hw.machine", &buffer, &length, NULL, 0) == 0) {
                computerModel = [[NSString allocWithZone:NULL] initWithCString:buffer encoding:NSASCIIStringEncoding];
            }
        }
        if (!computerModel || [computerModel length] == 0) {
            computerModel = [[NSString allocWithZone:NULL] initWithFormat:@"%@ computer model", hardwareModel];
        }
    }
    return computerModel;
}

// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/

@end
