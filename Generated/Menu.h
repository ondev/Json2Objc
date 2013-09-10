#import "JSONModel.h"

@class Menu; 
@class MenuItemsObject; 
@class ReviewsObject; 
@class StatusObject; 

@interface Menu : JSONModel
@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) StatusObject *status;
@end


@interface MenuItemsObject : JSONModel
@property (nonatomic, strong) NSString *id_;
@property (nonatomic, strong) NSString *spicy_level;
@property (nonatomic, strong) NSArray *reviews;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *reviewCount;
@end


@interface ReviewsObject : JSONModel
@property (nonatomic, strong) NSString *id_;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *rating;
@end


@interface StatusObject : JSONModel
@property (nonatomic, strong) NSString *localdesc;
@property (nonatomic, strong) NSString *code;
@end


