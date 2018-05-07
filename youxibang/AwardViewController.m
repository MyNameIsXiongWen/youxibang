//
//  AwardViewController.m
//  youxibang
//
//  Created by y on 2018/2/7.
//

#import "AwardViewController.h"
#import "SetPayPasswordViewController.h"
#import "RetrievePayPasswordViewController.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import <AlipaySDK/AlipaySDK.h>

@interface AwardViewController () <WXApiDelegate>
@property (weak, nonatomic) IBOutlet UILabel *awardLab;
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *content;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *moneyBtnAry;
@property (weak, nonatomic) IBOutlet UITextField *tf;
@property (weak, nonatomic) IBOutlet UIButton *commitBtn;
@property (weak, nonatomic) IBOutlet UIButton *wxBtn;
@property (weak, nonatomic) IBOutlet UIButton *zfbBtn;
@property (weak, nonatomic) IBOutlet UIButton *y_eBtn;
@property (weak, nonatomic) IBOutlet UILabel *balance;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameTopConstraint;
@end

@implementation AwardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"打赏";
    for (UIButton* i in self.moneyBtnAry){
        [i addTarget:self action:@selector(selectSumMoney:) forControlEvents:UIControlEventTouchUpInside];
    }
    //完成付款的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completePay:) name:@"completePay" object:nil];
    
    NSMutableDictionary* dic = [UserNameTool readPersonalData];
    NSString* balance = [NSString stringWithFormat:@"%@",(dic[@"user_money"]) ? (dic[@"user_money"]) : @"0"];
    self.balance.text = [NSString stringWithFormat:@"¥%@",balance];
    
    if (self.orderInfo){//info结构不一样
        if (self.type == 0) {
            [self.photo sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.orderInfo[@"photo"]]] placeholderImage:[UIImage imageNamed:@"ico_head"]];
            self.name.text = [NSString stringWithFormat:@"%@",self.orderInfo[@"nickname"]];
            self.content.text = [NSString stringWithFormat:@"%@  %@*%@小时",self.orderInfo[@"title"],self.orderInfo[@"perprice"],self.orderInfo[@"hours"]];
            self.awardLab.text = [NSString stringWithFormat:@"为%@打赏",self.orderInfo[@"nickname"]];
        }
        else if (self.type == 2) {
            [self.photo sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.orderInfo[@"photo"]]] placeholderImage:[UIImage imageNamed:@"ico_head"]];
            self.name.text = [NSString stringWithFormat:@"%@",self.orderInfo[@"nickname"]];
            self.nameTopConstraint.constant = 37;
            self.content.hidden = YES;
            self.awardLab.text = [NSString stringWithFormat:@"为 %@ 打赏",self.orderInfo[@"nickname"]];
        }
        else {
            [self.photo sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.orderInfo[@"info"][@"photo"]]] placeholderImage:[UIImage imageNamed:@"ico_head"]];
            self.name.text = [NSString stringWithFormat:@"%@",self.orderInfo[@"info"][@"nickname"]];
            self.content.text = [NSString stringWithFormat:@"%@  ¥%@*%@小时",self.orderInfo[@"gamename"],self.orderInfo[@"perprice"],self.orderInfo[@"hours"]];
            self.awardLab.text = [NSString stringWithFormat:@"为%@打赏",self.orderInfo[@"info"][@"nickname"]];
        }
    }
}

- (void)completePay:(NSNotification *)notification{
//    CustomAlertView* alert = [[CustomAlertView alloc]initWithTitle:@"温馨提示" Text:@"打赏完成，即将跳转到个人页面。" AndType:0];
//    alert.resultIndex = ^(NSInteger index) {
//        [self.navigationController popToRootViewControllerAnimated:1];
//    };
//    [alert showAlertView];
    [self.navigationController popViewControllerAnimated:YES];
    [SVProgressHUD showSuccessWithStatus:@"支付成功"];
    
}
//选择数额
- (void)selectSumMoney:(UIButton*)sender{
    [self.tf resignFirstResponder];
    for (UIButton* i in self.moneyBtnAry){
        i.selected = NO;
    }
    sender.selected = YES;
    self.tf.text = [sender.titleLabel.text substringToIndex:sender.titleLabel.text.length - 1];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//选择方式
- (IBAction)selectPayWay:(UIButton*)sender {
    self.zfbBtn.selected = NO;
    self.wxBtn.selected = NO;
    self.y_eBtn.selected = NO;

    sender.selected = YES;
}
//提交支付
- (void)payTipForLive:(NSDictionary*)dic {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@payment/buy",HttpURLString] Paremeters:dic successOperation:^(id object) {
        [self paymentParameters:object];
    } failoperation:^(NSError *error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        [SVProgressHUD showErrorWithStatus:@"网络信号差，请稍后再试"];
    }];
}

