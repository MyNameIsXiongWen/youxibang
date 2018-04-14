//
//  SetPasswordViewController.m
//  youxibang
//
//  Created by y on 2018/1/30.
//

#import "SetPasswordViewController.h"
#import "SupplementInfoViewController.h"

@interface SetPasswordViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *secPassword;//重复输入密码
@property (weak, nonatomic) IBOutlet UITextField *invitationCode;//邀请码

@end

@implementation SetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"设置密码";
    self.password.secureTextEntry = YES;
    self.secPassword.secureTextEntry = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//下一步
- (IBAction)nextStep:(id)sender {
    if ([self.password.text isEqualToString:self.secPassword.text]){
        if ([EBUtility validatePassword:self.password.text]){
            SupplementInfoViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"si"];
            vc.phoneNum = self.phoneNum;
            vc.password = self.password.text;
            vc.leadercode = self.invitationCode.text;
            vc.type = self.type;
            if (self.type.integerValue > 1){
                vc.threetoken = self.threetoken;
                if (self.unionid){
                    vc.unionid = self.unionid;
                }
            }
            [self.navigationController pushViewController:vc animated:1];
        }else{
            [SVProgressHUD showErrorWithStatus:@"请输入密码为6-15位数字或字母"];
        }
    }else{
        [SVProgressHUD showErrorWithStatus:@"两次输入的密码不一致"];
    }
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
