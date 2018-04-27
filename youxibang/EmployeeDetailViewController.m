//
//  EmployeeDetailViewController.m
//  youxibang
//
//  Created by y on 2018/1/19.
//

#import "EmployeeDetailViewController.h"
#import "EmployeeDetailTableViewCell.h"
#import "OrderViewController.h"
#import "GameBabyDetailViewController.h"
#import "PartTimeTableViewCell.h"
#import "LoginViewController.h"
#import "ZLPhotoPickerBrowserViewController.h"
#import <AliyunVodPlayerSDK/AliyunVodPlayerSDK.h>
#import "LiveCharmTableViewCell.h"
#import "LiveFansViewController.h"
#import "LiveInformationTableViewCell.h"
#import "LiveBaseInformationTableViewCell.h"

static NSString *const LIVECHARM_TABLEVIEW_ID = @"livecharm_tableview_id";
static NSString *const LIVEINFORMATION_TABLEVIEW_ID = @"liveinformation_tableview_id";
static NSString *const EMPLOYEEDETAIL_ID = @"EmployeeDetailTableViewCell";
static NSString *const PARTTIMETABLEVIEW_ID = @"PartTimeTableViewCell";
static NSString *const BASEINFORMATION_TABLEVIEW_ID = @"base_tableview_id";

@interface EmployeeDetailViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate, SDCycleScrollViewDelegate, ZLPhotoPickerBrowserViewControllerDelegate,AliyunVodPlayerDelegate>

@property (nonatomic,strong) UIView *nav;//渐显view
@property (nonatomic,strong) NSMutableDictionary* dataInfo;

@property (nonatomic,strong) AliyunVodPlayer *aliPlayer;
@property (nonatomic,strong) UIView *playerView;//播放view
@property (nonatomic,strong) UIProgressView *progressView;//加载进度
@property (nonatomic,strong) UISlider *sliderProgress;//当前播放进度，可拖拽
@property (nonatomic, strong) NSTimer *timer;//计时器，时时获取currentTime
@property (nonatomic, strong) UILabel *currentTimeLabel;//当前播放时间
@property (nonatomic, strong) UILabel *totalTimeLabel;//视频总时长
@end

@implementation EmployeeDetailViewController

