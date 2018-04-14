//
//  MineViewController.m
//  youxibang
//
//  Created by y on 2018/1/18.
//

#import "MineViewController.h"
#import "TopUpTableViewCell.h"
#import "SystemSettingViewController.h"
#import "TopUpAndWithdrawViewController.h"
#import "BalanceDetailViewController.h"
#import "AlipayAccountViewController.h"
#import "PersonalInfoViewController.h"
#import "ApplyForVipViewController.h"
#import "RealNameViewController.h"
#import "MySkillViewController.h"
#import "MyTaskViewController.h"
#import "MyOrderListViewController.h"
#import "DiscountViewController.h"
#import "MineTableViewCell.h"
#import "HttpManager.h"

@interface MineViewController ()<UITableViewDataSource,UITableViewDelegate,TopUpTableViewCellDelegate, SDCycleScrollViewDelegate>

@property (nonatomic,strong)NSMutableDictionary *dataInfo;

@end

static NSString *const TABLEVIEW_IDENTIFIER = @"tableview_identifier";
@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"我的";
    self.tableView.frame = CGRectMake(0, -20, SCREEN_WIDTH, SCREEN_HEIGHT - 44);
    if ([[UIDevice currentDevice] systemVersion].floatValue <= 11.f){
        self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 44);
    }
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshHead)];
    
    self.tableView.layer.masksToBounds = NO;
    [self.tableView registerNib:[UINib nibWithNibName:@"MineTableViewCell" bundle:nil] forCellReuseIdentifier:TABLEVIEW_IDENTIFIER];
    self.tableView.tableHeaderView = [self configTableViewHeaderView];
    //收到推送后刷新此页面的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHead) name:@"refreshMessage" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    //刷新个人信息
    [UserNameTool reloadPersonalData:^{
        self.dataInfo = [UserNameTool readPersonalData];
        self.tableView.tableHeaderView = [self configTableViewHeaderView];
        [self.tableView reloadData];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (UIView *)configTableViewHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 225 * ADAPTATIONRATIO)];
    //轮播图
    NSArray *bgImgAry = [NSArray array];
    if (self.dataInfo) {
        if ([self.dataInfo[@"bgimg"] count]>0) {
            bgImgAry = self.dataInfo[@"bgimg"];
        }
        else {
            bgImgAry = @[@"img_my111"];
        }
    }
    else {
        bgImgAry = @[@"img_my111"];
    }
    SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetHeight(headerView.frame)) imageNamesGroup:bgImgAry];
    cycleScrollView.infiniteLoop = YES;
    cycleScrollView.delegate = self;
    cycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleClassic;
    [headerView addSubview:cycleScrollView];
    
    UIImageView* photo = [EBUtility imgfrome:CGRectMake(15, CGRectGetMaxY(headerView.frame)-80, 70, 70) andImg:[UIImage imageNamed:@"ico_head"] andView:headerView];
    photo.backgroundColor = [UIColor whiteColor];
    photo.layer.masksToBounds = YES;
    photo.layer.cornerRadius = 5;
    photo.layer.borderColor = [UIColor whiteColor].CGColor;
    photo.layer.borderWidth = 3;
    
    UIButton* photoBtn = [EBUtility btnfrome:photo.frame andText:@"" andColor:nil andimg:nil andView: headerView];
    [photoBtn addTarget:self action:@selector(changeInfo:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *name = [EBUtility labfrome:CGRectMake(85+15, CGRectGetMaxY(headerView.frame)-50, 200, 15) andText:@"昵称" andColor:[UIColor whiteColor] andView:headerView];
    name.textAlignment = NSTextAlignmentLeft;
    name.font = [UIFont systemFontOfSize:15];
    
    UILabel *sex = [EBUtility labfrome:CGRectMake(85+15, CGRectGetMaxY(headerView.frame)-25, 45, 15) andText:@" ♂24岁 " andColor:[UIColor whiteColor]  andView:headerView];
    sex.font = [UIFont systemFontOfSize:10];
    sex.backgroundColor = Nav_color;
    sex.layer.cornerRadius = 4;
    sex.layer.masksToBounds = YES;
    [sex sizeToFit];
    
    UIButton* vipImg = [EBUtility btnfrome:CGRectZero andText:@"" andColor:nil andimg:[UIImage imageNamed:@"ico_vip1"] andView:headerView];
    vipImg.tag = 1;
    [vipImg setImage:[UIImage imageNamed:@"ico_vip"] forState:UIControlStateSelected];
    [vipImg addTarget:self action:@selector(applyVip) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView* changeImage = [EBUtility imgfrome:CGRectMake(SCREEN_WIDTH - 35, 25, 20, 20) andImg:[UIImage imageNamed:@"ico_xiugai"] andView:headerView];
    UIButton* change = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH - 40, 15, 40, 40) andText:@"" andColor:nil andimg:nil andView:headerView];
    [change addTarget:self action:@selector(changeInfo:) forControlEvents:UIControlEventTouchUpInside];
    
    [vipImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(sex.mas_bottom);
        make.left.equalTo(sex.mas_right).offset(10);
        make.size.mas_equalTo(CGSizeMake(17, 15));
    }];
    if (self.dataInfo){
        [photo sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.dataInfo[@"photo"]]] placeholderImage:[UIImage imageNamed:@"ico_tx_s"]];
        name.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"nickname"]];
        if ([NSString stringWithFormat:@"%@",self.dataInfo[@"sex"]].integerValue == 1){
            sex.text = [NSString stringWithFormat:@" ♂%@岁 ",self.dataInfo[@"age"]];
            sex.backgroundColor = Nav_color;
        }else{
            sex.text = [NSString stringWithFormat:@" ♀%@岁 ",self.dataInfo[@"age"]];
            sex.backgroundColor = Pink_color;
        }
        [sex sizeToFit];
        if ([NSString stringWithFormat:@"%@",self.dataInfo[@"is_vip"]].integerValue == 1){
            vipImg.selected = YES;
        }else{
            vipImg.selected = NO;
        }
    }
    return headerView;
}

