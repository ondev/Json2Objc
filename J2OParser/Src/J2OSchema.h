#import <Foundation/Foundation.h>

@class J2OType;
@interface J2OSchema : NSObject
@property (nonatomic, strong) NSMutableArray *customTypes;

- (J2OType *)typeForCustomClass:(NSString *)name;
- (J2OType *)typeForBaseClass;
@end
