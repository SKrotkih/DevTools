//
//  RuntimeBrowserWebServer.h
//  DevToolsClient
//
//  Created by Nicolas Seriot on 17.01.09.
//  Copyright Sen:te 2009. All rights reserved.
//
//#warning TODO: upgrade graphics to retina display

#import <UIKit/UIKit.h>

@class RTBHTTPServer;
@class AllClasses;

@protocol HTTPResponse;

@interface RuntimeBrowserWebServer: NSObject
{
	RTBHTTPServer* httpServer;
	AllClasses* allClasses;
	id viewServices_;    
}

@property (nonatomic, retain) AllClasses* allClasses;

+ (RuntimeBrowserWebServer*) sharedInstance;
- (void) stopWebServer;
- (NSObject<HTTPResponse>*) responseForPath: (NSString*) path;
- (UInt16) serverPort;
- (RTBHTTPServer*) httpServer;

@end
