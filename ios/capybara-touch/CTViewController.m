#import "CTViewController.h"

@interface CTViewController ()

@end

@implementation CTViewController

- (id)init {
    if (self = [super init]) {
        self.server = [[TCPServer alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.view = self.webView;
    self.webView.delegate = self;

    [self.webView loadHTMLString:@"<html><head><title>HI MOM</title></head><body><h1>I'M A WEB PAGE</h1></body></html>" baseURL:[NSURL URLWithString:@"hi"]];
}

- (void)injectCapybara {
    NSString *fileName = [[NSBundle mainBundle] pathForResource:@"capybara" ofType:@"js"];
NSData *fileData = [NSData dataWithContentsOfFile:fileName];
    NSString *capybaraString = [[NSString alloc] initWithData:fileData encoding:NSStringEncodingConversionAllowLossy];
    [self.webView stringByEvaluatingJavaScriptFromString: capybaraString];

    self.server.port = 9292;
    self.server.domain = @"localhost";
    NSError *error = [[NSError alloc] init];
    [self.server start:&error];
    self.server.delegate = self;
    NSLog(@"listening on port: %d", self.server.port);
}

- (NSString *)execute:(NSString *)js {
    return [self.webView stringByEvaluatingJavaScriptFromString:js];
}

#pragma mark - TCPServerDelegateProtocol
- (void)TCPServer:(TCPServer *)server didReceiveConnectionFromAddress:(NSData *)addr inputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream {
    NSLog(@"Received connection from address: %@", addr);

    if ([inputStream streamStatus] == NSStreamStatusNotOpen) {
        [inputStream open];
    }
    inputStream.delegate = self;

    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self injectCapybara];
}

#pragma mark - NSStreamDelegate
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)streamEvent {
    if (streamEvent == NSStreamEventHasBytesAvailable && [(NSInputStream *)stream hasBytesAvailable]) {
        uint8_t *buf;
        NSInteger len = [(NSInputStream *)stream read:buf maxLength:1024];
        if (len)        {
            NSString *tmpStr = [[NSString alloc] initWithBytes:buf length:len encoding:NSUTF8StringEncoding];
            NSLog(@"================> %@", tmpStr);
        }
    }
}

@end
