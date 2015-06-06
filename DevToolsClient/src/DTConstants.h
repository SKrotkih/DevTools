//
//  DTConstants.h
//  DevToolsClient
//
//  Created by Sergey Krotkih on 7/31/12.
//  Copyright (c) 2012 Quickoffice. All rights reserved.
//


// Abstract: Common constants across source files (screen coordinate consts, etc.)
// these are the various screen placement constants used across most the UIViewControllers

// padding for margins

// for general screen
#define kLeftMargin				20.0
#define kTopMargin				20.0
#define kRightMargin			20.0
#define kTweenMargin			10.0
#define kTextFieldHeight		30.0

extern NSString* const ReceivedDataNotificationId;
extern NSString* const EchoFromServerNotificationId;
extern NSString* const DisconnectToServerMessageId;
extern NSString* const StartTraceMessageId;
extern NSString* const StopTraceMessageId;
extern NSString* const RequestToRunTimeBrowserDataNotificationId;
extern NSString* const ResponseRTBrowserDataMessageId;
extern NSString* const ResponseRTBrowserDataMessageContinueId;
extern NSString* const ResponseRTBrowserDataMessageFinishedId;
extern NSString* const StartUITestingMessageId;
extern NSString* const RunUITestScriptMessageId;
extern NSString* const ConnectToServerMessageId;
extern NSString* const UITestErrorMessageId;
extern NSString* const UITestLogMessageId;
extern NSString* const MainLogMessageId;
extern NSString* const ViewsMapNotificationId;
extern NSString* const ViewsMapMessageId;
extern NSString* const ViewsMapMessageContinueId;
extern NSString* const RunCommandOnServerMessageId;
extern NSString* const UITestFinishedNotificationId;
extern NSString* const UITestErrorNotificationId;
extern NSString* const UITestLogNotificationId;
extern NSString* const SendLogNotificationId;
extern NSString* const RunViewScriptMessageId;
extern NSString* const CurrentViewsMessageId;
extern NSString* const ViewsMapFinishedMessageId;
extern NSString* const SwitchToDevToolsMessageId;
extern NSString* const SwitchToApplicationMessageId;

extern NSString* const ClassInterfaceRequestMessageId;
extern NSString* const ClassDependenciesRequestMessageId;
extern NSString* const ClassInterfaceResponceMessageId;
extern NSString* const ClassInterfaceResponceMessageContinueId;
extern NSString* const ClassDependenciesResponceMessageId;

extern NSString* const kSendCommandToServerNotification;
extern NSString* const UITestWasFinishedMessageId;

extern NSString* const HeaderOfClassSeparator;
extern NSString* const DependencySeparator;

extern NSString* const TraceLogMessageId;
extern NSString* const TraceLogMessageContinueId;

extern NSString* const CommandKeyForJSONdictionary;
extern NSString* const DataKeyForJSONdictionary;
extern NSString* const TagKeyForJSONdictionary;
extern NSString* const LenDataKeyForJSONdictionary;
