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
#import "LiveInformationTableViewCell.h"
#import "LiveBaseInformationTableViewCell.h"
#import "LiveCharmPhotoModel.h"
#import "LivePayView.h"
#import "SetPayPasswordViewController.h"
#import "RetrievePayPasswordViewController.h"
#import "AwardViewController.h"
#import "LiveCharmPhotoPayView.h"
#import "ShareView.h"

static NSString *const LIVECHARM_TABLEVIEW_ID = @"livecharm_tableview_id";
static NSString *const LIVEINFORMATION_TABLEVIEW_ID = @"liveinformation_tableview_id";
static NSString *const EMPLOYEEDETAIL_ID = @"EmployeeDetailTableViewCell";
static NSString *const PARTTIMETABLEVIEW_ID = @"PartTimeTableViewCell";
static NSString *const BASEINFORMATION_TABLEVIEW_ID = @"base_tableview_id";

@interface EmployeeDetailViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate, SDCycleScrollViewDelegate, ZLPhotoPickerBrowserViewControllerDelegate,AliyunVodPlayerDelegate> {
    UILabel *fans;//粉丝数量，因为要修改数目
    int fansCount;//粉丝数
    int laudCount;//点赞数
    BOOL isCanTalk;//是否能聊天
    NSString *price;//查看资料或聊天的价格
}

@property (nonatomic,strong) UIView *nav;//渐显view
@property (nonatomic,strong) NSMutableDictionary* dataInfo;

@property (nonatomic,strong) AliyunVodPlayer *aliPlayer;
@property (nonatomic,strong) UIView *playerView;//播放view
@property (nonatomic,strong) UIProgressView *progressView;//加载进度
@property (nonatomic,strong) UISlider *sliderProgress;//当前播放进度，可拖拽
@property (nonatomic, strong) NSTimer *timer;//计时器，时时获取currentTime
@property (nonatomic, strong) UILabel *currentTimeLabel;//当前播放时间
@property (nonatomic, strong) UILabel *totalTimeLabel;//视频总时长

@property (nonatomic,strong) NSArray *charmPhotoArray;//主播魅力照片
@property (strong, nonatomic) ShareView *shareView;

@end

@implementation EmployeeDetailViewController

- (void)dealloc {
    [self.aliPlayer releasePlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
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
    ScrollViewContentInsetAdjustmentNever(self, self.tableView);
    //渐显view
    UIView *nav = [EBUtility viewfrome:CGRectMake(0, 0, SCREEN_WIDTH, 64) andColor:UIColor.whiteColor andView:self.view];
    UIView *lineView = [EBUtility viewfrome:CGRectMake(0, 63.5, SCREEN_WIDTH, 0.5) andColor:[UIColor colorFromHexString:@"b2b2b2"] andView:nav];
    UILabel *title = [EBUtility labfrome:CGRectMake(0, 32, SCREEN_WIDTH, 20) andText:@"昵称" andColor:[UIColor colorFromHexString:@"333333"] andView:nav];
    title.font = [UIFont systemFontOfSize:18];
    title.textAlignment = NSTextAlignmentCenter;
    title.tag = 1000;
    nav.alpha = 0;
    self.nav = nav;
    UIButton *back = [EBUtility btnfrome:CGRectMake(0, 25, 40, 40) andText:@"" andColor:nil andimg:[UIImage imageNamed:@"back"] andView:self.view];
    back.tag = 1001;
    [back addTarget:self action:@selector(backBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [self downloadInfo];
    if (self.type != 2) {
        [self detailBottomButton];
    }
    else {
        UIButton *share = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH-45, 25, 40, 40) andText:@"" andColor:nil andimg:[UIImage imageNamed:@"share_white"] andView:self.view];
        share.tag = 1002;
        [share addTarget:self action:@selector(shareBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self queryJurisdictionRequestType:@"2" TargetId:self.employeeId Index:0];
    });
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationSelector:) name:@"SHARENOTIFICATION" object:nil];
}

- (void)notificationSelector:(NSNotification *)notification {
    NSString *object = notification.object;
    if ([object isEqualToString:@"success"]) {
        [self.shareView dismiss];
        [SVProgressHUD showSuccessWithStatus:@"分享成功"];
    }
    else {
        [SVProgressHUD showErrorWithStatus:@"分享失败"];
    }
}

