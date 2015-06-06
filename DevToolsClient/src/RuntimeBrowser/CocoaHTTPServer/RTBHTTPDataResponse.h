#import <Foundation/Foundation.h>
#import "HTTPResponse.h"


@interface RTBHTTPDataResponse : NSObject <HTTPResponse>
{
	NSUInteger offset;
	NSData *data;
}

- (id)initWithData:(NSData *)data;

@end
