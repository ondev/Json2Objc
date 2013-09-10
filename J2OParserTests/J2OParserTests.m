#import "J2OParserTests.h"
#import "Array.h"
#import "Menu.h"
#import "NSString+Helper.h"

@implementation J2OParserTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
    NSError *error = nil;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    id obj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    Menu *menu = [[Menu alloc] initWithDictionary:obj];
    NSString *json = [menu jsonString];
}

- (void)testArray {
    NSError *error = nil;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"array" ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    id obj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSArray *array = [JSONModel initWithArray:obj elementClassName:@"ArrayObject"];
    NSString *json = [NSString jsonStringWithObject:array];
}

@end
