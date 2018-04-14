//
//  NewPhoneViewController.m
//  youxibang
//
//  Created by 戎博 on 2018/2/19.
//

#import "NewPhoneViewController.h"
#import "JKCountDownButton.h"
#import "LoginViewController.h"

@interface NewPhoneViewController ()
@property (weak, nonatomic) IBOutlet UITextField *oldPhone;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *phone;
@property (weak, nonatomic) IBOutlet UITextField *code;
@property (weak, nonatomic) IBOutlet JKCountDownButton *codeBtn;

@end

@implementation NewPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"修改手机号";
    self.password.secureTextEntry = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)getCode:(JKCountDownButton *)sender {
    [self.view endEditing:YES];
    if ( [EBUtility isMobileNumber:self.oldPhone.text] ==NO) {
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
    
    [self gainCodeRequest:self.oldPhone.text];
}
-(void)gainCodeRequest:(NSString *)phoneString
{
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:phoneString forKey:@"mobile"];
    //        [dict setObject:@"send" forKey:@"act"];
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Currency/sendsms.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
        
        
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
- (IBAction)confrim:(id)sender {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:self.phone.text forKey:@"newmobile"];
    [dict setObject:self.code.text forKey:@"smscode"];
    [dict setObject:self.oldPhone.text forKey:@"mobile"];
    [dict setObject:self.password.text forKey:@"password"];
    [dict setObject:[DataStore sharedDataStore].token forKey:@"token"];
    
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Member/editmobile.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
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