- (void)detailBottomButton {
    self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 44);
    UIButton* phone = [EBUtility btnfrome:CGRectMake(0, SCREEN_HEIGHT - 44, SCREEN_WIDTH/2, 44) andText:@"电话" andColor:[UIColor whiteColor] andimg:nil andView:self.view];
    phone.backgroundColor = [EBUtility colorWithHexString:@"#73CDFB" alpha:1];
    [phone addTarget:self action:@selector(conBtn:) forControlEvents:UIControlEventTouchUpInside];
    phone.tag = 100;
    UIButton* confirm = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT - 44, SCREEN_WIDTH/2, 44) andText:@"下单" andColor:[UIColor whiteColor] andimg:nil andView:self.view];
    confirm.backgroundColor = Nav_color;
    confirm.tag = 101;
    [confirm addTarget:self action:@selector(conBtn:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configBottomView {
    if ([self.dataInfo[@"user_id"] integerValue] == DataStore.sharedDataStore.userid.integerValue) {
        return;
    }
    self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 48);
    UIButton* imBtn = [EBUtility btnfrome:CGRectMake(0, SCREEN_HEIGHT - 48, SCREEN_WIDTH/3, 48) andText:@"聊天" andColor:[UIColor colorFromHexString:@"333333"] andimg:[UIImage imageNamed:@"live_detail_review"] andView:self.view];
    imBtn.backgroundColor = UIColor.whiteColor;
    imBtn.tag = 777;
    imBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [imBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -4, 0, 4)];
    [imBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 4, 0, -4)];
    [imBtn addTarget:self action:@selector(clickLiveBottomBtn:) forControlEvents:UIControlEventTouchUpInside];
    UIButton* likeBtn = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH/3, SCREEN_HEIGHT - 48, SCREEN_WIDTH/3, 48) andText:@"0" andColor:[UIColor colorFromHexString:@"333333"] andimg:[UIImage imageNamed:@"live_detail_like"] andView:self.view];
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
    
    laudCount = [self.dataInfo[@"laud_count"] intValue];
    [likeBtn setTitle:[NSString stringWithFormat:@"%d",laudCount] forState:0];
    if ([self.dataInfo[@"is_laud"] integerValue] == 0) {
        [likeBtn setImage:[UIImage imageNamed:@"live_detail_like"] forState:0];
        likeBtn.selected = NO;
    }
    else {
        [likeBtn setImage:[UIImage imageNamed:@"live_detail_liked"] forState:0];
        likeBtn.selected = YES;
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

//查询权限  是否能查看微信/聊天/查看魅力图片
- (void)queryJurisdictionRequestType:(NSString *)type TargetId:(NSString *)targetId Index:(NSInteger)index {
    if (!DataStore.sharedDataStore.token) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController* vc = [sb instantiateViewControllerWithIdentifier:@"loginPWD"];
        [self.navigationController pushViewController:vc animated:1];
        return;
        
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:DataStore.sharedDataStore.token forKey:@"token"];
    [dict setObject:type forKey:@"type"];
    [dict setObject:targetId forKey:@"target_id"];
    NSString *requestUrl = [NSString stringWithFormat:@"%@anchor/check_authority",HttpURLString];
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:requestUrl Paremeters:dict successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            LiveCharmPhotoModel *model = self.charmPhotoArray[index];
            if (code == 1) {//有权限 聊天/查看微信和指定魅力照片
                if (type.integerValue == 2) {//聊天/查看微信
                    isCanTalk = YES;
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                }
                else if (type.integerValue == 1) {
                    model.is_charge = @"0";//图片
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
                    [self configZLPhotoPickerBrowserWithArray:self.charmPhotoArray Index:index];
                }
            }
            else if (code == 0) {//没权限 聊天/查看微信和指定魅力照片
                price = object[@"data"];
                if (type.integerValue == 1) {//图片
                    [self showCharmPhotoPayViewWithPrice:model.fee Type:@"2" TargetId:targetId Index:index];
                }
            }
        }
    } failoperation:^(NSError *error) {
    }];
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

