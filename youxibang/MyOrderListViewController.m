//
//  MyOrderListViewController.m
//  youxibang
//
//  Created by y on 2018/2/7.
//

#import "MyOrderListViewController.h"
#import "OrderListTableViewCell.h"
#import "ReVokeViewController.h"
#import "AwardViewController.h"
#import "EvaluateViewController.h"
#import "UpDataProgressViewController.h"
#import "OrderDetailViewController.h"
#import "PayOrderViewController.h"

@interface MyOrderListViewController ()<UITableViewDelegate,UITableViewDataSource,OrderListTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,strong) NSMutableArray* dataAry;
@property(nonatomic,assign)int currentPage;
@property(nonatomic,strong)UIView* placeHoldView;
@property(nonatomic,assign)NSInteger type;//0-全部，1-未完成，2-已结束
@end

@implementation MyOrderListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"订单中心";
    self.tableView.tableFooterView = [UIView new];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshHead)];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshFooter)];
    
    //筛选按钮
    UIView* rv = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
    UIButton* btn = [EBUtility greenBtnfrome:CGRectMake(0, 0, 20, 20) andText:@"" andColor:[UIColor colorFromHexString:@"333333"] andimg:[UIImage imageNamed:@"ico_order_set"] andView:rv];
    
    btn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [btn addTarget:self action:@selector(siftInfo:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rv];
    self.currentPage = 1;
    
    //占位图
    self.placeHoldView = [EBUtility viewfrome:self.view.bounds andColor:[UIColor whiteColor] andView:self.view];
    UIImageView* img = [EBUtility imgfrome:CGRectMake((SCREEN_WIDTH-310)/2, (SCREEN_HEIGHT-424)/2, 310, 360) andImg:[UIImage imageNamed:@"kong_news"] andView:self.placeHoldView];
    UILabel* lab = [EBUtility labfrome:CGRectMake((SCREEN_WIDTH-310)/2, (SCREEN_HEIGHT-424)/2+335, 310, 20) andText:@"你还没有订单，快邀请小伙伴们来玩吧" andColor:[UIColor darkGrayColor] andView:self.placeHoldView];
    lab.font = [UIFont systemFontOfSize:12];
    lab.textAlignment = 1;
    self.placeHoldView.hidden = YES;
    [self.view bringSubviewToFront:self.placeHoldView];
    [self refreshHead];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self refreshHead];
}

- (void)siftInfo:(UIButton*)sender {
    CustomAlertView* alert = [[CustomAlertView alloc] initWithSiftList];
    alert.resultIndex = ^(NSInteger index) {
        self.type = index;
        [self refreshHead];
    };
    [alert showAlertView];
}

-(void)refreshHead {
    self.currentPage = 1;
    [self downloadData];
    [self.tableView.mj_header endRefreshing];
}
-(void)refreshFooter {
    self.currentPage ++;
    [self downloadData];
    [self.tableView.mj_footer endRefreshing];
    
}

- (NSMutableArray*)dataAry {
    if (!_dataAry){
        _dataAry = [NSMutableArray array];
    }
    return _dataAry;
}
//下载数据
- (void)downloadData {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[DataStore sharedDataStore].token forKey:@"token"];
    [dict setObject:[NSString stringWithFormat:@"%ld",(long)self.type] forKey:@"type"];
    [dict setObject:[NSString stringWithFormat:@"%d",self.currentPage] forKey:@"p"];
    [dict setObject:@"10" forKey:@"psize"];
    
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Orders/orderlist.html",HttpURLString] Paremeters:dict successOperation:^(id object) {

        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            
            if (code == 1) {
                self.placeHoldView.hidden = YES;
                if (self.currentPage == 1) {
                    self.dataAry = [NSMutableArray arrayWithArray:object[@"data"]];
                }
                else {
                    [self.dataAry addObjectsFromArray:object[@"data"]];
                }
                [self.tableView reloadData];
            }else{
                [SVProgressHUD showErrorWithStatus:msg];
                if (self.currentPage == 1){
                    self.placeHoldView.hidden = NO;
                }
            }
        }
        
    } failoperation:^(NSError *error) {
        self.placeHoldView.hidden = NO;

        [SVProgressHUD showErrorWithStatus:@"网络信号差，请稍后再试"];
    }];
}
//聚合操作  type 1、雇主催单，2、撤销申请，3、同意退单，4、撤销仲裁，5、（未开始）取消订单，6、拒绝退单，7、申请验收
- (void)getRequestWithType:(NSString*)type AndOrderSn:(NSString*)orderSn {
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
                [self refreshHead];
            }else{
                [SVProgressHUD showErrorWithStatus:msg];
            }
        }
        
    } failoperation:^(NSError *error) {
        self.placeHoldView.hidden = NO;
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        [SVProgressHUD showErrorWithStatus:@"网络信号差，请稍后再试"];
    }];
}


