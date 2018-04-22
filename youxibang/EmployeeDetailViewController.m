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
    self.tableView.frame = CGRectMake(0, -20, SCREEN_WIDTH, SCREEN_HEIGHT + 20);
    self.tableView.showsVerticalScrollIndicator = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;

    self.tableView.tableFooterView = [UIView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
    //头像backImage
    UIButton* backImg = [EBUtility btnfrome:CGRectMake(15, 33, 10, 20) andText:@"" andColor:nil andimg:[UIImage imageNamed:@"back"] andView:self.view];
    UIButton* back = [EBUtility btnfrome:CGRectMake(0, 25, 40, 40) andText:@"" andColor:nil andimg:nil andView:self.view];
    [back addTarget:self action:@selector(backBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    //当查看宝贝信息时，显示的bottomview
    if (self.type == 0){
        self.tableView.frame = CGRectMake(0, -20, SCREEN_WIDTH, SCREEN_HEIGHT - 20);
        UIButton* phone = [EBUtility btnfrome:CGRectMake(0, SCREEN_HEIGHT - 44, SCREEN_WIDTH/2, 44) andText:@"电话" andColor:[UIColor whiteColor] andimg:nil andView:self.view];
        phone.backgroundColor = [EBUtility colorWithHexString:@"#73CDFB" alpha:1];
        [phone addTarget:self action:@selector(conBtn:) forControlEvents:UIControlEventTouchUpInside];
        phone.tag = 100;
        UIButton* confirm = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT - 44, SCREEN_WIDTH/2, 44) andText:@"下单" andColor:[UIColor whiteColor] andimg:nil andView:self.view];
        confirm.backgroundColor = Nav_color;
        confirm.tag = 101;
        [confirm addTarget:self action:@selector(conBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self downloadInfo];
    
    [self configMediaPlayer];
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
    if (self.type == 0){//宝贝信息
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        [SVProgressHUD show];
        
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
    }else if (self.type == 1){//雇主信息
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        [SVProgressHUD show];
        
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
- (void)backBtn:(UIButton*)sender{
    [self.navigationController popViewControllerAnimated:1];
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - tableViewDelegate/DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 1){
        if (self.type == 0){//技能列表
            return ((NSDictionary*)self.dataInfo[@"skilllist"]).count;
        }else if (self.type == 1){//最近发布列表
            return ((NSDictionary*)self.dataInfo[@"list"]).count;
        }
    }else if (section == 2){
        return 2;
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section > 0){
        return 45;
    }
    return 225 * ADAPTATIONRATIO;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* hv = [EBUtility viewfrome:CGRectMake(0, 0, SCREEN_WIDTH, 45) andColor:[UIColor whiteColor] andView:nil];
    if (section > 0){
        UILabel* lab = [EBUtility labfrome:CGRectMake(0, 0, SCREEN_WIDTH, 10) andText:@"" andColor:nil andView:hv];
        lab.backgroundColor = [UIColor groupTableViewBackgroundColor];
        UILabel* blue = [EBUtility labfrome:CGRectMake(10, 20, 5, 15) andText:@"" andColor:nil andView:hv];
        blue.backgroundColor = Nav_color;
        UILabel* name = [EBUtility labfrome:CGRectMake(20, 20, 5, 15) andText:@"技能" andColor:[UIColor blackColor] andView:hv];
        if (self.type == 1){
            name.text = @"最近发布";
        }
        if (section == 2){
            name.text = @"资料";
        }
        [name sizeToFit];
    }else{
        hv.frame = CGRectMake(0, 0, SCREEN_WIDTH, 225 * ADAPTATIONRATIO);
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
        SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetHeight(hv.frame)) imageNamesGroup:bgImgAry];
        cycleScrollView.infiniteLoop = YES;
        cycleScrollView.delegate = self;
        cycleScrollView.hideBkgView = NO;
        cycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleClassic;
        [hv addSubview:cycleScrollView];
        
        UIImageView* photo = [EBUtility imgfrome:CGRectMake(15, CGRectGetMaxY(hv.frame)-80, 70, 70) andImg:[UIImage imageNamed:@"ico_head"] andView:hv];
        photo.backgroundColor = [UIColor whiteColor];
        photo.layer.masksToBounds = YES;
        photo.layer.cornerRadius = 5;
        photo.layer.borderColor = [UIColor whiteColor].CGColor;
        photo.layer.borderWidth = 3;
        
        UILabel* signLab = [EBUtility labfrome:CGRectMake(0, 0, SCREEN_WIDTH, 20) andText:@"" andColor:[UIColor whiteColor] andView:hv];
        signLab.textAlignment = NSTextAlignmentLeft;
        signLab.font = [UIFont systemFontOfSize:13];
        signLab.numberOfLines = 0;
        [signLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(hv.mas_bottom).offset(-10);
            make.left.equalTo(hv.mas_left).offset(100);
            make.width.mas_equalTo(SCREEN_WIDTH-100-50);
        }];
        
        UILabel *age = [EBUtility labfrome:CGRectZero andText:@" ♂24岁 " andColor:[UIColor whiteColor]  andView:hv];
        age.font = [UIFont systemFontOfSize:10];
        age.backgroundColor = Nav_color;
        age.layer.cornerRadius = 4;
        age.layer.masksToBounds = YES;
        [age sizeToFit];
        [age mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(signLab.mas_top).offset(-10);
            make.left.equalTo(hv.mas_left).offset(100);
            make.size.mas_equalTo(CGSizeMake(45, 15));
        }];
        UIButton* vipImg = [EBUtility btnfrome:CGRectZero andText:@"" andColor:nil andimg:[UIImage imageNamed:@"ico_vip1"] andView:hv];
        vipImg.tag = 1;
        [vipImg setImage:[UIImage imageNamed:@"ico_vip"] forState:UIControlStateSelected];
        [vipImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(age.mas_bottom);
            make.left.equalTo(age.mas_right).offset(10);
            make.size.mas_equalTo(CGSizeMake(17, 15));
        }];
        UILabel* time = [EBUtility labfrome:CGRectZero andText:@"" andColor:[UIColor whiteColor] andView:hv];
        time.font = [UIFont systemFontOfSize:13];
        time.textAlignment = 0;
        [time sizeToFit];
        [time mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(age.mas_bottom);
            make.left.equalTo(vipImg.mas_right).offset(10);
            make.size.mas_equalTo(CGSizeMake(50, 15));
        }];
        
        UILabel *name = [EBUtility labfrome:CGRectZero andText:@"昵称" andColor:[UIColor whiteColor] andView:hv];
        name.textAlignment = NSTextAlignmentLeft;
        name.font = [UIFont systemFontOfSize:15];
        [name mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(age.mas_top).offset(-10);
            make.left.equalTo(hv.mas_left).offset(100);
            make.size.mas_equalTo(CGSizeMake(200, 15));
        }];
        
        if (self.dataInfo.count > 0){
            if (self.type == 0){
                if ([NSString stringWithFormat:@"%@",self.dataInfo[@"sex"]].integerValue == 1){
                    age.text = [NSString stringWithFormat:@" ♂%@岁\t",self.dataInfo[@"birthday"]];
                    age.backgroundColor = Nav_color;
                }else{
                    age.text = [NSString stringWithFormat:@" ♀%@岁\t",self.dataInfo[@"birthday"]];
                    age.backgroundColor = Pink_color;
                }
            }else if (self.type == 1){
                if ([NSString stringWithFormat:@"%@",self.dataInfo[@"sex"]].integerValue == 1){
                    age.text = [NSString stringWithFormat:@" ♂%@岁\t",self.dataInfo[@"age"]];
                    age.backgroundColor = Nav_color;
                }else{
                    age.text = [NSString stringWithFormat:@" ♀%@岁\t",self.dataInfo[@"age"]];
                    age.backgroundColor = Pink_color;
                }
            }
            
            [photo sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.dataInfo[@"photo"]]] placeholderImage:[UIImage imageNamed:@"ico_head"]];
            
            UILabel* title = [self.nav viewWithTag:1000];
            title.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"nickname"]];
            [title sizeToFit];
            
            name.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"nickname"]];
            time.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"last_login"]];
            if ([EBUtility isBlankString:self.dataInfo[@"mysign"]]){
                signLab.text = @"";
            }else{
                signLab.text = [NSString stringWithFormat:@"%@",(self.dataInfo[@"mysign"]) ? (self.dataInfo[@"mysign"]): @""];
            }
            
            if ([NSString stringWithFormat:@"%@",self.dataInfo[@"is_vip"]].integerValue == 1){
                vipImg.selected = YES;
            }else{
                vipImg.selected = NO;
            }
            if ([NSString stringWithFormat:@"%@",self.dataInfo[@"isable"]].integerValue == 2){
                UIButton* phone = [self.view viewWithTag:100];
                phone.hidden = YES;
                UIButton* com = [self.view viewWithTag:101];
                com.hidden = YES;
                self.tableView.frame = CGRectMake(0, -20, SCREEN_WIDTH, SCREEN_HEIGHT + 20);
            }else {
                if ([NSString stringWithFormat:@"%@",self.dataInfo[@"is_strangercall"]].integerValue != 1){
                    UIButton* phone = [self.view viewWithTag:100];
                    phone.hidden = YES;
                    UIButton* com = [self.view viewWithTag:101];
                    com.width = SCREEN_WIDTH;
                    com.x = 0;
                }
            }
            
        }
    }
    return hv;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1){
        if (self.type == 1){
            PartTimeTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
            if (!cell) {
                cell = [[PartTimeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            [cell setViewWithDic:self.dataInfo[@"list"][indexPath.row]];
            return cell;
        }else{
            EmployeeDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EmployeeDetailTableViewCell"];
            if (!cell) {
                cell = [[EmployeeDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"EmployeeDetailTableViewCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            [cell setViewWithDic:self.dataInfo[@"skilllist"][indexPath.row]];
            return cell;
        }
        
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"cell%ld %ld",indexPath.section,indexPath.row]];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"cell%ld %ld",indexPath.section,indexPath.row]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.section == 2){
        if (indexPath.row == 0){
            cell.textLabel.text = @"星座";
            for (UILabel* i in cell.viewForLastBaselineLayout.subviews){
                if (i.tag == 1){
                    [i removeFromSuperview];
                }
            }
            if (self.dataInfo.count > 0){
                
                if (self.type == 1){
                    UILabel* constellation = [EBUtility labfrome:CGRectMake(60, 13, 300, 20) andText:[NSString stringWithFormat:@"%@",self.dataInfo[@"constellation"]] andColor:[UIColor blackColor] andView:cell.viewForLastBaselineLayout];
                    constellation.tag = 1;
                    constellation.textAlignment = 0;
                }else{
                    UILabel* starsign = [EBUtility labfrome:CGRectMake(60, 13, 300, 20) andText:[NSString stringWithFormat:@"%@",self.dataInfo[@"starsign"]] andColor:[UIColor blackColor] andView:cell.viewForLastBaselineLayout];
                    starsign.tag = 1;
                    starsign.textAlignment = 0;
                }
                
            }
        }else if (indexPath.row == 1){
            for (UILabel* i in cell.viewForLastBaselineLayout.subviews){
                if (i.tag == 1){
                    [i removeFromSuperview];
                }
            }
            cell.textLabel.text = @"兴趣爱好";
            if (self.dataInfo.count > 0){
                UILabel* interest = [EBUtility labfrome:CGRectMake(90, 13, 300, 20) andText:[NSString stringWithFormat:@"%@",self.dataInfo[@"interest"]] andColor:[UIColor blackColor] andView:cell.viewForLastBaselineLayout];
                interest.tag = 1;
                interest.textAlignment = 0;
            }
        }
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.detailTextLabel.textColor = [UIColor blackColor];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.type == 0){
        if (indexPath.section == 1){//跳转技能详情
            UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            GameBabyDetailViewController* vc = [sb instantiateViewControllerWithIdentifier:@"gbd"];
            vc.gbId = [NSString stringWithFormat:@"%@",self.dataInfo[@"skilllist"][indexPath.row][@"id"]];
            [self.navigationController pushViewController:vc animated:1];
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
