//
//  PartTimeViewController.m
//  youxibang
//
//  Created by y on 2018/1/26.
//

#import "PartTimeViewController.h"
#import "PartTimeTableViewCell.h"
#import "SearchTableViewCell.h"
#import "OrderDetailViewController.h"
#import "GameBabyDetailViewController.h"

@interface PartTimeViewController ()<UITableViewDelegate,UITableViewDataSource,SDCycleScrollViewDelegate>
@property (nonatomic,strong)UIView* headerView;
@property (nonatomic,strong)NSMutableArray* bannerAry;//banner列表
@property (nonatomic,strong)NSMutableArray* dataAry;//数据列表
@property (nonatomic,strong)NSMutableArray* gameAry;//游戏列表
@property(nonatomic,assign)int currentPage;//页码
@property(nonatomic,assign)NSString* gid;//游戏id
@property(nonatomic,assign)int orderby;//排序
@property(nonatomic,assign)int pricerange;//价格范围
@property(nonatomic,assign)int sex;//性别
@property(nonatomic,assign)int birth;//生日范围
@end

@implementation PartTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.tableView.tableFooterView = [UIView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - (StatusBarHeight+44));
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshHead)];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshFooter)];
    
    self.title = @"兼职接单";
    self.gid = @"0";
    self.currentPage = 1;
    if (self.ptOrBaby){
        self.title = @"技能达人";
    }
    [self downloadOther];
    [self downloadInfo];
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
- (NSMutableArray*)bannerAry{
    if (!_bannerAry){
        _bannerAry = [NSMutableArray array];
    }
    return _bannerAry;
}
- (NSMutableArray*)gameAry{
    if (!_gameAry){
        _gameAry = [NSMutableArray array];
    }
    return _gameAry;
}
- (void)refreshHead {
    self.currentPage = 1;
    [self downloadInfo];
    [self.tableView.mj_header endRefreshing];
}
- (void)refreshFooter {
    self.currentPage ++;
    [self downloadInfo];
    [self.tableView.mj_footer endRefreshing];
}

