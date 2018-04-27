//
//  NewsDetailViewController.m
//  youxibang
//
//  Created by jiazhuo1 on 2018/4/26.
//

#import "NewsDetailViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "LoginViewController.h"

@interface NewsDetailViewController () <UIWebViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UITextField *reviewTextField;
- (IBAction)clickReviewBtn:(id)sender;
- (IBAction)clickLaudBtn:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *laudButton;
@property (strong, nonatomic) NSDictionary *dataInfo;
@property (strong, nonatomic) NSMutableArray *reviewArray;

@end

@implementation NewsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.laudButton.layer.borderColor = [UIColor colorFromHexString:@"b2b2b2"].CGColor;
    self.laudButton.layer.borderWidth = 0.5;
    self.laudButton.layer.cornerRadius = 16;
    self.laudButton.layer.masksToBounds = YES;
    self.reviewTextField.layer.borderColor = [UIColor colorFromHexString:@"b2b2b2"].CGColor;
    self.reviewTextField.layer.borderWidth = 0.5;
    self.reviewTextField.layer.cornerRadius = 16;
    self.reviewTextField.layer.masksToBounds = YES;
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 8, 40, 16)];
    leftView.backgroundColor = UIColor.clearColor;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"news_pencil"]];
    imageView.frame = CGRectMake(12, 0, 19, 16);
    [leftView addSubview:imageView];
    self.reviewTextField.leftView = leftView;
    self.reviewTextField.leftViewMode = UITextFieldViewModeAlways;
    
    [self getNewsDetailRequest];
}

- (void)getNewsDetailRequest {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    NSMutableDictionary *dic = @{@"article_id":self.article_id}.mutableCopy;
    if (DataStore.sharedDataStore.token) {
        [dic setObject:[DataStore sharedDataStore].token forKey:@"token"];
    }
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@article/get_details",HttpURLString] Paremeters:dic successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            if (code == 1) {
                self.dataInfo = object[@"data"];
                [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.dataInfo[@"content"]]]];
            }else{
                [SVProgressHUD showErrorWithStatus:msg];
            }
        }
    } failoperation:^(NSError *error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        [SVProgressHUD showErrorWithStatus:@"网络信号差，请稍后再试"];
    }];
}

- (void)getNewsDetailReviewListRequest {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    NSDictionary *dic = @{@"article_id":self.article_id};
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@article/comment_list",HttpURLString] Paremeters:dic successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            if (code == 1) {
                self.reviewArray = object[@"data"];
                
            }else{
                [SVProgressHUD showErrorWithStatus:msg];
            }
        }
    } failoperation:^(NSError *error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        [SVProgressHUD showErrorWithStatus:@"网络信号差，请稍后再试"];
    }];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
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
        
        //        return [[DataStore sharedDataStore].UId integerValue];
    };
    NSString *urlString =[[request URL] absoluteString];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any  that can be recreated.
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self reviewArticleRequestWithContent:textField.text];
}

- (void)reviewArticleRequestWithContent:(NSString *)content {
    if (!DataStore.sharedDataStore.token) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController* vc = [sb instantiateViewControllerWithIdentifier:@"loginPWD"];
        [self.navigationController pushViewController:vc animated:1];
        return;
    }
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    NSDictionary *dic = @{@"article_id":self.article_id,
                          @"token":[DataStore sharedDataStore].token,
                          @"details":content};
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@article/publish_comment",HttpURLString] Paremeters:dic successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            if (code == 1) {
                self.dataInfo = object[@"data"];
                
            }else{
                [SVProgressHUD showErrorWithStatus:msg];
            }
        }
    } failoperation:^(NSError *error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        [SVProgressHUD showErrorWithStatus:@"网络信号差，请稍后再试"];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)clickReviewBtn:(id)sender {
    [self getNewsDetailReviewListRequest];
}

- (IBAction)clickLaudBtn:(id)sender {
    [self likeRequest:(UIButton *)sender];
}

- (void)likeRequest:(UIButton *)sender {
    if (!DataStore.sharedDataStore.token) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController* vc = [sb instantiateViewControllerWithIdentifier:@"loginPWD"];
        [self.navigationController pushViewController:vc animated:1];
        return;
    }
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:self.article_id forKey:@"target_id"];
    [dict setObject:@"1" forKey:@"type"];
    [dict setObject:DataStore.sharedDataStore.token forKey:@"token"];
    NSString *requestUrl = [NSString stringWithFormat:@"%@article/laud",HttpURLString];
    if (sender.selected) {
        requestUrl = [NSString stringWithFormat:@"%@article/cancel_laud",HttpURLString];
    }
    
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:requestUrl Paremeters:dict successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            if (code == 1) {
                sender.selected = !sender.selected;
                if (sender.selected) {
                    [sender setImage:[UIImage imageNamed:@"news_liked"] forState:UIControlStateNormal];
                }
                else {
                    [sender setImage:[UIImage imageNamed:@"news_like"] forState:UIControlStateNormal];
                }
            }else{
                [SVProgressHUD showErrorWithStatus:msg];
            }
        }
    } failoperation:^(NSError *error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        [SVProgressHUD showErrorWithStatus:@"网络信号差，请稍后再试"];
    }];
}

@end
