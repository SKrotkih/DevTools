//
//  InfoViewController.m
//  RuntimeBrowser
//
//  Created by Nicolas Seriot on 25.01.09.
//  Copyright 2009 Sen:te. All rights reserved.
//

#import "InfoViewController.h"
#import "RuntimeBrowserWebServer.h"
#import "UDPutils.h"

#import <mach/mach.h>
#import <mach/mach_host.h>

@interface InfoViewController()
- (NSString *)memoryInfo;
@end

@implementation InfoViewController

@synthesize memoryLabel;
@synthesize revisionLabel;
@synthesize webServerStatusLabel;

- (id) initWithNibName: (NSString*) nibNameOrNil
                bundle: (NSBundle*) nibBundleOrNil
{
    if ((self = [super initWithNibName: nibNameOrNil
                                bundle: nibBundleOrNil]))
    {
        self.title = NSLocalizedString(@"Info", @"Tab bar item title");
        self.tabBarItem.image = [UIImage imageNamed: [NSString stringWithFormat: @"%@tab_info", gDevToolsClientResBundlePath]];
    }
    
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	
    NSString *revisionFile = [gDevToolsClientResBundle pathForResource: @"revision"
                                                                ofType: @"txt"];
    NSError *e = nil;
    NSString *revisionString = [NSString stringWithContentsOfFile: revisionFile
                                                         encoding: NSISOLatin1StringEncoding
                                                            error: &e];
    revisionLabel.text = (e || !revisionString || [revisionString length] == 0) ? @"unknown" : revisionString;
	
    RuntimeBrowserWebServer* webServer = [RuntimeBrowserWebServer sharedInstance];
	NSString* serverURL = [NSString stringWithFormat: @"http://%@:%d/", [[UDPutils sharedInstance] getIPAddress], [webServer serverPort]];
	webServerStatusLabel.text = [webServer httpServer] != nil ? serverURL : @"stopped";
    
	memoryLabel.text = [self memoryInfo];
    
	//[self fetchRevisionString];
	
    [super viewDidLoad];
}

- (IBAction) closeAction:(id) sender
{
    [[RuntimeBrowserWebServer sharedInstance] stopWebServer];
}

// http://landonf.bikemonkey.org/code/iphone/Determining_Available_Memory.20081203.html
- (NSString *)memoryInfo
{
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;
    
    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);
	
    vm_statistics_data_t vm_stat;
	
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS)
		return @"(N/A)";
	//NSLog(@"Failed to fetch vm statistics");
	
    /* Stats in bytes */
    natural_t mem_used = (vm_stat.active_count +
                          vm_stat.inactive_count +
                          vm_stat.wire_count) * pagesize;
    natural_t mem_free = vm_stat.free_count * pagesize;
    natural_t mem_total = mem_used + mem_free;
	
	float giga = (float)(1024 * 1024);
	NSString* used = [NSString stringWithFormat:@"%.2f", mem_used / giga ];
	NSString* free = [NSString stringWithFormat:@"%.2f", mem_free / giga];
	NSString* total = [NSString stringWithFormat:@"%.2f", mem_total / giga];
	
	return [NSString stringWithFormat: @"%@ / %@, %@ MB free", used, total, free];
	
    //NSLog(@"used: %u free: %u total: %u", mem_used, mem_free, mem_total);
}

- (void)viewDidAppear: (BOOL)animated
{
	memoryLabel.text = [self memoryInfo];
}

- (void)fetchRevisionString
{
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        NSURL *url = [NSURL URLWithString:@"http://code.google.com/feeds/p/runtimebrowser/svnchanges/basic"];
        NSString *xml = [NSString stringWithContentsOfURL:url encoding:NSISOLatin1StringEncoding error:nil];
        if(!xml || [xml length] == 0) return;
        
        NSRange r1 = [xml rangeOfString:@"Revision "];
        if(r1.location == NSNotFound) return;
        xml = [xml substringFromIndex:r1.location + r1.length];
        
        NSRange r2 = [xml rangeOfString:@":"];
        if(r2.location == NSNotFound) return;
        xml = [xml substringToIndex:r2.location];
        
        if([[NSString stringWithFormat:@"%d", [xml intValue]] isEqualToString:xml] && [xml length] > 0) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                revisionLabel.text = [revisionLabel.text stringByAppendingString:[NSString stringWithFormat:@" (latest:%@)", xml]];
            }];
        }
    }];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:op];
    [queue release];
}

- (IBAction)openWebSiteAction:(id)sender
{
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"http://code.google.com/p/runtimebrowser/"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
	
    //self.revisionLabel = nil;
	self.webServerStatusLabel = nil;
	self.memoryLabel = nil;
}

- (void)dealloc
{
    [revisionLabel release];
	[webServerStatusLabel release];
	[memoryLabel release];
	
    [super dealloc];
}

@end
