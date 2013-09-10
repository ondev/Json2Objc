#import "NSString+Helper.h"
#import <objc/runtime.h>

@implementation NSString (Helper)

#pragma mark - Helper
+(NSString *)classNameGenerate:(NSString *)key {
    NSString *className = [NSString capitalizeFirstChar:key];
    return [NSString stringWithFormat:@"%@Object", className];
}


+(NSString *)capitalizeFirstChar:(NSString *)inputString {
    return [inputString stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[inputString substringToIndex:1] uppercaseString]];
}

+(NSString *)removeSuffixS:(NSString *)inputString {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"s$" options:0 error:&error];
    
    NSMutableString *str = [inputString mutableCopy];
    
    [regex replaceMatchesInString:str options:0 range:NSMakeRange(0, inputString.length) withTemplate:@""];
    
    return str;
}

+(NSString *)dashDelimitedStringToUncapitalizedCamelCaseString:(NSString *)inputString {
    // eg. convert row-count to rowCount
    
    if ([inputString rangeOfString:@"-"].location == NSNotFound)
        return inputString;
    
    NSMutableString *returnString = [NSMutableString new];
    NSArray *a = [inputString componentsSeparatedByString:@"-"];
    
    // Do not capitalize the 1st one.
    [returnString appendString:a[0]];
    
    for (int i = 1; i < a.count; i++) {
        NSString *capSubstr = [a[i] capitalizedString];
        [returnString appendString:capSubstr];
    }
    return returnString;
}


#pragma mark - json
+(NSString *) jsonStringWithString:(NSString *) string{
    return [NSString stringWithFormat:@"\"%@\"",
            [[string stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"] stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]
            ];
}
+(NSString *) jsonStringWithArray:(NSArray *)array{
    NSMutableString *reString = [NSMutableString string];
    [reString appendString:@"["];
    NSMutableArray *values = [NSMutableArray array];
    for (id valueObj in array) {
        NSString *value = [NSString jsonStringWithObject:valueObj];
        if (value) {
            [values addObject:[NSString stringWithFormat:@"%@",value]];
        }
    }
    [reString appendFormat:@"%@",[values componentsJoinedByString:@","]];
    [reString appendString:@"]"];
    return reString;
}
+(NSString *) jsonStringWithDictionary:(NSDictionary *)dictionary{
    NSArray *keys = [dictionary allKeys];
    NSMutableString *reString = [NSMutableString string];
    [reString appendString:@"{"];
    NSMutableArray *keyValues = [NSMutableArray array];
    for (int i=0; i<[keys count]; i++) {
        NSString *name = [keys objectAtIndex:i];
        id valueObj = [dictionary objectForKey:name];
        NSString *value = [NSString jsonStringWithObject:valueObj];
        if (value) {
            [keyValues addObject:[NSString stringWithFormat:@"\"%@\":%@",name,value]];
        }
    }
    [reString appendFormat:@"%@",[keyValues componentsJoinedByString:@","]];
    [reString appendString:@"}"];
    return reString;
}


+(NSString *) jsonStringWithObject:(id) object{
    NSString *value = nil;
    if (!object) {
        return value;
    }
    if ([object isKindOfClass:[NSString class]]) {
        value = [NSString jsonStringWithString:object];
    }else if ([object isKindOfClass:[NSNumber class]]) {
        
        const char * pObjCType = [object objCType];
        if (strcmp(pObjCType, @encode(BOOL)) == 0) {
            value = [object boolValue] ? @"true" : @"false";
        }
        else {
            value = object;
        }
    }else if([object isKindOfClass:[NSDictionary class]]){
        value = [NSString jsonStringWithDictionary:object];
    }else if([object isKindOfClass:[NSArray class]]){
        value = [NSString jsonStringWithArray:object];
    }else if([object isKindOfClass:[NSObject class]]){
        value = [NSString jsonStringWithCustom:object];
    }
    return value;
}



+(NSString *)jsonStringWithCustom:(id)object {
    NSString *value = nil;
    if (!object) {
        return value;
    }
    BOOL hasProperty = NO;
    
    NSMutableString *reString = [NSMutableString string];
    [reString appendString:@"{"];
    NSMutableArray *keyValues = [NSMutableArray array];
    
    // get protocol property
    if (class_conformsToProtocol(class_getSuperclass([object class]), objc_getProtocol("DataPoolProtocol"))) {
        
        unsigned protocolPropertyCount = 0;
        objc_property_t *protocolProperties = protocol_copyPropertyList(objc_getProtocol("DataPoolProtocol"), &protocolPropertyCount);
        hasProperty = protocolPropertyCount > 0 ? YES : NO;
        
        for (int i = 0; i < protocolPropertyCount; i++) {
            objc_property_t property = protocolProperties[i];
            char *readonly = property_copyAttributeValue(property, "R");
            if (readonly)
            {
                free(readonly);
                continue;
            }
            
            NSString *propName = [NSString stringWithUTF8String:property_getName(property)];
            id valueObj = [object valueForKey:propName];
            
            if (valueObj) {
                NSString *value = [NSString jsonStringWithObject:valueObj];
                if (value) {
                    [keyValues addObject:[NSString stringWithFormat:@"\"%@\":%@",propName,value]];
                }
            }
        }
        free(protocolProperties);
    }
    
    // get class property
    unsigned propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList([object class], &propertyCount);
    hasProperty = (hasProperty || propertyCount > 0) ? YES : NO;
    
    for (int i = 0; i < propertyCount; i++) {
        objc_property_t property = properties[i];
        
        char *readonly = property_copyAttributeValue(property, "R");
        if (readonly)
        {
            free(readonly);
            continue;
        }
        
        NSString *propName = [NSString stringWithUTF8String:property_getName(property)];
        id valueObj = [object valueForKey:propName];
        
        if (valueObj) {
            NSString *value = [NSString jsonStringWithObject:valueObj];
            if (value) {
                [keyValues addObject:[NSString stringWithFormat:@"\"%@\":%@",propName,value]];
            }
        }
    }
    free(properties);
    
    if (hasProperty) {
        
        [reString appendFormat:@"%@",[keyValues componentsJoinedByString:@","]];
        [reString appendString:@"}"];
        return reString;
    }
    
    return object;
}
@end
