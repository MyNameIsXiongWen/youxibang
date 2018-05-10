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
#import <AliyunVodPlayerSDK/AliyunVodPlayerSDK.h>

@interface MineViewController ()<UITableViewDataSource,UITableViewDelegate,TopUpTableViewCellDelegate, SDCycleScrollViewDelegate, AliyunVodPlayerDelegate> {
    NSDictionary *adDataInfo;
}

@property (nonatomic,strong) AliyunVodPlayer *aliPlayer;
@property (nonatomic,strong) UIView *playerView;//播放view
@property (nonatomic,strong) UIProgressView *progressView;//加载进度
@property (nonatomic,strong) UISlider *sliderProgress;//当前播放进度，可拖拽
@property (nonatomic, strong) NSTimer *timer;//计时器，时时获取currentTime
@property (nonatomic, strong) UILabel *currentTimeLabel;//当前播放时间
@property (nonatomic, strong) UILabel *totalTimeLabel;//视频总时长

@end

static NSString *const TABLEVIEW_IDENTIFIER = @"tableview_identifier";
@implementation MineViewController

- (void)dealloc {
    [self.aliPlayer releasePlayer];
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
    if (self.aliPlayer) {
        [self.aliPlayer releasePlayer];
    }
    self.playerView.hidden = YES;
}

