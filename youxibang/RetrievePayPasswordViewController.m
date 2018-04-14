//
//  RetrievePayPasswordViewController.m
//  youxibang
//
//  Created by y on 2018/2/3.
//

#import "RetrievePayPasswordViewController.h"
#import "JKCountDownButton.h"
#import "SetPayPasswordViewController.h"

@interface RetrievePayPasswordViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *code;
@property (weak, nonatomic) IBOutlet UITextField *userPhone;
@property (weak, nonatomic) IBOutlet JKCountDownButton *codeBtn;

@end

@implementation RetrievePayPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"找回支付密码";
    NSDictionary* dic = [UserNameTool readPersonalData];
    self.userPhone.text = dic[@"mobile"];
    self.userPhone.userInteractionEnabled = NO;
    self.code.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)getCode:(JKCountDownButton *)sender {
    
    sender.enabled = NO;
    //button type要 设置成custom 否则会闪动
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
    
    
    [self gainCodeRequest:self.userPhone.text];
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
    if ([EBUtility isBlankString:self.code.text]){
        [SVProgressHUD showErrorWithStatus:@"验证码不能为空"];
        return;
    }
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[DataStore sharedDataStore].token forKey:@"token"];
    [dict setObject:self.userPhone.text forKey:@"mobile"];
    [dict setObject:self.code.text forKey:@"smscode"];
    
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Member/resetpwd.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            
            if (code == 1) {
                [SVProgressHUD showSuccessWithStatus:msg];
                SetPayPasswordViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"spp"];
                [self.navigationController pushViewController:vc animated:1];
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
//当用户按下return去键盘

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:1];
    
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
