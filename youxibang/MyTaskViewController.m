//
//  MyTaskViewController.m
//  youxibang
//
//  Created by y on 2018/2/6.
//

#import "MyTaskViewController.h"
#import "TaskTableViewCell.h"
#import "OrderSelectViewController.h"
#import "OrderDetailViewController.h"
#import "PayOrderViewController.h"

@interface MyTaskViewController ()<UITableViewDelegate,UITableViewDataSource,TaskTableViewCellDelegate>
@property(nonatomic,strong) NSMutableArray* dataAry;
@property(nonatomic,assign)int currentPage;//页码
@property(nonatomic,strong)UIView* placeHoldView;
@end

@implementation MyTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.tableFooterView = [UIView new];
    self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.title = @"我的任务";
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshHead)];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshFooter)];
    self.tableView.tableFooterView = [UIView new];
    self.currentPage = 1;

    self.placeHoldView = [EBUtility viewfrome:self.view.bounds andColor:[UIColor whiteColor] andView:nil];
    UIImageView* img = [EBUtility imgfrome:CGRectMake(0, 0, 220, 235) andImg:[UIImage imageNamed:@"kong_news"] andView:self.placeHoldView];
    img.center = CGPointMake(self.placeHoldView.width/2, self.placeHoldView.height/4);
    UILabel* lab = [EBUtility labfrome:CGRectMake(0, 0, 220, 20) andText:@"你还没有任务，快邀请小伙伴们来玩吧" andColor:[UIColor darkGrayColor] andView:self.placeHoldView];
    lab.font = [UIFont systemFontOfSize:12];
    lab.textAlignment = 1;
    lab.center = CGPointMake(self.placeHoldView.width/2, self.placeHoldView.height/4 + 140);
    self.placeHoldView.hidden = YES;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refreshHead];
}
-(void)refreshHead{
    self.currentPage = 1;
    [self.dataAry removeAllObjects];
    [self.tableView reloadData];
    [self downloadData];
    [self.tableView.mj_header endRefreshing];
}
-(void)refreshFooter{
    self.currentPage ++;
    [self downloadData];
    [self.tableView.mj_footer endRefreshing];

}

- (NSMutableArray*)dataAry{
    if (!_dataAry){
        _dataAry = [NSMutableArray array];
    }
    return _dataAry;
}
//下载信息列表
- (void)downloadData{
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[DataStore sharedDataStore].token forKey:@"token"];
    [dict setObject:[NSString stringWithFormat:@"%d",self.currentPage] forKey:@"p"];
    [dict setObject:@"10" forKey:@"psize"];
  
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Parttime/mypartlist.html",HttpURLString] Paremeters:dict successOperation:^(id object) {

        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            
            if (code == 1) {
                self.placeHoldView.hidden = YES;
                [self.dataAry addObjectsFromArray:object[@"data"]];
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
//取消任务接口   type 1 雇主取消任务    2 宝贝取消抢单
- (void)cancelTask:(NSString*)taskId WithType:(NSString*)type{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[DataStore sharedDataStore].token forKey:@"token"];
    [dict setObject:taskId forKey:@"id"];
    [dict setObject:type forKey:@"type"];
    
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Parttime/canceltask.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataAry.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.placeHoldView.hidden == NO){
        return SCREEN_HEIGHT;
    }
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.placeHoldView.hidden == NO){
        return self.placeHoldView;
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[TaskTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.row = indexPath.row;//记录行数，从delegate中回调需要
    cell.delegate = self;
    [cell setViewWithDic:self.dataAry[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([NSString stringWithFormat:@"%@",self.dataAry[indexPath.row][@"partstatus"]].intValue == 0){
        return;
    }
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    OrderDetailViewController* vc = [sb instantiateViewControllerWithIdentifier:@"od"];
    vc.itemId = [NSString stringWithFormat:@"%@",self.dataAry[indexPath.row][@"id"]];
    [self.navigationController pushViewController:vc animated:1];
}

#pragma mark - otherDelegate/DataSource
- (void)selectSomeThing:(NSString *)name AndRow:(NSInteger)row{
    if ([name isEqualToString:@"取消任务"]){//二次确认
        CustomAlertView* alert = [[CustomAlertView alloc]initWithTitle:@"温馨提示" Text:@"是否确定取消任务？" AndType:2];
        alert.resultIndex = ^(NSInteger index) {
            [self cancelTask:[NSString stringWithFormat:@"%@",self.dataAry[row][@"id"]] WithType:@"1"];
        };
        [alert showAlertView];
        
    }else if ([name isEqualToString:@"选择达人"]){
        OrderSelectViewController* vc = [[OrderSelectViewController alloc]init];
        vc.orderId = [NSString stringWithFormat:@"%@",self.dataAry[row][@"id"]];
        [self.navigationController pushViewController:vc animated:1];
    }else if ([name isEqualToString:@"查看订单"]){
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        OrderDetailViewController* vc = [sb instantiateViewControllerWithIdentifier:@"od"];
        if ([EBUtility isBlankString:[NSString stringWithFormat:@"%@",self.dataAry[row][@"order_sn"]]]){
            vc.itemId = [NSString stringWithFormat:@"%@",self.dataAry[row][@"order_sn"]];
            vc.isOrder = YES;
            [self.navigationController pushViewController:vc animated:1];
        }
    }else if ([name isEqualToString:@"去付款"]){
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PayOrderViewController* vc = [sb instantiateViewControllerWithIdentifier:@"po"];
        vc.type = NSStringFromClass([self class]);
        vc.orderId = [NSString stringWithFormat:@"%@",self.dataAry[row][@"id"]];
        [self.navigationController pushViewController:vc animated:1];
    }else if ([name isEqualToString:@"取消抢单"]){//二次确认
        CustomAlertView* alert = [[CustomAlertView alloc]initWithTitle:@"温馨提示" Text:@"是否确定取消抢单？" AndType:2];
        alert.resultIndex = ^(NSInteger index) {
            [self cancelTask:[NSString stringWithFormat:@"%@",self.dataAry[row][@"orderid"]] WithType:@"2"];
        };
        [alert showAlertView];
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