//下载banner列表与游戏列表
- (void)downloadOther {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (self.ptOrBaby) {
        [dict setObject:@"3" forKey:@"typeid"];
    }else {
        [dict setObject:@"2" forKey:@"typeid"];
    }
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Currency/bannerlist.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            if (code == 1) {
                self.bannerAry = [NSMutableArray arrayWithArray:object[@"data"]];
                [self.tableView reloadData];
            }
        }
        
    } failoperation:^(NSError *error) {
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络信号差，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
    }];
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Currency/gmlists.html",HttpURLString] Paremeters:nil successOperation:^(id object) {
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            if (code == 1) {
                self.gameAry = [NSMutableArray arrayWithArray:object[@"data"]];
            }
        }
    } failoperation:^(NSError *error) {
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络信号差，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
    }];
}
//下载，筛选
- (void)downloadInfo{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    if (self.ptOrBaby){
//        p＝$页面（必填）
//        psize＝$每页显示条数 0 默认
//        gameid=$游戏id 0 所有
//        sex=$性别 0 所有 1 男 2 女
//        orderby=$排序（非必填） 排序方式 0 默认 1 价格由高到底 2 价格由低到高 3 接单次数由高低 4 接单次数由低到高
//        borth=$生日（非必填）出生日期 0 所有  1 80后 2 90后 3 00后
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:self.gid forKey:@"gameid"];
        [dict setObject:[NSString stringWithFormat:@"%d",self.orderby] forKey:@"orderby"];
        [dict setObject:[NSString stringWithFormat:@"%d",self.birth] forKey:@"borth"];
        [dict setObject:[NSString stringWithFormat:@"%d",self.sex] forKey:@"sex"];
        [dict setObject:[NSString stringWithFormat:@"%d",self.currentPage] forKey:@"p"];
        [dict setObject:@"20" forKey:@"psize"];
        if (self.groupId) {
            [dict setObject:self.groupId forKey:@"group_id"];
        }
        if (UserModel.sharedUser.latitude) {
            [dict setObject:UserModel.sharedUser.latitude forKey:@"lat"];
        }
        if (UserModel.sharedUser.longitude) {
            [dict setObject:UserModel.sharedUser.longitude forKey:@"lon"];
        }
        
        [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Gamebaby/babyslist.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
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
                }else{
                    [[SYPromptBoxView sharedInstance] setPromptViewMessage:msg andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
                    if (self.dataAry.count > 0 && [object[@"data"] count] ==0) {
                        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
                        footerView.backgroundColor = UIColor.clearColor;
                        UILabel *footerLabel = [EBUtility labfrome:footerView.bounds andText:@"然后，就没有然后了～" andColor:[UIColor colorFromHexString:@"444444"] andView:footerView];
                        footerLabel.font = [UIFont systemFontOfSize:11.0];
                        self.tableView.tableFooterView = footerView;
                    }
                    else {
                        self.tableView.tableFooterView = UIView.new;
                    }
                    if ([object[@"data"] count] ==0) {
                        self.tableView.mj_footer.hidden = YES;
                    }
                    else {
                        self.tableView.mj_footer.hidden = NO;
                    }
                }
            }
        } failoperation:^(NSError *error) {
            [SVProgressHUD dismiss];
            [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络信号差，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
        }];
    }else{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:self.gid forKey:@"gid"];
        [dict setObject:[NSString stringWithFormat:@"%d",self.orderby] forKey:@"orderby"];
        [dict setObject:[NSString stringWithFormat:@"%d",self.pricerange] forKey:@"pricerange"];
        [dict setObject:[NSString stringWithFormat:@"%d",self.currentPage] forKey:@"p"];
        [dict setObject:@"10" forKey:@"psize"];
        if (UserModel.sharedUser.latitude) {
            [dict setObject:UserModel.sharedUser.latitude forKey:@"lat"];
        }
        if (UserModel.sharedUser.longitude) {
            [dict setObject:UserModel.sharedUser.longitude forKey:@"lon"];
        }
        
        [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Parttime/partlist.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
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
                }else{
                    [[SYPromptBoxView sharedInstance] setPromptViewMessage:msg andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
                    if (self.dataAry.count > 0 && [object[@"data"] count] ==0) {
                        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
                        footerView.backgroundColor = UIColor.clearColor;
                        UILabel *footerLabel = [EBUtility labfrome:footerView.bounds andText:@"然后，就没有然后了～" andColor:[UIColor colorFromHexString:@"444444"] andView:footerView];
                        footerLabel.font = [UIFont systemFontOfSize:11.0];
                        self.tableView.tableFooterView = footerView;
                    }
                    else {
                        self.tableView.tableFooterView = UIView.new;
                    }
                    if ([object[@"data"] count] ==0) {
                        self.tableView.mj_footer.hidden = YES;
                    }
                    else {
                        self.tableView.mj_footer.hidden = NO;
                    }
                }
            }
        } failoperation:^(NSError *error) {
            [SVProgressHUD dismiss];
            [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络信号差，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
        }];
    }
}
//headerview，避免刷新的时候将其初始化，所以变成属性
- (UIView*)headerView{
    if (!_headerView){
        _headerView = [EBUtility viewfrome:CGRectMake(0, 0, SCREEN_WIDTH, 40) andColor:[UIColor whiteColor] andView:nil];
        NSArray* tAry = @[@"技能名称",@"综合排序",@"价格区间"];
        if (self.ptOrBaby){
            tAry = @[@"综合排序",@"筛选"];
        }
        for (int i = 0; i < tAry.count; i ++){
            YHYButton* btn = [[YHYButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/tAry.count * i, 0, SCREEN_WIDTH/tAry.count, 40) ImageFrame:CGSizeMake(10, 10) TextFont:15 AndType:YHYButtonTypeLeft];
            [btn setTitle:tAry[i] forState:0];
            [btn setTitleColor:[UIColor blackColor] forState:0];
            [btn setTitleColor:Nav_color forState:UIControlStateSelected];
            [btn setImage:[UIImage imageNamed:@"ico_xl"] forState:0];
            [btn setImage:[UIImage imageNamed:@"ico_xl1"] forState:UIControlStateSelected];
            btn.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
            btn.layer.borderWidth = 1;
            btn.tag = i;
            [btn addTarget:self action:@selector(searchCondition:) forControlEvents:UIControlEventTouchUpInside];
            [_headerView addSubview: btn];
        }
    }
    return _headerView;
}
//筛选
- (void)searchCondition:(UIButton*)sender{
    sender.selected = YES;
    if (self.ptOrBaby){
        if (sender.tag == 0){
            NSArray* timeAry = @[@"综合排序",@"价格最高",@"价格最低",@"接单最多",@"接单最少"];
            CustomAlertView* alert = [[CustomAlertView alloc]initWithHeight:([sender.superview convertRect:sender.frame toView:self.view].origin.y + sender.height + StatusBarHeight+44) AndAry:timeAry];
            alert.resultDate = ^(NSString *date) {
                sender.selected = NO;
                [sender setTitle:timeAry[date.intValue] forState:0];
                
                self.orderby = date.intValue;
                [self refreshHead];
            };
            alert.resultRemove = ^(NSString *str) {
                sender.selected = NO;
            };
            [alert showAlertView];
        }else if (sender.tag == 1){
            NSMutableArray* ary = [NSMutableArray arrayWithObject:@"全部"];
            for (NSDictionary* i in self.gameAry){
                [ary addObject:i[@"title"]];
            }
            CustomAlertView* alert = [[CustomAlertView alloc]initWithSiftWithHeight:[sender.superview convertRect:sender.frame toView:self.view].origin.y + sender.height+ StatusBarHeight+44 AndTitleAry:ary];
            alert.resultDate = ^(NSString *date) {
                sender.selected = NO;
                NSArray<NSString*>* temp = [date componentsSeparatedByString:@","];
                self.sex = temp[0].intValue;
                self.birth = temp[1].intValue;
                if ([temp[2] isEqualToString:@"0"]){
                    self.gid = @"0";
                }else{
                    self.gid = self.gameAry[temp[2].intValue - 1][@"id"];
                }
                [self refreshHead];
            };
            alert.resultRemove = ^(NSString *str) {
                sender.selected = NO;
            };
            [alert showAlertView];
        }
    }else{
        if (sender.tag == 0){
            NSMutableArray* ary = [NSMutableArray array];
            for (NSDictionary* i in self.gameAry){
                [ary addObject:i[@"title"]];
            }
            CustomAlertView* alert = [[CustomAlertView alloc]initWithHeight:([sender.superview convertRect:sender.frame toView:self.view].origin.y + sender.height + StatusBarHeight+44) AndAry:ary];
            alert.resultDate = ^(NSString *date) {
                sender.selected = NO;
                [sender setTitle:[NSString stringWithFormat:@"%@",self.gameAry[date.integerValue][@"title"]] forState:0];
                self.gid = [NSString stringWithFormat:@"%@",self.gameAry[date.integerValue][@"id"]];
                [self refreshHead];
            };
            alert.resultRemove = ^(NSString *str) {
                sender.selected = NO;
            };
            [alert showAlertView];
        }else if (sender.tag == 1){
            NSArray* timeAry = @[@"综合排序",@"价格最高",@"价格最低",@"时间最多",@"时间最少"];
            CustomAlertView* alert = [[CustomAlertView alloc]initWithHeight:([sender.superview convertRect:sender.frame toView:self.view].origin.y + sender.height+ StatusBarHeight+44) AndAry:timeAry];
            alert.resultDate = ^(NSString *date) {
                sender.selected = NO;
                [sender setTitle:timeAry[date.intValue] forState:0];
                self.orderby = date.intValue;
                [self refreshHead];
            };
            alert.resultRemove = ^(NSString *str) {
                sender.selected = NO;
            };
            [alert showAlertView];
        }else if (sender.tag == 2){
            NSArray* priceAry = @[@"1-100",@"101-300",@"301-500",@"500以上",@"无限制"];
            CustomAlertView* alert = [[CustomAlertView alloc]initWithHeight:([sender.superview convertRect:sender.frame toView:self.view].origin.y + sender.height+ StatusBarHeight+44) AndAry:priceAry];
            alert.resultDate = ^(NSString *date) {
                sender.selected = NO;
                [sender setTitle:priceAry[date.intValue] forState:0];
                self.pricerange = date.intValue + 1;
                [self refreshHead];
            };
            alert.resultRemove = ^(NSString *str) {
                sender.selected = NO;
            };
            [alert showAlertView];
        }
    }
}
#pragma mark - tableViewDelegate/DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0){
        return 1;
    }
    return self.dataAry.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1){
        return 40;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (section == 1){

        return self.headerView;
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            return 375;
        }
        return 175;
    }
    return UITableViewAutomaticDimension;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){//banner cell
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"banner"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"banner"];
            SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 175) imageNamesGroup:nil];
            cycleScrollView.placeholderImage = [UIImage imageNamed:@"placeholder_banner"];
            cycleScrollView.infiniteLoop = YES;
            cycleScrollView.hideBkgView = YES;
            cycleScrollView.delegate = self;
            cycleScrollView.tag = 100;
            cycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleClassic;
            [cell.viewForLastBaselineLayout addSubview:cycleScrollView];
        }
        if (self.bannerAry.count > 0){
            SDCycleScrollView *cycleScrollView = [cell.viewForLastBaselineLayout viewWithTag:100];
            NSMutableArray* ary = [NSMutableArray array];
            for (NSDictionary* i in self.bannerAry){
                [ary addObject:i[@"adimg"]];
            }
            [SDCycleScrollView clearImagesCache];
            cycleScrollView.imageURLStringsGroup = ary;
            cycleScrollView.infiniteLoop = YES;
            cycleScrollView.autoScroll = YES;
            
        }
        
        return cell;
    }else if (indexPath.section == 1){
        if (self.ptOrBaby){
            SearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchTableViewCell"];
            if (!cell) {
                cell = [[SearchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SearchTableViewCell"];
            }
            [cell setViewWithDic:self.dataAry[indexPath.row] withType:1];
            return cell;
        }else{
            PartTimeTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
            if (!cell) {
                cell = [[PartTimeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
            }
            [cell setViewWithDic:self.dataAry[indexPath.row]];
            return cell;
        }
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.section == 1){
        if (!self.ptOrBaby){
            UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            OrderDetailViewController* vc = [sb instantiateViewControllerWithIdentifier:@"od"];
            vc.itemId = [NSString stringWithFormat:@"%@",self.dataAry[indexPath.row][@"id"]];
            [self.navigationController pushViewController:vc animated:1];
        }else{
            UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            GameBabyDetailViewController* vc = [sb instantiateViewControllerWithIdentifier:@"gbd"];
            vc.gbId = [NSString stringWithFormat:@"%@",self.dataAry[indexPath.row][@"id"]];
            [self.navigationController pushViewController:vc animated:1];
        }
    }
}

#pragma mark - otherDelegate/DataSource
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
    //banner跳转
    if ([NSString stringWithFormat:@"%@",self.bannerAry[index][@"link_lock"]].integerValue == 1){
        DSWebViewController* vc = [[DSWebViewController alloc]initWithURLSting: [NSString stringWithFormat:@"%@",self.bannerAry[index][@"detail"]]];
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
