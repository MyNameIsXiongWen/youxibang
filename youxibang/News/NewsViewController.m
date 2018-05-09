//
//  NewsViewController.m
//  youxibang
//
//  Created by jiazhuo1 on 2018/4/24.
//

#import "NewsViewController.h"
#import "NewsModel.h"
#import "NewsTableViewCell.h"
#import "DSWebViewController.h"
#import "NewsDetailViewController.h"

static NSString *const NEWS_TABLEVIEW_ID = @"news_tableview_id";
@interface NewsViewController () <UITableViewDelegate, UITableViewDataSource, SDCycleScrollViewDelegate>

@property (nonatomic,assign) int currentPage;
@property (nonatomic,copy) NSString *type;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) UITableView *tableview;
@property (strong, nonatomic) SDCycleScrollView *cycleScrollView;
@property (nonatomic, strong) NSMutableArray* bannerAry;

@end

@implementation NewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.currentPage = 1;
    self.type = @"1";
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-TabbarHeight) style:UITableViewStylePlain];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.rowHeight = 112;
    self.tableview.tableFooterView = UIView.new;
    self.tableview.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshHead)];
    self.tableview.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshFooter)];
    self.tableview.tableHeaderView = [self configTableViewHeaderView];
    [self.view addSubview:self.tableview];
    [self.tableview registerNib:[UINib nibWithNibName:@"NewsTableViewCell" bundle:nil] forCellReuseIdentifier:NEWS_TABLEVIEW_ID];
    
    [self configSegmentControl];
    [self getNewsListRequest];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)configSegmentControl {
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:@[@"新闻资讯",@"招聘主播"]];
    segment.selectedSegmentIndex = 0;
    NSDictionary *selecteddic = @{NSForegroundColorAttributeName:UIColor.whiteColor};
    [segment setTitleTextAttributes:selecteddic forState:UIControlStateSelected];
    NSDictionary *normaldic = @{NSForegroundColorAttributeName:[UIColor colorFromHexString:@"457fea"]};
    [segment setTitleTextAttributes:normaldic forState:UIControlStateNormal];
    [segment addTarget:self action:@selector(selectSegment:) forControlEvents:UIControlEventValueChanged];
    segment.tintColor = [UIColor colorFromHexString:@"457fea"];
    self.navigationItem.titleView = segment;
}

- (void)selectSegment:(UISegmentedControl *)segment {
    if (segment.selectedSegmentIndex == 0) {
        self.type = @"1";
    }
    else {
        self.type = @"2";
    }
    self.currentPage = 1;
    [self getNewsListRequest];
}

- (UIView *)configTableViewHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 175)];
    headerView.backgroundColor = UIColor.whiteColor;
    NSMutableArray* ary = [NSMutableArray array];
    for (NSDictionary* i in self.bannerAry){
        [ary addObject:i[@"adimg"]];
    }
    self.cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 175) imageNamesGroup:ary];
    self.cycleScrollView.infiniteLoop = YES;
    self.cycleScrollView.placeholderImage = [UIImage imageNamed:@"placeholder_banner"];
    self.cycleScrollView.delegate = self;
    self.cycleScrollView.hideBkgView = YES;
    self.cycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleClassic;
    [headerView addSubview:self.cycleScrollView];
    return headerView;
}

//下载数据的方法
- (void)getNewsListRequest {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    NSDictionary *dic = @{@"page":[NSString stringWithFormat:@"%d",self.currentPage],
                          @"type":self.type};
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@article/get_list",HttpURLString] Paremeters:dic successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            if (code == 1) {
                if (self.currentPage == 1) {
                    self.bannerAry = object[@"data"][@"ad"];
                    NSMutableArray* ary = [NSMutableArray array];
                    for (NSDictionary* i in self.bannerAry){
                        [ary addObject:i[@"adimg"]];
                    }
                    self.cycleScrollView.imageURLStringsGroup = ary;
                    self.dataArray = [NewsModel mj_objectArrayWithKeyValuesArray:object[@"data"][@"article"]];
                }
                else {
                    [self.dataArray addObjectsFromArray:[NewsModel mj_objectArrayWithKeyValuesArray:object[@"data"][@"article"]]];
                }
                [self.tableview reloadData];
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

#pragma mark - collectionview refresh
//头部刷新方法
- (void)refreshHead {
    self.currentPage = 1;
    [self getNewsListRequest];
    [self.tableview.mj_header endRefreshing];
}
//尾部刷新方法
- (void)refreshFooter {
    self.currentPage ++;
    [self getNewsListRequest];
    [self.tableview.mj_footer endRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - tableviewDelegate/DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewsModel *model = self.dataArray[indexPath.row];
    NewsTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:NEWS_TABLEVIEW_ID];
    [cell.coverImageView sd_setImageWithURL:[NSURL URLWithString:model.thumb] placeholderImage:[UIImage imageNamed:@"placeholder_news"]];
    cell.coverImageView.layer.masksToBounds = YES;
    cell.titleLabel.text = model.title;
    cell.readCountLabel.text = [NSString stringWithFormat:@"阅读数%@",model.click];
    cell.timeLabel.text = model.publish_time;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NewsModel *model = self.dataArray[indexPath.row];
    model.click = [NSString stringWithFormat:@"%d",model.click.intValue + 1];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    NewsDetailViewController *detailCon = [NewsDetailViewController new];
    detailCon.newsModel = model;
    detailCon.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailCon animated:YES];
}

#pragma mark - otherDelegate
//轮播图片点击事件
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
    if ([NSString stringWithFormat:@"%@",self.bannerAry[index][@"link_lock"]].integerValue == 1){
        DSWebViewController* vc = [[DSWebViewController alloc] initWithURLSting: [NSString stringWithFormat:@"%@",self.bannerAry[index][@"detail"]]];
        vc.title = [NSString stringWithFormat:@"%@",self.bannerAry[index][@"ad_name"]];
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