- (void)dealloc {
    [self.aliPlayer releasePlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.type = 2;
    self.tableView.frame = CGRectMake(0, -20, SCREEN_WIDTH, SCREEN_HEIGHT + 20);
    self.tableView.showsVerticalScrollIndicator = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;

    self.tableView.tableFooterView = [UIView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableHeaderView = [self configTableViewHeaderView];
    [self.tableView registerClass:EmployeeDetailTableViewCell.class forCellReuseIdentifier:EMPLOYEEDETAIL_ID];
    [self.tableView registerClass:PartTimeTableViewCell.class forCellReuseIdentifier:PARTTIMETABLEVIEW_ID];
    [self.tableView registerNib:[UINib nibWithNibName:@"LiveBaseInformationTableViewCell" bundle:nil] forCellReuseIdentifier:BASEINFORMATION_TABLEVIEW_ID];
    [self.tableView registerNib:[UINib nibWithNibName:@"LiveCharmTableViewCell" bundle:nil] forCellReuseIdentifier:LIVECHARM_TABLEVIEW_ID];
    [self.tableView registerNib:[UINib nibWithNibName:@"LiveInformationTableViewCell" bundle:nil] forCellReuseIdentifier:LIVEINFORMATION_TABLEVIEW_ID];
    //渐显view
    UIView* nav = [EBUtility viewfrome:CGRectMake(0, 0, SCREEN_WIDTH, 64) andColor:Nav_color andView:self.view];
    UILabel* title = [EBUtility labfrome:CGRectMake(0, 0, 100, 30) andText:@"昵称" andColor:[UIColor whiteColor] andView:nav];
    title.font = [UIFont systemFontOfSize:18];
    [title sizeToFit];
    title.centerX = nav.centerX;
    title.centerY = nav.height - 22;
    title.tag = 1000;
    nav.alpha = 0;
    self.nav = nav;
    UIButton* back = [EBUtility btnfrome:CGRectMake(0, 25, 40, 40) andText:@"" andColor:nil andimg:[UIImage imageNamed:@"back"] andView:self.view];
    [back addTarget:self action:@selector(backBtn:) forControlEvents:UIControlEventTouchUpInside];
    UIButton* share = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH-45, 25, 40, 40) andText:@"" andColor:nil andimg:[UIImage imageNamed:@"live_detail_share"] andView:self.view];
    [share addTarget:self action:@selector(shareBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [self downloadInfo];
    [self configBottomView];
    [self configMediaPlayer];
}

- (void)configBottomView {
    //当查看宝贝信息时，显示的bottomview
    if (self.type == 0){
        self.tableView.frame = CGRectMake(0, -20, SCREEN_WIDTH, SCREEN_HEIGHT - 44+20);
        UIButton* phone = [EBUtility btnfrome:CGRectMake(0, SCREEN_HEIGHT - 44, SCREEN_WIDTH/2, 44) andText:@"电话" andColor:[UIColor whiteColor] andimg:nil andView:self.view];
        phone.backgroundColor = [EBUtility colorWithHexString:@"#73CDFB" alpha:1];
        [phone addTarget:self action:@selector(conBtn:) forControlEvents:UIControlEventTouchUpInside];
        phone.tag = 100;
        UIButton* confirm = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT - 44, SCREEN_WIDTH/2, 44) andText:@"下单" andColor:[UIColor whiteColor] andimg:nil andView:self.view];
        confirm.backgroundColor = Nav_color;
        confirm.tag = 101;
        [confirm addTarget:self action:@selector(conBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if (self.type == 2) {
        self.tableView.frame = CGRectMake(0, -20, SCREEN_WIDTH, SCREEN_HEIGHT - 48+20);
        UIButton* imBtn = [EBUtility btnfrome:CGRectMake(0, SCREEN_HEIGHT - 48, SCREEN_WIDTH/3, 48) andText:@"聊天" andColor:[UIColor colorFromHexString:@"333333"] andimg:[UIImage imageNamed:@"live_detail_review"] andView:self.view];
        imBtn.backgroundColor = UIColor.whiteColor;
        imBtn.tag = 777;
        imBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [imBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -4, 0, 4)];
        [imBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 4, 0, -4)];
        [imBtn addTarget:self action:@selector(clickLiveBottomBtn:) forControlEvents:UIControlEventTouchUpInside];
        UIButton* likeBtn = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH/3, SCREEN_HEIGHT - 48, SCREEN_WIDTH/3, 48) andText:@"100" andColor:[UIColor colorFromHexString:@"333333"] andimg:[UIImage imageNamed:@"live_detail_like"] andView:self.view];
        likeBtn.backgroundColor = UIColor.whiteColor;
        likeBtn.tag = 888;
        likeBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [likeBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -4, 0, 4)];
        [likeBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 4, 0, -4)];
        [likeBtn addTarget:self action:@selector(clickLiveBottomBtn:) forControlEvents:UIControlEventTouchUpInside];
        UIButton* tipBtn = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH/3*2, SCREEN_HEIGHT - 48, SCREEN_WIDTH/3, 48) andText:@"打赏" andColor:[UIColor colorFromHexString:@"333333"] andimg:[UIImage imageNamed:@"live_detail_tip"] andView:self.view];
        tipBtn.backgroundColor = UIColor.whiteColor;
        tipBtn.tag = 999;
        tipBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [tipBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -4, 0, 4)];
        [tipBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 4, 0, -4)];
        [tipBtn addTarget:self action:@selector(clickLiveBottomBtn:) forControlEvents:UIControlEventTouchUpInside];
        UILabel *lineLabel = [EBUtility labfrome:CGRectMake(0, SCREEN_HEIGHT - 48, SCREEN_WIDTH, 0.5) andText:@"" andColor:nil andView:self.view];
        lineLabel.backgroundColor = [UIColor colorFromHexString:@"b2b2b2"];
        UILabel *sepLabel1 = [EBUtility labfrome:CGRectMake(SCREEN_WIDTH/3, SCREEN_HEIGHT - 48+9, 0.5, 30) andText:@"" andColor:nil andView:self.view];
        sepLabel1.backgroundColor = [UIColor colorFromHexString:@"b2b2b2"];
        UILabel *sepLabel2 = [EBUtility labfrome:CGRectMake(SCREEN_WIDTH/3*2, SCREEN_HEIGHT - 48+9, 0.5, 30) andText:@"" andColor:nil andView:self.view];
        sepLabel2.backgroundColor = [UIColor colorFromHexString:@"b2b2b2"];
    }
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
    [self.view addSubview:self.playerView];
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

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    [self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
    [self.tableView removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)downloadInfo{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    if (self.type == 0){//宝贝信息
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:self.employeeId forKey:@"buserid"];
        if (![EBUtility isBlankString:[DataStore sharedDataStore].userid]){
            [dict setObject:[DataStore sharedDataStore].userid forKey:@"userid"];
        }
        
        [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Gamebaby/userbabydetail.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
            [SVProgressHUD dismiss];
            [SVProgressHUD setDefaultMaskType:1];
            if (isKindOfNSDictionary(object)){
                NSInteger code = [object[@"errcode"] integerValue];
                NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
                NSLog(@"输出 %@--%@",object,msg);
                
                if (code == 1) {
                    self.dataInfo = [NSMutableDictionary dictionaryWithDictionary:object[@"data"]];
                    self.tableView.tableHeaderView = [self configTableViewHeaderView];
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
    else if (self.type == 1){//雇主信息
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:self.employeeId forKey:@"userid"];
        [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Parttime/partindex.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
            [SVProgressHUD dismiss];
            [SVProgressHUD setDefaultMaskType:1];
            if (isKindOfNSDictionary(object)){
                NSInteger code = [object[@"errcode"] integerValue];
                NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
                NSLog(@"输出 %@--%@",object,msg);
                if (code == 1) {
                    self.dataInfo = [NSMutableDictionary dictionaryWithDictionary:object[@"data"]];
                    self.tableView.tableHeaderView = [self configTableViewHeaderView];
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
    else if (self.type == 2){//主播信息
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:self.employeeId forKey:@"id"];
        if ([DataStore sharedDataStore].token) {
            [dict setObject:[DataStore sharedDataStore].token forKey:@"token"];
        }
        [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@anchor/detail",HttpURLString] Paremeters:dict successOperation:^(id object) {
            [SVProgressHUD dismiss];
            [SVProgressHUD setDefaultMaskType:1];
            if (isKindOfNSDictionary(object)){
                NSInteger code = [object[@"errcode"] integerValue];
                NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
                NSLog(@"输出 %@--%@",object,msg);
                if (code == 1) {
                    self.dataInfo = [NSMutableDictionary dictionaryWithDictionary:object[@"data"]];
                    self.tableView.tableHeaderView = [self configTableViewHeaderView];
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
}
//渐显效果
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        self.nav.alpha = self.tableView.contentOffset.y / 115;
    }
}
- (void)backBtn:(UIButton*)sender {
    [self.navigationController popViewControllerAnimated:1];
}

- (void)shareBtn:(UIButton *)sender {
    
}

//bottomview按键
- (void)conBtn:(UIButton*)sender{
    if ([EBUtility isBlankString:[DataStore sharedDataStore].token]){
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController* vc = [sb instantiateViewControllerWithIdentifier:@"loginPWD"];
        [self.navigationController pushViewController:vc animated:1];
        return;
    }
    if (sender.tag == 100){//电话
        if ([NSString stringWithFormat:@"%@",self.dataInfo[@"is_strangercall"]].integerValue != 1){
            [SVProgressHUD showErrorWithStatus:@"对方已禁止陌生人通话"];
            return;
        }else{//虚拟电话拨打
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",self.dataInfo[@"mobile"]]]];
        }
    }else{//下单
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        OrderViewController* vc = [sb instantiateViewControllerWithIdentifier:@"order"];
        vc.userId = self.employeeId;
        [self.navigationController pushViewController:vc animated:1];
    }
    
}

//主播界面 bottomview按键
- (void)clickLiveBottomBtn:(UIButton *)sender {
    if ([EBUtility isBlankString:[DataStore sharedDataStore].token]){
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController* vc = [sb instantiateViewControllerWithIdentifier:@"loginPWD"];
        [self.navigationController pushViewController:vc animated:1];
        return;
    }
    if (sender.tag == 777) {
        NIMSession *session = [NIMSession session:[NSString stringWithFormat:@"%@",self.dataInfo[@"invitecode"]] type:NIMSessionTypeP2P];
        ChatViewController *vc = [[ChatViewController alloc] initWithSession:session];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (sender.tag == 888) {
        
    }
    else if (sender.tag == 999) {
        
    }
}

- (void)likeRequest:(UIButton *)sender {
    if (!DataStore.sharedDataStore.token) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController* vc = [sb instantiateViewControllerWithIdentifier:@"loginPWD"];
        [self.navigationController pushViewController:vc animated:1];
        return;
    }
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:self.employeeId forKey:@"target_id"];
    [dict setObject:DataStore.sharedDataStore.token forKey:@"token"];
    NSString *requestUrl = [NSString stringWithFormat:@"%@article/laud",HttpURLString];
    if (sender.selected) {
        requestUrl = [NSString stringWithFormat:@"%@article/cancel_laud",HttpURLString];
    }
    
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:requestUrl Paremeters:dict successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            if (code == 1) {
                sender.selected = !sender.selected;
                if (sender.selected) {
                    [sender setImage:[UIImage imageNamed:@"live_detail_liked"] forState:UIControlStateNormal];
                }
                else {
                    [sender setImage:[UIImage imageNamed:@"live_detail_like"] forState:UIControlStateNormal];
                }
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)configTableViewHeaderView {
    UIView *headerView = [EBUtility viewfrome:CGRectMake(0, 0, SCREEN_WIDTH, 225 * ADAPTATIONRATIO) andColor:[UIColor whiteColor] andView:nil];
    //轮播图
    NSMutableArray *bgImgAry = [NSMutableArray array];
    BOOL existBgimg = NO;
    BOOL existVideo = NO;
    if (self.dataInfo) {
        if (self.dataInfo[@"bgimg"]) {
            if ([self.dataInfo[@"bgimg"] count]>0) {
                existBgimg = YES;
            }
        }
        if (self.dataInfo[@"video"]) {
            if (isKindOfNSDictionary(self.dataInfo[@"video"])) {
                if (isKindOfNSDictionary(self.dataInfo[@"video"][@"VideoMeta"])) {
                    if (self.dataInfo[@"video"][@"VideoMeta"][@"CoverURL"] || self.dataInfo[@"video"][@"VideoMeta"][@"VideoId"]) {
                        existVideo = YES;
                    }
                }
            }
        }
    }
    if (existBgimg) {
        for (NSString *str in self.dataInfo[@"bgimg"]) {
            [bgImgAry addObject:str];
        }
    }
    else {
        bgImgAry = @[@"img_my111"].mutableCopy;
    }
    if (existVideo) {
        [bgImgAry insertObject:self.dataInfo[@"video"][@"VideoMeta"][@"CoverURL"] atIndex:0];
    }
    SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetHeight(headerView.frame)) imageNamesGroup:bgImgAry];
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
    
    UIImageView* vipImg = [EBUtility imgfrome:CGRectZero andImg:[UIImage imageNamed:@"live_detail_gold"] andView:headerView];
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
    
    UIImageView *statusImg = [EBUtility imgfrome:CGRectZero andImg:[UIImage imageNamed:@"live_detail_online"] andView:headerView];
    [statusImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(sexImg.mas_centerY);
        make.left.equalTo(realnamedImg.mas_right).offset(7);
        make.size.mas_equalTo(CGSizeMake(29, 18));
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
    
    UILabel *fans = [EBUtility labfrome:CGRectZero andText:@"粉丝数量" andColor:[UIColor whiteColor] andView:headerView];
    fans.textAlignment = NSTextAlignmentRight;
    fans.font = [UIFont systemFontOfSize:13.0];
    [fans mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(sexImg.mas_centerY);
        make.right.equalTo(headerView.mas_right).offset(-15);
        make.size.mas_equalTo(CGSizeMake(100, 13));
    }];
    
    UIButton *attentionBtn = [EBUtility btnfrome:CGRectZero andText:@"" andColor:nil andimg:[UIImage imageNamed:@"live_detail_attention"] andView:headerView];
    [attentionBtn addTarget:self action:@selector(payAttentionTo:) forControlEvents:UIControlEventTouchUpInside];
    [attentionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(fans.mas_top).offset(-6);
        make.right.equalTo(headerView.mas_right).offset(-15);
        make.size.mas_equalTo(CGSizeMake(65, 22));
    }];
    
    if (self.dataInfo.count > 0){
        [photo sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.dataInfo[@"photo"]]] placeholderImage:[UIImage imageNamed:@"ico_head"]];
        name.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"nickname"]];
        
        UILabel* title = [self.nav viewWithTag:1000];
        title.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"nickname"]];
        [title sizeToFit];
        
        if ([self.dataInfo[@"sex"] integerValue] == 1) {
            sexImg.image = [UIImage imageNamed:@"live_detail_male"];
        }
        else {
            sexImg.image = [UIImage imageNamed:@"live_detail_female"];
        }
        if (self.type == 0){
            age.text = [NSString stringWithFormat:@"%@岁\t",self.dataInfo[@"birthday"]];
        }
        else {
            age.text = [NSString stringWithFormat:@"%@岁\t",self.dataInfo[@"age"]];
        }
        NSString *vipimgstr = @"";
        if ([self.dataInfo[@"vip_grade"] integerValue] == 1) {
            vipimgstr = @"live_detail_copper";
        }
        else if ([self.dataInfo[@"vip_grade"] integerValue] == 2) {
            vipimgstr = @"live_detail_silver";
        }
        else if ([self.dataInfo[@"vip_grade"] integerValue] == 3) {
            vipimgstr = @"live_detail_gold";
        }
        else if ([self.dataInfo[@"vip_grade"] integerValue] == 4) {
            vipimgstr = @"live_detail_diamond";
        }
        else if ([self.dataInfo[@"vip_grade"] integerValue] == 0) {
            [vipImg mas_updateConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(sexImg.mas_centerY);
                make.left.equalTo(age.mas_right);
                make.size.mas_equalTo(CGSizeMake(0, 20));
            }];
        }
        vipImg.image = [UIImage imageNamed:vipimgstr];
        if ([self.dataInfo[@"is_realauth"] integerValue] == 1) {
            realnamedImg.image = [UIImage imageNamed:@"live_detail_realnamed"];
        }
        else {
            [realnamedImg mas_updateConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(sexImg.mas_centerY);
                make.left.equalTo(vipImg.mas_right);
                make.size.mas_equalTo(CGSizeMake(0, 20));
            }];
        }
        fans.text = [NSString stringWithFormat:@"%@粉丝",self.dataInfo[@"follow_count"]];
        if ([self.dataInfo[@"is_follow"] integerValue] == 0) {
            [attentionBtn setImage:[UIImage imageNamed:@"live_detail_attention"] forState:0];
            attentionBtn.selected = NO;
        }
        else if ([self.dataInfo[@"is_follow"] integerValue] == 1) {
            [attentionBtn setImage:[UIImage imageNamed:@"live_detail_attentioned"] forState:0];
            attentionBtn.selected = YES;
        }
        
        if ([NSString stringWithFormat:@"%@",self.dataInfo[@"isable"]].integerValue == 2) {
            UIButton* phone = [self.view viewWithTag:100];
            phone.hidden = YES;
            UIButton* com = [self.view viewWithTag:101];
            com.hidden = YES;
            self.tableView.frame = CGRectMake(0, -20, SCREEN_WIDTH, SCREEN_HEIGHT + 20);
        }
        else {
            if ([NSString stringWithFormat:@"%@",self.dataInfo[@"is_strangercall"]].integerValue != 1) {
                UIButton* phone = [self.view viewWithTag:100];
                phone.hidden = YES;
                UIButton* com = [self.view viewWithTag:101];
                com.width = SCREEN_WIDTH;
                com.x = 0;
            }
        }
    }
    return headerView;
}

