//
//  TopUpAndWithdrawViewController.m
//  youxibang
//
//  Created by y on 2018/2/1.
//

#import "TopUpAndWithdrawViewController.h"
#import "LoanDelegateViewController.h"
#import "RetrievePayPasswordViewController.h"
#import "RealNameViewController.h"
#import "SetAliAccountViewController.h"
#import "SetPayPasswordViewController.h"
#import "AlipayAccountViewController.h"

@interface TopUpAndWithdrawViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *balanceLab;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *sumBtnAry;//金额数组
@property (weak, nonatomic) IBOutlet UITextField *tf;//金额输入框
@property (weak, nonatomic) IBOutlet UIButton *wxBtn;
@property (weak, nonatomic) IBOutlet UIButton *zfbBtn;
@property (weak, nonatomic) IBOutlet UIButton *commitBtn;
@property (weak, nonatomic) IBOutlet UIView *payView;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLab;

@end

@implementation TopUpAndWithdrawViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"充值余额";
    
    for (UIButton* i in self.sumBtnAry){
        [i addTarget:self action:@selector(selectSumMoney:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UserModel *userModel = UserModel.sharedUser;
    NSMutableAttributedString *mAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"余额%@元",userModel.user_money ? : @"0"]];
    [mAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:NSMakeRange(2, mAttStr.length - 3)];
    [mAttStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(2, mAttStr.length - 3)];
    self.balanceLab.attributedText = mAttStr;
    if (self.type == 1){
        self.title = @"提现";
        self.titleLab.text = @"提现";
        self.subtitleLab.text = @"提现至支付宝";
        self.payView.hidden = YES;
        [self.commitBtn setTitle:@"提现" forState:0];
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightBtn setTitle:@"账户管理" forState:UIControlStateNormal];
        rightBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [rightBtn setTitleColor:[UIColor colorFromHexString:@"333333"] forState:UIControlStateNormal];
        rightBtn.bounds = CGRectMake(0, 0, 70, 30);
        [rightBtn addTarget:self action:@selector(withdrawAccountManage) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completePay:) name:@"completePay" object:nil];
}

