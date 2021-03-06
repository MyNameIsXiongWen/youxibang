//
//  LoginViewController.m
//  youxibang
//
//  Created by y on 2018/1/18.
//

#import "LoginViewController.h"
#import "MainTabBarController.h"
#import "ForgotPasswordViewController.h"
#import "SignViewController.h"
#import "TalkingData.h"
#import "SetPasswordViewController.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "HomeViewController.h"
#import "AppDelegate.h"

@interface LoginViewController () <UITextFieldDelegate, TencentSessionDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *phoneNumber;//电话号码
@property (weak, nonatomic) IBOutlet UITextField *code;//密码
@property (weak, nonatomic) IBOutlet UIButton *codeBtn;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (copy,nonatomic) NSString* threeToken;//第三方token

@property (strong,nonatomic) TencentOAuth* tencentOAuth;//腾讯框架属性
@property (weak, nonatomic) IBOutlet UIButton *wechatBtn;//微信登录按键
@property (weak, nonatomic) IBOutlet UIButton *qqBtn;//qq登录按键
@property(nonatomic,assign)int seconds;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"验证码登录";
    //切换密码登录
    UIView* rv = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 55, 25)];
    UIButton* btn = [EBUtility greenBtnfrome:CGRectMake(-20, 0, 85, 25) andText:@"密码登录" andColor:[UIColor colorFromHexString:@"333333"] andimg:nil andView:rv];
    btn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    if (!self.codeOrPassword){
        self.title = @"密码登录";
        self.code.secureTextEntry = YES;
        [btn setTitle:@"验证码登录" forState:0];
    }
    btn.layer.cornerRadius = 5;
    btn.layer.masksToBounds = YES;
    [btn addTarget:self action:@selector(changeLogin:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rv];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    [self.phoneNumber addTarget:self action:@selector(textFieldValueChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)textFieldValueChange:(UITextField *)textfield {
    if (textfield.text.length >= 11) {
        textfield.text = [textfield.text substringToIndex:11];
        return;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return NO;
}

//第三方登录通知触发方法
- (void)InfoNotificationAction:(NSNotification *)notification {
    NSMutableDictionary* userInfo = notification.userInfo.mutableCopy;
    self.threeToken = userInfo[@"threetoken"];
    [self lg:userInfo];
}

- (void)leftBarButtonSelector {
    [self backWithLogin:NO];
}
//返回首页
- (void)backWithLogin:(BOOL)login {
    [self.view endEditing:1];
    UIViewController *vc = self.navigationController.childViewControllers.firstObject;
    if (login) {
        if ([NSStringFromClass(vc.class) isEqualToString:@"LoginViewController"]) {
            [self dismissViewControllerAnimated:1 completion:nil];
        }
        else {
            if (self.PushToMainTabbar) {
                MainTabBarController *mainTab = [[MainTabBarController alloc] init];
                AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                delegate.window.rootViewController = mainTab;
            }
            else {
                [self.navigationController popViewControllerAnimated:1];
            }
        }
    }
    else {
        if ([NSStringFromClass(vc.class) isEqualToString:@"MineViewController"] ||[NSStringFromClass(vc.class) isEqualToString:@"MessageViewController"]) {
            MainTabBarController *mainTab = [[MainTabBarController alloc] init];
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            delegate.window.rootViewController = mainTab;
        }
        else if ([NSStringFromClass(vc.class) isEqualToString:@"LoginViewController"]) {
            if (self.PushToMainTabbar) {
                MainTabBarController *mainTab = [[MainTabBarController alloc] init];
                AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                delegate.window.rootViewController = mainTab;
            }
            else {
                [self dismissViewControllerAnimated:1 completion:nil];
            }
        }
        else {
            [self.navigationController popViewControllerAnimated:1];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"threeLogin" object:nil];
    //第三方登录通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(InfoNotificationAction:) name:@"threeLogin" object:nil];
    //如果未安装微信或qq，隐藏按键
    if (![WXApi isWXAppInstalled]) {
        self.wechatBtn.hidden = YES;
    }
    //自定义返回键，因为要重写返回方法
    UIImageView* img = [[UIImageView alloc]initWithFrame:CGRectMake(0, 10, 10, 20)];
    img.image = [UIImage imageNamed:@"back_black"];
    UIButton *leftBtn = [[UIButton alloc]initWithFrame:CGRectMake(-15, 0, 40, 40)];
    [leftBtn addSubview:img];
    [leftBtn addTarget:self action:@selector(leftBarButtonSelector) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    
    if (UserModel.sharedUser.mobile) {
        self.phoneNumber.text = UserModel.sharedUser.mobile;
    }
    if (self.phoneNumberString) {
        self.phoneNumber.text = self.phoneNumberString;
    }
    if (self.passwordString || self.codeString) {
        self.code.text = self.phoneNumberString?:self.codeString;
    }
    if (self.phoneNumberString && (self.passwordString || self.codeString)) {
        if (!self.codeOrPassword){
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:self.phoneNumberString forKey:@"mobile"];
            [dict setObject:self.passwordString forKey:@"password"];
            [dict setObject:@"0" forKey:@"typeid"];
            [self lg:dict];
        }else{
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:self.phoneNumberString forKey:@"mobile"];
            [dict setObject:self.codeString forKey:@"smscode"];
            [dict setObject:@"1" forKey:@"typeid"];
            [self lg:dict];
        }
    }
}
//切换登录模式
- (void)changeLogin:(UIButton *)sender {
    if (!self.codeOrPassword){
        LoginViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"login"];
        vc.codeOrPassword = YES;
        [self.navigationController pushViewController:vc animated:1];
    }else{
        LoginViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"loginPWD"];
        [self.navigationController pushViewController:vc animated:1];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//获取验证码按键
- (IBAction)getCode:(id)sender {
    if ([EBUtility isMobileNumber:self.phoneNumber.text] == NO) {
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"请输入正确的手机号码" andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
        return;
    }
    self.codeBtn.userInteractionEnabled = NO;
    [self gainCodeRequest:self.phoneNumber.text];
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
            [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"验证码发送成功" andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.code becomeFirstResponder];
            });
        }else {
            self.codeBtn.userInteractionEnabled = YES;
            [[SYPromptBoxView sharedInstance] setPromptViewMessage:msg andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
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

//登录按钮
- (IBAction)loginBtn:(UIButton *)sender {
    if (!self.codeOrPassword){
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:self.phoneNumber.text forKey:@"mobile"];
        [dict setObject:self.code.text forKey:@"password"];
        [dict setObject:@"0" forKey:@"typeid"];
        [self lg:dict];
    }else{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:self.phoneNumber.text forKey:@"mobile"];
        [dict setObject:self.code.text forKey:@"smscode"];
        [dict setObject:@"1" forKey:@"typeid"];
        [self lg:dict];
    }
}

//注册按钮
- (IBAction)signBtn:(id)sender {
    SignViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"sign"];
    vc.type = @"0";
    [self.navigationController pushViewController:vc animated:1];
}

