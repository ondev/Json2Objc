#import <Foundation/Foundation.h>

#define kIllegalClassCharactersSet [NSCharacterSet characterSetWithCharactersInString:@"-./\\"]

@interface USObjCKeywords : NSObject {
	NSArray *keywords;
}

+ (USObjCKeywords *)sharedInstance;

- (BOOL)isAKeyword:(NSString *)testString;

@end
