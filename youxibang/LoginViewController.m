//
//  LoginViewController.m
//  youxibang
//
//  Created by y on 2018/1/18.
//

#import "LoginViewController.h"
#import "JKCountDownButton.h"
#import "MainTabBarController.h"
#import "ForgotPasswordViewController.h"
#import "SignViewController.h"
#import "TalkingData.h"
#import "SetPasswordViewController.h"
#import "BaseTool/QQFramework/TencentOpenAPI.framework/Headers/TencentOAuth.h"
#import "HomeViewController.h"

@interface LoginViewController ()<UITextFieldDelegate,TencentSessionDelegate>
@property (weak, nonatomic) IBOutlet UITextField *phoneNumber;//电话号码
@property (weak, nonatomic) IBOutlet UITextField *code;//密码
@property (weak, nonatomic) IBOutlet JKCountDownButton *codeBtn;//验证码按键
@property (copy,nonatomic) NSString* threeToken;//第三方token

@property (strong,nonatomic) TencentOAuth* tencentOAuth;//腾讯框架属性
@property (weak, nonatomic) IBOutlet UIButton *wechatBtn;//微信登录按键
@property (weak, nonatomic) IBOutlet UIButton *qqBtn;//qq登录按键
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"验证码登录";
    //切换密码登录
    UIView* rv = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 55, 25)];
    UIButton* btn = [EBUtility greenBtnfrome:CGRectMake(-20, 0, 85, 25) andText:@"密码登录" andColor:[UIColor whiteColor] andimg:nil andView:rv];
    
    if (!self.codeOrPassword){
        self.title = @"密码登录";
        self.code.secureTextEntry = YES;
        [btn setTitle:@"验证码登录" forState:0];
    }
    btn.layer.cornerRadius = 5;
    btn.layer.masksToBounds = YES;
    [btn addTarget:self action:@selector(changeLogin:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rv];
    
    //第三方登录通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(InfoNotificationAction:) name:@"threeLogin" object:nil];
}
//返回首页
- (void)back {
    [self.view endEditing:1];
    MainTabBarController *minTa = [[MainTabBarController alloc] init];
    [minTa setupChildVcs];
    self.view.window.rootViewController = minTa;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //如果未安装微信或qq，隐藏按键
    if (![WXApi isWXAppInstalled]) {
        self.wechatBtn.hidden = YES;
    }
//    if (!([TencentOAuth iphoneQQInstalled] || [TencentOAuth iphoneTIMInstalled])) {
//        self.qqBtn.hidden = YES;
//    }
    //自定义返回键，因为要重写返回方法
    UIImageView* img = [[UIImageView alloc]initWithFrame:CGRectMake(0, 10, 10, 20)];
    img.image = [UIImage imageNamed:@"back"];
    UIButton *leftBtn = [[UIButton alloc]initWithFrame:CGRectMake(-15, 0, 40, 40)];
    [leftBtn addSubview:img];
    [leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
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
//第三方登录通知触发方法
- (void)InfoNotificationAction:(NSNotification *)notification {
    NSMutableDictionary* userInfo = [[notification userInfo] mutableCopy];
    self.threeToken = userInfo[@"threetoken"];
    [self lg:userInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//获取验证码按键
- (IBAction)getCode:(JKCountDownButton *)sender {
    if ( [EBUtility isMobileNumber:self.phoneNumber.text] == NO) {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号码"];
        return;
    }
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
        }else {
            [SVProgressHUD showErrorWithStatus:msg];
            
        }
    } failoperation:^(NSError *error) {
        NSLog(@"errr %@",error);
    }];
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
        req.state = @"App";
        [WXApi sendReq:req];
    }else {
        [SVProgressHUD showErrorWithStatus:@"未安装微信"];
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
    if ([DataStore sharedDataStore].city) {
        [dic setObject:[DataStore sharedDataStore].city forKey:@"city"];
    }
    if ([DataStore sharedDataStore].latitude) {
        [dic setObject:[DataStore sharedDataStore].latitude forKey:@"lat"];
    }
    if ([DataStore sharedDataStore].longitude) {
        [dic setObject:[DataStore sharedDataStore].longitude forKey:@"lon"];
    }
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Member/login.html",HttpURLString] Paremeters:dic successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object))
        {
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]];
            NSLog(@"登录输出 %@--%@",object,msg);
            if (code == 1) {
                NSDictionary* user = object[@"data"];
                [self.view.window endEditing:YES];
                //单例注入数据
                [DataStore sharedDataStore].userid = [NSString stringWithFormat:@"%@",user[@"userid"]];
                [DataStore sharedDataStore].mobile = [NSString stringWithFormat:@"%@",user[@"mobile"]];
                [DataStore sharedDataStore].yxuser = [NSString stringWithFormat:@"%@",user[@"yxuser"]];
                [DataStore sharedDataStore].yxpwd = [NSString stringWithFormat:@"%@",user[@"yxpwd"]];
                [DataStore sharedDataStore].token = [NSString stringWithFormat:@"%@",user[@"token"]];
                
                [JPUSHService setAlias:[DataStore sharedDataStore].userid completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
                    NSLog(@"Alias   %@",iAlias);
                } seq:1];
                
                //长久化存储登录账号密码
                [UserNameTool saveLoginData:dic];
                //talkingdata注册
                [TalkingData onRegister:[DataStore sharedDataStore].mobile type:TDAccountTypeRegistered name:[NSString stringWithFormat:@"%@",user[@"mobile"]]];
                //云信登录
                [[NIMSDK sharedSDK] registerWithAppID:@"d27ffe90d087aaeb5c579f7485a2dcb6" cerName:nil];
                NIMServerSetting *setting = [[NIMServerSetting alloc] init];
                setting.httpsEnabled = NO;
                [[NIMSDK sharedSDK] setServerSetting:setting];
                [[NIMSDK sharedSDK].userManager fetchUserInfos:@[[NSString stringWithFormat:@"%@",user[@"yxuser"]]] completion:nil];
                [[NIMSDK sharedSDK].loginManager login:[NSString stringWithFormat:@"%@",user[@"yxuser"]] token:[NSString stringWithFormat:@"%@",user[@"yxpwd"]] completion:^(NSError *error) {
                    if (!error) {
                        NSLog(@"登录成功");
                        
                    }else{
                        NSLog(@"登录失败");
                        
                    }
                }];
                MainTabBarController *minTa = [[MainTabBarController alloc] init];
                self.view.window.rootViewController = minTa;
            }else if (code == 8){//验证码首次登录，设置密码
                SetPasswordViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"spw"];
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
                [SVProgressHUD showErrorWithStatus:msg];
            }
        }
    } failoperation:^(NSError *error) {
        NSLog(@"errr %@",error);
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        [SVProgressHUD showErrorWithStatus:@"网络有误，请稍后再试"];
    }];
}

