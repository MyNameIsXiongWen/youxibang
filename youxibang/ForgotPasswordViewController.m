//
//  ForgotPasswordViewController.m
//  youxibang
//
//  Created by y on 2018/1/30.
//

#import "ForgotPasswordViewController.h"
#import "LoginViewController.h"

@interface ForgotPasswordViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *phone;
@property (weak, nonatomic) IBOutlet UITextField *code;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *secPassword;
@property(nonatomic,assign)int seconds;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *codeBtn;

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
- (IBAction)getCode:(id)sender {
    if ( [EBUtility isMobileNumber:self.phone.text] ==NO) {
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"请输入正确的手机号码" andDuration:2.0];
        return;
    }
    self.codeBtn.userInteractionEnabled = NO;
    [self gainCodeRequest:self.phone.text];
}
- (void)gainCodeRequest:(NSString *)phoneString {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:phoneString forKey:@"mobile"];
    
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Currency/sendsms",HttpURLString] Paremeters:dict successOperation:^(id object) {
        
        NSInteger code = [object[@"errcode"] integerValue];
        NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]];
        NSLog(@"验证码输出 %@--%@",object,msg);
        if (code == 1) {
            self.seconds = 60;
            self.codeBtn.backgroundColor = [UIColor colorFromHexString:@"cccccc"];
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timecaculate:) userInfo:nil repeats:YES];
            [timer fire];
            [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"验证码发送成功" andDuration:2.0];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.code becomeFirstResponder];
            });
        }else {
            self.codeBtn.userInteractionEnabled = YES;
            [[SYPromptBoxView sharedInstance] setPromptViewMessage:msg andDuration:2.0];
        }
    } failoperation:^(NSError *error) {
        NSLog(@"errr %@",error);
        
    }];
}

-(void)timecaculate:(NSTimer*)timer {
    NSString *str =[NSString stringWithFormat:@"%ds后重试",self.seconds];
    self.seconds -= 1;
    [self.codeBtn setTitle:@"" forState:UIControlStateNormal];
    self.timeLabel.text = str;
    self.timeLabel.hidden = NO;
    if (self.seconds <=0) {
        [timer invalidate];
        self.timeLabel.hidden = YES;
        self.codeBtn.userInteractionEnabled = YES;
        self.codeBtn.backgroundColor = [UIColor colorFromHexString:@"457fea"];
        [self.codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    }
}

//提交
- (IBAction)commit:(id)sender {
    [self.view endEditing:YES];
    if ([EBUtility isBlankString:self.phone.text]){
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"请输入手机号码" andDuration:2.0];
        return;
    }
    if ([EBUtility isBlankString:self.code.text]){
        [SVProgressHUD showErrorWithStatus:@"请输入验证码"];
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"请输入验证码" andDuration:2.0];
        return;
    }
    if ([EBUtility isBlankString:self.password.text]){
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"请输入密码" andDuration:2.0];
        return;
    }
    if ([EBUtility isBlankString:self.secPassword.text]){
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"请再次输入密码" andDuration:2.0];
        return;
    }
    if (![self.password.text isEqualToString:self.secPassword.text]){
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"两次输入的密码不一致" andDuration:2.0];
        return;
    }
    if (![EBUtility validatePassword:self.password.text]){
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"请输入密码为6-15位数字或字母" andDuration:2.0];
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
            [[SYPromptBoxView sharedInstance] setPromptViewMessage:msg andDuration:2.0];
        }
    } failoperation:^(NSError *error) {
        
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        [SVProgressHUD showErrorWithStatus:@"网络信号差，请稍后再试"];
    }];
    
}
//当用户按下return去键盘

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
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
