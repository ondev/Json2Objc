#import "Menu.h"
@implementation Menu
@end


@implementation MenuItemsObject
+(NSDictionary *) jsonKeyToObjectPropertyNameMap {
    return @{
           @"id":@"id_",
           @"review-count":@"reviewCount",
           };
}
@end


@implementation ReviewsObject
+(NSDictionary *) jsonKeyToObjectPropertyNameMap {
    return @{
           @"id":@"id_",
           };
}
@end


@implementation StatusObject
@end