#pragma mark - tableViewDelegate/DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataAry.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.placeHoldView.hidden == NO && section == 0){
        return SCREEN_HEIGHT;
    }
    return 10;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.placeHoldView.hidden == NO && section == 0){
        return self.placeHoldView;
    }
    return [UIView new];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    OrderListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setViewWithDic:self.dataAry[indexPath.section]];
    cell.row = indexPath.section;
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    OrderDetailViewController* vc = [sb instantiateViewControllerWithIdentifier:@"od"];
    vc.itemId = [NSString stringWithFormat:@"%@",self.dataAry[indexPath.section][@"order_sn"]];

    vc.isOrder = YES;
    [self.navigationController pushViewController:vc animated:1];
}

#pragma mark - otherDelegate/DataSource
- (void)selectSomeThing:(NSString *)name AndRow:(NSInteger)row{
    if ([name isEqualToString:@"取消订单"]){
        CustomAlertView* alert = [[CustomAlertView alloc]initWithTitle:@"温馨提示" Text:@"是否确定取消抢单？" AndType:2];
        alert.resultIndex = ^(NSInteger index) {
            [self getRequestWithType:@"5" AndOrderSn:self.dataAry[row][@"order_sn"]];
        };
        [alert showAlertView];
    }else if ([name isEqualToString:@"催单"]){
        [self getRequestWithType:@"1" AndOrderSn:self.dataAry[row][@"order_sn"]];
    }else if ([name isEqualToString:@"申请取消"]){
        ReVokeViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"rv"];
        vc.type = 1;
        vc.orderId = self.dataAry[row][@"order_sn"];
        if ([NSString stringWithFormat:@"%@",self.dataAry[row][@"is_baby"]].intValue == 1){//宝贝身份
            if ([NSString stringWithFormat:@"%@",self.dataAry[row][@"typeid"]].intValue == 1){//直接向宝贝下单，无需退还保证金
                vc.withdrawOrderType = 1;
            }else{//宝贝抢单的订单，需要退还保证金
                vc.withdrawOrderType = 2;
            }
        }else{//雇主身份
            vc.withdrawOrderType = 0;
        }
        [self.navigationController pushViewController:vc animated:1];
    }else if ([name isEqualToString:@"申请仲裁"]){
        ReVokeViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"rv"];
        vc.type = 2;
        vc.orderId = self.dataAry[row][@"order_sn"];
        [self.navigationController pushViewController:vc animated:1];
    }else if ([name isEqualToString:@"撤销申请"]){
        CustomAlertView* alert = [[CustomAlertView alloc]initWithTitle:@"温馨提示" Text:@"是否确定撤销申请？" AndType:2];
        alert.resultIndex = ^(NSInteger index) {
            [self getRequestWithType:@"2" AndOrderSn:self.dataAry[row][@"order_sn"]];
        };
        [alert showAlertView];
        
    }else if ([name isEqualToString:@"同意退单"]){
        CustomAlertView* alert = [[CustomAlertView alloc]initWithTitle:@"温馨提示" Text:@"是否确定同意退单？" AndType:2];
        alert.resultIndex = ^(NSInteger index) {
            [self getRequestWithType:@"3" AndOrderSn:self.dataAry[row][@"order_sn"]];
        };
        [alert showAlertView];
        
    }else if ([name isEqualToString:@"拒绝退单"]){
        CustomAlertView* alert = [[CustomAlertView alloc]initWithTitle:@"温馨提示" Text:@"是否确定拒绝退单？" AndType:2];
        alert.resultIndex = ^(NSInteger index) {
            [self getRequestWithType:@"6" AndOrderSn:self.dataAry[row][@"order_sn"]];
        };
        [alert showAlertView];
        
    }else if ([name isEqualToString:@"撤销仲裁"]){
        CustomAlertView* alert = [[CustomAlertView alloc]initWithTitle:@"温馨提示" Text:@"是否确定撤销仲裁？" AndType:2];
        alert.resultIndex = ^(NSInteger index) {
            [self getRequestWithType:@"4" AndOrderSn:self.dataAry[row][@"order_sn"]];
        };
        [alert showAlertView];
        
    }else if ([name isEqualToString:@"评价"]){
        EvaluateViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"eva"];
        vc.orderInfo = [NSMutableDictionary dictionaryWithDictionary:self.dataAry[row]];
        [self.navigationController pushViewController:vc animated:1];
    }else if ([name isEqualToString:@"打赏"]){
        AwardViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"avc"];
        vc.orderInfo = [NSMutableDictionary dictionaryWithDictionary:self.dataAry[row]];
        [self.navigationController pushViewController:vc animated:1];
    }else if ([name isEqualToString:@"开始打单"]){
        UpDataProgressViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"udp"];
        vc.orderSn = self.dataAry[row][@"order_sn"];
        vc.type = @"1";
        [self.navigationController pushViewController:vc animated:1];
    }else if ([name isEqualToString:@"上传进度"]){
        UpDataProgressViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"udp"];
        vc.orderSn = self.dataAry[row][@"order_sn"];
        vc.type = @"2";
        [self.navigationController pushViewController:vc animated:1];
    }else if ([name isEqualToString:@"去支付"]){
        PayOrderViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"po"];
        vc.type = @"OrderViewController";
        vc.orderId = [NSString stringWithFormat:@"%@",self.dataAry[row][@"order_id"]];
        [self.navigationController pushViewController:vc animated:1];
    }
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
