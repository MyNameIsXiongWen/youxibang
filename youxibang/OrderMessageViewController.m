//
//  OrderMessageViewController.m
//  youxibang
//
//  Created by y on 2018/1/24.
//

#import "OrderMessageViewController.h"
#import "OrderDetailViewController.h"

@interface OrderMessageViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,strong)NSMutableArray* dataAry;
@property(nonatomic,assign)int currentPage;
@property(nonatomic,strong)UIView* placeHoldView;//为空时占位图
@end

@implementation OrderMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"订单消息";
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshHead)];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshFooter)];
    self.currentPage = 1;
    [self downloadData];
    
    self.placeHoldView = [EBUtility viewfrome:self.view.bounds andColor:[UIColor whiteColor] andView:nil];
    UIImageView* img = [EBUtility imgfrome:CGRectMake(0, 0, 220, 235) andImg:[UIImage imageNamed:@"kong_news"] andView:self.placeHoldView];
    img.center = CGPointMake(self.placeHoldView.width/2, self.placeHoldView.height/4);
    UILabel* lab = [EBUtility labfrome:CGRectMake(0, 0, 220, 20) andText:@"暂无订单消息" andColor:[UIColor darkGrayColor] andView:self.placeHoldView];
    lab.font = [UIFont systemFontOfSize:12];
    lab.textAlignment = 1;
    lab.center = CGPointMake(self.placeHoldView.width/2, self.placeHoldView.height/4 + 140);
    self.placeHoldView.hidden = YES;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSMutableArray*)dataAry{
    if (!_dataAry){
        _dataAry = [NSMutableArray array];
    }
    return _dataAry;
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

- (void)downloadData{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setObject:[DataStore sharedDataStore].token forKey:@"token"];
    [dict setObject:[NSString stringWithFormat:@"%d",self.currentPage] forKey:@"p"];
    
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Message/ordermessage.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            
            if (code == 1) {
                [self.dataAry addObjectsFromArray: object[@"data"]];
                self.placeHoldView.hidden = YES;
                [self.tableView reloadData];
            }else{
                if (self.currentPage == 1){
//                    [SVProgressHUD showErrorWithStatus:msg];
                    self.placeHoldView.hidden = NO;
                }
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"omcell"];
    
    UILabel* pulishtime = [cell viewWithTag:1];
    pulishtime.text = [NSString stringWithFormat:@"%@",self.dataAry[indexPath.row][@"pulishtime"]];
    UILabel* tname = [cell viewWithTag:2];
    tname.text = [NSString stringWithFormat:@"订单：%@",self.dataAry[indexPath.row][@"tname"]];
    UILabel* game_name = [cell viewWithTag:4];
    game_name.text = [NSString stringWithFormat:@"%@",self.dataAry[indexPath.row][@"game_name"]];
    UILabel* desc = [cell viewWithTag:5];
    desc.text = [NSString stringWithFormat:@"%@",self.dataAry[indexPath.row][@"desc"]];
    UILabel* stime = [cell viewWithTag:6];
    stime.text = [NSString stringWithFormat:@"%@ %@",self.dataAry[indexPath.row][@"stime"],self.dataAry[indexPath.row][@"hours"]];
    
    UIImageView* img = [cell viewWithTag:3];
    [img sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.dataAry[indexPath.row][@"image"]]]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    OrderDetailViewController* vc = [sb instantiateViewControllerWithIdentifier:@"od"];
    if ([NSString stringWithFormat:@"%@",self.dataAry[indexPath.row][@"type"]].integerValue == 1){//跳转订单
        vc.itemId = [NSString stringWithFormat:@"%@",self.dataAry[indexPath.row][@"order_sn"]];
        vc.isOrder = YES;
    }else if ([NSString stringWithFormat:@"%@",self.dataAry[indexPath.row][@"type"]].integerValue == 3){//跳转任务
        vc.itemId = [NSString stringWithFormat:@"%@",self.dataAry[indexPath.row][@"order_id"]];
        
    }
    
    [self.navigationController pushViewController:vc animated:1];
}

#pragma mark - otherDelegate/DataSource
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
