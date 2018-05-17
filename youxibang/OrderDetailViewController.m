//
//  OrderDetailViewController.m
//  youxibang
//
//  Created by y on 2018/1/30.
//

#import "OrderDetailViewController.h"
#import "PayOrderViewController.h"
#import "UpDataProgressViewController.h"
#import "ReVokeViewController.h"
#import "OrderSelectViewController.h"
#import "EvaluateViewController.h"
#import "AwardViewController.h"
#import "EmployeeDetailViewController.h"
#import "AppealViewController.h"
#import "LoginViewController.h"

@interface OrderDetailViewController ()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>

/* type
 我的任务
 0 未登录
 
 1 任务发布者本人访问 && 未有宝贝抢单
 
 2 任务发布者本人访问 && 有宝贝抢单（选择宝贝）
 
 3 游戏宝贝访问 && 未抢单或者未对该任务抢单（支付定金）
 
 4 游戏宝贝访问 && 已抢单（已抢单）
 
 我的订单
 
 */
@property (nonatomic,assign)int type;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *commitBtn;//下方单一Btn
@property (weak, nonatomic) IBOutlet UIView *startBtnView;//下方双Btn的承载view
@property (nonatomic,assign)int unusual;// 0 不显示提交异常cell   1 显示一个键   2 显示两个键
@property (weak, nonatomic) IBOutlet UIButton *bottomLeftBtn;//左下方Btn
@property (weak, nonatomic) IBOutlet UIButton *bottomRightBtn;//右下方Btn
@property (nonatomic,strong)NSMutableDictionary *dataInfo;//数据地点
@end

