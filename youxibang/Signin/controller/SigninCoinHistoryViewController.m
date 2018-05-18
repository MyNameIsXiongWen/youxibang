//
//  SigninCoinHistoryViewController.m
//  youxibang
//
//  Created by jiazhuo1 on 2018/5/2.
//

#import "SigninCoinHistoryViewController.h"
#import "SigninCoinTableViewCell.h"

static NSString *const COIN_TABLEVIEW_ID = @"coin_tableview_id";
@interface SigninCoinHistoryViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) NSMutableArray *coinArray;
@property (nonatomic,assign) int currentPage;

@end

@implementation SigninCoinHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"金币记录";
    self.currentPage = 1;
    self.tableview.rowHeight = 65;
    [self.tableview registerNib:[UINib nibWithNibName:@"SigninCoinTableViewCell" bundle:nil] forCellReuseIdentifier:COIN_TABLEVIEW_ID];
    self.tableview.tableFooterView = UIView.new;
    self.tableview.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshHead)];
    self.tableview.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshFooter)];
    [self getCoinHistoryRequest];
}

- (void)getCoinHistoryRequest {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    NSDictionary *dic = @{@"page":[NSString stringWithFormat:@"%d",self.currentPage],
                          @"token":UserModel.sharedUser.token};
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@member/gold_bill",HttpURLString] Paremeters:dic successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            if (code == 1) {
                if (self.currentPage == 1) {
                    self.coinArray = object[@"data"];
                }
                else {
                    [self.coinArray addObjectsFromArray:object[@"data"]];
                }
                [self.tableview reloadData];
            }else{
                [SVProgressHUD showErrorWithStatus:msg];
            }
        }
    } failoperation:^(NSError *error) {
        [SVProgressHUD dismiss];
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络信号差，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
    }];
}

#pragma mark - collectionview refresh
//头部刷新方法
- (void)refreshHead {
    self.currentPage = 1;
    [self getCoinHistoryRequest];
    [self.tableview.mj_header endRefreshing];
}
//尾部刷新方法
- (void)refreshFooter {
    self.currentPage ++;
    [self getCoinHistoryRequest];
    [self.tableview.mj_footer endRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.coinArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SigninCoinTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:COIN_TABLEVIEW_ID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *dic = self.coinArray[indexPath.row];
    cell.infoLabel.text = dic[@"remark"];
    cell.timeLabel.text = dic[@"time"];
    if ([dic[@"type"] isEqualToString:@"收入"]) {
        cell.valueChangedLabel.text = [NSString stringWithFormat:@"+%@",dic[@"gold"]];
    }
    else {
        cell.valueChangedLabel.text = [NSString stringWithFormat:@"-%@",dic[@"gold"]];
    }
    
    return cell;
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