//viewdidload查询详情
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
                    self.charmPhotoArray = [LiveCharmPhotoModel mj_objectArrayWithKeyValuesArray:self.dataInfo[@"img_arr"]];
                    [self.tableView reloadData];
                    [self configBottomView];
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
        UIButton *back = [self.view viewWithTag:1001];
        UIButton *share = [self.view viewWithTag:1002];
        if (self.nav.alpha > 0.6) {
            [back setImage:[UIImage imageNamed:@"back_black"] forState:0];
            [share setImage:[UIImage imageNamed:@"share_black"] forState:0];
        }
        else {
            [back setImage:[UIImage imageNamed:@"back"] forState:0];
            [share setImage:[UIImage imageNamed:@"share_white"] forState:0];
        }
    }
}
- (void)backBtn:(UIButton*)sender {
    [self.navigationController popViewControllerAnimated:1];
}

#pragma mark - 分享
- (void)shareBtn:(UIButton *)sender {
    self.shareView = [[ShareView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-140, SCREEN_WIDTH, 140) WithShareUrl:SHARE_WEBURL ShareTitle:@"我是主播" WithShareDescription:@"这是我的主播魅力名片，我为自己代言，欢迎来围观"];
    [self.shareView show];
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
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController* vc = [sb instantiateViewControllerWithIdentifier:@"loginPWD"];
        [self.navigationController pushViewController:vc animated:1];
        return;
    }
    if (sender.tag == 777) {
        if (isCanTalk){
            NIMSession *session = [NIMSession session:[NSString stringWithFormat:@"%@",self.dataInfo[@"invitecode"]] type:NIMSessionTypeP2P];
            ChatViewController *vc = [[ChatViewController alloc] initWithSession:session];
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            [self lookWechatSelector];
        }
    }
    else if (sender.tag == 888) {
        [self likeRequest:sender];
    }
    else if (sender.tag == 999) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        AwardViewController *vc = [sb instantiateViewControllerWithIdentifier:@"avc"];
        vc.orderInfo = self.dataInfo;
        vc.type = 2;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

//点赞/取消点赞
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
    [dict setObject:@"3" forKey:@"type"];
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
                    laudCount++;
                    [sender setImage:[UIImage imageNamed:@"live_detail_liked"] forState:UIControlStateNormal];
                }
                else {
                    laudCount--;
                    [sender setImage:[UIImage imageNamed:@"live_detail_like"] forState:UIControlStateNormal];
                }
                [sender setTitle:[NSString stringWithFormat:@"%d",laudCount] forState:0];
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

#pragma mark - 配置tableview的headerview
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
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self configMediaPlayer];
        });
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
    
//    UIImageView *statusImg = [EBUtility imgfrome:CGRectZero andImg:[UIImage imageNamed:@"live_detail_online"] andView:headerView];
//    [statusImg mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(sexImg.mas_centerY);
//        make.left.equalTo(realnamedImg.mas_right).offset(7);
//        make.size.mas_equalTo(CGSizeMake(29, 18));
//    }];
    
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
    
    fans = [EBUtility labfrome:CGRectZero andText:@"粉丝数量" andColor:[UIColor whiteColor] andView:headerView];
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
    if (self.type != 2) {
        fans.hidden = YES;
        attentionBtn.hidden = YES;
    }
    else {
        fans.hidden = NO;
        attentionBtn.hidden = NO;
    }
    
    if (self.dataInfo.count > 0){
        [photo sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.dataInfo[@"photo"]]] placeholderImage:[UIImage imageNamed:@"ico_head"]];
        name.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"nickname"]];
        
        UILabel* title = [self.nav viewWithTag:1000];
        title.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"nickname"]];
        
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
        if ([self.dataInfo[@"vip_grade"] integerValue] == 0) {
            [vipImg mas_updateConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(sexImg.mas_centerY);
                make.left.equalTo(age.mas_right);
                make.size.mas_equalTo(CGSizeMake(0, 20));
            }];
        }
        else {
            vipImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"vip_grade_%@",self.dataInfo[@"vip_grade"]]];
        }
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
        fansCount = [self.dataInfo[@"follow_count"] intValue];
        fans.text = [NSString stringWithFormat:@"%d粉丝",fansCount];
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
            self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
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