@implementation OrderDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    //添加去除第一响应者的手势
    UITapGestureRecognizer *tapSuperGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSuperView:)];
    tapSuperGesture.delegate = self;
    [_tableView addGestureRecognizer:tapSuperGesture];
    //付款过后反向传值的推送  暂弃用
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(InfoNotificationAction:) name:@"payOrder" object:nil];

    self.title = @"任务详情";
    if (self.isOrder){
        self.title = @"订单详情";
    }
    
    //初始状态隐藏下方的任何按钮
    self.commitBtn.hidden = YES;
    self.startBtnView.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //因为有可能付款后返回此页面也需要刷新，所以获得数据方法写在这里
    [self downloadData];
}
//手势方法
- (void)tapSuperView:(UITapGestureRecognizer *)tapSuperGesture{
    [self.tableView endEditing:1];
}
//下载数据
- (void)downloadData{
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if (!self.isOrder){
        if (![EBUtility isBlankString:[DataStore sharedDataStore].userid]){
            [dict setObject:[DataStore sharedDataStore].userid forKey:@"userid"];
        }
        [dict setObject:self.itemId forKey:@"itemid"];
        [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Parttime/partdetail.html",HttpURLString] Paremeters:dict successOperation:^(id object) {

            if (isKindOfNSDictionary(object)){
                NSInteger code = [object[@"errcode"] integerValue];
                NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
                NSLog(@"输出 %@--%@",object,msg);
                
                if (code == 1) {
                    self.dataInfo = [NSMutableDictionary dictionaryWithDictionary:object[@"data"]];
                    //获取此页面的状态后，根据状态设置页面并刷新
                    self.type = [NSString stringWithFormat:@"%@",self.dataInfo[@"btnstatus"]].intValue;
                    [self setTypeStatus];
                    
                }else{
                    [SVProgressHUD showErrorWithStatus:msg];
                }
            }
            
        } failoperation:^(NSError *error) {
            [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络信号差，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
        }];
    }else if (self.isOrder){
        [dict setObject:[DataStore sharedDataStore].token forKey:@"token"];
        [dict setObject:self.itemId forKey:@"order_sn"];
        [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Orders/orderdetail.html",HttpURLString] Paremeters:dict successOperation:^(id object) {

            if (isKindOfNSDictionary(object)){
                NSInteger code = [object[@"errcode"] integerValue];
                NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
                NSLog(@"输出 %@--%@",object,msg);
                if (isKindOfNSDictionary(object[@"data"])){
                    if (code == 1) {
                        self.dataInfo = [NSMutableDictionary dictionaryWithDictionary:object[@"data"]];
                        //获取此页面的状态后，根据状态设置页面并刷新
                        self.type = [NSString stringWithFormat:@"%@",self.dataInfo[@"status"]].intValue;
                        [self setTypeStatus];
                        
                    }else{
                        [SVProgressHUD showErrorWithStatus:msg];
                    }
                }
            }
            
        } failoperation:^(NSError *error) {
            [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络信号差，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
        }];
    }
}
//选择的按钮触发一些在本页面就可以进行的事件
- (void)getRequestWithType:(NSString*)type AndOrderSn:(NSString*)orderSn{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[DataStore sharedDataStore].token forKey:@"token"];
    [dict setObject:orderSn forKey:@"order_sn"];
    [dict setObject:type forKey:@"type"];
    
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Orders/orderhandle.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            
            if (code == 1) {
                [SVProgressHUD showSuccessWithStatus:msg];
                
                [self downloadData];
            }else{
                [SVProgressHUD showErrorWithStatus:msg];
            }
        }
        
    } failoperation:^(NSError *error) {
        [SVProgressHUD dismiss];
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络信号差，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
    }];
}
//根据状态设置页面
- (void)setTypeStatus{
    if (!self.isOrder){
        if (self.type == 0){
            self.startBtnView.hidden = YES;
            self.commitBtn.hidden = NO;
            
        }else  if (self.type == 1){
            self.startBtnView.hidden = YES;
            self.commitBtn.hidden = YES;
            
        }else if (self.type == 2){
            self.startBtnView.hidden = YES;
            self.commitBtn.hidden = NO;
            [self.commitBtn setTitle:@"选择宝贝" forState:0];
            
        }else if (self.type == 3){
            self.startBtnView.hidden = YES;
            self.commitBtn.hidden = NO;
            
        }else if (self.type == 4){
            
            self.startBtnView.hidden = YES;
            self.commitBtn.hidden = NO;
            [self.commitBtn setTitle:@"已报名" forState:0];
            self.commitBtn.userInteractionEnabled = NO;
            self.commitBtn.backgroundColor = [UIColor lightGrayColor];
        }else if (self.type == 5){
            
            self.startBtnView.hidden = YES;
            self.commitBtn.hidden = NO;
            [self.commitBtn setTitle:@"查看订单详情" forState:0];
        }else if (self.type == 6){
            
            self.startBtnView.hidden = YES;
            self.commitBtn.hidden = NO;
            [self.commitBtn setTitle:@"查看订单详情" forState:0];
            
        }else if (self.type == 4){
            
            self.startBtnView.hidden = YES;
            self.commitBtn.hidden = NO;
            [self.commitBtn setTitle:@"任务失败" forState:0];
            self.commitBtn.userInteractionEnabled = NO;
            self.commitBtn.backgroundColor = [UIColor lightGrayColor];
        }
        
    }else if (self.isOrder){
        if ([NSString stringWithFormat:@"%@",self.dataInfo[@"is_baby"]].intValue == 1){
            if (self.type == 0){
                
                self.unusual = 0;
                self.startBtnView.hidden = NO;
                self.commitBtn.hidden = YES;
                
                [self.bottomLeftBtn setTitle:@"开始打单" forState:0];
                [self.bottomRightBtn setTitle:@"取消订单" forState:0];
            }else if (self.type == 1){
                
                self.unusual = 1;
                self.startBtnView.hidden = NO;
                self.commitBtn.hidden = YES;
                
                [self.bottomLeftBtn setTitle:@"上传进度" forState:0];
                [self.bottomRightBtn setTitle:@"申请取消" forState:0];
            }else if (self.type == 2){
                
                self.unusual = 1;
                self.startBtnView.hidden = NO;
                self.commitBtn.hidden = YES;
                
                [self.bottomLeftBtn setTitle:@"同意退单" forState:0];
                [self.bottomRightBtn setTitle:@"拒绝退单" forState:0];
                
            }else if (self.type == 3){
                
                self.unusual = 1;
                self.startBtnView.hidden = NO;
                self.commitBtn.hidden = YES;
                
                [self.bottomLeftBtn setTitle:@"撤销申请" forState:0];
                [self.bottomRightBtn setTitle:@"申请仲裁" forState:0];
                
            }else if (self.type == 4){
                
                self.unusual = 1;
                self.startBtnView.hidden = YES;
                self.commitBtn.hidden = YES;
                
            }else if (self.type == 5){
                
                self.unusual = 1;
                self.startBtnView.hidden = YES;
                self.commitBtn.hidden = NO;
                
                [self.commitBtn setTitle:@"等待雇主验收" forState:0];
                self.commitBtn.userInteractionEnabled = NO;
                self.commitBtn.backgroundColor = [UIColor lightGrayColor];
            }else if (self.type == 8){
                
                self.unusual = 1;
                self.startBtnView.hidden = YES;
                self.commitBtn.hidden = YES;
            }
        }else if ([NSString stringWithFormat:@"%@",self.dataInfo[@"is_baby"]].intValue == 2){
            
            if (self.type == 0){
                
                self.unusual = 0;
                self.startBtnView.hidden = NO;
                self.commitBtn.hidden = YES;
                
                [self.bottomLeftBtn setTitle:@"催单" forState:0];
                [self.bottomRightBtn setTitle:@"取消订单" forState:0];
                
            }else if (self.type == 1){
                
                self.unusual = 1;
                self.startBtnView.hidden = YES;
                self.commitBtn.hidden = NO;
                
                [self.commitBtn setTitle:@"申请取消" forState:0];
            }else if (self.type == 2){
                
                self.unusual = 1;
                self.startBtnView.hidden = NO;
                self.commitBtn.hidden = YES;
                
                [self.bottomLeftBtn setTitle:@"撤销申请" forState:0];
                [self.bottomRightBtn setTitle:@"申请仲裁" forState:0];
            }else if (self.type == 3){
                
                self.unusual = 1;
                self.startBtnView.hidden = NO;
                self.commitBtn.hidden = YES;
                
                [self.bottomLeftBtn setTitle:@"同意退单" forState:0];
                [self.bottomRightBtn setTitle:@"拒绝退单" forState:0];
            }else if (self.type == 4){
                
                self.unusual = 1;
                self.startBtnView.hidden = YES;
                self.commitBtn.hidden = NO;
                
                [self.commitBtn setTitle:@"撤销仲裁" forState:0];
                
            }else if (self.type == 5){
                
                self.unusual = 2;
                self.startBtnView.hidden = NO;
                self.commitBtn.hidden = YES;
                
                [self.bottomLeftBtn setTitle:@"打赏" forState:0];
                [self.bottomRightBtn setTitle:@"评价" forState:0];
            }else if (self.type == 6){
                
                self.unusual = 1;
                self.startBtnView.hidden = YES;
                self.commitBtn.hidden = NO;
                
                [self.commitBtn setTitle:@"评价" forState:0];
            }else if (self.type == 8){
                
                self.unusual = 1;
                self.startBtnView.hidden = YES;
                self.commitBtn.hidden = YES;
                
            }else if (self.type == 99){
                
                self.unusual = 0;
                self.startBtnView.hidden = NO;
                self.commitBtn.hidden = YES;
                
                [self.bottomLeftBtn setTitle:@"去付款" forState:0];
                [self.bottomRightBtn setTitle:@"取消订单" forState:0];
            }
        }else{
            self.unusual = 0;
            self.startBtnView.hidden = YES;
            self.commitBtn.hidden = YES;
        }
    }
    
    [self.tableView reloadData];
}
//最下方startBtnView左边的按钮
- (IBAction)leftBtn:(UIButton *)sender {
    if ([EBUtility isBlankString:[DataStore sharedDataStore].token]){
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController* vc = [sb instantiateViewControllerWithIdentifier:@"loginPWD"];
        [self.navigationController pushViewController:vc animated:1];
        return;
    }
    if(self.isOrder){
        if ([NSString stringWithFormat:@"%@",self.dataInfo[@"is_baby"]].intValue == 1){
            if (self.type == 0){//开始打单
                UpDataProgressViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"udp"];
                vc.orderSn = self.itemId;
                vc.type = @"1";
                [self.navigationController pushViewController:vc animated:1];
            }else if (self.type == 1){//上传进度
                UpDataProgressViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"udp"];
                vc.orderSn = self.itemId;
                vc.type = @"2";
                [self.navigationController pushViewController:vc animated:1];
            }else if (self.type == 2){//同意退单
                [self getRequestWithType:@"3" AndOrderSn:self.itemId];
            }else if (self.type == 3){//撤销申请
                [self getRequestWithType:@"2" AndOrderSn:self.itemId];
            }
        }else if ([NSString stringWithFormat:@"%@",self.dataInfo[@"is_baby"]].intValue == 2){
            if (self.type == 0){//催单
                [self getRequestWithType:@"1" AndOrderSn:self.itemId];
            }else if (self.type == 2){//撤销申请
                [self getRequestWithType:@"2" AndOrderSn:self.itemId];
            }else if (self.type == 3){//同意退单
                [self getRequestWithType:@"3" AndOrderSn:self.itemId];
            }else if (self.type == 5){//打赏
                AwardViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"avc"];
                vc.orderInfo = self.dataInfo;
                vc.type = 1;
                [self.navigationController pushViewController:vc animated:1];
            }else if (self.type == 99){//去付款
                PayOrderViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"po"];
                vc.type = @"OrderViewController";
                vc.orderId = [NSString stringWithFormat:@"%@",self.dataInfo[@"order_id"]];
                [self.navigationController pushViewController:vc animated:1];
            }
        }
    }
}

