#import "NSObject+Parse.h"
#import "NSString+Helper.h"
#import "J2OSchema.h"
#import "J2OType.h"

@implementation NSObject (Parse)

+ (void)startParse:(id)data schema:(J2OSchema *)schema className:(NSString *)name{
    if ([data isKindOfClass:[NSDictionary class]]) {
        J2OType *type = [schema typeForCustomClass:name];
        [[self class] parseDic:data schema:schema type:type];
    }
    else if ([data isKindOfClass:[NSArray class]]){
        J2OType *type = [schema typeForBaseClass];
        NSString *className = [NSString classNameGenerate:name];
        type.elementClassName = className;
        [[self class] parseArray:data schema:schema type:type];
    }
    else {
        assert(@"Failed");
    }
}

+(void)parseDic:(NSDictionary *)dict schema:(J2OSchema *)schema type:(J2OType *)type {
    NSArray *allKeys = [dict allKeys];
    for (NSString *key in allKeys) {
        id element = [dict objectForKey:key];
        if ([element isKindOfClass:[NSDictionary class]]) {
            NSString *className = [NSString classNameGenerate:key];
            J2OType *t = [schema typeForCustomClass:className];
            t.variableType = Custom_Type;
            t.variableTypeClassName = className;
            t.variableName = key;
            [NSObject parseDic:element schema:schema type:t];
            [type addAttribute:t];
        }
        else if ([element isKindOfClass:[NSArray class]]) {
            NSString *className = [NSString classNameGenerate:key];
            J2OType *t = [J2OType new];
            t.variableType = Base_Type;
            t.variableTypeClassName = @"NSArray";
            t.variableName = key;
            t.elementClassName = className;
            [NSObject parseArray:element schema:schema type:t];
            [type addAttribute:t];
        }
        else {
            //base type
            J2OType *t = [J2OType new];
            NSString *className = nil;
            if ([element isKindOfClass:[NSNumber class]]) {
                const char * pObjCType = [element objCType];
                if (strcmp(pObjCType, @encode(int))  == 0) {
                    className = @"int";
                }
                else if (strcmp(pObjCType, @encode(float)) == 0) {
                    className = @"float";
                }
                else if (strcmp(pObjCType, @encode(double))  == 0) {
                    className = @"double";
                }
                else if (strcmp(pObjCType, @encode(BOOL)) == 0) {
                    className = @"BOOL";
                }
                t.isPointer = @"NO";
            }
            else  {
                className = @"NSString";
            }
            
            t.variableType = Base_Type;
            t.variableTypeClassName = className;
            t.variableName = key;
            [type addAttribute:t];
        }
    }
}

+(void)parseArray:(NSArray *)array schema:(J2OSchema *)schema type:(J2OType *)type {
    for (id element in array) {
        if ([element isKindOfClass:[NSDictionary class]]) {
            NSString *className = [NSString capitalizeFirstChar:type.elementClassName];
            J2OType *t = [schema typeForCustomClass:className];
            [NSObject parseDic:element schema:schema type:t];
            break;  //because array are same object, so only parse one here
        }else if ([element isKindOfClass:[NSArray class]]) {
            assert(@"No support array in array");
        } else {
        }
    }
}

@end