#pragma mark - 关注/取消关注
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
                    fansCount++;
                    [sender setImage:[UIImage imageNamed:@"live_detail_attentioned"] forState:UIControlStateNormal];
                }
                else {
                    fansCount--;
                    [sender setImage:[UIImage imageNamed:@"live_detail_attention"] forState:UIControlStateNormal];
                }
                fans.text = [NSString stringWithFormat:@"%d粉丝",fansCount];
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
            NSInteger count = self.charmPhotoArray.count;
            if (count%4 == 0) {
                count = (count/4);
            }
            else {
                count = (count/4 + 1);
            }
            return count*((SCREEN_WIDTH-30-30)/4 + 10);
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
    if (self.type == 1) {
        name.text = @"最近发布";
    }
    else if (self.type == 2) {
        name.text = @"主播资料";
    }
    if (section == 1) {
        name.text = @"资料";
    }
    else if (section == 2) {
        name.text = @"主播魅力";
    }
    [name sizeToFit];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
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
            [cell setContentWithDic:self.dataInfo IsTalk:isCanTalk];
            [cell.lookButton addTarget:self action:@selector(lookWechatSelector) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }
    }
    else if (indexPath.section == 1) {
        if (self.type == 2) {
            LiveCharmTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LIVECHARM_TABLEVIEW_ID];
            cell.liveCharmArray = self.charmPhotoArray;
            WEAKSELF
            cell.didSelectItemBlock = ^(NSInteger index) {
                LiveCharmPhotoModel *model = weakSelf.charmPhotoArray[index];
                //如果这张照片时收费照片，需要再去请求一下自己能否看，因为照片是针对所有人的，请求是只针对自己
                if (model.is_charge.intValue == 1) {
                    [self queryJurisdictionRequestType:@"1" TargetId:model.id Index:index];
                }
                else {
                    [weakSelf configZLPhotoPickerBrowserWithArray:weakSelf.charmPhotoArray Index:index];
                }
            };
            return cell;
        }
        else {
            LiveBaseInformationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BASEINFORMATION_TABLEVIEW_ID];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setContentWithDic:self.dataInfo Type:self.type];
            return cell;
        }
    }
    else if (indexPath.section == 2) {
        LiveBaseInformationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BASEINFORMATION_TABLEVIEW_ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setContentWithDic:self.dataInfo Type:2];
        return cell;
    }
    return UITableViewCell.new;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.type == 0){
        if (indexPath.section == 1){//跳转技能详情
            UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            GameBabyDetailViewController* vc = [sb instantiateViewControllerWithIdentifier:@"gbd"];
            vc.gbId = [NSString stringWithFormat:@"%@",self.dataInfo[@"skilllist"][indexPath.row][@"id"]];
            [self.navigationController pushViewController:vc animated:1];
        }
    }
}

//查看微信号/聊天
- (void)lookWechatSelector {
    [self showPayViewWithPrice:price Type:@"3" TargetId:self.dataInfo[@"id"]];
}

#pragma mark - 付款/微信/聊天
- (void)showPayViewWithPrice:(NSString *)money Type:(NSString *)type TargetId:(NSString *)targetId {
    LivePayView *freeView = [[LivePayView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-261)/2, (SCREEN_HEIGHT-284)/2, 261, 284) Price:money];
    WEAKSELF
    typeof(freeView) __weak weakFreeView = freeView;
    freeView.confirmSelecrBlock = ^(NSInteger index) {
        [weakFreeView dismiss];
        if (index == 0) {
            UserModel *user = UserModel.sharedUser;
            if ([user.is_paypwd isEqualToString:@"0"]){
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                SetPayPasswordViewController* vc = [sb instantiateViewControllerWithIdentifier:@"spp"];
                [weakSelf.navigationController pushViewController:vc animated:1];
                return;
            }
            //弹起支付密码alert
            CustomAlertView* alert = [[CustomAlertView alloc] initWithType:6];
            alert.resultDate = ^(NSString *date) {
                [weakSelf payRequestWithPwd:date Price:money Type:type TargetId:targetId];
            };
            alert.resultIndex = ^(NSInteger index) {
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                RetrievePayPasswordViewController* vc = [sb instantiateViewControllerWithIdentifier:@"rpp"];
                [weakSelf.navigationController pushViewController:vc animated:1];
            };
            [alert showAlertView];
        }
    };
    [freeView show];
}

