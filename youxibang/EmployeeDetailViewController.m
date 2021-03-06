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
#import "VipWebViewController.h"
#import "AliPlayerViewController.h"
#import "TopUpAndWithdrawViewController.h"

static NSString *const LIVECHARM_TABLEVIEW_ID = @"livecharm_tableview_id";
static NSString *const LIVEINFORMATION_TABLEVIEW_ID = @"liveinformation_tableview_id";
static NSString *const EMPLOYEEDETAIL_ID = @"EmployeeDetailTableViewCell";
static NSString *const PARTTIMETABLEVIEW_ID = @"PartTimeTableViewCell";
static NSString *const BASEINFORMATION_TABLEVIEW_ID = @"base_tableview_id";

@interface EmployeeDetailViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate, SDCycleScrollViewDelegate, ZLPhotoPickerBrowserViewControllerDelegate> {
    UILabel *fans;//粉丝数量，因为要修改数目
    int fansCount;//粉丝数
    int laudCount;//点赞数
    BOOL isCanTalk;//是否能聊天
    NSString *price;//查看资料或聊天的价格
    NSDictionary *adDataInfo;//查询会员是否能够点击（应对审核）
    BOOL hadRequestLimitOfWechat_IM;//是都请求过是否有查看微信号和聊天的权限
    BOOL isCanPlayVideo;//是否有播放视频的权限(只针对非会员，因为会员可以看视频)
}

@property (nonatomic,strong) UIView *nav;//渐显view
@property (nonatomic,strong) NSMutableDictionary* dataInfo;

@property (nonatomic,strong) NSArray *charmPhotoArray;//主播魅力照片
@property (strong, nonatomic) ShareView *shareView;

@end

@implementation EmployeeDetailViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configUI];
    [self downloadInfo];
    if (self.type != 2) {
        if (self.type == 0) {
            [self detailBottomButton];
        }
    }
    else {
        UIButton *share = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH-45, StatusBarHeight-20+25, 40, 40) andText:@"" andColor:nil andimg:[UIImage imageNamed:@"share_white"] andView:self.view];
        share.tag = 1002;
        [share addTarget:self action:@selector(shareBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationSelector:) name:@"SHARENOTIFICATION" object:nil];
}

- (void)configUI {
    self.view.backgroundColor = UIColor.groupTableViewBackgroundColor;
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
    UIView *nav = [EBUtility viewfrome:CGRectMake(0, 0, SCREEN_WIDTH, 44+StatusBarHeight) andColor:UIColor.whiteColor andView:self.view];
    UIView *lineView = [EBUtility viewfrome:CGRectMake(0, StatusBarHeight+43.5, SCREEN_WIDTH, 0.5) andColor:[UIColor colorFromHexString:@"b2b2b2"] andView:nav];
    UILabel *title = [EBUtility labfrome:CGRectMake(0, StatusBarHeight-20+32, SCREEN_WIDTH, 20) andText:@"昵称" andColor:[UIColor colorFromHexString:@"333333"] andView:nav];
    title.font = [UIFont systemFontOfSize:18];
    title.textAlignment = NSTextAlignmentCenter;
    title.tag = 1000;
    nav.alpha = 0;
    self.nav = nav;
    UIButton *back = [EBUtility btnfrome:CGRectMake(0, StatusBarHeight-20+25, 60, 40) andText:@"" andColor:nil andimg:[UIImage imageNamed:@"back"] andView:self.view];
    back.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10);
    back.tag = 1001;
    [back addTarget:self action:@selector(backBtn:) forControlEvents:UIControlEventTouchUpInside];
}

//通知
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

#pragma mark - 配置宝贝详情页下面2个按钮
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

