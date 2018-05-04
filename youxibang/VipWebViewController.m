//
//  VipWebViewController.m
//  youxibang
//
//  Created by jiazhuo1 on 2018/5/4.
//

#import "VipWebViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface VipWebViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;


@end

@implementation VipWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"购买会员";
    [self.webView sizeToFit];
    [self.webView scalesPageToFit];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.loadUrlString]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [SVProgressHUD dismiss];
    self.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [SVProgressHUD dismiss];
//    [SVProgressHUD setDefaultMaskType:1];
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    context[@"getUserId"] = ^(){
        
    };
    //    NSString *urlString =[[request URL] absoluteString];
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
