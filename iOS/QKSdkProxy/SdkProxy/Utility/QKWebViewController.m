//
//  QKWebViewController.m
//  Unity-iPhone
//
//  Created by wending on 2018/5/7.
//

#import "QKWebViewController.h"

#import "QKSdkProxyUtility.h"

@interface QKWebViewController ()

@property(nonatomic, strong) NSString* url;
@property(nonatomic, strong) UIWebView* webView;

@end

QKWebViewController *webViewController = nil;

@implementation QKWebViewController

+ (void)showWeb:(NSString*)url
{
    if (webViewController == nil) {
        
        webViewController = [[QKWebViewController alloc] initWithUrl:url];
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [[QKSdkProxyUtility getViewController] presentViewController:webViewController animated:NO completion:^{
                
            }];
        });
    }
}

- (instancetype)initWithUrl:(NSString*)url
{
    if (self = [super init]) {
        self.url = url;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIWebView* webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    // 2.创建URL
    NSURL* url = [NSURL URLWithString:self.url];
    // 3.创建Request
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    // 4.加载网页
    [webView loadRequest:request];
    // 5.最后将webView添加到界面
    [self.view addSubview:webView];
    self.webView = webView;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"X" forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:30]];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor grayColor]];
    [btn setFrame:CGRectMake(self.view.bounds.size.width - 60, 20, 40, 40)];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(closeWebView:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)closeWebView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        webViewController = nil;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
//    return UIInterfaceOrientationMaskPortrait;
}

@end
