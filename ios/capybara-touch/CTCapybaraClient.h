#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol CTCapybaraDelegate<NSObject>

- (void)visit:(NSString *)url;
- (void)reset;
- (void)javascriptCommand:(NSArray *)arguments;
- (void)executeScript:(NSString *)script;

- (void)findXpath:(NSString *)xpath;
- (void)findCSS:(NSString *)selector;

- (void)currentURL;
- (void)body;
- (void)title;
- (void)headers;

@end

@interface CTCapybaraClient : NSObject<CTCapybaraDelegate, UIWebViewDelegate>

- (void)connect;

@property (strong, nonatomic) UIWebView *webView;

@end