#pragma mark - 付款/魅力图片
- (void)showCharmPhotoPayViewWithPrice:(NSString *)money Type:(NSString *)type TargetId:(NSString *)targetId Index:(NSInteger)index {
    LiveCharmPhotoPayView *payView = [[LiveCharmPhotoPayView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-171)/2, (SCREEN_HEIGHT-177)/2, 171, 177) Price:money Index:index];
    WEAKSELF
    typeof(payView) __weak weakPayView = payView;
    payView.confirmPayBlock = ^(NSInteger indexTag) {
        [weakPayView dismiss];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选取支付方式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:nil];
        UIAlertAction *pay = [UIAlertAction actionWithTitle:@"余额支付" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UserModel *user = UserModel.sharedUser;
            if ([user.is_paypwd isEqualToString:@"0"]){
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                SetPayPasswordViewController* vc = [sb instantiateViewControllerWithIdentifier:@"spp"];
                [weakSelf.navigationController pushViewController:vc animated:1];
                return;
            }
            //弹起支付密码alert
            CustomAlertView* alert = [[CustomAlertView alloc] initWithType:6];
            alert.resultDate = ^(NSString *date) {
                [weakSelf payRequestWithPwd:date Price:money Type:type TargetId:targetId];
            };
            alert.resultIndex = ^(NSInteger index) {
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                RetrievePayPasswordViewController* vc = [sb instantiateViewControllerWithIdentifier:@"rpp"];
                [weakSelf.navigationController pushViewController:vc animated:1];
            };
            [alert showAlertView];
        }];
        [alert addAction:pay];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    };
    [payView show];
}

//提交支付
- (void)payRequestWithPwd:(NSString *)pwd Price:(NSString *)money Type:(NSString *)type TargetId:(NSString *)targetId {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    NSDictionary *dic = @{@"token":DataStore.sharedDataStore.token,
                           @"type":type,
                           @"pwd":pwd,
                           @"paytype":@"3",
                           @"target_id":targetId,
                           @"account":money
                           };
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Payment/buy",HttpURLString] Paremeters:dic successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            if (code == 1) {
                [SVProgressHUD showSuccessWithStatus:@"支付成功"];
                if (type.intValue == 3) {
                    isCanTalk = YES;
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                }
                else if (type.intValue == 2) {
                    for (int i=0; i<self.charmPhotoArray.count; i++) {
                        LiveCharmPhotoModel *model = self.charmPhotoArray[i];
                        if ([model.id isEqualToString:targetId]) {
                            model.is_charge = @"0";
                            [self configZLPhotoPickerBrowserWithArray:self.charmPhotoArray Index:i];
                            break;
                        }
                    }
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
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

#pragma mark - otherDelegate/DataSource
//点击顶部轮播图
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
            [self startVideoPlay];// 播放视频
        }
        else {
            [self configZLPhotoPickerBrowserWithArray:self.dataInfo[@"bgimg"] Index:index-1];
        }
    }
    else {
        [self configZLPhotoPickerBrowserWithArray:self.dataInfo[@"bgimg"] Index:index];
    }
}

//配置图片浏览器
- (void)configZLPhotoPickerBrowserWithArray:(NSArray *)targetArray Index:(NSInteger )index {
    NSArray *bgImgAry = [NSArray array];
    if (targetArray.count>0) {
        ZLPhotoPickerBrowserViewController *pickerBrowser = [[ZLPhotoPickerBrowserViewController alloc] init];
        // 淡入淡出效果
        pickerBrowser.status = UIViewAnimationAnimationStatusFade;
        // 数据源/delegate
        pickerBrowser.delegate = self;
        // 是否可以删除照片
        pickerBrowser.editing = NO;
        // 当前选中的值
        // 展示控制器
        bgImgAry = targetArray;
        NSMutableArray *zlPhotoArray = [NSMutableArray arrayWithCapacity:0];
        for (id object in bgImgAry) {
            NSString *url = @"";
            if ([object isKindOfClass:LiveCharmPhotoModel.class]) {
                LiveCharmPhotoModel *model = (LiveCharmPhotoModel *)object;
                url = model.url;
                pickerBrowser.charmPhotoArray = targetArray;
            }
            else {
                url = (NSString *)object;
            }
            ZLPhotoPickerBrowserPhoto *photo = [ZLPhotoPickerBrowserPhoto photoAnyImageObjWith:url];
            [zlPhotoArray addObject:photo];
        }
        WEAKSELF
        pickerBrowser.paySuccessedBlock = ^{
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
        };
        pickerBrowser.photos = zlPhotoArray;
        pickerBrowser.currentIndex = index;
        [pickerBrowser showPushPickerVc:self];
    }
}

- (void)photoBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser photoDidSelectView:(UIView *)scrollBoxView atIndex:(NSInteger)index {
    [self.navigationController popViewControllerAnimated:NO];
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
