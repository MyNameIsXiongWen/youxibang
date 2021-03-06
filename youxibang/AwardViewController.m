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
#import "TopUpAndWithdrawViewController.h"

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
    
    UserModel *userModel = UserModel.sharedUser;
    NSString* balance = [NSString stringWithFormat:@"%@",userModel.user_money ? : @"0"];
    self.balance.text = [NSString stringWithFormat:@"¥%@",balance];
    
    if (self.orderInfo){//info结构不一样
        if (self.type == 0) {
            [self.photo sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.orderInfo[@"photo"]]] placeholderImage:[UIImage imageNamed:@"ico_head"]];
            self.name.text = [NSString stringWithFormat:@"%@",self.orderInfo[@"nickname"]];
            self.content.text = [NSString stringWithFormat:@"%@  %@*%@小时",self.orderInfo[@"title"],self.orderInfo[@"perprice"],self.orderInfo[@"hours"]];
            self.awardLab.text = [NSString stringWithFormat:@"为 %@ 打赏",self.orderInfo[@"nickname"]];
        }
        else if (self.type == 2) {
            [self.photo sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.orderInfo[@"photo"]]] placeholderImage:[UIImage imageNamed:@"ico_head"]];
            self.name.text = [NSString stringWithFormat:@"%@",self.orderInfo[@"nickname"]];
            self.nameTopConstraint.constant = 34;
            self.content.hidden = YES;
            self.awardLab.text = [NSString stringWithFormat:@"为 %@ 打赏",self.orderInfo[@"nickname"]];
        }
        else {
            [self.photo sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.orderInfo[@"info"][@"photo"]]] placeholderImage:[UIImage imageNamed:@"ico_head"]];
            self.name.text = [NSString stringWithFormat:@"%@",self.orderInfo[@"info"][@"nickname"]];
            self.content.text = [NSString stringWithFormat:@"%@  ¥%@*%@小时",self.orderInfo[@"gamename"],self.orderInfo[@"perprice"],self.orderInfo[@"hours"]];
            self.awardLab.text = [NSString stringWithFormat:@"为 %@ 打赏",self.orderInfo[@"info"][@"nickname"]];
        }
    }
}

- (void)completePay:(NSNotification *)notification{
    if (self.awardSuccessBlock) {
        self.awardSuccessBlock();
    }
    [self.navigationController popViewControllerAnimated:YES];
    [SVProgressHUD showSuccessWithStatus:@"打赏成功"];
    
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
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络信号差，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
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
        NSMutableDictionary *dict = @{@"token":UserModel.sharedUser.token,
                                      @"type":@"4",
                                      @"target_id":self.orderInfo[@"id"],
                                      }.mutableCopy;
        NSString* account = self.tf.text;
        if ([EBUtility isBlankString:account]){
            [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"金额不能为空" andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
            return;
        }
        if (account.intValue <= 0){
            [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"金额不能小于0" andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
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
            if (balance.floatValue < account.floatValue) {
                UIAlertController *alertcon = [UIAlertController alertControllerWithTitle:@"当前余额不足，是否前去充值" message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelaction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                UIAlertAction *confiraction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    TopUpAndWithdrawViewController* vc = [sb instantiateViewControllerWithIdentifier:@"tuaw"];
                    vc.type = 0;
                    [self.navigationController pushViewController:vc animated:1];
                }];
                [alertcon addAction:confiraction];
                [alertcon addAction:cancelaction];
                [self presentViewController:alertcon animated:YES completion:nil];
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
            [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"金额不能为空" andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
            return;
        }
        if (account.intValue <= 0){
            [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"金额不能小于0" andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
            return;
        }
        [dict setObject:UserModel.sharedUser.token forKey:@"token"];
        [dict setObject:[NSString stringWithFormat:@"%@",self.orderInfo[@"order_sn"]] forKey:@"order_sn"];
        [dict setObject:account forKey:@"account"];
        
        if (self.zfbBtn.selected){
            [dict setObject:@"1" forKey:@"paytype"];
            [self payAwardingMoney:dict];
        }else if (self.wxBtn.selected){
            [dict setObject:@"2" forKey:@"paytype"];
            [self payAwardingMoney:dict];
        }else if (self.y_eBtn.selected){
            UserModel *userModel = UserModel.sharedUser;
            NSString* i = [NSString stringWithFormat:@"%@",userModel.is_paypwd];
            if ([i isEqualToString:@"0"]){
                SetPayPasswordViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"spp"];
                [self.navigationController pushViewController:vc animated:1];
                return;
            }
            NSString* balance = [NSString stringWithFormat:@"%@",userModel.user_money ? : @"0"];
            if (balance.floatValue < account.floatValue) {
                UIAlertController *alertcon = [UIAlertController alertControllerWithTitle:@"当前余额不足，是否前去充值" message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelaction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                UIAlertAction *confiraction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    TopUpAndWithdrawViewController* vc = [sb instantiateViewControllerWithIdentifier:@"tuaw"];
                    vc.type = 0;
                    [self.navigationController pushViewController:vc animated:1];
                }];
                [alertcon addAction:confiraction];
                [alertcon addAction:cancelaction];
                [self presentViewController:alertcon animated:YES completion:nil];
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

- (void)payAwardingMoney:(NSMutableDictionary*)dict {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Payment/rewardpay.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
        [self paymentParameters:object];
    } failoperation:^(NSError *error) {
        [SVProgressHUD dismiss];
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络信号差，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
    }];
}

#pragma mark - otherDelegate/DataSource
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    for (UIButton* i in self.moneyBtnAry){
        i.selected = NO;
    }
    return YES;
}
//当用户按下return去键盘

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
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
