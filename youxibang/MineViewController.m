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
#import "PersonalInfoViewController.h"
#import "ApplyForVipViewController.h"
#import "RealNameViewController.h"
#import "MySkillViewController.h"
#import "MyTaskViewController.h"
#import "MyOrderListViewController.h"
#import "DiscountViewController.h"
#import "MineTableViewCell.h"
#import "LiveCreateViewController.h"
#import "LiveFansViewController.h"
#import "VipWebViewController.h"
#import "InviteViewController.h"
#import "SigninViewController.h"
#import "AliPlayerViewController.h"

@interface MineViewController ()<UITableViewDataSource,UITableViewDelegate,TopUpTableViewCellDelegate, SDCycleScrollViewDelegate> {
    NSDictionary *adDataInfo;
}

@end

static NSString *const TABLEVIEW_IDENTIFIER = @"tableview_identifier";
@implementation MineViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"我的";
    self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-TabbarHeight);
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
    ScrollViewContentInsetAdjustmentNever(self, self.tableView);
    
    //收到推送后刷新此页面的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHead) name:@"refreshMessage" object:nil];
    [self getBuyVipInfoRequest];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    //刷新个人信息 
    [UserNameTool reloadPersonalData:^{
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
    UserModel *userModel = UserModel.sharedUser;
    NSMutableArray *bgImgAry = [NSMutableArray array];
    BOOL existBgimg = NO;
    BOOL existVideo = NO;
    if (userModel.bgimg.count > 0) {
        existBgimg = YES;
    }
    if (isKindOfNSString(userModel.video) && isKindOfNSString(userModel.video_img)) {
        if (userModel.video.length > 0 && userModel.video_img.length > 0) {
            existVideo = YES;
        }
    }
    if (existBgimg) {
        for (NSString *str in userModel.bgimg) {
            [bgImgAry addObject:str];
        }
    }
    else {
        bgImgAry = @[@"placeholder_media"].mutableCopy;
    }
    if (existVideo) {
        [bgImgAry insertObject:userModel.video_img atIndex:0];
    }
    
    SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetHeight(headerView.frame)) imageNamesGroup:bgImgAry];
    cycleScrollView.placeholderImage = [UIImage imageNamed:@"placeholder_media"];
    cycleScrollView.infiniteLoop = YES;
    cycleScrollView.delegate = self;
    cycleScrollView.hideBkgView = NO;
    cycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleClassic;
    cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter;
    [headerView addSubview:cycleScrollView];
    
    UIImageView *sexImg = [EBUtility imgfrome:CGRectMake(15, CGRectGetMaxY(headerView.frame)-15-20, 20, 20) andImg:[UIImage imageNamed:@"live_detail_male"] andView:headerView];
    
    UILabel *age = [EBUtility labfrome:CGRectZero andText:@"24岁 " andColor:[UIColor whiteColor]  andView:headerView];
    age.textAlignment = NSTextAlignmentLeft;
    age.font = [UIFont systemFontOfSize:13.0];
    [age mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(sexImg.mas_centerY);
        make.left.equalTo(sexImg.mas_right).offset(7);
        make.size.mas_equalTo(CGSizeMake(30, 15));
    }];
    
    UIImageView* vipImg = [EBUtility imgfrome:CGRectZero andImg:[UIImage imageNamed:@"vip_grade_1"] andView:headerView];
    [vipImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(sexImg.mas_centerY);
        make.left.equalTo(age.mas_right).offset(7);
        make.size.mas_equalTo(CGSizeMake(17, 20));
    }];
    
    UIImageView *realnamedImg = [EBUtility imgfrome:CGRectZero andImg:[UIImage imageNamed:@"live_detail_realnamed"] andView:headerView];
    [realnamedImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(sexImg.mas_centerY);
        make.left.equalTo(vipImg.mas_right).offset(7);
        make.size.mas_equalTo(CGSizeMake(35, 20));
    }];
    
    UILabel *name = [EBUtility labfrome:CGRectZero andText:@"昵称" andColor:[UIColor whiteColor] andView:headerView];
    name.textAlignment = NSTextAlignmentLeft;
    name.font = [UIFont systemFontOfSize:16.0];
    [name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(sexImg.mas_top).offset(-6);
        make.left.equalTo(headerView.mas_left).offset(15);
        make.size.mas_equalTo(CGSizeMake(170, 15));
    }];
    
    UIImageView* photo = [EBUtility imgfrome:CGRectZero andImg:[UIImage imageNamed:@"ico_head"] andView:headerView];
    photo.backgroundColor = [UIColor whiteColor];
    photo.layer.masksToBounds = YES;
    photo.layer.cornerRadius = 23.5;
    photo.layer.borderColor = [UIColor whiteColor].CGColor;
    photo.layer.borderWidth = 1;
    [photo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(name.mas_top).offset(-8);
        make.left.equalTo(headerView.mas_left).offset(15);
        make.size.mas_equalTo(CGSizeMake(47, 47));
    }];
    photo.userInteractionEnabled = YES;
    UITapGestureRecognizer *phototap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeInfo:)];
    [photo addGestureRecognizer:phototap];
    
    UIImageView* changeImage = [EBUtility imgfrome:CGRectMake(SCREEN_WIDTH - 35, 25, 20, 20) andImg:[UIImage imageNamed:@"ico_xiugai"] andView:headerView];
    UIButton* change = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH - 40, 15, 40, 40) andText:@"" andColor:nil andimg:nil andView:headerView];
    [change addTarget:self action:@selector(changeInfo:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *laudLabel = [EBUtility labfrome:CGRectZero andText:[NSString stringWithFormat:@"%@\n赞",userModel.laud_count] andColor:[UIColor whiteColor] andView:headerView];
    laudLabel.textAlignment = NSTextAlignmentCenter;
    laudLabel.font = [UIFont systemFontOfSize:13.0];
    laudLabel.numberOfLines = 2;
    [laudLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(headerView.mas_bottom).offset(-12);
        make.right.equalTo(headerView.mas_right).offset(-15);
        make.size.mas_equalTo(CGSizeMake(30, 35));
    }];
    UILabel *fansLabel = [EBUtility labfrome:CGRectZero andText:[NSString stringWithFormat:@"%@\n粉丝",userModel.follow_count] andColor:[UIColor whiteColor] andView:headerView];
    fansLabel.textAlignment = NSTextAlignmentCenter;
    fansLabel.font = [UIFont systemFontOfSize:13.0];
    fansLabel.numberOfLines = 2;
    fansLabel.userInteractionEnabled = YES;
    [fansLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(laudLabel.mas_centerY);
        make.right.equalTo(laudLabel.mas_left);
        make.size.mas_equalTo(CGSizeMake(50, 35));
    }];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFansSelector)];
    [fansLabel addGestureRecognizer:tap];
    
    [photo sd_setImageWithURL:[NSURL URLWithString:userModel.photo] placeholderImage:[UIImage imageNamed:@"ico_head"]];
    name.text = userModel.nickname;
    if (userModel.sex.integerValue == 1) {
        sexImg.image = [UIImage imageNamed:@"live_detail_male"];
    }
    else {
        sexImg.image = [UIImage imageNamed:@"live_detail_female"];
    }
    age.text = [NSString stringWithFormat:@"%@岁\t",userModel.age];
    if (userModel.vip_grade.integerValue == 0) {
        [vipImg mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(sexImg.mas_centerY);
            make.left.equalTo(age.mas_right);
            make.size.mas_equalTo(CGSizeMake(0, 20));
        }];
    }
    else {
        vipImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"vip_grade_%@",userModel.vip_grade]];
    }
    if (userModel.is_realauth.integerValue == 1) {
        realnamedImg.image = [UIImage imageNamed:@"live_detail_realnamed"];
    }
    else {
        [realnamedImg mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(sexImg.mas_centerY);
            make.left.equalTo(vipImg.mas_right);
            make.size.mas_equalTo(CGSizeMake(0, 20));
        }];
    }
    return headerView;
}

