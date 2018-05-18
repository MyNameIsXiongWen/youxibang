//
//  DSWebViewController.m
//  DChang
//
//  Created by 戎博 on 2017/8/25.
//  Copyright © 2017年 昆博. All rights reserved.
//

#import "DSWebViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "AppDelegate.h"

@interface DSWebViewController ()<UIWebViewDelegate>

@property (nonatomic, strong)UIWebView* webView;
@property (nonatomic,strong)NSString* url;

@end

@implementation DSWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
}

-(instancetype)initWithURLSting:(NSString *)urlString {
    if (self = [super init]) {
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH,SCREEN_HEIGHT)];
        webView.delegate = self;
        for (UIView *subView in [webView subviews]) {
            if ([subView isKindOfClass:[UIScrollView class]]) {
                // 不显示竖直的滚动条
                [(UIScrollView *)subView setShowsVerticalScrollIndicator:NO];
            }
        }
        [self.view addSubview:webView];
        self.webView = webView;
        self.url = urlString;
    }
    return self;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    context[@"getUserId"] = ^(){
       
    };
    NSString *urlString =[[request URL] absoluteString];
    
    if ([urlString hasPrefix:@"tel"]){
        return NO;
    }
    
    if ([urlString hasPrefix:DSFinish]) {
        [self.navigationController popViewControllerAnimated:YES];
        return NO;
    }
    if ([urlString hasPrefix:DSMsgToast]) {
        NSString* str = [[urlString substringFromIndex:20] stringByRemovingPercentEncoding];
        
        [SVProgressHUD setBackgroundColor:[UIColor colorWithWhite:0.5 alpha:0.8]];
        [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
        [SVProgressHUD showInfoWithStatus:str];
        return NO;
    }
    if ([urlString hasPrefix:DSMsgDialog]) {
        NSString* str = [[urlString substringFromIndex:21] stringByRemovingPercentEncoding];
        NSLog(@"%@",str);
        
        UIAlertController* alert =  [UIAlertController alertControllerWithTitle:@"温馨提示" message:str preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* s = [UIAlertAction actionWithTitle:@"确认" style:0 handler:^(UIAlertAction * _Nonnull action){
            
            [self.navigationController popViewControllerAnimated:1];
        }];
        [alert addAction:s];
        [self presentViewController:alert animated:YES completion:nil];
        return NO;
    }


    if ([urlString hasPrefix:DSOpenLogin]) {
        return NO;
    }
    if ([urlString hasPrefix:DSOpenIndex]) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        UITabBarController *tabViewController = (UITabBarController *) appDelegate.window.rootViewController;
        
        [tabViewController setSelectedIndex:0];
        [self.navigationController popToRootViewControllerAnimated:YES];
        
        return NO;
    }
    if ([urlString hasPrefix:DSOpen]) {
        NSRange range = [request.URL.absoluteString rangeOfString:@"http"];
        NSString *urlStr = [request.URL.absoluteString substringFromIndex:range.location];
        DSWebViewController *vc = [[DSWebViewController alloc] initWithURLSting:urlStr];
        
        [self.navigationController pushViewController:vc animated:YES];
        return NO;
    }
    if ([urlString hasPrefix:@"switch://cas"]) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        UITabBarController *tabViewController = (UITabBarController *) appDelegate.window.rootViewController;
        
        [tabViewController setSelectedIndex:3];
        return NO;
    }
    if ([urlString hasPrefix:@"switch://order"]) {
        NSNotification *notification = [NSNotification notificationWithName:@"pushOrderList" object:nil userInfo:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"4",@"selectIndex",@"MyOrderListViewController",@"pushVC", nil]];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        [self.navigationController popToRootViewControllerAnimated:1];

        return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