//配置播放器相关UI
- (void)configMediaPlayer {
    //创建播放器对象，可以创建多个示例
    self.aliPlayer = [[AliyunVodPlayer alloc] init];
    //设置播放器代理
    self.aliPlayer.delegate = self;
    self.aliPlayer.circlePlay = YES;
    
    self.playerView = self.aliPlayer.playerView;
    self.playerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    //添加播放器视图到需要展示的界面上
    [UIApplication.sharedApplication.keyWindow addSubview:self.playerView];
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.frame = CGRectMake(40, SCREEN_HEIGHT-40, SCREEN_WIDTH-80, 20);
    self.progressView.progressTintColor = UIColor.whiteColor;
    self.progressView.trackTintColor = UIColor.grayColor;
    [self.playerView addSubview:self.progressView];
    self.sliderProgress = [[UISlider alloc] initWithFrame:self.progressView.frame];
    self.sliderProgress.maximumTrackTintColor = UIColor.whiteColor;
    self.sliderProgress.minimumTrackTintColor = UIColor.blueColor;
    //    [self.playerView addSubview:self.sliderProgress];
    self.currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, SCREEN_HEIGHT-40, 40, 20)];
    self.currentTimeLabel.font = [UIFont systemFontOfSize:10.0];
    self.currentTimeLabel.textAlignment = NSTextAlignmentRight;
    self.currentTimeLabel.textColor = UIColor.whiteColor;
    self.totalTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-50, SCREEN_HEIGHT-40, 40, 20)];
    self.totalTimeLabel.font = [UIFont systemFontOfSize:10.0];
    self.totalTimeLabel.textColor = UIColor.whiteColor;
    [self.playerView addSubview:self.currentTimeLabel];
    [self.playerView addSubview:self.totalTimeLabel];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPlayerView)];
    [self.playerView addGestureRecognizer:tap];
    self.playerView.hidden = YES;
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
    if (isKindOfNSString(userModel.video)) {
        if (userModel.video.length > 0) {
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
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self configMediaPlayer];
        });
    }
    
    SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetHeight(headerView.frame)) imageNamesGroup:bgImgAry];
    cycleScrollView.placeholderImage = [UIImage imageNamed:@"placeholder_media"];
    cycleScrollView.infiniteLoop = YES;
    cycleScrollView.delegate = self;
    cycleScrollView.hideBkgView = NO;
    cycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleClassic;
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
    
    [photo sd_setImageWithURL:[NSURL URLWithString:userModel.photo] placeholderImage:[UIImage imageNamed:@"ico_tx_s"]];
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
    if (isKindOfNSString(userModel.video)) {
        if (userModel.video.length > 0) {
            existVideo = YES;
        }
    }
    if (existVideo) {
        if (index == 0) {
            [self startVideoPlay];// 播放视频
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
    NSArray* ary = @[@[@"我的钱包",@""],@[@""],@[@"我的金币",@"我的任务",@"我的技能",@"我是主播",@"订单中心",@"有奖邀请",@"联系客服",@"系统设置"]];
    NSArray* imgAry = @[@[@"ico_myqb",@""],@[@""],@[@"ico_gold",@"ico_renwu",@"ico_gamebaby",@"ico_anchor",@"ico_order_center",@"ico_yqm1",@"ico_kf",@"ico_setting"]];
    if (usermodel.is_anchor.integerValue == 1) {
        ary = @[@[@"我的钱包",@""],@[@""],@[@"我的金币",@"我的任务",@"我是主播",@"订单中心",@"有奖邀请",@"联系客服",@"系统设置"]];
        imgAry = @[@[@"ico_myqb",@""],@[@""],@[@"ico_gold",@"ico_renwu",@"ico_anchor",@"ico_order_center",@"ico_txgl",@"ico_yqm1",@"ico_kf",@"ico_setting"]];
    }
    else if (usermodel.isbaby.integerValue == 1) {
        ary = @[@[@"我的钱包",@""],@[@""],@[@"我的金币",@"我的任务",@"我的技能",@"订单中心",@"有奖邀请",@"联系客服",@"系统设置"]];
        imgAry = @[@[@"ico_myqb",@""],@[@""],@[@"ico_gold",@"ico_renwu",@"ico_gamebaby",@"ico_order_center",@"ico_yqm1",@"ico_kf",@"ico_setting"]];
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
            if (indexPath.row == 2){//实名认证或者个人技能
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"我的技能和我是主播\n只能二选一" message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                UIAlertAction *confim = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self pushToMySkill];
                }];
                [alert addAction:cancel];
                [alert addAction:confim];
                [self presentViewController:alert animated:YES completion:nil];
            }else if (indexPath.row == 3){//我是主播
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"我是主播和我的技能\n只能二选一" message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                UIAlertAction *confim = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self pushToAnchor];
                }];
                [alert addAction:cancel];
                [alert addAction:confim];
                [self presentViewController:alert animated:YES completion:nil];
            }else if (indexPath.row == 4){//订单列表
                [self pushToOrder];
            }else if (indexPath.row == 5){//点击分享邀请码
                [self pushToInvite];
            }else if (indexPath.row == 6){//自定义alert显示客服电话
                [self pushToAlertView];
            }else if (indexPath.row == 7){//系统设置
                [self pushToSystemSetting];
            }
        }
        else {
            if (indexPath.row == 2) {//我是主播或者个人技能
                UserModel *usermodel = UserModel.sharedUser;
                if (usermodel.is_anchor.integerValue == 1) {
                    [self pushToAnchor];
                }
                else if (usermodel.isbaby.integerValue == 1) {
                    [self pushToMySkill];
                }
            }else if (indexPath.row == 3){//订单列表
                [self pushToOrder];
            }else if (indexPath.row == 4){//点击分享邀请码
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
//    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    RealNameViewController* vc = [sb instantiateViewControllerWithIdentifier:@"rn"];
//    [self.navigationController pushViewController:vc animated:1];
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


#pragma mark ALIPLAYER DELEGATE
- (void)vodPlayer:(AliyunVodPlayer *)vodPlayer onEventCallback:(AliyunVodPlayerEvent)event{
    //这里监控播放事件回调
    //主要事件如下：
    switch (event) {
        case AliyunVodPlayerEventPrepareDone:
            //播放准备完成时触发
        {
            //开始播放
            [self.aliPlayer start];
            self.aliPlayer.quality = AliyunVodPlayerVideoHD;
            
            AliyunVodPlayerVideo *videoModel = [self.aliPlayer getAliyunMediaInfo];
            if (videoModel) {
                self.totalTimeLabel.text = [self getMMSSFromSS:[NSString stringWithFormat:@"%.f",videoModel.duration]];
            }else{
                self.totalTimeLabel.text = [self getMMSSFromSS:[NSString stringWithFormat:@"%.f",self.aliPlayer.duration]];
            }
            
            [self.timer invalidate];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerRun:) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
        }
            break;
        case AliyunVodPlayerEventPlay:
            //暂停后恢复播放时触发
            break;
        case AliyunVodPlayerEventFirstFrame:
            //播放视频首帧显示出来时触发
            [SVProgressHUD dismiss];
            [SVProgressHUD setDefaultMaskType:1];
            break;
        case AliyunVodPlayerEventPause:
            //视频暂停时触发
            break;
        case AliyunVodPlayerEventStop:
            //主动使用stop接口时触发
            break;
        case AliyunVodPlayerEventFinish:
            //视频正常播放完成时触发
            //            [self.sliderProgress setValue:0];
            self.progressView.progress = 0;
            self.playerView.hidden = YES;
            //            [self.playerView removeFromSuperview];
            break;
        case AliyunVodPlayerEventBeginLoading:
            //视频开始载入时触发
            break;
        case AliyunVodPlayerEventEndLoading:
            //视频加载完成时触发
            break;
        case AliyunVodPlayerEventSeekDone:
            //视频Seek完成时触发
            break;
        default:
            break;
    }
}
- (void)vodPlayer:(AliyunVodPlayer *)vodPlayer playBackErrorModel:(ALPlayerVideoErrorModel *)errorModel{
    //播放出错时触发，通过errorModel可以查看错误码、错误信息、视频ID、视频地址和requestId。
    [self.timer invalidate];
    //    [self.sliderProgress setValue:0];
    self.progressView.progress = 0;
    self.currentTimeLabel.text = [self getMMSSFromSS:[NSString stringWithFormat:@"%.f",0.0]];
    self.playerView.hidden = YES;
}
- (void)vodPlayer:(AliyunVodPlayer*)vodPlayer willSwitchToQuality:(AliyunVodPlayerVideoQuality)quality{
    //将要切换清晰度时触发
}
- (void)vodPlayer:(AliyunVodPlayer *)vodPlayer didSwitchToQuality:(AliyunVodPlayerVideoQuality)quality{
    //清晰度切换完成后触发
}
- (void)vodPlayer:(AliyunVodPlayer*)vodPlayer failSwitchToQuality:(AliyunVodPlayerVideoQuality)quality{
    //清晰度切换失败触发
}
- (void)onCircleStartWithVodPlayer:(AliyunVodPlayer*)vodPlayer{
    //开启循环播放功能，开始循环播放时接收此事件。
}
- (void)onTimeExpiredErrorWithVodPlayer:(AliyunVodPlayer *)vodPlayer{
    //播放器鉴权数据过期回调，出现过期可重新prepare新的地址或进行UI上的错误提醒。
    [self.timer invalidate];
    //    [self.sliderProgress setValue:0];
    self.progressView.progress = 0;
    self.currentTimeLabel.text = [self getMMSSFromSS:[NSString stringWithFormat:@"%.f",0.0]];
    self.playerView.hidden = YES;
}
/*
 *功能：播放过程中鉴权即将过期时提供的回调消息（过期前一分钟回调）
 *参数：videoid：过期时播放的videoId
 *参数：quality：过期时播放的清晰度，playauth播放方式和STS播放方式有效。
 *参数：videoDefinition：过期时播放的清晰度，MPS播放方式时有效。
 *备注：使用方法参考高级播放器-点播。
 */
- (void)vodPlayerPlaybackAddressExpiredWithVideoId:(NSString *)videoId quality:(AliyunVodPlayerVideoQuality)quality videoDefinition:(NSString*)videoDefinition{
    //鉴权有效期为2小时，在这个回调里面可以提前请求新的鉴权，stop上一次播放，prepare新的地址，seek到当前位置
}

- (void)startVideoPlay {
    //使用vid+STS方式播放（点播用户推荐使用）
    if (self.aliPlayer.playerState == 4) {
        [self.aliPlayer resume];
        self.playerView.hidden = NO;
    }
    else if (self.aliPlayer.playerState == 6) {
        [self.aliPlayer replay];
        self.playerView.hidden = NO;
    }
    else {
        if (self.aliPlayer) {
            self.playerView.hidden = NO;
            [self getVideoUploadToken];
        }
    }
}

#pragma mark - seek
- (void)timeProgress:(UISlider *)sender {
    if (self.aliPlayer && (self.aliPlayer.playerState == AliyunVodPlayerStateLoading || self.aliPlayer.playerState == AliyunVodPlayerStatePause ||
                           self.aliPlayer.playerState == AliyunVodPlayerStatePlay)) {
        [ self.aliPlayer seekToTime:sender.value * self.aliPlayer.duration ];
    }
}
#pragma mark - timerRun
- (void)timerRun:(NSTimer *)sender{
    if (self.aliPlayer) {
        self.currentTimeLabel.text = [self getMMSSFromSS:[NSString stringWithFormat:@"%.f",self.aliPlayer.currentTime]];
        //        [self.sliderProgress setValue:self.aliPlayer.currentTime/self.aliPlayer.duration animated:YES];
        //        [self.progressView setProgress:self.aliPlayer.loadedTime/self.aliPlayer.duration];
        [self.progressView setProgress:self.aliPlayer.currentTime/self.aliPlayer.duration];
    }
}

-(NSString *)getMMSSFromSS:(NSString *)totalTime{
    NSInteger seconds = [totalTime integerValue];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
    //format of time
    //    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    NSString *format_time = [NSString stringWithFormat:@"%@:%@",str_minute,str_second];
    return format_time;
}

- (void)tapPlayerView {
    [self.aliPlayer pause];
    self.playerView.hidden = YES;
    //    [self.playerView removeFromSuperview];
}

- (void)getVideoUploadToken {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:DataStore.sharedDataStore.token forKey:@"token"];
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@video/get_token",HttpURLString] Paremeters:dict successOperation:^(id response) {
        if (isKindOfNSDictionary(response)) {
            NSInteger msg = [[response objectForKey:@"errcode"] integerValue];
            NSString *str = [response objectForKey:@"message"];
            if (msg == 1) {
                NSDictionary *tokenDictionary = (NSDictionary *)response;
                [self.aliPlayer prepareWithVid:UserModel.sharedUser.video
                                   accessKeyId:tokenDictionary[@"data"][@"Credentials"][@"AccessKeyId"]
                               accessKeySecret:tokenDictionary[@"data"][@"Credentials"][@"AccessKeySecret"]
                                 securityToken:tokenDictionary[@"data"][@"Credentials"][@"SecurityToken"]];
            }else{
                [SVProgressHUD showErrorWithStatus:str];
            }
        }
    } failoperation:^(NSError *error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        [SVProgressHUD showErrorWithStatus:@"网络延迟，请稍后再试"];
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
