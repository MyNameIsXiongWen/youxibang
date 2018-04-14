//
//  BalanceDetailViewController.m
//  youxibang
//
//  Created by y on 2018/2/1.
//

#import "BalanceDetailViewController.h"

@interface BalanceDetailViewController ()<UITableViewDelegate,UITableViewDataSource,ScrollTitleViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,strong)NSMutableArray* dataAry;
@property(nonatomic,assign)int currentPage;
@property(nonatomic,assign)NSInteger type;
@end

@implementation BalanceDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"余额明细";
    ScrollTitleView* view = [[ScrollTitleView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 35)];
    [view initCellWithTitles:@[@"全部",@"收入",@"支出"] Tag:0 WithColor:Nav_color];
    view.delegate = self;
    [self.view addSubview:view];
    self.tableView.tableFooterView = [UIView new];
    self.currentPage = 1;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshHead)];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshFooter)];
    self.tableView.tableFooterView = [UIView new];
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
    [dict setObject:@"10" forKey:@"psize"];
    [dict setObject:[NSString stringWithFormat:@"%ld",self.type] forKey:@"type"];
    
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Member/rwdetailed.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
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
//                [SVProgressHUD showErrorWithStatus:msg];
            }
        }
        
    } failoperation:^(NSError *error) {
        
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
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (self.dataAry.count > indexPath.section){
        UIImageView* img = [cell viewWithTag:1];
        
        if ([NSString stringWithFormat:@"%@",self.dataAry[indexPath.section][@"flag"]].intValue == 1){
            img.image = [UIImage imageNamed:@"shou"];
        }else if ([NSString stringWithFormat:@"%@",self.dataAry[indexPath.section][@"flag"]].intValue == 2){
            img.image = [UIImage imageNamed:@"ti"];
            
        }
        
        UILabel* time = [cell viewWithTag:2];
        time.text = [NSString stringWithFormat:@"%@",self.dataAry[indexPath.section][@"addtime"]];
        
        UILabel* title = [cell viewWithTag:3];
        title.text = [NSString stringWithFormat:@"%@",self.dataAry[indexPath.section][@"title"]];
        
        UILabel* money = [cell viewWithTag:4];
        money.text = [NSString stringWithFormat:@"%@",self.dataAry[indexPath.section][@"money"]];
        
        UILabel* content = [cell viewWithTag:5];
        content.text =[NSString stringWithFormat:@"%@",self.dataAry[indexPath.section][@"remark"]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - otherDelegate/DataSource
-(void)touchTitle:(NSInteger)tag{
    self.type = tag;
    [self refreshHead];
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
