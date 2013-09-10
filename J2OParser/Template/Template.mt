@implementation %«className»
%IFDEF attributes
+(NSDictionary *) jsonKeyToObjectPropertyNameMap {
    return @{
%FOREACH attribute in attributes
%IFNEQ attribute.variableName attribute.originVariableName
           @"%«attribute.originVariableName»":@"%«attribute.variableName»",
%ENDIF
%ENDFOR
           };
}
%ENDIF
@end