//忘记密码
- (IBAction)forgotPassword:(id)sender {
    ForgotPasswordViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"fpw"];
    [self.navigationController pushViewController:vc animated:1];
}

//微信登录
- (IBAction)wxLogin:(id)sender {
    if ([WXApi isWXAppInstalled]) {
        SendAuthReq *req = [[SendAuthReq alloc] init];
        req.scope = @"snsapi_userinfo";
        req.state = @"AiShangBo";
        [WXApi sendReq:req];
    }
}

//qq登录
- (IBAction)qqLogin:(id)sender {
    self.tencentOAuth = [[TencentOAuth alloc] initWithAppId:QQ_OPEN_ID andDelegate:self];
    NSArray *permissions= [NSArray arrayWithObjects:@"get_user_info",@"get_simple_userinfo",@"add_t",nil];
    [self.tencentOAuth authorize:permissions inSafari:YES];
}

//登录主方法，传入登录所需的字典
- (void)lg:(NSMutableDictionary*)dic{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    if (UserModel.sharedUser.city) {
        [dic setObject:UserModel.sharedUser.city forKey:@"city"];
    }
    if (UserModel.sharedUser.latitude) {
        [dic setObject:UserModel.sharedUser.latitude forKey:@"lat"];
    }
    if (UserModel.sharedUser.longitude) {
        [dic setObject:UserModel.sharedUser.longitude forKey:@"lon"];
    }
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Member/login.html",HttpURLString] Paremeters:dic successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)) {
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]];
            NSLog(@"登录输出 %@--%@",object,msg);
            if (code == 1) {
                NSDictionary* user = object[@"data"];
                [self.view.window endEditing:YES];
                //单例注入数据
                UserModel.sharedUser.yxpwd = [NSString stringWithFormat:@"%@",user[@"yxpwd"]];
                UserModel.sharedUser.yxuser = [NSString stringWithFormat:@"%@",user[@"yxuser"]];
                UserModel.sharedUser.mobile = [NSString stringWithFormat:@"%@",user[@"mobile"]];
                UserModel.sharedUser.userid = [NSString stringWithFormat:@"%@",user[@"userid"]];
                UserModel.sharedUser.token = [NSString stringWithFormat:@"%@",user[@"token"]];
                [self getVideoUploadToken];
                [UserNameTool reloadPersonalData:^{
                }];
                //长久化存储登录账号密码
                [UserNameTool saveLoginData:dic];
                
                [JPUSHService setAlias:UserModel.sharedUser.userid completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
                    NSLog(@"Alias   %@",iAlias);
                    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Member/send_leave_message",HttpURLString] Paremeters:@{@"token":UserModel.sharedUser.token} successOperation:^(id response) {
                        
                    } failoperation:^(NSError *error) {
                        
                    }];
                } seq:1];
                
                //talkingdata注册
                [TalkingData onRegister:UserModel.sharedUser.mobile type:TDAccountTypeRegistered name:[NSString stringWithFormat:@"%@",UserModel.sharedUser.mobile]];
                //云信登录
                [[NIMSDK sharedSDK] registerWithAppID:NIM_APP_ID cerName:nil];
                NIMServerSetting *setting = [[NIMServerSetting alloc] init];
                setting.httpsEnabled = NO;
                [[NIMSDK sharedSDK] setServerSetting:setting];
                [[NIMSDK sharedSDK].userManager fetchUserInfos:@[[NSString stringWithFormat:@"%@",UserModel.sharedUser.yxuser]] completion:nil];
                [[NIMSDK sharedSDK].loginManager login:[NSString stringWithFormat:@"%@",UserModel.sharedUser.yxuser] token:[NSString stringWithFormat:@"%@",UserModel.sharedUser.yxpwd] completion:^(NSError *error) {
                }];
                [self backWithLogin:YES];
            }else if (code == 8){//验证码首次登录，设置密码
                SetPasswordViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"spw"];
                vc.inviteCode = object[@"data"];
                vc.phoneNum = self.phoneNumber.text;
                vc.type = @"1";
                [self.navigationController pushViewController:vc animated:1];
            }else if (code == 9){//第三方登录未绑定账号，跳转绑定
                [SVProgressHUD showInfoWithStatus:msg];
                SignViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"sign"];
                vc.type = [NSString stringWithFormat:@"%@",dic[@"typeid"]];
                vc.threetoken = self.threeToken;
                vc.unionid = [NSString stringWithFormat:@"%@",dic[@"unionid"]];
                [self.navigationController pushViewController:vc animated:1];
            }else{
                [[SYPromptBoxView sharedInstance] setPromptViewMessage:msg andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
            }
        }
    } failoperation:^(NSError *error) {
        NSLog(@"errr %@",error);
        [SVProgressHUD dismiss];
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络信号差，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
    }];
}

