http://code.google.com/p/uispec/wiki/Documentation

List script's items which are supporting now:

touch navigation item button
is UISwitch on?
UISwith on
is UISwitch off?
UISwith off
scroll to bottom on UITableView
scroll to top on UITableView
scroll on 1 row on UITableView
wait <...> sec
enter text '<...>' to UITextField with placeholder '<...>'
check label with text '<...>'
touch button with text '<...>'






1. Copy DTSendLog.h and DTSendLog.m to the Quickoffice/IPH_QO_Shared/inc/utils and Quickoffice/IPH_QO_Shared/src/utils folders.

2. In QuickofficeAppDelegate.m add next code

#import <DevToolsClient/DevToolsDTClientController.h>

…

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
…

    [[DevToolsDTClientController sharedInstance] initWithAppRootViewController: navController
                                                                andMainWidow: self.window];

…
}


2.1. New FM:

#import <DevToolsClient/DevToolsDTClientController.h>

iPad_QuickofficeAppWindowController.mm

- (void) presentModalDialog: (UIViewController *) modalViewController animated: (BOOL) animated
...

    [[DevToolsDTClientController sharedInstance] initWithAppRootViewController: modalViewController
                                                                andMainWidow: window];
...


3. Add DevToolsClient.xcodeproj to the SampleFileManager (or to an other FileManager). Add DevToolsClientLib to the SampleFileManagerLib Target Dependencies.

4. Add DevToolsClientRes.bundle to SampleFileManagerBundle.

5. For send the log-messages you need add next code's strings to a code module:

#import <QOShared/DTSendLog.h>
...

[[DTSendLog sharedInstance] logMessage: @"\n%@", NSStringFromCGRect([value CGRectValue])];



#ifdef __DEBUG__
#import <QOShared/DTSendLog.h>
#define DTLog(A, ...)  \
[[DTSendLog sharedInstance] logMessage: [NSString stringWithFormat: @"[%-50s : %-5d] %@", [[[NSString stringWithUTF8String : __FUNCTION__] lastPathComponent] UTF8String], __LINE__, (A)] , ##__VA_ARGS__]
#else
#define DTLog(A, ...)
#endif
