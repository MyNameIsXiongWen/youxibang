//
//  SignViewController.m
//  youxibang
//
//  Created by y on 2018/1/26.
//

#import "SignViewController.h"
#import "SetPasswordViewController.h"
#import "JKCountDownButton.h"
#import "LoginViewController.h"

@interface SignViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *phone;//电话
@property (weak, nonatomic) IBOutlet UITextField *code;//密码
@property (weak, nonatomic) IBOutlet JKCountDownButton *codeBtn;//验证码

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
    DSWebViewController* vc = [[DSWebViewController alloc]initWithURLSting:@"http://youxibang.zjr1.com/index.php/api/onlypage/detail/id/1.html"];
    [self.navigationController pushViewController:vc animated:1];
}
//获取验证码
- (IBAction)getCode:(JKCountDownButton *)sender {
    if ( [EBUtility isMobileNumber:self.phone.text] ==NO) {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号码"];
        return;
    }
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
