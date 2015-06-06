#import <Foundation/Foundation.h>

@interface SpecsOutputData : NSObject
{

}

+ (void) sendCurrentViewsData;

+ (void) sendViewsMapWithName: (NSString*) aMapName;

+ (void) runScriptItem: (NSString*) aScriptItem;

@end