- (void)refreshHead {
    [UserNameTool reloadPersonalData:^{
        self.dataInfo = [UserNameTool readPersonalData];
        self.tableView.tableHeaderView = [self configTableViewHeaderView];
        [self.tableView reloadData];
    }];
    [self.tableView.mj_header endRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//跳转加V页面
- (void)applyVip {
    if ([NSString stringWithFormat:@"%@",self.dataInfo[@"is_vip"]].integerValue != 1){
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ApplyForVipViewController* vc = [sb instantiateViewControllerWithIdentifier:@"afv"];
        [self.navigationController pushViewController:vc animated:1];
    }
}

//跳转修改个人资料页面
- (void)changeInfo:(id)sender {
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PersonalInfoViewController* vc = [sb instantiateViewControllerWithIdentifier:@"pi"];
    vc.dataInfo = self.dataInfo;
    [self.navigationController pushViewController:vc animated:1];
    
}

#pragma mark - otherDelegate

//轮播图片点击事件
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
    [self changeInfo:nil];
}

#pragma mark - tableViewDelegate/DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 1){
        return 8;
    }
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 1){
        return 50;
    }
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 1){
        return 50;
    }
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //写死的title和图片
    NSArray* ary = @[@[@"我的钱包",@""],@[@"我的任务",@"我的技能",@"优惠券",@"订单中心",@"提现账户管理",@"我的邀请码",@"联系客服",@"系统设置"]];
    NSArray* imgAry = @[@[@"ico_myqb",@""],@[@"ico_renwu",@"ico_gamebaby",@"ico_yhq",@"ico_order_center",@"ico_txgl",@"ico_yqm1",@"ico_kf",@"ico_setting"]];
    if (indexPath.section == 0 && indexPath.row == 1){
        //充值提现的cell
        TopUpTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"TopUpTableViewCell"];
        if (!cell) {
            cell = [[TopUpTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TopUpTableViewCell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        [cell initCell];
        return cell;
    }
    MineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TABLEVIEW_IDENTIFIER];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0 && indexPath.row == 0){
        cell.accessoryType = UITableViewCellAccessoryNone;
        //余额数字显示
        NSMutableAttributedString *mAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"余额%@元",(self.dataInfo[@"user_money"]) ? (self.dataInfo[@"user_money"]) : @"0"]];
        [mAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(2, mAttStr.length - 3)];
        [mAttStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(2, mAttStr.length - 3)];
        cell.rightLabel.attributedText = mAttStr;
        cell.rightLabel.font = [UIFont systemFontOfSize:12];

    }else if (indexPath.section == 1 && indexPath.row == 5){
        //邀请码
        cell.rightLabel.text = @"EE0F85D131C1";
    }else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.leftLabel.text = ary[indexPath.section][indexPath.row];
    cell.iconImageView.image = [UIImage imageNamed:imgAry[indexPath.section][indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1){
        if (indexPath.row == 0){//任务列表
            MyTaskViewController* vc = [[MyTaskViewController alloc]init];
            [self.navigationController pushViewController:vc animated:1];
        }else if (indexPath.row == 1){//实名认证或者个人技能
            if ([NSString stringWithFormat:@"%@",self.dataInfo[@"is_realauth"]].integerValue == 1){
                MySkillViewController *vc = [[MySkillViewController alloc]init];
                [self.navigationController pushViewController:vc animated:1];
            }else{
                UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                RealNameViewController* vc = [sb instantiateViewControllerWithIdentifier:@"rn"];
                [self.navigationController pushViewController:vc animated:1];
            }
        }else if (indexPath.row == 2){//优惠券
            UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            DiscountViewController* vc = [sb instantiateViewControllerWithIdentifier:@"dvc"];
            [self.navigationController pushViewController:vc animated:1];
        }else if (indexPath.row == 3){//订单列表
            UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            MyOrderListViewController* vc = [sb instantiateViewControllerWithIdentifier:@"mol"];
            [self.navigationController pushViewController:vc animated:1];
        }else if (indexPath.row == 4){//支付宝绑定
            UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            AlipayAccountViewController* vc = [sb instantiateViewControllerWithIdentifier:@"aa"];
            [self.navigationController pushViewController:vc animated:1];
        }else if (indexPath.row == 5){//点击复制邀请码
            UIPasteboard *pab = [UIPasteboard generalPasteboard];
            [pab setString:@"EE0F85D131C1"];
            [SVProgressHUD showInfoWithStatus:@"已将邀请码复制"];
        }else if (indexPath.row == 6){//自定义alert显示客服电话
            CustomAlertView* alert = [[CustomAlertView alloc]initWithAry:@[@"客服电话1：15306544612\n(微信同号)",@"客服电话2：15372402489\n(微信同号)",@"客服电话3：15372416943\n(微信同号)"]];
            alert.resultDate = ^(NSString *date) {
                if ([date isEqualToString:@"0"]){
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"telprompt://15306544612"]];
                }else  if ([date isEqualToString:@"1"]){
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"telprompt://15372402489"]];
                }else if ([date isEqualToString:@"2"]){
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"telprompt://15372416943"]];
                }
            };
            [alert showAlertView];
        }else if (indexPath.row == 7){//系统设置
            SystemSettingViewController* vc = [[SystemSettingViewController alloc]init];
            [self.navigationController pushViewController:vc animated:1];
        }
    }
}

#pragma mark - otherDelegate/DataSource
- (void)pushTopUpView:(NSInteger)tag {
    if (tag < 2){//充值||提现页面
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        TopUpAndWithdrawViewController* vc = [sb instantiateViewControllerWithIdentifier:@"tuaw"];
        vc.type = tag;
        [self.navigationController pushViewController:vc animated:1];
    }else{//余额明细页面
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BalanceDetailViewController* vc = [sb instantiateViewControllerWithIdentifier:@"bd"];
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