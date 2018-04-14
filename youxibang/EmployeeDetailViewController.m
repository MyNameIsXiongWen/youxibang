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

@interface EmployeeDetailViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate, SDCycleScrollViewDelegate, ZLPhotoPickerBrowserViewControllerDelegate>
@property (nonatomic,strong)UIView *nav;//渐显view
@property (nonatomic,strong)NSMutableDictionary* dataInfo;
@end

@implementation EmployeeDetailViewController

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
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
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
        SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetHeight(hv.frame)) imageNamesGroup:bgImgAry];
        cycleScrollView.infiniteLoop = YES;
        cycleScrollView.delegate = self;
        cycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleClassic;
        [hv addSubview:cycleScrollView];
        
        UIImageView* photo = [EBUtility imgfrome:CGRectMake(15, CGRectGetMaxY(hv.frame)-80, 70, 70) andImg:[UIImage imageNamed:@"ico_head"] andView:hv];
        photo.backgroundColor = [UIColor whiteColor];
        photo.layer.masksToBounds = YES;
        photo.layer.cornerRadius = 5;
        photo.layer.borderColor = [UIColor whiteColor].CGColor;
        photo.layer.borderWidth = 3;
        
        UILabel* signLab = [EBUtility labfrome:CGRectMake(0, 0, SCREEN_WIDTH, 20) andText:@"" andColor:[UIColor whiteColor] andView:hv];
        signLab.textAlignment = NSTextAlignmentCenter;
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

- (void) photoBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser photoDidSelectView:(UIView *)scrollBoxView atIndex:(NSInteger)index {
    [self.navigationController popViewControllerAnimated:YES];
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
