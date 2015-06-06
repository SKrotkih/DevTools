#import <Foundation/Foundation.h>
#import "HTTPResponse.h"

@class RTBHTTPConnection;


@interface RTBHTTPFileResponse : NSObject <HTTPResponse>
{
	RTBHTTPConnection *connection;
	
	NSString *filePath;
	UInt64 fileLength;
	UInt64 fileOffset;
	
	BOOL aborted;
	
	int fileFD;
	void *buffer;
	NSUInteger bufferSize;
}

- (id)initWithFilePath:(NSString *)filePath forConnection:(RTBHTTPConnection *)connection;
- (NSString *)filePath;

@end