//startBtnView右边的按钮
- (IBAction)rightBtn:(UIButton *)sender {
    if ([EBUtility isBlankString:[DataStore sharedDataStore].token]){
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController* vc = [sb instantiateViewControllerWithIdentifier:@"loginPWD"];
        [self.navigationController pushViewController:vc animated:1];
        return;
    }
    if(self.isOrder){
        if ([NSString stringWithFormat:@"%@",self.dataInfo[@"is_baby"]].intValue == 1){
            if (self.type == 0 || self.type == 99){//取消订单
                CustomAlertView* alert = [[CustomAlertView alloc]initWithTitle:@"温馨提示" Text:@"是否确定取消抢单？" AndType:2];
                alert.resultIndex = ^(NSInteger index) {
                    [self getRequestWithType:@"5" AndOrderSn:self.itemId];
                };
                [alert showAlertView];
                
            }else if (self.type == 1){//申请取消
                ReVokeViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"rv"];
                vc.type = 1;
                if ([NSString stringWithFormat:@"%@",self.dataInfo[@"typeid"]].intValue == 1){
                    vc.withdrawOrderType = 1;
                }else{
                    vc.withdrawOrderType = 2;
                }
                vc.orderId = self.itemId;
                [self.navigationController pushViewController:vc animated:1];
            }else if (self.type == 2){//拒绝退单
                [self getRequestWithType:@"6" AndOrderSn:self.itemId];
            }else if (self.type == 3){//申请仲裁
                ReVokeViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"rv"];
                vc.type = 2;
                vc.orderId = self.itemId;
                [self.navigationController pushViewController:vc animated:1];
            }
        }else if ([NSString stringWithFormat:@"%@",self.dataInfo[@"is_baby"]].intValue == 2){
            if (self.type == 0){//取消订单
                [self getRequestWithType:@"5" AndOrderSn:self.itemId];
            }else if (self.type == 2){//申请仲裁
                
                ReVokeViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"rv"];
                vc.type = 2;
                vc.orderId = self.itemId;
                [self.navigationController pushViewController:vc animated:1];
            }else if (self.type == 3){//拒绝退单
                [self getRequestWithType:@"6" AndOrderSn:self.itemId];
            }else if (self.type == 5){//评价
                EvaluateViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"eva"];
                vc.orderInfo = self.dataInfo;
                vc.type = 1;
                [self.navigationController pushViewController:vc animated:1];
            }
        }
    }
}
//当下方只有一个按钮时按键方法
- (IBAction)oneBtn:(UIButton *)sender {
    if ([EBUtility isBlankString:[DataStore sharedDataStore].token]){
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController* vc = [sb instantiateViewControllerWithIdentifier:@"loginPWD"];
        [self.navigationController pushViewController:vc animated:1];
        return;
    }
    if (!_isOrder){
        if (self.type == 2){//选择宝贝
            OrderSelectViewController* vc = [[OrderSelectViewController alloc]init];
            vc.orderId = self.itemId;
            [self.navigationController pushViewController:vc animated:1];
        }else if (self.type == 3){//支付保证金
            UITableViewCell* cell1 = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
            UITextField* tf = [cell1 viewWithTag:11];
            
            PayOrderViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"po"];
            vc.type = NSStringFromClass([self class]);
            vc.orderId = self.itemId;
            vc.purposemoney = tf.text;
            [self.navigationController pushViewController:vc animated:1];
        }else if (self.type == 5 || self.type == 6){//查看订单详情
            self.isOrder = YES;
            self.itemId = [NSString stringWithFormat:@"%@",self.dataInfo[@"order_sn"]];
            [self downloadData];
        }
    }else{
        if ([NSString stringWithFormat:@"%@",self.dataInfo[@"is_baby"]].intValue == 1){
            if (self.type == 4){//撤销仲裁
                [self getRequestWithType:@"4" AndOrderSn:self.itemId];
            }
        }else{
            if (self.type == 1){//申请取消
                ReVokeViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"rv"];
                vc.type = 1;
                vc.orderId = self.itemId;
                vc.withdrawOrderType = 0;
                [self.navigationController pushViewController:vc animated:1];
            }else if (self.type == 4){//撤销仲裁
                [self getRequestWithType:@"4" AndOrderSn:self.itemId];
            }else if (self.type == 6){
                EvaluateViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"eva"];
                vc.orderInfo = self.dataInfo;
                vc.type = 1;
                [self.navigationController pushViewController:vc animated:1];
            }
        }
    }
}

