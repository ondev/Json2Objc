#import "JSONModel.h"
#import <objc/message.h>
#import "NSString+Helper.h"

@interface JSONModel()

@property (nonatomic) BOOL rootIsArray;
@end

@implementation JSONModel

+(NSDictionary *)jsonKeyToObjectPropertyNameMap {
    // subclass should override this if there's any remap of JSON key vs. Object property name
    return nil;
}

# pragma mark - Designated Init
+(NSArray *)initWithArray:(NSArray *)array elementClassName:(NSString *)className {
    return [[self class] arrayWithArray:array className:className];
}


-(id)initWithDictionary:(NSDictionary *)jsonObject {  // Designated
    if ((self = [super init])) {
        [self setValuesForKeysWithDictionary:jsonObject];
    }
    return self;
}

-(NSString *)jsonString {
    return [NSString jsonStringWithObject:self];
}

# pragma mark - KVC
- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{    
    NSDictionary *key2propMap = [[self class] jsonKeyToObjectPropertyNameMap];
    
    if (key2propMap && key2propMap[key])
        [self setValue:value forKey:key2propMap[key]];
    else {
        // subclass implementation should set the correct key value mappings for custom keys
        NSLog(@">>>>>>> Undefined Key: %@", key);
    }

}

-(void)setValue:(id)value forKey:(NSString *)key {
    
    // If key contains "-", convert to lower case start and the rest camel case
    // eg. convert row-count to rowCount
    key = [NSString dashDelimitedStringToUncapitalizedCamelCaseString:key];
    
    // perform type/class checking
    // Introspect on the key/property's class type
    objc_property_t property = class_getProperty([self class], [key UTF8String]);
    if (property != nil) {
        
        NSString *propertyType = [[self class] propertyTypeStringOfProperty:property];
        
        // Handle Array of KEJSONModel objects
        if ([propertyType isEqualToString:@"NSArray"] || [propertyType isEqualToString:@"NSMutableArray"]) {
            
            // Figure out what class/type the element of this array is:
            // Convention: just remove the 's' at the end of the name and capitalize
            NSString *elemClassName = nil;
            elemClassName = [self.propertyArrayMap objectForKey:key];   //check manually map first
            if (!elemClassName)
            {
                elemClassName = [NSString classNameGenerate:key];
            }
            
            
            NSMutableArray *arr = [@[] mutableCopy];
            for (id elem in value) {
                if ([elem isKindOfClass:[NSMutableDictionary class]] ||
                    [elem isKindOfClass:[NSDictionary class]]) {
                    Class elemClass = NSClassFromString(elemClassName);
                    if (elemClass)
                    {
                        id elemObj = [[elemClass alloc] initWithDictionary:elem];
                        [arr addObject:elemObj];
                    }
                    else {
                        NSAssert(NO, @"%@ class is not define.", elemClassName);
                    }
                }
                else if ([elem isKindOfClass:[NSArray class]]){
                    NSAssert(NO, @"This json is not fit the ruler.");
                    continue;
                }
                else {
                    [arr addObject:elem];
                }
            }
            [super setValue:arr forKey:key];
        
            
            return;       // IMPORTANT: return here, you don't want another repeated setValue:forKey: call
        }
        
        // Handle a KEJSONModel
        Class elemClass = NSClassFromString(propertyType);
        if ([elemClass isSubclassOfClass:[JSONModel class]]) {
            id elemObj = [[elemClass alloc] initWithDictionary:value];
            [super setValue:elemObj forKey:key];
            return;
        }

    }
    
    [super setValue:value forKey:key];
}


-(id)valueForUndefinedKey:(NSString *)key {
    // subclass implementation should provide the correct key value mappings for custom keys
    NSLog(@">>>>>>> Undefined Key: %@", key);
    return nil;
}

+(NSArray *)arrayWithArray:(NSArray *)jsonArray className:(NSString *)className{    
    NSMutableArray *objectsArray = [@[] mutableCopy];
    for (id obj in jsonArray) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            id elemObj = [[NSClassFromString(className) alloc] initWithDictionary:obj];
            [objectsArray addObject:elemObj];
        }
        else if ([obj isKindOfClass:[NSArray class]]) {
            NSAssert(NO, @"This json is not fit the ruler.");
            continue;
        }
        else {
            [objectsArray addObject:obj];
        }
    }
    
    return objectsArray;
}

#pragma mark - Helper
+ (NSString *)propertyTypeStringOfProperty:(objc_property_t) property {
    
    // TODO: Auto-doc this with Xcode 5
    // return the String representing the name of the property's type, eg. "NSMutableArray", "NSString", etc.
    
    const char *attr = property_getAttributes(property);
    NSString *const attributes = [NSString stringWithCString:attr encoding:NSUTF8StringEncoding];
    
    NSRange const typeRangeStart = [attributes rangeOfString:@"T@\""];  // start of type string
    if (typeRangeStart.location != NSNotFound) {
        NSString *const typeStringWithQuote = [attributes substringFromIndex:typeRangeStart.location + typeRangeStart.length];
        NSRange const typeRangeEnd = [typeStringWithQuote rangeOfString:@"\""]; // end of type string
        if (typeRangeEnd.location != NSNotFound) {
            NSString *const typeString = [typeStringWithQuote substringToIndex:typeRangeEnd.location];
            return typeString;
        }
    }
    return nil;
}

@end

