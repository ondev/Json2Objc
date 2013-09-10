#import <Foundation/Foundation.h>

typedef enum _VariableType {
    Base_Type,
    Custom_Type
    
}VariableType;

@interface J2OType : NSObject
@property (nonatomic, strong) NSMutableArray *attributes;             //该类的所属性
@property (nonatomic, strong) NSString       *isPointer;              //是否是指针
@property (nonatomic, assign) VariableType   variableType;            //是否是自定义类型
@property (nonatomic, strong) NSString       *variableName;           //变量名
@property (nonatomic, strong) NSString       *variableTypeClassName;  //类型
@property (nonatomic, strong) NSString       *elementClassName;       //如果是数组，则数组中存的变量名
@property (nonatomic, strong) NSString       *originVariableName;     //json中的名字，如果是关键字则改变，否则与variableName相同

- (void)addAttribute:(J2OType *)type;
@end


//declare is:
// variableType variableName