- (IBAction)cellLeftBtn:(UIButton *)sender {//提交异常
    if ([EBUtility isBlankString:[DataStore sharedDataStore].token]){
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController* vc = [sb instantiateViewControllerWithIdentifier:@"loginPWD"];
        [self.navigationController pushViewController:vc animated:1];
        return;
    }
    ReVokeViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"rv"];
    vc.type = 0;
    vc.orderId = self.itemId;
    [self.navigationController pushViewController:vc animated:1];
}

- (IBAction)cellRightBtn:(UIButton *)sender {//投诉
    if ([EBUtility isBlankString:[DataStore sharedDataStore].token]){
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController* vc = [sb instantiateViewControllerWithIdentifier:@"loginPWD"];
        [self.navigationController pushViewController:vc animated:1];
        return;
    }
    AppealViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"app"];
    vc.orderInfo = self.dataInfo;
    [self.navigationController pushViewController:vc animated:1];
}

//付款过后反向传值的推送  暂弃用
//- (void)InfoNotificationAction:(NSNotification *)notification{
//    //更改下方按钮的alert
//    CustomAlertView* alert = [[CustomAlertView alloc]initWithType:2];
//    alert.resultIndex = ^(NSInteger index) {
//        [self.commitBtn setTitle:@"已报名" forState:0];
//        self.commitBtn.backgroundColor = [UIColor lightGrayColor];
//        self.commitBtn.userInteractionEnabled = NO;
//    };
//    [alert showAlertView];
//}