- (void)refreshHead {
    [self getBuyVipInfoRequest];
    [UserNameTool reloadPersonalData:^{
        self.tableView.tableHeaderView = [self configTableViewHeaderView];
        [self.tableView reloadData];
    }];
    [self.tableView.mj_header endRefreshing];
}

- (void)tapFansSelector {
    LiveFansViewController* vc = [[LiveFansViewController alloc]init];
    [self.navigationController pushViewController:vc animated:1];
}

- (void)getBuyVipInfoRequest {
    NSDictionary *dict = @{@"typeid":@"6"};
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Currency/bannerlist.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            if (code == 1) {
                adDataInfo = [object[@"data"] lastObject];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
            }else{
            }
        }
        
    } failoperation:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"网络信号差，请稍后再试"];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//跳转加V页面
- (void)applyVip {
//    if ([NSString stringWithFormat:@"%@",self.dataInfo[@"is_vip"]].integerValue != 1){
//        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        ApplyForVipViewController* vc = [sb instantiateViewControllerWithIdentifier:@"afv"];
//        [self.navigationController pushViewController:vc animated:1];
//    }
    if (UserModel.sharedUser.is_vip.integerValue != 1){
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ApplyForVipViewController* vc = [sb instantiateViewControllerWithIdentifier:@"afv"];
        [self.navigationController pushViewController:vc animated:1];
    }
}

//跳转修改个人资料页面
- (void)changeInfo:(id)sender {
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PersonalInfoViewController* vc = [sb instantiateViewControllerWithIdentifier:@"pi"];
    [self.navigationController pushViewController:vc animated:1];
    
}

