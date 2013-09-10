#import <Foundation/Foundation.h>

@class J2OSchema;
@class J2OType;

@interface NSObject (Parse)
+ (void)startParse:(id)data schema:(J2OSchema *)schema className:(NSString *)name;
@end