- (void)paymentParameters:(id)object {
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
            }else if (self.y_eBtn.selected){
                [self completePay:nil];
            }
        }else{
            [SVProgressHUD showErrorWithStatus:msg];
        }
    }
}

//提交
- (IBAction)commitInfo:(UIButton *)sender {
    if (self.type == 2) {
        NSMutableDictionary *dict = @{@"token":DataStore.sharedDataStore.token,
                                      @"type":@"4",
                                      @"target_id":self.orderInfo[@"id"],
                                      }.mutableCopy;
        NSString* account = self.tf.text;
        if ([EBUtility isBlankString:account]){
            [SVProgressHUD showErrorWithStatus:@"金额不能为空"];
            return;
        }
        if (account.intValue <= 0){
            [SVProgressHUD showErrorWithStatus:@"金额不能小于0"];
            return;
        }
        [dict setObject:account forKey:@"account"];
        if (self.zfbBtn.selected) {
            [dict setObject:@"1" forKey:@"paytype"];
            [self payTipForLive:dict];
        }else if (self.wxBtn.selected) {
            [dict setObject:@"2" forKey:@"paytype"];
            [self payTipForLive:dict];
        }else if (self.y_eBtn.selected) {
            UserModel *user = UserModel.sharedUser;
            if ([user.is_paypwd isEqualToString:@"0"]){
                SetPayPasswordViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"spp"];
                [self.navigationController pushViewController:vc animated:1];
                return;
            }
            NSString* balance = [NSString stringWithFormat:@"%@",user.user_money?:@"0"];
            if (account.intValue > balance.intValue){
                [SVProgressHUD showErrorWithStatus:@"余额不足"];
                return;
            }
            CustomAlertView* alert = [[CustomAlertView alloc] initWithType:6];
            alert.resultDate = ^(NSString *date) {
                [dict setObject:@"3" forKey:@"paytype"];
                [dict setObject:date forKey:@"pwd"];
                [self payTipForLive:dict];
            };
            alert.resultIndex = ^(NSInteger index) {
                RetrievePayPasswordViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"rpp"];
                [self.navigationController pushViewController:vc animated:1];
            };
            [alert showAlertView];
            return;
        }
    }
    else {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        NSString* account = self.tf.text;
        if ([EBUtility isBlankString:account]){
            [SVProgressHUD showErrorWithStatus:@"金额不能为空"];
            return;
        }
        if (account.intValue <= 0){
            [SVProgressHUD showErrorWithStatus:@"金额不能小于0"];
            return;
        }
        [dict setObject:[DataStore sharedDataStore].token forKey:@"token"];
        [dict setObject:[NSString stringWithFormat:@"%@",self.orderInfo[@"order_sn"]] forKey:@"order_sn"];
        [dict setObject:account forKey:@"account"];
        
        if (self.zfbBtn.selected){
            [dict setObject:@"1" forKey:@"paytype"];
            [self payAwardingMoney:dict];
        }else if (self.wxBtn.selected){
            [dict setObject:@"2" forKey:@"paytype"];
            [self payAwardingMoney:dict];
        }else if (self.y_eBtn.selected){
            NSMutableDictionary* dic = [UserNameTool readPersonalData];
            NSString* i = [NSString stringWithFormat:@"%@",dic[@"is_paypwd"]];
            if ([i isEqualToString:@"0"]){
                SetPayPasswordViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"spp"];
                [self.navigationController pushViewController:vc animated:1];
                return;
            }
            NSString* balance = [NSString stringWithFormat:@"%@",(dic[@"user_money"]) ? (dic[@"user_money"]) : @"0"];
            if (account.intValue > balance.intValue){
                [SVProgressHUD showErrorWithStatus:@"余额不足"];
                return;
            }
            CustomAlertView* alert = [[CustomAlertView alloc] initWithType:6];
            alert.resultDate = ^(NSString *date) {
                [dict setObject:@"3" forKey:@"paytype"];
                [dict setObject:date forKey:@"paypwd"];
                [self payAwardingMoney:dict];
            };
            alert.resultIndex = ^(NSInteger index) {
                RetrievePayPasswordViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"rpp"];
                [self.navigationController pushViewController:vc animated:1];
            };
            [alert showAlertView];
            return;
        }
    }
}

- (void)payAwardingMoney:(NSMutableDictionary*)dict{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Payment/rewardpay.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
        [self paymentParameters:object];
    } failoperation:^(NSError *error) {
        
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        [SVProgressHUD showErrorWithStatus:@"网络信号差，请稍后再试"];
    }];
}

#pragma mark - otherDelegate/DataSource
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    for (UIButton* i in self.moneyBtnAry){
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