#pragma mark - WXDelegate
- (void)onResp:(BaseResp *)resp {
    // 向微信请求授权后,得到响应结果
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *temp = (SendAuthResp *)resp;
        [[NetWorkEngine shareNetWorkEngine] getInfoFromServerWithUrlStr:[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=wx9409b172842c7d01&secret=e4a47d8a0bc2ba61fa2adb0091788e35&code=%@&grant_type=authorization_code",temp.code] Paremeters:nil successOperation:^(id response) {
            NSLog(@"绑定输出 %@",response);
            NSNotification *notification = [NSNotification notificationWithName:@"threeLogin" object:nil userInfo:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"2",@"typeid",response[@"openid"],@"threetoken",response[@"unionid"],@"unionid", nil]];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        } failoperation:^(NSError *error) {
            NSLog(@"errr %@",error);
        }];
    }
}

#pragma mark - TencentSessionDelegate
//登录成功回调
- (void)tencentDidLogin {
    if (_tencentOAuth.accessToken && 0 != [_tencentOAuth.accessToken length]){
        NSNotification *notification = [NSNotification notificationWithName:@"threeLogin" object:nil userInfo:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"3",@"typeid",[_tencentOAuth getUserOpenID],@"threetoken", nil]];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        
    }
}
//登录失败回调
- (void)tencentDidNotLogin:(BOOL)cancelled {
    NSLog(@"登录失败");
}
//没有网络
- (void)tencentDidNotNetWork {
    [SVProgressHUD showErrorWithStatus:@"网络信号差，请稍后再试"];
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

@end
