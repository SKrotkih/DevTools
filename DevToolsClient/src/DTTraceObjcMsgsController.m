//  DTTraceController.m
//  DevToolsClient
//
//  Created by Raymond Wisman on 12/16/09.
//  Copyright Indiana University SE 2009. All rights reserved.
//  Edited by Krotkih Sergey on 27.11.12.
//  Copyright Quickoffice 2012. All rights reserved.
//
// http://www.dribin.org/dave/blog/archives/2006/04/22/tracing_objc/
//

#import "DTTraceObjcMsgsController.h"
#import <foundation/foundation.h>
#import "DevToolsClientController.h"
#import "DevToolsClientViewController.h"
#import "AllClasses.h"
#import "UDPServerController.h"
#import "UDPutils.h"
#import <UISpec/UISpec.h>

const NSUInteger TraceLogBufferMaxLength = 320000;

extern void instrumentObjcMessageSends(BOOL);

char** classesFilter;
uint classesFilterCount;

char* buffer;
bool bufferIsFull;

DTTraceObjcMsgsController* selfInstance;

static int LogObjCMessageSend (BOOL isClassMethod,
                                 const char* objectsClass,
                                 const char* implementingClass,
                                 SEL selector)
{
    BOOL enable = YES;
    
    if (classesFilterCount > 0)
    {
        enable = NO;
        
        for (uint i = 0; i < classesFilterCount; i++)
        {
            char* className = classesFilter[i];
            
            if ((strcmp(className, implementingClass) == 0) || (strcmp(className, objectsClass) == 0))
            {
                enable = YES;

                break;
            }
        }
    }
    
    if (enable && !bufferIsFull)
    {
        char message[1024];
        message[0] = isClassMethod ? '+' : '-';
        message[1] = '\0';
        strcat(message, objectsClass);
        strcat(message, " ");
        
        if (strcmp(objectsClass, implementingClass) != 0)
        {
            strcat(message, implementingClass);
            strcat(message, " ");
        }
        strcat(message, (char*) sel_getName(selector));
        strcat(message, ";");
        strcat(message, "?");
        
        if (buffer == NULL)
        {
            buffer = (char*) malloc(TraceLogBufferMaxLength * sizeof(char));
            *buffer = '\0';
        }
        
        if (strlen(buffer) + strlen(message) > TraceLogBufferMaxLength)
        {
            bufferIsFull = true;
            
            // TODO:: call this code (temporary disable-enable log trace) only if all data were sended!
            //[selfInstance temporaryDisableLogTrace];

            [selfInstance stopTrace];
            
            [selfInstance showLog];
            
            free(buffer);
            buffer = NULL;
            
            //[selfInstance temporaryEnableLogTrace];

            bufferIsFull = false;
        }
        else
        {
            strcat(buffer, message);
        }
    }
    
    return 0;
}

@interface  DTTraceObjcMsgsController  ()
- (void) temporaryDisableLogTrace;
- (void) temporaryEnableLogTrace;
- (void) startTrace;
@end

@implementation DTTraceObjcMsgsController

- (void) dealloc
{
    if (classesFilter != NULL)
    {
        free(classesFilter);
        classesFilter = NULL;
    }

    if (buffer != NULL)
    {
        free(buffer);
        buffer = NULL;
    }
    
    [super dealloc];
}

- (void) startTraceCodeWithCommand: (NSString*) aCommandString
{
    [self performSelectorOnMainThread: @selector(stopTraceUsersAction)
                           withObject: nil
                        waitUntilDone: YES];
    
    [self parseClassesForTrace: aCommandString];
    
    NSInteger lenArray = [classesForTrace count];
    
    classesFilterCount = 0;
    
    if (lenArray > 0)
    {
        classesFilter = (char**)malloc(lenArray * sizeof(char*));
        
        for (NSUInteger i = 0; i < lenArray; i++)
        {
            NSString* str = [classesForTrace objectAtIndex: i];
            
            const char* className = [str UTF8String];
            classesFilter[i] = (char*)className;
            
            classesFilterCount++;
        }
        
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self startTrace];
    });
}