- (void)payAttentionTo:(UIButton *)sender {
    if (!DataStore.sharedDataStore.token) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController* vc = [sb instantiateViewControllerWithIdentifier:@"loginPWD"];
        [self.navigationController pushViewController:vc animated:1];
        return;
    }
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:self.employeeId forKey:@"target_id"];
    [dict setObject:DataStore.sharedDataStore.token forKey:@"token"];
    NSString *requestUrl = [NSString stringWithFormat:@"%@member/follow",HttpURLString];
    if (sender.selected) {
        requestUrl = [NSString stringWithFormat:@"%@member/cancel_follow",HttpURLString];
    }
    
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:requestUrl Paremeters:dict successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            if (code == 1) {
                sender.selected = !sender.selected;
                if (sender.selected) {
                    [sender setImage:[UIImage imageNamed:@"live_detail_attentioned"] forState:UIControlStateNormal];
                }
                else {
                    [sender setImage:[UIImage imageNamed:@"live_detail_attention"] forState:UIControlStateNormal];
                }
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

#pragma mark - tableViewDelegate/DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.type == 2) {
        return 3;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0){
        if (self.type == 0){//技能列表
            return ((NSDictionary*)self.dataInfo[@"skilllist"]).count;
        }else if (self.type == 1){//最近发布列表
            return ((NSDictionary*)self.dataInfo[@"list"]).count;
        }
    }
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (self.type == 2) {
            return 189;
        }
    }
    else if (indexPath.section == 1) {
        if (self.type == 2) {
            return (SCREEN_WIDTH - 60)/4*2+10+20;
        }
        return 125;
    }
    else if (indexPath.section == 2) {
        return 125;
    }
    return UITableViewAutomaticDimension;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        if (self.type == 2) {
            return 64;
        }
    }
    return 60;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [EBUtility viewfrome:CGRectMake(0, 0, SCREEN_WIDTH, 65) andColor:[UIColor whiteColor] andView:nil];
    UILabel* lab = [EBUtility labfrome:CGRectMake(0, 0, SCREEN_WIDTH, 15) andText:@"" andColor:nil andView:headerView];
    lab.backgroundColor = [UIColor colorFromHexString:@"f0f4f8"];
    UILabel* name = [EBUtility labfrome:CGRectMake(15, 30, 5, 15) andText:@"技能" andColor:[UIColor colorFromHexString:@"333333"] andView:headerView];
    name.font = [UIFont systemFontOfSize:14.0];
    if (self.type == 1){
        name.text = @"最近发布";
    }
    else if (self.type == 2) {
        name.text = @"主播资料";
    }
    if (section == 1){
        name.text = @"资料";
    }
    else if (section == 2) {
        name.text = @"主播魅力";
    }
    [name sizeToFit];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        if (self.type == 1){
            PartTimeTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:PARTTIMETABLEVIEW_ID];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setViewWithDic:self.dataInfo[@"list"][indexPath.row]];
            return cell;
        }
        else if (self.type == 0) {
            EmployeeDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:EMPLOYEEDETAIL_ID];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setViewWithDic:self.dataInfo[@"skilllist"][indexPath.row]];
            return cell;
        }
        else {
            LiveInformationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LIVEINFORMATION_TABLEVIEW_ID];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setContentWithDic:self.dataInfo];
            return cell;
        }
    }
    else if (indexPath.section == 1){
        if (self.type == 2) {
            LiveCharmTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LIVECHARM_TABLEVIEW_ID];
            
            return cell;
        }
        else {
            LiveBaseInformationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BASEINFORMATION_TABLEVIEW_ID];
            cell.idLabel.text = [NSString stringWithFormat:@"ID：%@",self.dataInfo[@"id"]];
            if (self.type == 1){
                cell.constellationLabel.text = [NSString stringWithFormat:@"星座：%@",self.dataInfo[@"constellation"]];
            }else {
                cell.constellationLabel.text = [NSString stringWithFormat:@"星座：%@",self.dataInfo[@"starsign"]];
            }
            cell.hobbyLabel.text = [NSString stringWithFormat:@"爱好：%@",self.dataInfo[@"interest"]];
            cell.signLabel.text = [NSString stringWithFormat:@"签名：%@",self.dataInfo[@"mysign"]];
            return cell;
        }
    }
    else if (indexPath.section == 2) {
        LiveBaseInformationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BASEINFORMATION_TABLEVIEW_ID];
        cell.idLabel.text = [NSString stringWithFormat:@"ID：%@",self.dataInfo[@"id"]];
        cell.constellationLabel.text = [NSString stringWithFormat:@"星座：%@",self.dataInfo[@"starsign"]];
        cell.hobbyLabel.text = [NSString stringWithFormat:@"爱好：%@",self.dataInfo[@"interest"]];
        cell.signLabel.text = [NSString stringWithFormat:@"签名：%@",self.dataInfo[@"mysign"]];
        return cell;
    }
    return UITableViewCell.new;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.type == 0){
        if (indexPath.section == 0){//跳转技能详情
//            UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//            GameBabyDetailViewController* vc = [sb instantiateViewControllerWithIdentifier:@"gbd"];
//            vc.gbId = [NSString stringWithFormat:@"%@",self.dataInfo[@"skilllist"][indexPath.row][@"id"]];
//            [self.navigationController pushViewController:vc animated:1];
            LiveFansViewController *fansCon = [LiveFansViewController new];
            [self.navigationController pushViewController:fansCon animated:YES];
        }
    }
}