- (void)withdrawAccountManage {
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AlipayAccountViewController* vc = [sb instantiateViewControllerWithIdentifier:@"aa"];
    [self.navigationController pushViewController:vc animated:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)selectSumMoney:(UIButton*)sender{
    [self.tf resignFirstResponder];
    for (UIButton* i in self.sumBtnAry){
        i.selected = NO;
    }
    sender.selected = YES;
    self.tf.text = [sender.titleLabel.text substringToIndex:sender.titleLabel.text.length - 1];
}
//选择支付方式
- (IBAction)selectPayWay:(UIButton*)sender {
    sender.selected = YES;
    if (sender.tag == 1){
        self.wxBtn.selected = NO;
    }else if (sender.tag == 0){
        self.zfbBtn.selected = NO;
    }
}
//提现
- (IBAction)topUp:(id)sender {
    if (self.type == 1){
        NSString* account = self.tf.text;
        if (account.intValue < 30){
            [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"提现金额不能少于30元" andDuration:2.0];
            return;
        }
        UserModel *userModel = UserModel.sharedUser;
        NSString* i = [NSString stringWithFormat:@"%@",userModel.is_paypwd];
        if ([i isEqualToString:@"0"]){
            SetPayPasswordViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"spp"];
            [self.navigationController pushViewController:vc animated:1];
            return;
        }
        CustomAlertView* alert = [[CustomAlertView alloc] initWithType:6];
        alert.resultDate = ^(NSString *date) {
            [self drawMoney:date];
            
        };
        alert.resultIndex = ^(NSInteger index) {
            RetrievePayPasswordViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"rpp"];
            [self.navigationController pushViewController:vc animated:1];
        };
        [alert showAlertView];
    }else{
        NSString* account = self.tf.text;
        if (account.intValue < 1){
            [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"充值金额不能少于1元" andDuration:2.0];
            return;
        }
        NSString* otype;
        if (self.zfbBtn.selected){
            otype = @"1";
        }else if (self.wxBtn.selected){
            otype = @"2";
        }
        
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        [SVProgressHUD show];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:[DataStore sharedDataStore].token forKey:@"token"];
        [dict setObject:account forKey:@"account"];
        [dict setObject:otype forKey:@"paytype"];
        
        [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Payment/rechargepay.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
            [SVProgressHUD dismiss];
            [SVProgressHUD setDefaultMaskType:1];
            if (isKindOfNSDictionary(object)){
                NSInteger code = [object[@"errcode"] integerValue];
                NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
                NSLog(@"输出 %@--%@",object,msg);
                
                if (code == 1) {
                    if (self.wxBtn.selected){
                        
                        PayReq *request = [[PayReq alloc] init];
                        
                        request.partnerId = [NSString stringWithFormat:@"%@",object[@"data"][@"partnerid"]];
                        request.prepayId = [NSString stringWithFormat:@"%@",object[@"data"][@"prepayid"]];
                        request.package = [NSString stringWithFormat:@"%@",object[@"data"][@"package"]];
                        request.nonceStr = [NSString stringWithFormat:@"%@",object[@"data"][@"noncestr"]];
                        request.timeStamp = [NSString stringWithFormat:@"%@",object[@"data"][@"timestamp"]].intValue;
                        request.sign= [NSString stringWithFormat:@"%@",object[@"data"][@"sign"]];
                        [WXApi sendReq:request];
                    }else if (self.zfbBtn.selected){
                        [[AlipaySDK defaultService] payOrder:[NSString stringWithFormat:@"%@",object[@"data"]] fromScheme:@"alipayYouxibang" callback:^(NSDictionary *resultDic) {

                        }];
                    }
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
}

- (void)drawMoney:(NSString*)pw{

    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[DataStore sharedDataStore].token forKey:@"token"];
    [dict setObject:self.tf.text forKey:@"account"];
    [dict setObject:pw forKey:@"paypwd"];
    
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Member/withdrawalsu.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            
            if (code == 1) {
//                [SVProgressHUD showSuccessWithStatus:msg];
                LoanDelegateViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ld"];

                [self.navigationController pushViewController:vc animated:1];
            }else if (code == 2) {
                [SVProgressHUD showInfoWithStatus:msg];
                RealNameViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"rn"];
                [self.navigationController pushViewController:vc animated:1];
            }else if (code == 3) {
                [SVProgressHUD showInfoWithStatus:msg];
                SetAliAccountViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"saa"];
                [self.navigationController pushViewController:vc animated:1];
            }else if (code == 4) {
                [SVProgressHUD showInfoWithStatus:msg];
                SetPayPasswordViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"spp"];
                [self.navigationController pushViewController:vc animated:1];
            }else if (code == 5) {
                [SVProgressHUD showInfoWithStatus:msg];
                LoanDelegateViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ld"];
                vc.dic = [NSMutableDictionary dictionaryWithDictionary:dict];
                vc.urlStr = [NSString stringWithFormat:@"%@",object[@"data"]];
                [self.navigationController pushViewController:vc animated:1];
            }else{
                CustomAlertView* alert = [[CustomAlertView alloc]initWithTitle:@"温馨提示" Text:msg AndType:0];
                [alert showAlertView];
            }
        }
        
    } failoperation:^(NSError *error) {
        
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        [SVProgressHUD showErrorWithStatus:@"网络信号差，请稍后再试"];
    }];

}

- (void)completePay:(NSNotification *)notification{

    CustomAlertView* alert = [[CustomAlertView alloc]initWithTitle:@"温馨提示" Text:@"支付完成，即将跳转到个人页面。" AndType:0];
    alert.resultIndex = ^(NSInteger index) {
        
        [self.navigationController popToRootViewControllerAnimated:1];
    };
    [alert showAlertView];

}
#pragma mark - otherDelegate/DataSource
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    for (UIButton* i in self.sumBtnAry){
        i.selected = NO;
    }
    return YES;
}
//当用户按下return去键盘

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.tf resignFirstResponder];
}

//微信支付回调
//-(void)onResp:(BaseResp*)resp{
//    if ([resp isKindOfClass:[PayResp class]]){
//        PayResp *response=(PayResp *)resp;
//        if (response.errCode == WXSuccess){
//            NSLog(@"支付成功");
//            NSNotification *notification = [NSNotification notificationWithName:@"completePay" object:nil userInfo:nil];
//            [[NSNotificationCenter defaultCenter] postNotification:notification];
//        }else{
//            NSLog(@"支付失败，retcode=%d",resp.errCode);
//        }
////        switch(response.errCode){
////            caseWXSuccess:
////                //服务器端查询支付通知或查询API返回的结果再提示成功
////                NSLog(@"支付成功");
////                [self completePay];
////                break;
////            default:
////                NSLog(@"支付失败，retcode=%d",resp.errCode);
////                break;
////        }
//    }
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
