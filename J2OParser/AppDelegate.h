#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (nonatomic, readonly) NSURL *jsonURL;
@property (nonatomic, readonly) NSURL *outURL;
@property (nonatomic, strong) NSString *className;

- (IBAction)browseJson:(id)sender;
- (IBAction)browseOutput:(id)sender;
- (IBAction)startParse:(id)sender;
@property (weak) IBOutlet NSTextField *classNameField;
@end