#pragma mark - otherDelegate/DataSource

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    BOOL existVideo = NO;
    if (self.dataInfo) {
        if (self.dataInfo[@"video"]) {
            if (isKindOfNSDictionary(self.dataInfo[@"video"])) {
                if (isKindOfNSDictionary(self.dataInfo[@"video"][@"VideoMeta"])) {
                    if (self.dataInfo[@"video"][@"VideoMeta"][@"CoverURL"] || self.dataInfo[@"video"][@"VideoMeta"][@"VideoId"]) {
                        existVideo = YES;
                    }
                }
            }
        }
    }
    if (existVideo) {
        if (index == 0) {
//            播放视频
            [self startVideoPlay];
        }
        else {
            [self clickPhotoWithIndex:index-1];
        }
    }
    else {
        [self clickPhotoWithIndex:index];
    }
}

- (void)clickPhotoWithIndex:(NSInteger)index {
    ZLPhotoPickerBrowserViewController *pickerBrowser = [[ZLPhotoPickerBrowserViewController alloc] init];
    // 淡入淡出效果
    pickerBrowser.status = UIViewAnimationAnimationStatusFade;
    // 数据源/delegate
    pickerBrowser.delegate = self;
    // 是否可以删除照片
    pickerBrowser.editing = NO;
    // 当前选中的值
    // 展示控制器
    NSArray *bgImgAry = [NSArray array];
    if (self.dataInfo) {
        if ([self.dataInfo[@"bgimg"] count]>0) {
            bgImgAry = self.dataInfo[@"bgimg"];
            NSMutableArray *zlPhotoArray = [NSMutableArray arrayWithCapacity:0];
            for (NSString *url in bgImgAry) {
                ZLPhotoPickerBrowserPhoto *photo = [ZLPhotoPickerBrowserPhoto photoAnyImageObjWith:url];
                [zlPhotoArray addObject:photo];
            }
            pickerBrowser.photos = zlPhotoArray;
            pickerBrowser.currentIndex = index;
            [pickerBrowser showPushPickerVc:self];
        }
        else {
            bgImgAry = @[@"img_my111"];
        }
    }
    else {
        bgImgAry = @[@"img_my111"];
    }
}

