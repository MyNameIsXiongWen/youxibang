//
//  ForgotPasswordViewController.m
//  youxibang
//
//  Created by y on 2018/1/30.
//

#import "ForgotPasswordViewController.h"
#import "JKCountDownButton.h"
#import "LoginViewController.h"

@interface ForgotPasswordViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *phone;
@property (weak, nonatomic) IBOutlet UITextField *code;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *secPassword;
@property (weak, nonatomic) IBOutlet JKCountDownButton *codeBtn; 

@end

@implementation ForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"找回密码";
    if (self.titleText){
        self.title = self.titleText;
    }
    
    self.password.secureTextEntry = YES;
    self.secPassword.secureTextEntry = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//获取验证码
- (IBAction)getCode:(JKCountDownButton *)sender {
    if ( [EBUtility isMobileNumber:self.phone.text] ==NO) {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号码"];
        return;
    }
    
//    sender.enabled = NO;
//    //button type要 设置成custom 否则会闪动
//    [sender startWithSecond:60];
//
//    [sender didChange:^NSString *(JKCountDownButton *countDownButton,int second) {
//        NSString *title = [NSString stringWithFormat:@"剩余%d秒",second];
//        return title;
//    }];
//    [sender didFinished:^NSString *(JKCountDownButton *countDownButton, int second) {
//        countDownButton.enabled = YES;
//        return @"获取验证码";
//    }];
    
    [self gainCodeRequest:self.phone.text];
}
- (void)gainCodeRequest:(NSString *)phoneString
{
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:phoneString forKey:@"mobile"];
    
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Currency/sendsms",HttpURLString] Paremeters:dict successOperation:^(id object) {
        
        NSInteger code = [object[@"errcode"] integerValue];
        NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]];
        NSLog(@"验证码输出 %@--%@",object,msg);
        if (code == 1) {
            [SVProgressHUD showSuccessWithStatus:msg];
            self.codeBtn.enabled = NO;
            [self.codeBtn startWithSecond:60];
            
            [self.codeBtn didChange:^NSString *(JKCountDownButton *countDownButton,int second) {
                NSString *title = [NSString stringWithFormat:@"剩余%d秒",second];
                return title;
            }];
            [self.codeBtn didFinished:^NSString *(JKCountDownButton *countDownButton, int second) {
                countDownButton.enabled = YES;
                return @"获取验证码";
            }];
        }else
        {
            [SVProgressHUD showErrorWithStatus:msg];
            
        }
    } failoperation:^(NSError *error) {
        NSLog(@"errr %@",error);
        
    }];
}
//提交
- (IBAction)commit:(id)sender {
    [self.view endEditing:YES];
    if ([EBUtility isBlankString:self.code.text]){
        [SVProgressHUD showErrorWithStatus:@"请输入验证码"];
        return;
    }
    if ([EBUtility isBlankString:self.code.text]){
        [SVProgressHUD showErrorWithStatus:@"请输入验证码"];
        return;
    }
    if ([EBUtility isBlankString:self.password.text]){
        [SVProgressHUD showErrorWithStatus:@"请输入密码"];
        return;
    }
    if ([EBUtility isBlankString:self.secPassword.text]){
        [SVProgressHUD showErrorWithStatus:@"请再次输入密码"];
        return;
    }
    if (![self.password.text isEqualToString:self.secPassword.text]){
        [SVProgressHUD showErrorWithStatus:@"两次输入的密码不一致"];
        return;
    }
    if (![EBUtility validatePassword:self.password.text]){
        [SVProgressHUD showErrorWithStatus:@"请输入密码为6-15位数字或字母"];
        return;
    }
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:self.phone.text forKey:@"mobile"];
    [dict setObject:self.code.text forKey:@"smscode"];
    [dict setObject:self.password.text forKey:@"password"];
    [dict setObject:self.secPassword.text forKey:@"repassword"];
    
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Member/retrievepwd.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        NSInteger code = [object[@"errcode"] integerValue];
        NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
        NSLog(@"输出 %@--%@",object,msg);
        
        if (code == 1) {
            [SVProgressHUD showSuccessWithStatus:msg];
            LoginViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"loginPWD"];
            [self.navigationController pushViewController:vc animated:1];
        }else{
            [SVProgressHUD showErrorWithStatus:msg];
        }
    } failoperation:^(NSError *error) {
        
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        [SVProgressHUD showErrorWithStatus:@"网络信号差，请稍后再试"];
    }];
    
}
//当用户按下return去键盘

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
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