#pragma mark - 配置主播详情页下面的3个按钮
- (void)configBottomView {
    if ([self.dataInfo[@"user_id"] integerValue] == UserModel.sharedUser.userid.integerValue) {
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

//查询权限  是否能查看微信/聊天
- (void)queryJurisdictionRequestTargetId:(NSString *)targetId completionHandle:(void(^)(BOOL limit))handle {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:UserModel.sharedUser.token forKey:@"token"];
    [dict setObject:@"2" forKey:@"type"];
    [dict setObject:targetId forKey:@"target_id"];
    NSString *requestUrl = [NSString stringWithFormat:@"%@anchor/check_authority",HttpURLString];
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:requestUrl Paremeters:dict successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        hadRequestLimitOfWechat_IM = YES;
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            if (code == 1) {//有权限 聊天/查看微信
                isCanTalk = YES;
                if ([object[@"data"] integerValue] == 0) {
                    [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"当天会员权限已用完" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
                }
            }
            else if (code == 0) {//没权限 聊天/查看微信
                price = object[@"data"];
            }
            if (handle) {
                handle(isCanTalk);
            }
        }
    } failoperation:^(NSError *error) {
        [SVProgressHUD dismiss];
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络信号差，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
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
    if (self.type != 2){//宝贝信息  雇主信息
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        NSString *method = @"";
        if (UserModel.sharedUser.token){
            [dict setObject:UserModel.sharedUser.token forKey:@"token"];
        }
        if (self.type == 0) {
            [dict setObject:self.employeeId forKey:@"buserid"];
            method = @"Gamebaby/userbabydetail.html";
            if (UserModel.sharedUser.userid){
                [dict setObject:UserModel.sharedUser.userid forKey:@"userid"];
            }
        }
        else if (self.type == 1) {
            [dict setObject:self.employeeId forKey:@"userid"];
            method = @"Parttime/partindex.html";
        }
        
        [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@%@",HttpURLString,method] Paremeters:dict successOperation:^(id object) {
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
            [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络信号差，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
        }];
    }
    else {//主播信息
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:self.employeeId forKey:@"id"];
        if (UserModel.sharedUser.token) {
            [dict setObject:UserModel.sharedUser.token forKey:@"token"];
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
                    if (UserModel.sharedUser.userid.integerValue == [self.dataInfo[@"user_id"] integerValue]) {
                        for (LiveCharmPhotoModel *model in self.charmPhotoArray) {
                            model.is_charge = @"0";
                        }
                    }
                    [self.tableView reloadData];
                    [self configBottomView];
                    if ([self.dataInfo[@"user_id"] integerValue] == UserModel.sharedUser.userid.integerValue) {
                        isCanTalk = YES;
                        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self getBuyVipInfoRequest];
                        });
                    }
                }else{
                    [SVProgressHUD showErrorWithStatus:msg];
                }
            }
        } failoperation:^(NSError *error) {
            [SVProgressHUD dismiss];
            [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络信号差，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
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
    NSString *anchor_url = [NSString stringWithFormat:@"%@index#/anchorDetail?token%@&anchorId=%@&skip=phone",SHARE_WEBURL,UserModel.sharedUser.token,self.employeeId];
    self.shareView = [[ShareView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-140, SCREEN_WIDTH, 140) WithShareUrl:anchor_url ShareTitle:@"我是主播" WithShareDescription:@"这是我的主播魅力名片，我为自己代言，欢迎来围观"];
    [self.shareView show];
}

//bottomview按键
- (void)conBtn:(UIButton*)sender{
    if ([EBUtility isBlankString:UserModel.sharedUser.token]){
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
    if ([EBUtility isBlankString:UserModel.sharedUser.token]){
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController* vc = [sb instantiateViewControllerWithIdentifier:@"loginPWD"];
        [self.navigationController pushViewController:vc animated:1];
        return;
    }
    if (sender.tag == 777) {
        [self lookWechatSelector:sender];
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
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:self.dataInfo[@"id"] forKey:@"target_id"];
    [dict setObject:@"3" forKey:@"type"];
    [dict setObject:UserModel.sharedUser.token forKey:@"token"];
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
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络信号差，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
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
        if (isKindOfNSString(self.dataInfo[@"video_img"]) && isKindOfNSString(self.dataInfo[@"video"])) {
            if ([self.dataInfo[@"video_img"] length] > 0 && [self.dataInfo[@"video"] length] > 0) {
                existVideo = YES;
            }
        }
    }
    if (existBgimg) {
        for (NSString *str in self.dataInfo[@"bgimg"]) {
            [bgImgAry addObject:str];
        }
    }
    else {
        bgImgAry = @[@"placeholder_media"].mutableCopy;
    }
    if (existVideo) {
        [bgImgAry insertObject:self.dataInfo[@"video_img"] atIndex:0];
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
        make.left.equalTo(vipImg.mas_right).offset(10);
        make.size.mas_equalTo(CGSizeMake(35, 20));
    }];
    
//    UIImageView *statusImg = [EBUtility imgfrome:CGRectZero andImg:[UIImage imageNamed:@"live_detail_online"] andView:headerView];
//    [statusImg mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(sexImg.mas_centerY);
//        make.left.equalTo(realnamedImg.mas_right).offset(7);
//        make.size.mas_equalTo(CGSizeMake(29, 18));
//    }];
    
    UILabel *time = [EBUtility labfrome:CGRectZero andText:@"时间" andColor:[UIColor whiteColor] andView:headerView];
    time.backgroundColor = [UIColor colorFromHexString:@"666666"];
    time.font = [UIFont systemFontOfSize:11.0];
    time.layer.cornerRadius = 2;
    time.layer.masksToBounds = YES;
    [time sizeToFit];
    [time mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(age.mas_centerY);
        make.left.equalTo(realnamedImg.mas_right).offset(10);
        make.height.mas_equalTo(16);
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
    
    fans = [EBUtility labfrome:CGRectZero andText:@"粉丝数量" andColor:[UIColor whiteColor] andView:headerView];
    fans.textAlignment = NSTextAlignmentRight;
    fans.font = [UIFont systemFontOfSize:13.0];
    [fans mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(sexImg.mas_centerY);
        make.right.equalTo(headerView.mas_right).offset(-15);
        make.size.mas_equalTo(CGSizeMake(100, 13));
    }];
    
    BOOL display = NO;
    if (self.type == 2) {
        if ([self.dataInfo[@"user_id"] integerValue] != UserModel.sharedUser.userid.integerValue) {
            display = YES;
        }
    }
    else {
        if ([self.employeeId integerValue] != UserModel.sharedUser.userid.integerValue) {
            display = YES;
        }
    }
    
    if (display) {
        UIButton *attentionBtn = [EBUtility btnfrome:CGRectZero andText:@"" andColor:nil andimg:[UIImage imageNamed:@"live_detail_attention"] andView:headerView];
        [attentionBtn addTarget:self action:@selector(payAttentionTo:) forControlEvents:UIControlEventTouchUpInside];
        [attentionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(fans.mas_top).offset(-6);
            make.right.equalTo(headerView.mas_right).offset(-15);
            make.size.mas_equalTo(CGSizeMake(65, 22));
        }];
        if ([self.dataInfo[@"is_follow"] integerValue] == 0) {
            [attentionBtn setImage:[UIImage imageNamed:@"live_detail_attention"] forState:0];
            attentionBtn.selected = NO;
        }
        else if ([self.dataInfo[@"is_follow"] integerValue] == 1) {
            [attentionBtn setImage:[UIImage imageNamed:@"live_detail_attentioned"] forState:0];
            attentionBtn.selected = YES;
        }
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
        time.text = [NSString stringWithFormat:@" %@   ",self.dataInfo[@"last_login"]];
        fansCount = [self.dataInfo[@"follow_count"] intValue];
        fans.text = [NSString stringWithFormat:@"%d粉丝",fansCount];
        
        UIButton* phone = [self.view viewWithTag:100];
        UIButton* com = [self.view viewWithTag:101];
        if ([NSString stringWithFormat:@"%@",self.dataInfo[@"isable"]].integerValue == 2) {
            phone.hidden = YES;
            com.hidden = YES;
            self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        }
        else if ([NSString stringWithFormat:@"%@",self.dataInfo[@"is_strangercall"]].integerValue != 1) {
                phone.hidden = YES;
                com.width = SCREEN_WIDTH;
                com.x = 0;
        }
        if (!display) {
            phone.hidden = YES;
            com.hidden = YES;
            self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        }
    }
    return headerView;
}

