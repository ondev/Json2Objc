#import "J2OType.h"
#import "USObjCKeywords.h"
#import "NSString+Helper.h"

@implementation J2OType
- (id)init {
    self = [super init];
    if (self) {
        self.attributes = [NSMutableArray new];
        self.isPointer = @"YES";
    }
    
    return self;
}

- (void)setVariableName:(NSString *)variableName {
	self.originVariableName = variableName;
    USObjCKeywords *keywords = [USObjCKeywords sharedInstance];
	if([keywords isAKeyword:variableName]) {
		variableName = [NSString stringWithFormat:@"%@_", variableName];
	}
    variableName = [NSString dashDelimitedStringToUncapitalizedCamelCaseString:variableName];
    _variableName = variableName;
}

- (void)addAttribute:(J2OType *)type {
    [self.attributes addObject:type];
}
@end