- (void) stopTraceCode
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopTraceUsersAction];
    });
}

#pragma mark private methods

- (void) startTrace
{
    if (isTracingNow)
    {
        return;
    }
    
    if (![self replacingLibobjcLoggingFunction])
    {
        NSString* msg = @"Failed replacing libobjc logging function!";
        DTLog(msg);
        [self.delegate setLog: msg];
        DTLog(@"%@", msg);
        isTracingNow = NO;
        
        return;
    }
    
    [[DevToolsClientController sharedInstance] switchToApplication];
    
    [self temporaryEnableLogTrace];
}

- (void) temporaryDisableLogTrace
{
    isTracingNow = NO;
    instrumentObjcMessageSends(NO);
}

- (void) temporaryEnableLogTrace
{
    isTracingNow = YES;
    instrumentObjcMessageSends(YES);    // Enable logging
}

- (void) stopTrace
{
    if (!isTracingNow)
    {
        return;
    }
    
    [self temporaryDisableLogTrace];
    
    [devToolsMessenger runCommand: StopTraceMessageId
                    contCommandID: @""
                             data: @""];
    
    [self.delegate setLog: StopTraceMessageId];
    DTLog(@"%@", StopTraceMessageId);
    
    [[DevToolsClientController sharedInstance] switchToDevToolsClient];
}

- (void) stopTraceUsersAction
{
    BOOL wasTracing = isTracingNow;
    
    [self stopTrace];
    
    if (buffer == NULL)
    {
        if (wasTracing)
        {
            NSString* msg = @"Trace buffer is empty!";
            DTLog(msg);
            [self.delegate setLog: msg];
        }
        
        return;
    }
    
    [self showLog];

    free(buffer);
    buffer = NULL;
}

- (void) showLog
{
    NSString* traceBuff = [[NSString alloc] initWithUTF8String: buffer];
    
    [devToolsMessenger runCommand: TraceLogMessageId
                    contCommandID: TraceLogMessageContinueId
                             data: traceBuff];
    
    [self.delegate setLog: [traceBuff stringByReplacingOccurrencesOfString: @"?"
                                                                withString: @"\n"]];
    [traceBuff release];
}

- (BOOL) replacingLibobjcLoggingFunction
{
    // Begin code for replacing libobjc logging function
    typedef int (*ObjCLogProc)(BOOL, const char *, const char *, SEL);
    typedef int (*LogObjcMessageSendsFunc)(ObjCLogProc);
    LogObjcMessageSendsFunc fcn;
    
    struct nlist nl[3];
    bzero(&nl, sizeof(struct nlist) * 3);
    nl[0].n_un.n_name = "_instrumentObjcMessageSends";
    nl[1].n_un.n_name = "_logObjcMessageSends";
    
    // Replace libobjc.A.dylib by whatever version you're using
    if (nlist("/usr/lib/libobjc.A.dylib", nl) < 0 || nl[0].n_type == N_UNDF)
    {
        NSString* msg = [NSString stringWithFormat: @"nlist(%s, %s) failed\n", "/usr/lib/libobjc.dylib", nl[0].n_un.n_name];
        DTLog(msg);
        [self.delegate setLog: msg];

        return NO;
    }
    // This line locates libobjc.A.dylib in the memory by getting the address of the symbol
    // instrumentObjcMessageSends contained in this library. To get to the non-exported symbol,
    // we just add the offset between the two symbols which we got by nlist
    fcn = (LogObjcMessageSendsFunc)( (long) (&instrumentObjcMessageSends) + (nl[1].n_value-nl[0].n_value));
    fcn(&LogObjCMessageSend);
    // End
    
    return YES;
}

@end
