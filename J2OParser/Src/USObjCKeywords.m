#import "USObjCKeywords.h"

static USObjCKeywords *sharedInstance = nil;

@implementation USObjCKeywords

+ (USObjCKeywords *)sharedInstance
{
	if(sharedInstance == nil) {
		sharedInstance = [USObjCKeywords new];
	}
	
	return sharedInstance;
}

- (id)init
{
	// Also included here are standard Mac/iPhone typedefs that might
	// be likely names of attributes as these cause the compiler to
	// complain as well.

	if((self = [super init])) {
		keywords = [NSArray arrayWithObjects:
					@"id",
					@"for",
					@"self",
					@"super",
					@"return",
					@"const",
					@"volatile",
					@"in",
					@"out",
					@"inout",
					@"bycopy",
					@"byref",
					@"oneway",
					@"void",
					@"char",
					@"short",
					@"int",
					@"long",
					@"float",
					@"double",
					@"signed",
					@"unsigned",
					@"class",
					@"break",
					@"switch",
					@"default",
					@"case",
					@"inline",
								
					// Standard Mac/iPhone types that might be chosen as attribute names
					@"fixed",
					@"ptr",
					@"handle",
					@"size",
					@"bytecount",
					@"byteoffset",
					@"duration",
					@"absolutetime",
					@"itemcount",
					@"langcode",
					@"regioncode",
					@"oserr",
					@"ostype",
					@"osstatus",
					@"point",
					@"style",
					
					// Variable names used during serialization
					@"doc",
					@"root",
					@"ns",
					@"xsi",
					@"node",
					@"buf",
					
					// more:
					@"method",
					@"category",
					nil];
	}
	
	return self;
}

- (BOOL)isAKeyword:(NSString *)testString
{
  // Compiler objects to things with the same name as keywords even if the
  // case differs, so convert to lower case for the test.
  
	if([keywords containsObject:[testString lowercaseString]]) {
		return YES;
	}
	
	return NO;
}

@end
