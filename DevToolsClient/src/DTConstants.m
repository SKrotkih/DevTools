//
//  DTConstants.m
//  DevToolsClient
//
//  Created by Sergey Krotkih on 7/31/12.
//  Copyright (c) 2012 Quickoffice. All rights reserved.
//

#import "DTConstants.h"

NSString* const ReceivedDataNotificationId = @"ReceivedDataNotificationId";
NSString* const EchoFromServerNotificationId = @"EchoFromServerNotificationId";
NSString* const DisconnectToServerMessageId = @"disconnect";
NSString* const StartTraceMessageId = @"start trace";
NSString* const StopTraceMessageId = @"stop trace";
NSString* const RequestToRunTimeBrowserDataNotificationId = @"all classes data";
NSString* const ResponseRTBrowserDataMessageId = @"ResponseRTBrowserDataMessageId";
NSString* const ResponseRTBrowserDataMessageContinueId = @"ResponseRTBrowserDataMessageContinueId";
NSString* const ResponseRTBrowserDataMessageFinishedId = @"ResponseRTBrowserDataMessageFinishedId";
NSString* const StartUITestingMessageId = @"start UI auto testing";
NSString* const RunUITestScriptMessageId = @"run script fo UI testing";
NSString* const ConnectToServerMessageId = @"connect is OK";
NSString* const UITestErrorMessageId = @"ERROR_UITEST";
NSString* const UITestLogMessageId = @"LOG_UITEST";
NSString* const MainLogMessageId = @"LOG_MAIN";
NSString* const SendLogNotificationId = @"SendLogNotificationId";
NSString* const ViewsMapMessageId = @"MAP_UITEST";
NSString* const ViewsMapMessageContinueId = @"MAP_UITEST_CONTINUE";
NSString* const UITestFinishedNotificationId = @"UITestFinishedNotificationId";
NSString* const UITestErrorNotificationId = @"UITestErrorNotificationId";
NSString* const UITestLogNotificationId = @"UITestLogNotificationId";
NSString* const ViewsMapNotificationId = @"ViewsMapNotificationId";
NSString* const RunViewScriptMessageId = @"run script item";
NSString* const CurrentViewsMessageId = @"current views data";
NSString* const ViewsMapFinishedMessageId = @"current views data finished";
NSString* const SwitchToDevToolsMessageId = @"swith to dev tools UI";
NSString* const SwitchToApplicationMessageId = @"swith to application UI";

NSString* const ClassInterfaceRequestMessageId = @"get class interface info";
NSString* const ClassDependenciesRequestMessageId = @"get class dependencies info";
NSString* const ClassInterfaceResponceMessageId = @"ClassInterfaceResponceMessageId";
NSString* const ClassInterfaceResponceMessageContinueId = @"ClassInterfaceResponceMessageContinueId";
NSString* const ClassDependenciesResponceMessageId = @"ClassDependenciesResponceMessageId";

NSString* const RunCommandOnServerMessageId = @"Run command on server";
NSString* const kSendCommandToServerNotification = @"kSendCommandToServerNotification";
NSString* const UITestWasFinishedMessageId = @"UITestWasFinishedMessageId";

NSString* const HeaderOfClassSeparator = @"-HEADER-";
NSString* const DependencySeparator = @"-DEPEND-";

NSString* const TraceLogMessageId = @"-TRACE-LOG-";
NSString* const TraceLogMessageContinueId = @"-TRACE-LOG-CONTINUE";

NSString* const CommandKeyForJSONdictionary = @"Command";
NSString* const DataKeyForJSONdictionary = @"Data";
NSString* const TagKeyForJSONdictionary = @"Tag";
NSString* const LenDataKeyForJSONdictionary = @"LenData";



