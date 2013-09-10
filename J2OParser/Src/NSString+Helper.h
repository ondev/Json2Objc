#import <Foundation/Foundation.h>

@interface NSString (Helper)
+(NSString *)classNameGenerate:(NSString *)key;
+(NSString *)capitalizeFirstChar:(NSString *)inputString;
+(NSString *)removeSuffixS:(NSString *)inputString;
+(NSString *)dashDelimitedStringToUncapitalizedCamelCaseString:(NSString *)inputString;
+(NSString *)jsonStringWithObject:(id) object;
@end
