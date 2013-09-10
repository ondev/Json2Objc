#import "J2OSchema.h"
#import "J2OType.h"

@interface J2OSchema()
@end

@implementation J2OSchema
- (id)init {
    self = [super init];
    if (self) {
        self.customTypes = [NSMutableArray new];
    }
    
    return self;
}

- (J2OType *)typeForCustomClass:(NSString *)name {
    J2OType *ret = nil;
    for (J2OType *type in _customTypes) {
        if ([type.variableTypeClassName isEqualToString:name]) {
            ret = type;
            break;
        }
    }
    if (!ret) {
        ret = [J2OType new];
        ret.variableType = Custom_Type;
        ret.variableTypeClassName = name;
        [_customTypes addObject:ret];
    }
    
    return ret;
}

- (J2OType *)typeForBaseClass {
    J2OType *type = [J2OType new];
    type.variableType = Base_Type;
    
    return type;
}
@end
