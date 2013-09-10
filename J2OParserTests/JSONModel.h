

#import <Foundation/Foundation.h>

@interface JSONModel : NSObject
@property (nonatomic, strong) NSMutableDictionary *propertyArrayMap;  //The type of the NSArrary saved element
+(NSDictionary *)jsonKeyToObjectPropertyNameMap;

+(NSArray *)initWithArray:(NSArray *)array elementClassName:(NSString *)className;
-(id)initWithDictionary:(NSDictionary *)jsonObject;
-(NSString *)jsonString;
@end
