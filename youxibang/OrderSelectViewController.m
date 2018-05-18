//
//  OrderSelectViewController.m
//  youxibang
//
//  Created by y on 2018/1/24.
//

#import "OrderSelectViewController.h"
#import "SearchTableViewCell.h"
#import "PayOrderViewController.h"

@interface OrderSelectViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)NSMutableArray* dataAry;
@property(nonatomic,assign)int currentPage;
@end

@implementation OrderSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"选择达人";
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshHead)];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshFooter)];
    
    [self downloadData];
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

    [self.dataAry removeAllObjects];
    [self downloadData];
    [self.tableView.mj_header endRefreshing];
}
-(void)refreshFooter{

    [self.dataAry removeAllObjects];
    [self downloadData];
    [self.tableView.mj_footer endRefreshing];

}

- (void)downloadData{
    if (!self.orderId){
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"错误的订单号" andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
        [self.navigationController popViewControllerAnimated:1];
    }
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setObject:UserModel.sharedUser.userid forKey:@"userid"];
    [dict setObject:self.orderId forKey:@"id"];
    
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Parttime/selectbabylist.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            
            if (code == 1) {
                [self.dataAry addObjectsFromArray:object[@"data"]];
                [self.tableView reloadData];
            }else{
                [SVProgressHUD showErrorWithStatus:msg];
                [self.tableView reloadData];
            }
        }
        
    } failoperation:^(NSError *error) {
        
        [SVProgressHUD dismiss];
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络信号差，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[SearchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    [cell setViewWithDic:self.dataAry[indexPath.row] withType:2];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //弹起确认支付的alert
    CustomAlertView* alert = [[CustomAlertView alloc]initWithCustomerDic:self.dataAry[indexPath.row]];
    alert.resultIndex = ^(NSInteger index){
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PayOrderViewController* vc = [sb instantiateViewControllerWithIdentifier:@"po"];
        vc.type = NSStringFromClass([self class]);
        vc.orderId = [NSString stringWithFormat:@"%@",self.dataAry[indexPath.row][@"rid"]];
        [self.navigationController pushViewController:vc animated:1];
    };
    [alert showAlertView];
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
