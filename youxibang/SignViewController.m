//
//  SignViewController.m
//  youxibang
//
//  Created by y on 2018/1/26.
//

#import "SignViewController.h"
#import "SetPasswordViewController.h"
#import "LoginViewController.h"

@interface SignViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *phone;//电话
@property (weak, nonatomic) IBOutlet UITextField *code;//密码
@property(nonatomic,assign)int seconds;
@property (weak, nonatomic) IBOutlet UIButton *codeBtn;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation SignViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"注册";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//注册协议
- (IBAction)signDelegate:(id)sender {
    DSWebViewController* vc = [[DSWebViewController alloc]initWithURLSting:[NSString stringWithFormat:@"%@onlypage/detail/id/1.html",HttpURLString]];
    [self.navigationController pushViewController:vc animated:1];
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

//下一步
- (IBAction)nextStep:(id)sender {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:self.phone.text forKey:@"mobile"];
    [dict setObject:self.code.text forKey:@"smscode"];
    if (self.type.integerValue > 1){
        [dict setObject:self.type forKey:@"typeid"];
        [dict setObject:self.threetoken forKey:@"threetoken"];
    }
    
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Member/regone.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        NSInteger code = [object[@"errcode"] integerValue];
        NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
        NSLog(@"输出 %@--%@",object,msg);
        
        if (code == 1) {//下一步，设置密码
            SetPasswordViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"spw"];
            vc.inviteCode = object[@"data"];
            vc.phoneNum = self.phone.text;
            vc.type = self.type;
            
            if (self.type.integerValue > 1){
                vc.threetoken = self.threetoken;
                if (self.unionid){
                    vc.unionid = self.unionid;
                }
            }
            [self.navigationController pushViewController:vc animated:1];
        }else if (code == 6){//绑定成功，跳转登录
            [SVProgressHUD showSuccessWithStatus:msg];
            LoginViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"loginPWD"];
            vc.phoneNumberString = self.phone.text;
            vc.codeString = self.code.text;
            vc.codeOrPassword = YES;
            vc.PushToMainTabbar = YES;
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
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
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
