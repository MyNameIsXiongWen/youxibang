//
//  AlipayAccountViewController.m
//  youxibang
//
//  Created by y on 2018/2/2.
//

#import "AlipayAccountViewController.h"
#import "SetAliAccountViewController.h"
#import "SetPayPasswordViewController.h"
#import "RetrievePayPasswordViewController.h"

@interface AlipayAccountViewController ()
@property (weak, nonatomic) IBOutlet UIView *accountView;//账户view
@property (weak, nonatomic) IBOutlet UILabel *accountLab;//显示账户邮箱lab
@end

@implementation AlipayAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"提现账户";
    //右上角按键
    UIView* rv = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 55, 25)];
    UIButton* btn = [EBUtility greenBtnfrome:CGRectMake(-40, 0, 105, 25) andText:@"设置支付密码" andColor:[UIColor colorFromHexString:@"333333"] andimg:nil andView:rv];
    
    btn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [btn addTarget:self action:@selector(addPayPassword:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rv];

}
- (void)viewWillAppear:(BOOL)animated{
    //获取绑定支付宝信息
    UserModel *userModel = UserModel.sharedUser;
    if (userModel.is_alipay.integerValue == 1){
        self.accountView.hidden = NO;
        self.accountLab.text =[NSString stringWithFormat:@"%@",userModel.alipay];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//设置支付密码或修改支付密码
- (void)addPayPassword:(UIButton*)sender{
    NSMutableDictionary* dic = [UserNameTool readPersonalData];
    NSString* i = [NSString stringWithFormat:@"%@",[dic objectForKey:@"is_paypwd"]];
    if (i.intValue == 0){
        SetPayPasswordViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"spp"];
        [self.navigationController pushViewController:vc animated:1];
    }else{
        RetrievePayPasswordViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"rpp"];
        [self.navigationController pushViewController:vc animated:1];
    }
    
}
//增加绑定账户
- (IBAction)addAccount:(id)sender {
    SetAliAccountViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"saa"];
    [self.navigationController pushViewController:vc animated:1];
    
}
//删除绑定账户
- (IBAction)deleteAccount:(id)sender {
    CustomAlertView* alert = [[CustomAlertView alloc] initWithType:9];
    alert.resultIndex = ^(NSInteger index) {
        if (index == 0){
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
            [SVProgressHUD show];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:[DataStore sharedDataStore].token forKey:@"token"];
            [dict setObject:@"2" forKey:@"typeid"];
            
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
                            self.navigationItem.rightBarButtonItem.customView.hidden = YES;
                            self.accountView.hidden = YES;
                        }];
                        
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
    };
    [alert showAlertView];
    
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
