#import "AppDelegate.h"
#import "J2OType.h"
#import "J2OSchema.h"
#import "NSObject+Parse.h"
#import "STSTemplateEngine.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}


- (NSURL *)jsonURL
{
#ifdef APPKIT_EXTERN
	NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
	
	NSString *pathString = [defaults valueForKeyPath:@"values.jsonPath"];
#else
	NSString *pathString = [[NSUserDefaults standardUserDefaults] stringForKey:@"jsonPath"];
#endif
	
	if(pathString == nil) return nil;
	if ([pathString length] == 0) return nil;
    
	if([pathString characterAtIndex:0] == '/') {
		return [NSURL fileURLWithPath:pathString];
	}
	
	return [NSURL URLWithString:pathString];
}

- (NSURL *)outURL
{
#ifdef APPKIT_EXTERN
	NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
	
	NSString *pathString = [defaults valueForKeyPath:@"values.outPath"];
#else
	NSString *pathString = [[NSUserDefaults standardUserDefaults] stringForKey:@"outPath"];
#endif
	
	if(pathString == nil) return nil;
	if ([pathString length] == 0) return nil;
	
	if([pathString characterAtIndex:0] == '/') {
		return [NSURL fileURLWithPath:pathString];
	}
    
	return [NSURL URLWithString:pathString];
}

- (IBAction)browseJson:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setCanChooseFiles:YES];
	[panel setCanChooseDirectories:NO];
	[panel setResolvesAliases:NO]; 
	[panel setAllowsMultipleSelection:NO];
    [panel setAllowedFileTypes:[NSArray arrayWithObject:@"json"]];
    if ([panel runModal] == NSOKButton) {
		NSString *chosenPath = [[[panel URLs] lastObject] path];
		NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
		[defaults setValue:chosenPath forKeyPath:@"values.jsonPath"];
    }
}

- (IBAction)browseOutput:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setCanChooseFiles:NO];
	[panel setCanChooseDirectories:YES];
	[panel setResolvesAliases:NO];
	[panel setAllowsMultipleSelection:NO];
    if ([panel runModal] == NSOKButton) {
		NSString *chosenPath = [[[panel URLs] lastObject] path];
		NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
		[defaults setValue:chosenPath forKeyPath:@"values.outPath"];
    }
}

- (IBAction)startParse:(id)sender {
    self.className = [self.classNameField stringValue];
    if ([_className length] > 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            J2OSchema *schema = [J2OSchema new];
            NSError *error = nil;
            NSData *data = [[NSData alloc] initWithContentsOfFile:[self.jsonURL path]];
            id obj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            [NSObject startParse:obj schema:schema className:_className];
            
            if (schema.customTypes.count > 0) {
                
                NSArray *errors;
                NSMutableString *hString = [NSMutableString string];
                NSMutableString *mString = [NSMutableString string];
                [hString appendFormat:@"#import \"JSONModel.h\"\n\n"];
                [mString appendFormat:@"#import \"%@.h\"\n", _className];
                
                //declare foward
                for (J2OType *type in schema.customTypes) {
                    [hString appendFormat:@"@class %@; \n", type.variableTypeClassName];
                }
                [hString appendFormat:@"\n"];
                
                //declare in detail
                for (J2OType *type in schema.customTypes) {
                    NSDictionary *dich = @{@"className":type.variableTypeClassName, @"attributes":type.attributes};
                    
                    
                    NSString *schemaHString = [NSString stringByExpandingTemplateAtPath:[self templateFileHPath]
                                                                        usingDictionary:dich
                                                                               encoding:NSUTF8StringEncoding
                                                                         errorsReturned:&errors];
                    if(errors == nil) {
                        [hString appendString:schemaHString];
                        [hString appendString:@"\n\n"];
                    }
                    
                    NSMutableArray *array = [NSMutableArray new];
                    for (J2OType *t in type.attributes) {
                        if ([t.variableName isEqualToString:t.originVariableName]) {
                            continue;
                        }
                        
                        [array addObject:t];
                    }
                    
                    NSDictionary *dicm = nil;
                    if (array.count > 0) {
                        dicm = @{@"className":type.variableTypeClassName, @"attributes":array};
                    }
                    else {
                        dicm = @{@"className":type.variableTypeClassName};
                    }
                    NSString *schemaMString = [NSString stringByExpandingTemplateAtPath:[self templateFileMPath]
                                                                        usingDictionary:dicm
                                                                               encoding:NSUTF8StringEncoding
                                                                         errorsReturned:&errors];
                    
                    if(errors == nil) {
                        [mString appendString:schemaMString];
                        [mString appendString:@"\n\n"];
                    }
                }
                
                
                //write to file
                [hString writeToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.h", _className] relativeToURL:self.outURL]
                         atomically:NO
                           encoding:NSUTF8StringEncoding
                              error:&error];
                
                [mString writeToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.m", _className] relativeToURL:self.outURL]
                         atomically:NO
                           encoding:NSUTF8StringEncoding
                              error:&error];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self alert:@"Notification" infor:@"Success parse, goto out dir to see the generated file." tag:1];
                });
            }
            else {
                [self alert:@"Notification" infor:@"No custom object, so no file generated" tag:0];
            }
        });
    }
    else {
        [self alert:@"Notification" infor:@"You must input out dir!!!" tag:0];
    }
}

- (NSString *)templateFileHPath
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Template" ofType:@"ht"];
    return path;
}

- (NSString *)templateFileMPath
{
	return [[NSBundle mainBundle] pathForResource:@"Template" ofType:@"mt"];
}

#pragma mark - Notification
- (void)notification:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    NSNumber *num = (__bridge NSNumber *)contextInfo;
    if ([num integerValue] == 1) {
        const char *path = [[self.outURL path] UTF8String];
        char buf[256];
        memset(buf, 0, sizeof(buf));
        sprintf(buf, "open %s", path);
        system(buf);
    }
}

- (void)alert:(NSString *)msg infor:(NSString *)infor tag:(NSInteger)tag {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setAlertStyle:NSInformationalAlertStyle];
    [alert setMessageText:msg];
    [alert setInformativeText:infor];
    
    [alert beginSheetModalForWindow:self.window
                      modalDelegate:self
                     didEndSelector:@selector(notification:returnCode:contextInfo:)
                        contextInfo:(__bridge void *)[NSNumber numberWithInteger:tag]];
}
@end
