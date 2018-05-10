//
//  VipWebViewController.m
//  youxibang
//
//  Created by jiazhuo1 on 2018/5/4.
//

#import "VipWebViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "SetPayPasswordViewController.h"
#import "RetrievePayPasswordViewController.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import <AlipaySDK/AlipaySDK.h>

@interface VipWebViewController () <UIWebViewDelegate, WXApiDelegate> {
    NSString *payType;
}

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
    //完成付款的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completePay:) name:@"completePay" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)alipayWithTargetId:(NSString *)targetId Account:(NSString *)account PayType:(NSString *)paytype {
    payType = paytype;
    NSMutableDictionary *dict = @{@"token":DataStore.sharedDataStore.token,
                                  @"type":@"1",
                                  @"target_id":targetId,
                                  @"account":account,
                                  @"paytype":paytype
                                  }.mutableCopy;
    if (paytype.integerValue == 3) {
        UserModel *user = UserModel.sharedUser;
        if ([user.is_paypwd isEqualToString:@"0"]){
            SetPayPasswordViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"spp"];
            [self.navigationController pushViewController:vc animated:1];
            return;
        }
        NSString* balance = [NSString stringWithFormat:@"%@",user.user_money?:@"0"];
        if (account.intValue > balance.intValue){
            [SVProgressHUD showErrorWithStatus:@"余额不足"];
            return;
        }
        CustomAlertView* alert = [[CustomAlertView alloc] initWithType:6];
        alert.resultDate = ^(NSString *date) {
            [dict setObject:@"3" forKey:@"paytype"];
            [dict setObject:date forKey:@"pwd"];
            [self payTipForLive:dict];
        };
        alert.resultIndex = ^(NSInteger index) {
            RetrievePayPasswordViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"rpp"];
            [self.navigationController pushViewController:vc animated:1];
        };
        [alert showAlertView];
    }
    else {
        [self payTipForLive:dict];
    }
}

//提交支付
- (void)payTipForLive:(NSDictionary*)dic {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@payment/buy",HttpURLString] Paremeters:dic successOperation:^(id object) {
        [self paymentParameters:object];
    } failoperation:^(NSError *error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        [SVProgressHUD showErrorWithStatus:@"网络信号差，请稍后再试"];
    }];
}

- (void)paymentParameters:(id)object {
    [SVProgressHUD dismiss];
    [SVProgressHUD setDefaultMaskType:1];
    if (isKindOfNSDictionary(object)){
        NSInteger code = [object[@"errcode"] integerValue];
        NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
        NSLog(@"输出 %@--%@",object,msg);
        if (code == 1) {
            if (payType.integerValue == 2) {
                PayReq *request = [[PayReq alloc] init];
                request.partnerId = [NSString stringWithFormat:@"%@",object[@"data"][@"partnerid"]];
                request.prepayId = [NSString stringWithFormat:@"%@",object[@"data"][@"prepayid"]];
                request.package = [NSString stringWithFormat:@"%@",object[@"data"][@"package"]];
                request.nonceStr = [NSString stringWithFormat:@"%@",object[@"data"][@"noncestr"]];
                request.timeStamp = [NSString stringWithFormat:@"%@",object[@"data"][@"timestamp"]].intValue;
                request.sign= [NSString stringWithFormat:@"%@",object[@"data"][@"sign"]];
                [WXApi sendReq:request];
            }else if (payType.integerValue == 1) {
                [[AlipaySDK defaultService] payOrder:[NSString stringWithFormat:@"%@",object[@"data"]] fromScheme:@"alipayYouxibang" callback:^(NSDictionary *resultDic) {
                    
                }];
            }else if (payType.integerValue == 3) {
                [self completePay:nil];
            }
        }else{
            [SVProgressHUD showErrorWithStatus:msg];
        }
    }
}

- (void)completePay:(NSNotification *)notification{
    [self.navigationController popViewControllerAnimated:YES];
    [SVProgressHUD showSuccessWithStatus:@"支付成功"];
    if (self.paySuccessBlock) {
        self.paySuccessBlock();
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [SVProgressHUD dismiss];
//    self.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [SVProgressHUD dismiss];
    [SVProgressHUD setDefaultMaskType:1];
//    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    context[@"getUserId"] = ^(){
        
    };
    NSLog(@"----selector:%@",NSStringFromSelector(_cmd));
    //OC调用JS是基于协议拦截实现的 下面是相关操作
    NSString *absolutePath = request.URL.absoluteString;
    NSString *scheme = @"rrcc://";
    if ([absolutePath hasPrefix:scheme]) {
        NSString *subPath = [absolutePath substringFromIndex:scheme.length];
        if ([subPath containsString:@"?"]) {//1个或多个参数
            if ([subPath containsString:@"&"]) {//多个参数
                NSArray *components = [subPath componentsSeparatedByString:@"?"];
                NSString *methodName = [components firstObject];
                methodName = [methodName stringByReplacingOccurrencesOfString:@"_" withString:@":"];
                SEL sel = NSSelectorFromString(methodName);
                NSString *parameter = [components lastObject];
                NSArray *params = [parameter componentsSeparatedByString:@"&"];
                
                if ([self respondsToSelector:sel]) {
                    [self alipayWithTargetId:params.firstObject Account:params[1] PayType:params.lastObject];
                }
            }
        }
    }
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