- (void)photoBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser photoDidSelectView:(UIView *)scrollBoxView atIndex:(NSInteger)index {
    [self.navigationController popViewControllerAnimated:YES];
}

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
    if ([EBUtility isBlankString:[DataStore sharedDataStore].token]){
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController* vc = [sb instantiateViewControllerWithIdentifier:@"loginPWD"];
        [self.navigationController pushViewController:vc animated:1];
        return;
    }
    //使用vid+STS方式播放（点播用户推荐使用）
    if (self.aliPlayer.playerState == 4) {
        [self.aliPlayer resume];
    }
    else if (self.aliPlayer.playerState == 6) {
        [self.aliPlayer replay];
    }
    else {
        [self getVideoUploadToken];
    }
    self.playerView.hidden = NO;
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
    //format of hour
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",seconds/3600];
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
    [dict setObject:[DataStore sharedDataStore].token forKey:@"token"];
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@video/get_token",HttpURLString] Paremeters:dict successOperation:^(id response) {
        if (isKindOfNSDictionary(response)) {
            NSInteger msg = [[response objectForKey:@"errcode"] integerValue];
            NSString *str = [response objectForKey:@"message"];
            if (msg == 1) {
                NSDictionary *tokenDictionary = (NSDictionary *)response;
                [self.aliPlayer prepareWithVid:self.dataInfo[@"video"][@"VideoMeta"][@"VideoId"]
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