#pragma mark - 关注/取消关注
- (void)payAttentionTo:(UIButton *)sender {
    if (!UserModel.sharedUser.token) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController* vc = [sb instantiateViewControllerWithIdentifier:@"loginPWD"];
        [self.navigationController pushViewController:vc animated:1];
        return;
    }
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (self.type == 2) {
        [dict setObject:self.dataInfo[@"user_id"] forKey:@"target_id"];
    }
    else {
        [dict setObject:self.employeeId forKey:@"target_id"];
    }
    [dict setObject:UserModel.sharedUser.token forKey:@"token"];
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
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络信号差，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
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
    NSArray *nameArray = NSArray.array;
    if (self.type == 0) {
        nameArray = @[@"技能",@"资料"];//宝贝个人资料
    }
    else if (self.type == 1) {
        nameArray = @[@"最近发布",@"资料"];//雇主资料
    }
    else if (self.type == 2) {
        nameArray = @[@"主播资料",@"主播魅力",@"资料"];//主播资料
    }
    UILabel* name = [EBUtility labfrome:CGRectMake(15, 30, 5, 15) andText:nameArray[section] andColor:[UIColor colorFromHexString:@"333333"] andView:headerView];
    name.font = [UIFont systemFontOfSize:14.0];
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
            cell.lookButton.tag = 123;
            [cell.lookButton addTarget:self action:@selector(lookWechatSelector:) forControlEvents:UIControlEventTouchUpInside];
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
                if (model.is_charge.intValue == 1) {
                    if (!UserModel.sharedUser.token) {
                        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                        LoginViewController* vc = [sb instantiateViewControllerWithIdentifier:@"loginPWD"];
                        [self.navigationController pushViewController:vc animated:1];
                    }
                    else {
                        LiveCharmPhotoModel *model = self.charmPhotoArray[index];
                        [self showCharmPhotoPayViewWithPrice:model.fee Type:@"2" TargetId:model.id Index:index];
                    }
                }
                else {
                    [weakSelf configZLPhotoPickerBrowserWithArray:weakSelf.charmPhotoArray Index:index];
                }
