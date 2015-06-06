//
//  DTConstants.m
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import "DTConstants.h"

NSString* const ReceivedDataNotificationId = @"ReceivedDataNotificationId";
NSString* const EchoFromServerNotificationId = @"EchoFromServerNotificationId";
NSString* const MouseMoveEventsNotificationId = @"MouseMoveEventsNotificationId";
NSString* const MoveDTClassInfoViewFrameToHomeNotificationId = @"MoveDTClassInfoViewFrameToHomeNotificationId";
NSString* const MoveViewsFrameToHomeNotificationId = @"MoveViewsFrameToHomeNotificationId";
NSString* const MouseUpEventsNotificationId = @"MouseUpEventsNotificationId";
NSString* const StartServerNotificationId = @"StartServerNotificationId";
NSString* const StopServerNotificationId = @"StopServerNotificationId";
NSString* const RequestToRunTimeBrowserDataNotificationId = @"all classes data";
NSString* const CheckNodeOnRunTimeBrowserNotificationId = @"CheckNodeOnRunTimeBrowserNotificationId";

NSString* const DisconnectToServerMessageId = @"disconnect";
NSString* const StartTraceMessageId = @"start trace";
NSString* const StopTraceMessageId = @"stop trace";
NSString* const StartUITestingMessageId = @"start UI auto testing";
NSString* const RunUITestScriptMessageId = @"run script fo UI testing";
NSString* const ConnectToServerMessageId = @"connect is OK";
NSString* const UITestErrorMessageId = @"ERROR_UITEST";
NSString* const UITestLogMessageId = @"LOG_UITEST";
NSString* const MainLogMessageId = @"LOG_MAIN";
NSString* const ViewsMapMessageId = @"MAP_UITEST";
NSString* const ViewsMapMessageContinueId = @"MAP_UITEST_CONTINUE";
NSString* const RunViewScriptMessageId = @"run script item";
NSString* const CurrentViewsMessageId = @"current views data";
NSString* const ViewsMapFinishedMessageId = @"current views data finished";
NSString* const SwitchToDevToolsMessageId = @"swith to dev tools UI";
NSString* const SwitchToApplicationMessageId = @"swith to application UI";
NSString* const ResponseRTBrowserDataMessageId = @"ResponseRTBrowserDataMessageId";
NSString* const ResponseRTBrowserDataMessageContinueId = @"ResponseRTBrowserDataMessageContinueId";
NSString* const ResponseRTBrowserDataMessageFinishedId = @"ResponseRTBrowserDataMessageFinishedId";

NSString* const ClassInterfaceRequestMessageId = @"get class interface info";
NSString* const ClassDependenciesRequestMessageId = @"get class dependencies info";
NSString* const ClassInterfaceResponceMessageId = @"ClassInterfaceResponceMessageId";
NSString* const ClassInterfaceResponceMessageContinueId = @"ClassInterfaceResponceMessageContinueId";
NSString* const ClassDependenciesResponceMessageId = @"ClassDependenciesResponceMessageId";

NSString* const RunCommandOnServerMessageId = @"Run command on server";
NSString* const UITestWasFinishedMessageId = @"UITestWasFinishedMessageId";

NSString* const HeaderOfClassSeparator = @"-HEADER-";
NSString* const DependencySeparator = @"-DEPEND-";

NSString* const TraceLogMessageId = @"-TRACE-LOG-";
NSString* const TraceLogMessageContinueId = @"-TRACE-LOG-CONTINUE";

NSString* const SendDataNotificationId = @"SendDataNotificationId";
NSString* const DefaultClientHostName = @"localhost";
const NSInteger DefaultServerPortNumber = 1235;
const NSInteger DefaultClientPortNumber = 1234;

NSString* const IsFlexibleFrameOfDTClassInfoViewUserDefaultId = @"IsFlexibleFrameOfDTClassInfoView";
NSString* const LocalServerPortNumberUserDefaultId = @"LocalServerPortNumber";
NSString* const LocalServerHostNameUserDefaultId = @"LocalServerHostName";
NSString* const ClientPortNumberUserDefaultId = @"ClientPortNumberUserDefaultId";
NSString* const ClientHostNameUserDefaultId = @"ClientHostNameUserDefaultId";

NSString* const DirectoryNameForRunTimeClassesSelect = @"ClassesSchemes";
NSString* const ExtentionFileNameOfRunTimeClassesSelect = @"classes";
NSString* const DirectoryNameForPDFUMLClassesSheme = @"shemes";

NSString* const RootNodeNameOnRunTimeBrowser = @"Root";

NSString* const CommandKeyForJSONdictionary = @"Command";
NSString* const DataKeyForJSONdictionary = @"Data";
NSString* const TagKeyForJSONdictionary = @"Tag";
NSString* const LenDataKeyForJSONdictionary = @"LenData";

NSString* const PathToProjectOfTracingDefaultId = @"PathToProjectOfTracingDefaultId";
NSString* const DTTraceLogMacroName = @"DTTraceLog()";