#pragma mark - otherDelegate

//轮播图片点击事件
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
    BOOL existVideo = NO;
    UserModel *userModel = UserModel.sharedUser;
    if (isKindOfNSString(userModel.video) && isKindOfNSString(userModel.video_img)) {
        if (userModel.video.length > 0 && userModel.video_img.length > 0) {
            existVideo = YES;
        }
    }
    if (existVideo) {
        if (index == 0) {
            AliPlayerViewController *playCon = [AliPlayerViewController new];
            playCon.videoIdString = UserModel.sharedUser.video;
            [self.navigationController pushViewController:playCon animated:YES];
        }
        else {
            [self changeInfo:nil];
        }
    }
    else {
        [self changeInfo:nil];
    }
}

#pragma mark - tableViewDelegate/DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 1){
        return 1;
    }
    else if (section == 2) {
        if (UserModel.sharedUser.is_anchor.integerValue == 0 && UserModel.sharedUser.isbaby.integerValue == 0) {
            return 8;
        }
        return 7;
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
    else if (indexPath.section == 1) {
        return 80;
    }
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 1){
        return 50;
    }
    else if (indexPath.section == 1) {
        return 60;
    }
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
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
    else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableviewcell_id"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableviewcell_id"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        NSArray *subviewArray = cell.contentView.subviews;
        for (id subview in subviewArray) {
            if ([subview isKindOfClass:UIImageView.class]) {
                [subview removeFromSuperview];
            }
        }
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 80)];
        [imgView sd_setImageWithURL:[NSURL URLWithString:adDataInfo[@"adimg"]] placeholderImage:[UIImage imageNamed:@"placeholder_vip"]];
        [cell.contentView addSubview:imgView];
        return cell;
    }
    return [self displayTableViewCell:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1){
        if ([adDataInfo[@"link_lock"] integerValue] == 1) {
            VipWebViewController *con = [VipWebViewController new];
            con.loadUrlString = [NSString stringWithFormat:@"%@?type=phone&token=%@",adDataInfo[@"ad_link"],DataStore.sharedDataStore.token];
            [self.navigationController pushViewController:con animated:YES];
        }
    }
    else if (indexPath.section == 2) {
        [self pushToController:indexPath];
    }
}

- (UITableViewCell *)displayTableViewCell:(NSIndexPath *)indexPath {
    UserModel *usermodel = UserModel.sharedUser;
    NSArray* ary = @[@[@"我的钱包",@""],@[@""],@[@"我的金币",@"我的任务",@"订单中心",@"我的技能",@"我是主播",@"订单中心",@"有奖邀请",@"联系客服",@"系统设置"]];
    NSArray* imgAry = @[@[@"ico_myqb",@""],@[@""],@[@"ico_gold",@"ico_renwu",@"ico_order_center",@"ico_gamebaby",@"ico_anchor",@"ico_yqm1",@"ico_kf",@"ico_setting"]];
    if (usermodel.is_anchor.integerValue == 1) {
        ary = @[@[@"我的钱包",@""],@[@""],@[@"我的金币",@"我的任务",@"订单中心",@"我是主播",@"有奖邀请",@"联系客服",@"系统设置"]];
        imgAry = @[@[@"ico_myqb",@""],@[@""],@[@"ico_gold",@"ico_renwu",@"ico_order_center",@"ico_anchor",@"ico_txgl",@"ico_yqm1",@"ico_kf",@"ico_setting"]];
    }
    else if (usermodel.isbaby.integerValue == 1) {
        ary = @[@[@"我的钱包",@""],@[@""],@[@"我的金币",@"我的任务",@"订单中心",@"我的技能",@"有奖邀请",@"联系客服",@"系统设置"]];
        imgAry = @[@[@"ico_myqb",@""],@[@""],@[@"ico_gold",@"ico_renwu",@"ico_order_center",@"ico_gamebaby",@"ico_yqm1",@"ico_kf",@"ico_setting"]];
    }
    MineTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:TABLEVIEW_IDENTIFIER];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0 && indexPath.row == 0){
        cell.accessoryType = UITableViewCellAccessoryNone;
        //余额数字显示
        NSMutableAttributedString *mAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"余额%@元",UserModel.sharedUser.user_money ? : @"0"]];
        [mAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(2, mAttStr.length - 3)];
        [mAttStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(2, mAttStr.length - 3)];
        cell.rightLabel.attributedText = mAttStr;
        cell.rightLabel.font = [UIFont systemFontOfSize:12];
        
    }else{
        cell.rightLabel.text = @"";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.leftLabel.text = ary[indexPath.section][indexPath.row];
    cell.iconImageView.image = [UIImage imageNamed:imgAry[indexPath.section][indexPath.row]];
    return cell;
}

