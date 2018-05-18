//
//  SetPayPasswordViewController.m
//  youxibang
//
//  Created by y on 2018/2/2.
//

#import "SetPayPasswordViewController.h"
#import "RetrievePayPasswordViewController.h"

@interface SetPayPasswordViewController ()<UITextFieldDelegate>
@property (nonatomic,weak)UITextField* tf;
@property (nonatomic,weak)UILabel* titleLab;
@property (nonatomic,copy)NSString* password;

@end

@implementation SetPayPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"设置支付密码";
    
    UILabel* titleLab = [EBUtility labfrome:CGRectMake(0, 20, 100, 20) andText:@"设置支付密码" andColor:[UIColor blackColor] andView:self.view];
    titleLab.font = [UIFont systemFontOfSize:20];
    [titleLab sizeToFit];
    titleLab.centerX = self.view.width/2;
    self.titleLab = titleLab;
    
    UIView* tfView = [EBUtility viewfrome:CGRectMake(15, 80, SCREEN_WIDTH - 30, 45) andColor:[UIColor whiteColor] andView:self.view];
    tfView.layer.cornerRadius = 5;
    tfView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    tfView.layer.borderWidth = 1;
    tfView.layer.masksToBounds = 1;
    UITextField* tf = [EBUtility textFieldfrome:CGRectMake(-10, -10, 1, 1) andText:@"" andColor:[UIColor blackColor] andView:self.view];
    tf.keyboardType = UIKeyboardTypePhonePad;
    [tf becomeFirstResponder];
    tf.delegate = self;
    self.tf = tf;
    [tf addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    for (int i = 0; i < 6; i++){
        UILabel* bot = [EBUtility labfrome:CGRectMake(i * tfView.width/6, 0, tfView.width/6, tfView.height) andText:@"·" andColor:[UIColor blackColor] andView:tfView];
        bot.tag = i + 1000;
        bot.hidden = YES;
        bot.font = [UIFont systemFontOfSize:55];
        if (i < 5){
            UILabel* gLine = [EBUtility labfrome:CGRectMake((i + 1) * tfView.width/6, 0, 1, tfView.height) andText:@"" andColor:[UIColor blackColor] andView:tfView];
            gLine.backgroundColor = [UIColor lightGrayColor];
        }
    }
    
}

- (IBAction)confrim:(id)sender {
    if ([self.titleLab.text isEqualToString:@"设置支付密码"]){
        if (self.tf.text.length >= 6){
            self.titleLab.text = @"再次输入支付密码";
            [self.titleLab sizeToFit];
            self.titleLab.centerX = self.view.width/2;
            self.password = self.tf.text;
            self.tf.text = @"";
            for (int i = 0; i < 6; i++){
                UILabel* bot = [self.view viewWithTag:1000 + i];
                bot.hidden = YES;
            }
        }else{
            [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"请输入6位密码" andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
        }
    }else{
        if ([self.tf.text isEqualToString:self.password]){
            
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
            [SVProgressHUD show];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:UserModel.sharedUser.token forKey:@"token"];
            //typeid=$类型 （1-头像，2-昵称，3-签名，4-兴趣爱好，5-背景图，6-允许陌生人通话，7-设置支付密码）
            
            [dict setObject:@"7" forKey:@"typeid"];
            [dict setObject:self.password forKey:@"paypassword"];
            
            [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Member/edituserinfo.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
                [SVProgressHUD dismiss];
                [SVProgressHUD setDefaultMaskType:1];
                if (isKindOfNSDictionary(object)){
                    NSInteger code = [object[@"errcode"] integerValue];
                    NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
                    NSLog(@"输出 %@--%@",object,msg);
                    
                    if (code == 1) {
                        
                        [SVProgressHUD showSuccessWithStatus:msg];
                        [UserNameTool reloadPersonalData:^{
                            for (UIViewController* i in self.navigationController.viewControllers){
                                if ([i isKindOfClass:[RetrievePayPasswordViewController class]]){
                                    [self.navigationController popToRootViewControllerAnimated:1];
                                    return ;
                                }
                            }
                            [self.navigationController popViewControllerAnimated:1];
                        }];
                    }else{
                        [SVProgressHUD showErrorWithStatus:msg];
                    }
                }
            } failoperation:^(NSError *error) {
                [SVProgressHUD dismiss];
                [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络信号差，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
            }];
        }else{
            [SVProgressHUD dismiss];
            [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"两次密码输入不一致" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textFieldDidChange:(UITextField *)textField{
    for (int i = 0; i < 6; i++){
        UILabel* bot = [self.view viewWithTag:1000 + i];
        if (i >= textField.text.length ){
            bot.hidden = YES;
        }else{
            bot.hidden = NO;
        }
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{

    if (range.location > 5){

        return NO;
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