#pragma mark - TencentSessionDelegate
//登录成功回调
- (void)tencentDidLogin {
    if (_tencentOAuth.accessToken && 0 != [_tencentOAuth.accessToken length]){
        self.threeToken = [_tencentOAuth getUserOpenID];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:@"3" forKey:@"typeid"];
        [dic setObject:[_tencentOAuth getUserOpenID] forKey:@"threetoken"];
        [self lg:dic];
    }
}
//登录失败回调
- (void)tencentDidNotLogin:(BOOL)cancelled {
    NSLog(@"登录失败");
}
//没有网络
- (void)tencentDidNotNetWork {
    [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络信号差，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
}
//获取回调的用户信息
- (void)getUserInfoResponse:(APIResponse *)response {
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
//当用户按下return去键盘

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)getVideoUploadToken {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:UserModel.sharedUser.token forKey:@"token"];
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@video/get_token",HttpURLString] Paremeters:dict successOperation:^(id response) {
        if (isKindOfNSDictionary(response)) {
            NSInteger msg = [[response objectForKey:@"errcode"] integerValue];
            NSString *str = [response objectForKey:@"message"];
            if (msg == 1) {
                NSDictionary *tokenDictionary = (NSDictionary *)response;
                [[NSUserDefaults standardUserDefaults] setObject:tokenDictionary forKey:@"AliPlayerToken"];
            }else{
                [[SYPromptBoxView sharedInstance] setPromptViewMessage:str andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
            }
        }
    } failoperation:^(NSError *error) {
    }];
}

@end