//                [weakSelf configZLPhotoPickerBrowserWithArray:weakSelf.charmPhotoArray Index:index];
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
- (void)lookWechatSelector:(UIButton *)sender {
    if (!UserModel.sharedUser.token) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController* vc = [sb instantiateViewControllerWithIdentifier:@"loginPWD"];
        [self.navigationController pushViewController:vc animated:1];
        return;
    }
    if (isCanTalk) {//有权限 查看微信/聊天
        if (sender.tag == 777) {//聊天
            NIMSession *session = [NIMSession session:[NSString stringWithFormat:@"%@",self.dataInfo[@"invitecode"]] type:NIMSessionTypeP2P];
            ChatViewController *vc = [[ChatViewController alloc] initWithSession:session];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if (sender.tag == 123) {//查看微信
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    else {
        if (hadRequestLimitOfWechat_IM) {
            [self showPayViewWithPrice:price Type:@"3" TargetId:self.dataInfo[@"id"]];
        }
        else {
            [self queryJurisdictionRequestTargetId:self.employeeId completionHandle:^(BOOL limit) {
                if (limit) {
                    if (sender.tag == 777) {//聊天
                        NIMSession *session = [NIMSession session:[NSString stringWithFormat:@"%@",self.dataInfo[@"invitecode"]] type:NIMSessionTypeP2P];
                        ChatViewController *vc = [[ChatViewController alloc] initWithSession:session];
                        [self.navigationController pushViewController:vc animated:YES];
                    }
                    else if (sender.tag == 123) {//查看微信
                        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                    }
                }
                else {
                    [self showPayViewWithPrice:price Type:@"3" TargetId:self.dataInfo[@"id"]];
                }
            }];
        }
    }
}

#pragma mark - 付款/微信/聊天
- (void)showPayViewWithPrice:(NSString *)money Type:(NSString *)type TargetId:(NSString *)targetId {
    LivePayView *freeView = [[LivePayView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-261)/2, (SCREEN_HEIGHT-284)/2, 261, 284-45) Price:money];
    freeView.titleString = @"查看主播的全部资料或聊天";
    freeView.showBuyVip = NO;
    if (isKindOfNSDictionary(adDataInfo)) {
        if ([adDataInfo[@"link_lock"] integerValue] == 1) {
            freeView.showBuyVip = YES;
            freeView.frame = CGRectMake((SCREEN_WIDTH-261)/2, (SCREEN_HEIGHT-284)/2, 261, 284);
        }
    }
    WEAKSELF
    typeof(freeView) __weak weakFreeView = freeView;
    weakFreeView.confirmSelecrBlock = ^(NSInteger index) {
        [weakFreeView dismiss];
        [weakSelf clickLivePayViewWithIndex:index Price:money Type:type TargetId:targetId];
    };
    [freeView show];
}

- (void)clickLivePayViewWithIndex:(NSInteger)index Price:(NSString *)money Type:(NSString *)type TargetId:(NSString *)targetId {
    if (index == 0) {
        UserModel *user = UserModel.sharedUser;
        if ([user.is_paypwd isEqualToString:@"0"]){
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            SetPayPasswordViewController* vc = [sb instantiateViewControllerWithIdentifier:@"spp"];
            [self.navigationController pushViewController:vc animated:1];
            return;
        }
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选取支付方式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *pay = [UIAlertAction actionWithTitle:@"余额支付" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (user.user_money.floatValue < money.floatValue) {
                UIAlertController *alertcon = [UIAlertController alertControllerWithTitle:@"当前余额不足，是否前去充值" message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelaction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                UIAlertAction *confiraction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    TopUpAndWithdrawViewController* vc = [sb instantiateViewControllerWithIdentifier:@"tuaw"];
                    vc.type = 0;
                    [self.navigationController pushViewController:vc animated:1];
                }];
                [alertcon addAction:confiraction];
                [alertcon addAction:cancelaction];
                [self presentViewController:alertcon animated:YES completion:nil];
                return;
            }
            //弹起支付密码alert
            CustomAlertView* customAlert = [[CustomAlertView alloc] initWithType:6];
            customAlert.resultDate = ^(NSString *date) {
                [self payRequestWithPwd:date Price:money Type:type TargetId:targetId];
            };
            customAlert.resultIndex = ^(NSInteger index) {
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                RetrievePayPasswordViewController* vc = [sb instantiateViewControllerWithIdentifier:@"rpp"];
                [self.navigationController pushViewController:vc animated:1];
            };
            [customAlert showAlertView];
        }];
        [alert addAction:pay];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else if (index == 1) {
        VipWebViewController *con = [VipWebViewController new];
        con.loadUrlString = [NSString stringWithFormat:@"%@?type=phone&token=%@",adDataInfo[@"ad_link"],UserModel.sharedUser.token];
        con.paySuccessBlock = ^{
            if (type.integerValue == 5) {
                if (!UserModel.sharedUser.token) {
                    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    LoginViewController* vc = [sb instantiateViewControllerWithIdentifier:@"loginPWD"];
                    [self.navigationController pushViewController:vc animated:1];
                    return;
                }
                AliPlayerViewController *playCon = [AliPlayerViewController new];
                playCon.videoIdString = self.dataInfo[@"video"];
                [self.navigationController pushViewController:playCon animated:YES];
            }
            else if (type.integerValue == 3) {
                hadRequestLimitOfWechat_IM = NO;
            }
        };
        [self.navigationController pushViewController:con animated:YES];
    }
}

