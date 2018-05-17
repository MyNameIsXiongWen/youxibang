//
//  SetAliAccountViewController.m
//  youxibang
//
//  Created by y on 2018/2/2.
//

#import "SetAliAccountViewController.h"
#import "RealNameViewController.h"

@interface SetAliAccountViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *accountTf;
@property (weak, nonatomic) IBOutlet UITextField *nameTf;

@end

@implementation SetAliAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"提现账户";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//提交
- (IBAction)confrimBtn:(UIButton*)sender {
    if ([EBUtility isBlankString:self.accountTf.text]){
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"账号不能为空" andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
        return;
    }
    if ([EBUtility isBlankString:self.nameTf.text]){
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"真实姓名不能为空" andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
        return;
    }
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[DataStore sharedDataStore].token forKey:@"token"];
    [dict setObject:@"1" forKey:@"typeid"];
    [dict setObject:self.accountTf.text forKey:@"alipay"];
    [dict setObject:self.nameTf.text forKey:@"realname"];
    
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Member/setalipay.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            
            if (code == 1) {
                
                [SVProgressHUD showSuccessWithStatus:msg];
                [UserNameTool reloadPersonalData:^{
                    [self.navigationController popViewControllerAnimated:1];
                }];
                
            }else if (code == 2) {
                [SVProgressHUD showInfoWithStatus:msg];
                RealNameViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"rn"];
                [self.navigationController pushViewController:vc animated:1];
            }else{
                [SVProgressHUD showErrorWithStatus:msg];
            }
        }
    } failoperation:^(NSError *error) {
        
        [SVProgressHUD dismiss];
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络信号差，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
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
