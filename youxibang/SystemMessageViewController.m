//
//  SystemMessageViewController.m
//  youxibang
//
//  Created by 戎博 on 2018/2/22.
//

#import "SystemMessageViewController.h"

//这个页面基本和订单消息页面一样
@interface SystemMessageViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,strong)NSMutableArray* dataAry;
@property(nonatomic,assign)int currentPage;
@property(nonatomic,strong)UIView* placeHoldView;
@end

@implementation SystemMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"系统消息";
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshHead)];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshFooter)];
    self.tableView.tableFooterView = [UIView new];
    self.currentPage = 1;
    [self downloadData];
    
    self.placeHoldView = [EBUtility viewfrome:self.view.bounds andColor:[UIColor whiteColor] andView:nil];
    UIImageView* img = [EBUtility imgfrome:CGRectMake(0, 0, 220, 235) andImg:[UIImage imageNamed:@"kong_news"] andView:self.placeHoldView];
    img.center = CGPointMake(self.placeHoldView.width/2, self.placeHoldView.height/4);
    UILabel* lab = [EBUtility labfrome:CGRectMake(0, 0, 220, 20) andText:@"暂无系统消息" andColor:[UIColor darkGrayColor] andView:self.placeHoldView];
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
    [dict setObject:@"10" forKey:@"psize"];
    
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Message/sysmsglist.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
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
                    [SVProgressHUD showErrorWithStatus:msg];
                    self.placeHoldView.hidden = NO;
                }
            }
        }
        
    } failoperation:^(NSError *error) {
        self.placeHoldView.hidden = NO;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"systemcell"];
    
    UILabel* lab1 = [cell viewWithTag:1];
    lab1.text = [NSString stringWithFormat:@"%@",self.dataAry[indexPath.row][@"addtime"]];
    UILabel* lab2 = [cell viewWithTag:2];
    lab2.text = [NSString stringWithFormat:@"%@",self.dataAry[indexPath.row][@"title"]];
    UILabel* lab3 = [cell viewWithTag:3];
    lab3.text = [NSString stringWithFormat:@"%@",self.dataAry[indexPath.row][@"content"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