//获取购买会员信息
- (void)getBuyVipInfoRequest {
    NSDictionary *dict = @{@"typeid":@"6"};
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Currency/bannerlist.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            if (code == 1) {
                adDataInfo = [object[@"data"] lastObject];
            }
        }
    } failoperation:^(NSError *error) {
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络信号差，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
    }];
}

#pragma mark - 付款/魅力图片
- (void)showCharmPhotoPayViewWithPrice:(NSString *)money Type:(NSString *)type TargetId:(NSString *)targetId Index:(NSInteger)index {
    LiveCharmPhotoPayView *payView = [[LiveCharmPhotoPayView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-171)/2, (SCREEN_HEIGHT-177)/2, 171, 177) Price:money Index:index];
    WEAKSELF
    typeof(payView) __weak weakPayView = payView;
    payView.confirmPayBlock = ^(NSInteger indexTag) {
        [weakPayView dismiss];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选取支付方式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *pay = [UIAlertAction actionWithTitle:@"余额支付" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UserModel *user = UserModel.sharedUser;
            if ([user.is_paypwd isEqualToString:@"0"]){
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                SetPayPasswordViewController* vc = [sb instantiateViewControllerWithIdentifier:@"spp"];
                [weakSelf.navigationController pushViewController:vc animated:1];
                return;
            }
            if (user.user_money.floatValue < money.floatValue) {
                UIAlertController *alertcon = [UIAlertController alertControllerWithTitle:@"当前余额不足，是否前去充值" message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelaction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                UIAlertAction *confiraction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    TopUpAndWithdrawViewController* vc = [sb instantiateViewControllerWithIdentifier:@"tuaw"];
                    vc.type = 0;
                    [self.navigationController pushViewController:vc animated:1];
                }];
                [alertcon addAction:confiraction];
                [alertcon addAction:cancelaction];
                [self presentViewController:alertcon animated:YES completion:nil];
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
    NSDictionary *dic = @{@"token":UserModel.sharedUser.token,
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
                if (type.intValue == 2) {
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
                else if (type.intValue == 3) {
                    isCanTalk = YES;
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                }
                else if (type.intValue == 5) {
                    isCanPlayVideo = YES;
                    AliPlayerViewController *playCon = [AliPlayerViewController new];
                    playCon.videoIdString = self.dataInfo[@"video"];
                    [self.navigationController pushViewController:playCon animated:YES];
                }
            }else{
                [SVProgressHUD showErrorWithStatus:msg];
            }
        }
    } failoperation:^(NSError *error) {
        [SVProgressHUD dismiss];
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络信号差，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
    }];
}