- (void)pushToController:(NSIndexPath *)indexPath {
    if (indexPath.row == 0){//我的金币
        SigninViewController *con = [SigninViewController new];
        [self.navigationController pushViewController:con animated:YES];
    }
    else if (indexPath.row == 1){//任务列表
        MyTaskViewController* vc = [[MyTaskViewController alloc]init];
        [self.navigationController pushViewController:vc animated:1];
    }
    else {
        if (UserModel.sharedUser.is_anchor.integerValue == 0 && UserModel.sharedUser.isbaby.integerValue == 0) {
            if (indexPath.row == 2){//订单列表
                [self pushToOrder];
            }else if (indexPath.row == 3){//实名认证或者个人技能
                if ([NSString stringWithFormat:@"%@",UserModel.sharedUser.is_realauth].integerValue == 2) {
                    [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"您的实名认证正在审核中" andDuration:2.0];
                }
                else if ([NSString stringWithFormat:@"%@",UserModel.sharedUser.is_realauth].integerValue == 1) {
                    [self pushToMySkill];
                }
                else {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"我的技能和我是主播\n只能二选一" message:nil preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                    UIAlertAction *confim = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self pushToMySkill];
                    }];
                    [alert addAction:cancel];
                    [alert addAction:confim];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }else if (indexPath.row == 4){//我是主播
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"我是主播和我的技能\n只能二选一" message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                UIAlertAction *confim = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self pushToAnchor];
                }];
                [alert addAction:cancel];
                [alert addAction:confim];
                [self presentViewController:alert animated:YES completion:nil];
            }else if (indexPath.row == 5){//点击分享邀请码
                [self pushToInvite];
            }else if (indexPath.row == 6){//自定义alert显示客服电话
                [self pushToAlertView];
            }else if (indexPath.row == 7){//系统设置
                [self pushToSystemSetting];
            }
        }
        else {
            if (indexPath.row == 2){//订单列表
                [self pushToOrder];
            }else if (indexPath.row == 3) {//我是主播或者个人技能
                UserModel *usermodel = UserModel.sharedUser;
                if (usermodel.is_anchor.integerValue == 1) {
                    [self pushToAnchor];
                }
                else if (usermodel.isbaby.integerValue == 1) {
                    [self pushToMySkill];
                }
            } else if (indexPath.row == 4){//点击分享邀请码
                [self pushToInvite];
            }else if (indexPath.row == 5){//自定义alert显示客服电话
                [self pushToAlertView];
            }else if (indexPath.row == 6){//系统设置
                [self pushToSystemSetting];
            }
        }
    }
}

- (void)pushToMySkill {
    if ([UserModel sharedUser].is_realauth.integerValue == 1) {
        MySkillViewController *vc = [[MySkillViewController alloc]init];
        [self.navigationController pushViewController:vc animated:1];
    }else{
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        RealNameViewController* vc = [sb instantiateViewControllerWithIdentifier:@"rn"];
        [self.navigationController pushViewController:vc animated:1];
    }
}

- (void)pushToAnchor {
    LiveCreateViewController* vc = [[LiveCreateViewController alloc]init];
    [self.navigationController pushViewController:vc animated:1];
}

- (void)pushToOrder {
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MyOrderListViewController* vc = [sb instantiateViewControllerWithIdentifier:@"mol"];
    [self.navigationController pushViewController:vc animated:1];
}

- (void)pushToInvite {
    InviteViewController *invite = [InviteViewController new];
    [self.navigationController pushViewController:invite animated:YES];
}

- (void)pushToAlertView {
    CustomAlertView* alert = [[CustomAlertView alloc]initWithAry:@[@"客服电话1：15306544612\n(微信同号)",@"客服电话2：15372402489\n(微信同号)",@"客服电话3：15372416943\n(微信同号)"]];
    alert.resultDate = ^(NSString *date) {
        if ([date isEqualToString:@"0"]){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"telprompt://15306544612"]];
        }else if ([date isEqualToString:@"1"]){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"telprompt://15372402489"]];
        }else if ([date isEqualToString:@"2"]){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"telprompt://15372416943"]];
        }
    };
    [alert showAlertView];
}

- (void)pushToSystemSetting {
    SystemSettingViewController* vc = [[SystemSettingViewController alloc]init];
    [self.navigationController pushViewController:vc animated:1];
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

//下载技能列表
- (void)downloadMySkillDataCompletionHandle:(void(^)(NSArray *dataarray))handle {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[DataStore sharedDataStore].token forKey:@"token"];
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Gamebaby/mysklist.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            if (code == 1) {
                if (handle) {
                    handle(object[@"data"]);
                }
            }
        }
    } failoperation:^(NSError *error) {
    }];
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