#pragma mark - tableViewDelegate/DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.dataInfo.count == 0){
        return 0;
    }
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 1){
        return 1;
    }else if (section == 2){
        if (self.unusual > 0){
            return 3;
        }
        return 2;
    }
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1){
        return 80;
    }
    return UITableViewAutomaticDimension;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    if (indexPath.section == 1){
        return 80;
    }
    return UITableViewAutomaticDimension;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 2){
        return 45;
    }
    return 10;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section != 1){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"cell%ld%ld",(long)indexPath.section,(long)indexPath.row]];
        if (self.dataInfo){
            if (indexPath.section == 0){
                //设置右上角状态显示
                if(indexPath.row == 0){
                    if (_isOrder){
                        UILabel* status = [cell viewWithTag:1];
                        status.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"tname"]];
                    }else{
                        UILabel* status = [cell viewWithTag:1];
                        status.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"statusname"]];
                    }

                }else if (indexPath.row == 1){
                    
                    //设置订单信息显示
                    if (_isOrder){
                        if ([NSString stringWithFormat:@"%@",self.dataInfo[@"typeid"]].intValue == 1){
                            cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"cell%ld%ld1",(long)indexPath.section,(long)indexPath.row]];
                            
                            if (![EBUtility isBlankString:[NSString stringWithFormat:@"%@",self.dataInfo[@"gamefee"]]]){
                                UILabel* gamefee = [cell viewWithTag:10];
                                gamefee.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"gamefee"]];
                            }else{
                                UILabel* gamefee = [cell viewWithTag:10];
                                gamefee.text = @"";
                            }
                        }else{

                            UITextField* tf = [cell viewWithTag:11];
                            tf.text = [NSString stringWithFormat:@"¥%@",self.dataInfo[@"editprice"]];
                            tf.textColor = [UIColor redColor];
                            tf.userInteractionEnabled = NO;
                            tf.borderStyle = UITextBorderStyleNone;
                            UILabel* lab = [cell viewWithTag:10];
                            lab.textColor = [EBUtility colorWithHexString:@"FD9055" alpha:1];
                            
                            UILabel* title = [cell viewWithTag:1];
                            title.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"title"]];
                            
                            UILabel* nickname = [cell viewWithTag:6];
                            nickname.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"publisher"]];
                            
                            UILabel* deposit = [cell viewWithTag:10];
                            deposit.text = [NSString stringWithFormat:@"¥%@",self.dataInfo[@"deposit"]];
                        }
                        
                        UILabel* type = [cell viewWithTag:2];
                        type.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"gamename"]];
                        
                        UILabel* orderNum = [cell viewWithTag:3];
                        orderNum.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"order_sn"]];
                        
                        UILabel* addTime = [cell viewWithTag:4];
                        addTime.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"addtime"]];
                        
                        UILabel* startTime = [cell viewWithTag:5];
                        startTime.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"stime"]];
                        
                        UILabel* price = [cell viewWithTag:7];
                        price.text = [NSString stringWithFormat:@"¥%@/小时",self.dataInfo[@"perprice"]];
                        
                        UILabel* time = [cell viewWithTag:8];
                        time.text = [NSString stringWithFormat:@"%@小时",self.dataInfo[@"hours"]];
                        
                        UILabel* totalprice = [cell viewWithTag:9];
                        totalprice.text = [NSString stringWithFormat:@"¥%@",self.dataInfo[@"totalprice"]];
                    }else{
                        //任务信息显示
                        if (self.type == 3 || self.type == 0){
                            UITextField* purposemoneyTf = [cell viewWithTag:11];
                            purposemoneyTf.hidden = NO;
                            
                            UILabel* purposemoney = [cell viewWithTag:12];
                            purposemoney.hidden = NO;
                        }else if (self.type == 4 || self.type == 6 || self.type == 7){
 
                            UITextField* tf = [cell viewWithTag:11];
                            tf.text = [NSString stringWithFormat:@"¥%@",self.dataInfo[@"purposemoney"]];
                            tf.textColor = [UIColor redColor];
                            tf.userInteractionEnabled = NO;
                            tf.borderStyle = UITextBorderStyleNone;
                            UILabel* lab = [cell viewWithTag:10];
                            lab.textColor = [EBUtility colorWithHexString:@"FD9055" alpha:1];
                            
                        }else{
                            UITextField* purposemoneyTf = [cell viewWithTag:11];
                            purposemoneyTf.hidden = YES;
                            
                            UILabel* purposemoney = [cell viewWithTag:12];
                            purposemoney.hidden = YES;
                        }
                        
                        UILabel* taskNum = [cell viewWithTag:13];
                        taskNum.text = @"任务编号";
                        
                        UILabel* title = [cell viewWithTag:1];
                        title.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"title"]];
                        
                        UILabel* type = [cell viewWithTag:2];
                        type.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"gamename"]];
                        
                        UILabel* orderNum = [cell viewWithTag:3];
                        orderNum.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"order_sn"]];
                        
                        UILabel* addTime = [cell viewWithTag:4];
                        addTime.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"addtime"]];
                        
                        UILabel* startTime = [cell viewWithTag:5];
                        startTime.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"stime"]];
                        
                        UILabel* nickname = [cell viewWithTag:6];
                        nickname.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"nickname"]];
                        
                        UILabel* price = [cell viewWithTag:7];
                        price.text = [NSString stringWithFormat:@"¥%@/小时",self.dataInfo[@"price"]];
                        
                        UILabel* time = [cell viewWithTag:8];
                        time.text = [NSString stringWithFormat:@"%@小时",self.dataInfo[@"num"]];
                        
                        UILabel* totalprice = [cell viewWithTag:9];
                        totalprice.text = [NSString stringWithFormat:@"¥%@",self.dataInfo[@"totalprice"]];
                        
                        UILabel* deposit = [cell viewWithTag:10];
                        deposit.text = [NSString stringWithFormat:@"¥%@",self.dataInfo[@"deposit"]];
                    }
                }
            }else if (indexPath.section == 2){
                //订单备注
                if (indexPath.row == 1){
                    UILabel* content = [cell viewWithTag:1];
                    if (_isOrder){
                        content.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"remarks"]];
                    }else{
                        content.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"note"]];
                    }
                }else if (indexPath.row == 2){
                    if (self.unusual == 2){
                        cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"cell%ld%ld2",(long)indexPath.section,(long)indexPath.row]];
                    }
                }
            }
        }
        return cell;
    }
    
    //这个cell是中间的人物cell
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell11"];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.imageView.image = [UIImageView OriginImage:[UIImage imageNamed:@"ico_head"] scaleToSize:CGSizeMake(60, 60)];
    
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.layer.cornerRadius = 30;
    cell.textLabel.text = @"昵称";
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.detailTextLabel.text = @"♂24岁";
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.backgroundColor = Nav_color;
    cell.detailTextLabel.layer.masksToBounds = YES;
    cell.detailTextLabel.layer.cornerRadius = 5;
    if (_isOrder){
        if (self.dataInfo[@"info"]){
            cell.textLabel.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"info"][@"nickname"]];
            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.dataInfo[@"info"][@"photo"]]] ];
        }
    }else{
        if (self.dataInfo[@"userinfo"]){
            cell.textLabel.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"userinfo"][@"nickname"]];
            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.dataInfo[@"userinfo"][@"photo"]]] ];
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1){
        if (_isOrder){
            if (self.dataInfo[@"info"]){
                if ([NSString stringWithFormat:@"%@",self.dataInfo[@"info"][@"sex"]].integerValue == 1){
                    cell.detailTextLabel.text = [NSString stringWithFormat:@" ♂%@ ",self.dataInfo[@"info"][@"age"]];
                    cell.detailTextLabel.backgroundColor = Nav_color;
                }else{
                    cell.detailTextLabel.text = [NSString stringWithFormat:@" ♀%@ ",self.dataInfo[@"info"][@"age"]];
                    cell.detailTextLabel.backgroundColor = Pink_color;
                }
                cell.imageView.image = [UIImageView OriginImage:cell.imageView.image scaleToSize:CGSizeMake(60, 60)];
            }
        }else{
            if (self.dataInfo[@"userinfo"]){
                if ([NSString stringWithFormat:@"%@",self.dataInfo[@"userinfo"][@"sex"]].integerValue == 1){
                    cell.detailTextLabel.text = [NSString stringWithFormat:@" ♂%@ ",self.dataInfo[@"userinfo"][@"age"]];
                    cell.detailTextLabel.backgroundColor = Nav_color;
                }else{
                    cell.detailTextLabel.text = [NSString stringWithFormat:@" ♀%@ ",self.dataInfo[@"userinfo"][@"age"]];
                    cell.detailTextLabel.backgroundColor = Pink_color;
                }
                cell.imageView.image = [UIImageView OriginImage:cell.imageView.image scaleToSize:CGSizeMake(60, 60)];
            }
        }
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView endEditing:1];
    if (indexPath.section == 1){
        if (!_isOrder){
            EmployeeDetailViewController* vc = [[EmployeeDetailViewController alloc]init];
            vc.type = 1;
            vc.employeeId = [NSString stringWithFormat:@"%@",self.dataInfo[@"userinfo"][@"userid"]];
            [self.navigationController pushViewController:vc animated:1];
        }else{
            
            NIMSession *session = [NIMSession session:[NSString stringWithFormat:@"%@",self.dataInfo[@"info"][@"invitecode"]] type:NIMSessionTypeP2P];
            ChatViewController *vc = [[ChatViewController alloc] initWithSession:session];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

#pragma mark - otherDelegate/DataSource

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return NO;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceivePress:(UIPress *)press {
    return NO;
}
//当用户按下return去键盘
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
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
