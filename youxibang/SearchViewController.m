//
//  SearchViewController.m
//  youxibang
//
//  Created by y on 2018/1/19.
//

#import "SearchViewController.h"
#import "SearchTableViewCell.h"
#import "EmployeeDetailViewController.h"
@interface SearchViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (nonatomic,strong) UITextField* tf;
@property (nonatomic,strong) UIButton* searchBtn;
@property (nonatomic,strong) NSMutableArray* dataAry;
@property (nonatomic,assign)int currentPage;
@property (nonatomic,assign)BOOL isHistoryRecord;//是否显示历史记录
@property (nonatomic,strong)NSMutableArray* historyRecord;//历史记录列表
@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.frame = CGRectMake(0, StatusBarHeight+44, SCREEN_WIDTH, SCREEN_HEIGHT - (StatusBarHeight+44));
    self.tableView.showsVerticalScrollIndicator = NO;
    self.currentPage = 1;
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshFooter)];
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //头部view
    UIView* hv = [EBUtility viewfrome:CGRectMake(0, 0, SCREEN_WIDTH, StatusBarHeight+44) andColor:[UIColor groupTableViewBackgroundColor] andView:self.view];
    UIView* searchView = [EBUtility viewfrome:CGRectMake(10, StatusBarHeight-20+25, SCREEN_WIDTH - 70, 32) andColor:[UIColor whiteColor] andView:hv];
    searchView.layer.cornerRadius = 5;
    searchView.layer.masksToBounds = NO;
    UIImageView* img = [EBUtility imgfrome:CGRectMake(10, 7, 16, 16) andImg:[UIImage imageNamed:@"ico_search"] andView:searchView];
    UITextField* tf = [EBUtility textFieldfrome:CGRectMake(30, 6, searchView.width - img.width - 20, 20) andText:@"搜索达人昵称" andColor:[UIColor whiteColor] andView:searchView];
    self.tf = tf;
    tf.delegate = self;
    tf.returnKeyType = UIReturnKeySearch;
    UIButton* sBtn = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH - 60, StatusBarHeight-20+25, 60, 32) andText:@"取消" andColor:Nav_color andimg:nil andView:hv];
    [sBtn addTarget:self action:@selector(searchEmployee:) forControlEvents:UIControlEventTouchUpInside];
    self.searchBtn = sBtn;
    //默认显示历史记录
    self.isHistoryRecord = YES;
    
    self.historyRecord = [[[NSUserDefaults standardUserDefaults] objectForKey:@"historyRecord"] mutableCopy];
    ScrollViewContentInsetAdjustmentNever(self, self.tableView);
}
- (NSMutableArray*)dataAry{
    if (!_dataAry){
        _dataAry = [NSMutableArray array];
    }
    return _dataAry;
}
- (NSMutableArray*)historyRecord{
    if (!_historyRecord){
        _historyRecord = [NSMutableArray array];
    }
    return _historyRecord;
}
-(void)refreshHead{
    self.currentPage = 1;
    [self searchData];
    [self.tableView.mj_header endRefreshing];
}
-(void)refreshFooter{
    self.currentPage ++;
    [self searchData];
    [self.tableView.mj_footer endRefreshing];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}
- (void)searchEmployee:(UIButton*)sender {
    [self.tf resignFirstResponder];
    [self.navigationController popViewControllerAnimated:1];
}
//搜索
- (void)searchData{
    self.isHistoryRecord = NO;
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setObject:self.tf.text forKey:@"keyword"];
    [dict setObject:[NSString stringWithFormat:@"%d",self.currentPage] forKey:@"p"];
    
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Gamebaby/searchbabylist.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            
            if (code == 1) {
                if (self.currentPage == 1) {
                    self.dataAry = object[@"data"];
                }
                else {
                    [self.dataAry addObjectsFromArray:object[@"data"]];
                }
                [self.tableView reloadData];
            }else if (code == 2) {
                [SVProgressHUD showErrorWithStatus:msg];
                self.isHistoryRecord = YES;
                [self.tableView reloadData];
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
//清除历史记录
- (void)clearHistory{
    [self.historyRecord removeAllObjects];
    [[NSUserDefaults standardUserDefaults] setObject:self.historyRecord forKey:@"historyRecord"];
    [self.tableView reloadData];
}

#pragma mark - tableViewDelegate/DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (!self.isHistoryRecord){
        if (_dataAry.count > 0){
            return _dataAry.count;
        }
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.isHistoryRecord){
        return self.historyRecord.count + 2;
    }
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (_dataAry.count == 0){
        if (section == 0){
            return 50;
        }
    }
    return 10;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    return [UIView new];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!self.isHistoryRecord){//搜索到的信息cell
        if (_dataAry.count > 0){
            SearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchTableViewCell"];
            if (!cell) {
                cell = [[SearchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SearchTableViewCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            [cell setViewWithDic:self.dataAry[indexPath.section] withType:0];
            return cell;
        }
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.row == 0){
        cell.textLabel.text = @"历史搜索";
        cell.textLabel.textColor = [UIColor grayColor];
    }else if (indexPath.row == self.historyRecord.count + 1){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellLast"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellLast"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
        cell.textLabel.text = @"清除历史记录";
        cell.textLabel.textColor = [UIColor grayColor];
        cell.textLabel.width = SCREEN_WIDTH;
        cell.textLabel.textAlignment = 1;
        cell.textLabel.font = [UIFont systemFontOfSize:12];
        return cell;
    }else{
        cell.textLabel.text = self.historyRecord[indexPath.row - 1];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isHistoryRecord){//点击清除历史记录
        if (indexPath.row == self.historyRecord.count + 1){
            [self clearHistory];
        }else if (indexPath.row > 0 ){//点击历史记录搜索
            self.tf.text = self.historyRecord[indexPath.row - 1];
            [self refreshHead];
        }
    }else{
        if (self.dataAry.count > 0){//跳转
            EmployeeDetailViewController* vc = [[EmployeeDetailViewController alloc]init];
            vc.employeeId = self.dataAry[indexPath.section][@"userid"];
            [self.navigationController pushViewController:vc animated:1];
        }
    }

}

#pragma mark - otherDelegate/DataSource

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    [self.historyRecord insertObject:self.tf.text atIndex:0];
    [[NSUserDefaults standardUserDefaults] setObject:self.historyRecord forKey:@"historyRecord"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self refreshHead];
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    self.isHistoryRecord = YES;
    [self.tableView reloadData];
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