#pragma mark - otherDelegate/DataSource
//点击顶部轮播图
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    BOOL existVideo = NO;
    if (self.dataInfo) {
        if (isKindOfNSString(self.dataInfo[@"video_img"]) && isKindOfNSString(self.dataInfo[@"video"])) {
            if ([self.dataInfo[@"video_img"] length] > 0 && [self.dataInfo[@"video"] length] > 0) {
                existVideo = YES;
            }
        }
    }
    if (existVideo) {
        if (index == 0) {
            if ([EBUtility isBlankString:UserModel.sharedUser.token]){
                UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                LoginViewController* vc = [sb instantiateViewControllerWithIdentifier:@"loginPWD"];
                [self.navigationController pushViewController:vc animated:1];
                return;
            }
            BOOL playvideo = YES;
            if (UserModel.sharedUser.vip_grade.integerValue == 0) {
                if (!isCanPlayVideo) {
                    if (![UserModel.sharedUser.userid isEqualToString:self.dataInfo[@"user_id"]]) {
                        playvideo = NO;
                    }
                }
                return;
            }
            if (playvideo) {
                AliPlayerViewController *playCon = [AliPlayerViewController new];
                playCon.videoIdString = self.dataInfo[@"video"];
                [self.navigationController pushViewController:playCon animated:YES];
            }
            else {
                LivePayView *freeView = [[LivePayView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-261)/2, (SCREEN_HEIGHT-284)/2, 261, 284) Price:self.dataInfo[@"video_price"]];
                freeView.titleString = @"是否继续观看视频？";
                freeView.showBuyVip = YES;
                WEAKSELF
                typeof(freeView) __weak weakFreeView = freeView;
                weakFreeView.confirmSelecrBlock = ^(NSInteger index) {
                    [weakFreeView dismiss];
                    [weakSelf clickLivePayViewWithIndex:index Price:self.dataInfo[@"video_price"] Type:@"5" TargetId:self.dataInfo[@"id"]];
                };
                [freeView show];
            }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
