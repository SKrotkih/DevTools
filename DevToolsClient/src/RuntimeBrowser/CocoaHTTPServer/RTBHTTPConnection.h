#import <Foundation/Foundation.h>

@class GCDAsyncSocket;
@class HTTPMessage;
@class RTBHTTPServer;
@class WebSocket;
@protocol HTTPResponse;


#define RTBHTTPConnectionDidDieNotification  @"RTBHTTPConnectionDidDie"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface HTTPConfig : NSObject
{
	RTBHTTPServer *server;
	NSString *documentRoot;
	dispatch_queue_t queue;
}

- (id)initWithServer:(RTBHTTPServer *)server documentRoot:(NSString *)documentRoot;
- (id)initWithServer:(RTBHTTPServer *)server documentRoot:(NSString *)documentRoot queue:(dispatch_queue_t)q;

@property (nonatomic, readonly) RTBHTTPServer *server;
@property (nonatomic, readonly) NSString *documentRoot;
@property (nonatomic, readonly) dispatch_queue_t queue;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface RTBHTTPConnection : NSObject
{
	dispatch_queue_t connectionQueue;
	GCDAsyncSocket *asyncSocket;
	HTTPConfig *config;
	
	BOOL started;
	
	HTTPMessage *request;
	unsigned int numHeaderLines;
	
	BOOL sentResponseHeaders;
	
	NSString *nonce;
	long lastNC;
	
	NSObject<HTTPResponse> *httpResponse;
	
	NSMutableArray *ranges;
	NSMutableArray *ranges_headers;
	NSString *ranges_boundry;
	int rangeIndex;
	
	UInt64 requestContentLength;
	UInt64 requestContentLengthReceived;
	
	NSMutableArray *responseDataSizes;
}

- (id)initWithAsyncSocket:(GCDAsyncSocket *)newSocket configuration:(HTTPConfig *)aConfig;

- (void)start;
- (void)stop;

- (void)startConnection;

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path;
- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path;

- (BOOL)isSecureServer;
- (NSArray *)sslIdentityAndCertificates;

- (BOOL)isPasswordProtected:(NSString *)path;
- (BOOL)useDigestAccessAuthentication;
- (NSString *)realm;
- (NSString *)passwordForUser:(NSString *)username;

- (NSDictionary *)parseParams:(NSString *)query;
- (NSDictionary *)parseGetParams;

- (NSString *)requestURI;

- (NSArray *)directoryIndexFileNames;
- (NSString *)filePathForURI:(NSString *)path;
- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path;
- (WebSocket *)webSocketForURI:(NSString *)path;

- (void)prepareForBodyWithSize:(UInt64)contentLength;
- (void)processDataChunk:(NSData *)postDataChunk;

- (void)handleVersionNotSupported:(NSString *)version;
- (void)handleAuthenticationFailed;
- (void)handleResourceNotFound;
- (void)handleInvalidRequest:(NSData *)data;
- (void)handleUnknownMethod:(NSString *)method;

- (NSData *)preprocessResponse:(HTTPMessage *)response;
- (NSData *)preprocessErrorResponse:(HTTPMessage *)response;

- (BOOL)shouldDie;
- (void)die;

@end

@interface RTBHTTPConnection (AsynchronousHTTPResponse)
- (void)responseHasAvailableData:(NSObject<HTTPResponse> *)sender;
- (void)responseDidAbort:(NSObject<HTTPResponse> *)sender;
@end
