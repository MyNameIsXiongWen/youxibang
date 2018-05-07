//
//  HomeViewController.m
//  youxibang
//
//  Created by y on 2018/1/18.
//

#import "HomeViewController.h"
#import "HomeCollectionViewCell.h"
#import "EmployeeDetailViewController.h"
#import "SearchViewController.h"
#import "PartTimeViewController.h"
#import "IssueOrderViewController.h"
#import "GameBabyDetailViewController.h"
#import "LoginViewController.h"

#import "SDCityPickerViewController.h"
#import "SDCityInitial.h"
#import "SDCityModel.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>

#import "ContentModel.h"
#import "HomeIntelligentTableViewCell.h"
#import "LiveShowViewController.h"
#import "LiveCreateViewController.h"
#import "NewsModel.h"
#import "SigninViewController.h"

#define historyCityFilepath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"historyCity.data"]

static NSString *const INTELLIGENT_TABLEVIEW_IDENTIFIER = @"intelligent_identifier";
@interface HomeViewController ()<SDCycleScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, AMapLocationManagerDelegate>

@property (strong, nonatomic) SDCycleScrollView *cycleScrollView;
@property (strong, nonatomic) UITableView *adTableview;
@property (strong, nonatomic) UITableView *contentTableview;
@property (strong, nonatomic) NSDictionary *responseDictionary;
@property (strong, nonatomic) UIView* navView;

@property (nonatomic, strong) NSMutableArray* intelligentArray;
@property (nonatomic, strong) NSMutableArray* bannerAry;
@property (nonatomic, strong) NSMutableArray* anchorAry;
@property (nonatomic, strong) NSMutableArray* informationAry;
@property (nonatomic, assign) int currentPage;

@property (strong, nonatomic) UIButton *locationBtn;
@property (nonatomic, strong) AMapLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *locationDataSourceArray;

// 热门
@property (nonatomic,strong)NSMutableArray *hotArr;
// 历史
@property (nonatomic,strong)NSMutableArray *historyArr;
// 当前选择
@property (nonatomic,strong)NSMutableArray *selectArr;
//@property (nonatomic,strong)UIButton *btn; //左按钮
@property (nonatomic,strong)NSMutableArray *historySelectArr;
//新闻招聘 上下滚动定时器
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSInteger currentIndex;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"首页";
    [self initLocationManager];
    self.currentPage = 1;
    self.currentIndex = 0;
    self.view.backgroundColor = UIColor.whiteColor;

    [self configUI];
    [self homeDataRequest];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(scrollTableView) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    //这个通知是付款完成后跳转个人页面的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushMineView:) name:@"pushMineView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMessage:) name:@"refreshMessage" object:nil];
}

- (void)scrollTableView {
    if (self.currentIndex == self.informationAry.count-1) {
        self.currentIndex = 0;
    }
    else {
        self.currentIndex ++;
    }
    if (self.informationAry.count > 0) {
        [self.adTableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

//渐显效果
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        self.navView.alpha = self.contentTableview.contentOffset.y / 115;
        UIView *search = [self.view viewWithTag:10000];
        if (self.navView.alpha > 0.6) {
            [self.locationBtn setImage:[UIImage imageNamed:@"home_location_black"] forState:0];
            [self.locationBtn setTitleColor:[UIColor colorFromHexString:@"333333"] forState:0];
            search.backgroundColor = [UIColor colorFromHexString:@"f6f6f6"];
        }
        else {
            [self.locationBtn setImage:[UIImage imageNamed:@"home_location"] forState:0];
            [self.locationBtn setTitleColor:UIColor.whiteColor forState:0];
            search.backgroundColor = [UIColor whiteColor];
        }
    }
}

- (void)configNavView {
    //白色的navi
    self.navView = [EBUtility viewfrome:CGRectMake(0, 0, SCREEN_WIDTH, 64) andColor:[UIColor whiteColor] andView:self.view];
    self.navView.alpha = 0;
    
    UIView* searchView = [EBUtility viewfrome:CGRectMake(80, 30, SCREEN_WIDTH - 80-30*ADAPTATIONRATIO, 25) andColor:[UIColor whiteColor] andView:self.view];
    searchView.layer.cornerRadius = 12.5;
    searchView.layer.masksToBounds = NO;
    searchView.tag = 10000;
    UIImageView* img = [EBUtility imgfrome:CGRectMake(20, 5, 15, 15) andImg:[UIImage imageNamed:@"home_search"] andView:searchView];
    UIButton* searchBtn = [EBUtility btnfrome:CGRectMake(45, 0, searchView.frame.size.width-45-20, 25) andText:@"搜任务标题、用户昵称、ID" andColor:[UIColor colorFromHexString:@"83889a"] andimg:nil andView:searchView];
    searchBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [searchBtn addTarget:self action:@selector(searchView:) forControlEvents:UIControlEventTouchUpInside];
    
    //定位按钮
    self.locationBtn = [EBUtility btnfrome:CGRectMake(15, 32, 50, 20) andText:self.historySelectArr.count==0?@"全国":((SDCityModel *)self.historySelectArr.firstObject).name andColor:UIColor.whiteColor andimg:[UIImage imageNamed:@"home_location"] andView:self.view];
    [self.locationBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 5)];
    [self.locationBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, -2)];
    self.locationBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [self.locationBtn addTarget:self action:@selector(locationUser:) forControlEvents:UIControlEventTouchUpInside];
    UIView* lineView = [EBUtility viewfrome:CGRectMake(0, 63.5, SCREEN_WIDTH, 0.5) andColor:[UIColor colorFromHexString:@"b2b2b2"] andView:self.navView];
}

- (void)configUI {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 345)];
    headerView.backgroundColor = UIColor.whiteColor;
    NSMutableArray* ary = [NSMutableArray array];
    for (NSDictionary* i in self.bannerAry){
        [ary addObject:i[@"adimg"]];
    }
    self.cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 175) imageNamesGroup:ary];
    self.cycleScrollView.infiniteLoop = YES;
    self.cycleScrollView.delegate = self;
    self.cycleScrollView.hideBkgView = YES;
    self.cycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleClassic;
    [headerView addSubview:self.cycleScrollView];
    UIImageView *bkgImgView = [EBUtility imgfrome:CGRectMake(0, 150, SCREEN_WIDTH, 25) andImg:[UIImage imageNamed:@"banner_bg"] andView:headerView];
    bkgImgView.contentMode = UIViewContentModeScaleToFill;
    bkgImgView.backgroundColor = UIColor.clearColor;
    //三个按钮
    NSArray *textAry = @[@"主播基地",@"兼职空间",@"发布任务",@"每日打卡"];
    NSArray *imgAry = @[@"home_live_base",@"home_parttime",@"home_publish",@"home_daily_clock"];
    for (int i = 0;i < 4;i ++){
        UIView* v = [EBUtility viewfrome:CGRectMake(i * SCREEN_WIDTH/4 , 175, SCREEN_WIDTH/4, 100) andColor:UIColor.whiteColor andView:headerView];
        
        UIButton* btn = [EBUtility btnfrome:CGRectMake(0, 10, SCREEN_WIDTH/4, 60) andText:@"" andColor:nil andimg:[UIImage imageNamed:imgAry[i]] andView:v];
        btn.tag = i;
        [btn addTarget:self action:@selector(pushOrder:) forControlEvents:UIControlEventTouchUpInside];
        UILabel *lab = [EBUtility labfrome:CGRectMake(0, 75, SCREEN_WIDTH/4, 15) andText:textAry[i] andColor:[UIColor colorFromHexString:@"333333"] andView:v];
        lab.font = [UIFont systemFontOfSize:13.0];
        lab.textAlignment = NSTextAlignmentCenter;
    }
    
    UIImageView *iconImgView = [EBUtility imgfrome:CGRectMake(5, 275, 55, 70) andImg:[UIImage imageNamed:@"home_toutiao"] andView:headerView];
    iconImgView.contentMode = UIViewContentModeCenter;
    iconImgView.backgroundColor = UIColor.whiteColor;
    self.adTableview = [[UITableView alloc] initWithFrame:CGRectMake(50, 293, SCREEN_WIDTH-50-22, 35) style:UITableViewStylePlain];
    self.adTableview.delegate = self;
    self.adTableview.dataSource = self;
    self.adTableview.tag = 111;
    self.adTableview.separatorStyle = UITableViewCellSelectionStyleNone;
    [headerView addSubview:self.adTableview];
    UIImageView *arrowImgView = [EBUtility imgfrome:CGRectMake(SCREEN_WIDTH-22, 304, 7, 12) andImg:[UIImage imageNamed:@"arrow_right"] andView:headerView];
    arrowImgView.contentMode = UIViewContentModeCenter;
    arrowImgView.backgroundColor = UIColor.whiteColor;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    footerView.backgroundColor = UIColor.clearColor;
    UILabel *footerLabel = [EBUtility labfrome:footerView.bounds andText:@"然后，就没有然后了～" andColor:[UIColor colorFromHexString:@"444444"] andView:footerView];
    footerLabel.font = [UIFont systemFontOfSize:11.0];
    
    self.contentTableview = [[UITableView alloc] initWithFrame:CGRectMake(0, -20, SCREEN_WIDTH, SCREEN_HEIGHT-49+20) style:UITableViewStyleGrouped];
    self.contentTableview.delegate = self;
    self.contentTableview.dataSource = self;
    self.contentTableview.tag = 999;
    self.contentTableview.estimatedSectionHeaderHeight = 0;
    self.contentTableview.estimatedSectionFooterHeight = 0;
    self.contentTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.contentTableview registerNib:[UINib nibWithNibName:@"HomeIntelligentTableViewCell" bundle:nil] forCellReuseIdentifier:INTELLIGENT_TABLEVIEW_IDENTIFIER];
    [self.view addSubview:self.contentTableview];
    self.contentTableview.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshHead)];
    self.contentTableview.tableHeaderView = headerView;
    self.contentTableview.tableFooterView = footerView;
    
    [self configNavView];
}

//兼职，游戏宝贝，发布三个按钮的方法，发布任务必须登陆后才能进入
- (void)pushOrder:(UIButton*)sender{
    //因为第三方登录后直接获取userinfo服务器的token会与当前不符，故在首页进行点击行为时才获取userinfo
    if (![EBUtility isBlankString:[DataStore sharedDataStore].token]){
        [UserNameTool reloadPersonalData:^{

        }];
    }
    if (sender.tag == 0) {
        LiveShowViewController *showCon = [LiveShowViewController new];
        [self.navigationController pushViewController:showCon animated:YES];
    }
    else if (sender.tag == 1) {
        PartTimeViewController* vc = [[PartTimeViewController alloc]init];
        [self.navigationController pushViewController:vc animated:1];
    }
    else if (sender.tag == 2) {
        if ([EBUtility isBlankString:[DataStore sharedDataStore].token]){
            UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            LoginViewController* vc = [sb instantiateViewControllerWithIdentifier:@"loginPWD"];
            [self.navigationController pushViewController:vc animated:1];
            return;
        }
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        IssueOrderViewController* vc = [sb instantiateViewControllerWithIdentifier:@"io"];
        [self.navigationController pushViewController:vc animated:1];
    }
    else if (sender.tag == 3) {
        SigninViewController *con = [SigninViewController new];
        [self.navigationController pushViewController:con animated:YES];
    }
}

- (void)homeDataRequest {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    NSMutableDictionary *dic = NSMutableDictionary.dictionary;
    if ([DataStore sharedDataStore].latitude) {
        [dic setObject:[DataStore sharedDataStore].latitude forKey:@"lat"];
    }
    if ([DataStore sharedDataStore].longitude) {
        [dic setObject:[DataStore sharedDataStore].longitude forKey:@"lon"];
    }
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@currency/get_info",HttpURLString] Paremeters:dic successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            if (code == 1) {
                self.responseDictionary = object[@"data"];
                //banner展示 
                self.bannerAry = self.responseDictionary[@"ad"];
                NSMutableArray* ary = [NSMutableArray array];
                for (NSDictionary* i in self.bannerAry){
                    [ary addObject:i[@"adimg"]];
                }
                self.cycleScrollView.imageURLStringsGroup = ary;
                //tableview展示
                self.intelligentArray = [ContentModel mj_objectArrayWithKeyValuesArray:self.responseDictionary[@"group"]];
                self.anchorAry = [IntelligentModel mj_objectArrayWithKeyValuesArray:self.responseDictionary[@"anchor"]];
                self.informationAry = [NewsModel mj_objectArrayWithKeyValuesArray:self.responseDictionary[@"information"]];
                [self.adTableview reloadData];
                [self.timer fire];//新闻招聘上下滚动启动
                [self.contentTableview reloadData];
            }
            else {
                [SVProgressHUD showErrorWithStatus:object[@"message"]];
            }
        }
    } failoperation:^(NSError *error) {
        [SVProgressHUD setDefaultMaskType:1];
        [SVProgressHUD showErrorWithStatus:@"网络信号差，请稍后再试"];
    }];
}

#pragma mark - location
- (void)locationUser:(UIButton *)btn {
    [self startSerialLocation];
    SDCityPickerViewController *city =[[SDCityPickerViewController alloc]init];
    city.cityPickerBlock = ^(SDCityModel *city)
    {
        self.navigationItem.title = city.name;
        [self.historyArr insertObject:city atIndex:0];
        [self setSelectCityModel:city];
        [self.locationBtn setTitle:city.name forState:0];
        [self convertCoordinate:city.name];
    };
    city.dataArr = [NSMutableArray arrayWithArray:self.locationDataSourceArray];
    [self.navigationController pushViewController:city animated:YES];
}
-(void)setSelectCityModel:(SDCityModel *)city{
    [self.historyArr removeAllObjects];
    SDCityInitial *cityInitial = [[SDCityInitial alloc]init];
    cityInitial.initial = @"历史";
    [self historySelectArr];
    
    NSMutableArray *emptyArr =[NSMutableArray arrayWithArray:_historySelectArr];
    [emptyArr enumerateObjectsUsingBlock:^(SDCityModel  *_Nonnull hiscity, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([hiscity.name isEqualToString:city.name]) {
            [_historySelectArr removeObjectAtIndex:idx];
            *stop =YES;
        }
    }];
    [_historySelectArr insertObject:city atIndex:0];
    if (_historySelectArr.count>6){
        [_historySelectArr removeLastObject];
    }
    
    [NSKeyedArchiver archiveRootObject:_historySelectArr toFile:historyCityFilepath];
    cityInitial.cityArrs = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithFile:historyCityFilepath]];
    [self.historyArr addObject:cityInitial];
    [self.locationDataSourceArray replaceObjectsAtIndexes:[NSIndexSet indexSetWithIndex:1] withObjects:self.historyArr];
}
// 定位选择
-(NSMutableArray *)selectArr{
    if (!_selectArr){
        _selectArr = [NSMutableArray array];
        SDCityInitial *cityInitial =[[SDCityInitial alloc]init];
        cityInitial.initial = @"定位";
        SDCityModel *city = [[SDCityModel alloc]init];
        city.name = @"全国";
        NSMutableArray *selectArrs =[NSMutableArray array];
        [selectArrs addObject:city];
        cityInitial.cityArrs = selectArrs;
        [_selectArr addObject:cityInitial];
    }
    return _selectArr;
}
// 历史
-(NSMutableArray *)historyArr{
    if (!_historyArr){
        _historyArr = [NSMutableArray array];
        SDCityInitial *cityInitial =[[SDCityInitial alloc]init];
        cityInitial.initial = @"历史";
        cityInitial.cityArrs = self.historySelectArr;
        [_historyArr addObject:cityInitial];
    }
    return _historyArr;
}
-(NSMutableArray *)historySelectArr{
    if (!_historySelectArr){
        _historySelectArr = [NSKeyedUnarchiver unarchiveObjectWithFile:historyCityFilepath];
        if (!_historySelectArr){
            _historySelectArr =[NSMutableArray array];
        }
    }
    return _historySelectArr;
}
// 热门
-(NSMutableArray *)hotArr{
    if(!_hotArr){
        _hotArr = [NSMutableArray array];
        SDCityInitial *cityInitial =[[SDCityInitial alloc]init];
        cityInitial.initial = @"热门";
        NSArray *hotCityArr =@[@{@"id":@"1",@"name":@"北京",@"pid":@"11"},
                               @{@"id":@"2",@"name":@"上海",@"pid":@"11"},
                               @{@"id":@"3",@"name":@"广州",@"pid":@"11"},
                               @{@"id":@"4",@"name":@"深圳",@"pid":@"11"},
                               @{@"id":@"4",@"name":@"成都",@"pid":@"11"},
                               @{@"id":@"4",@"name":@"杭州",@"pid":@"11"},
                               ];
        NSMutableArray *hotarrs =[NSMutableArray array];
        for (NSDictionary *dic in hotCityArr){
            SDCityModel *city = [SDCityModel cityWithDict:dic];
            [hotarrs addObject:city];
        }
        cityInitial.cityArrs = hotarrs;
        [_hotArr addObject:cityInitial];
    }
    return _hotArr;
}

-(NSMutableArray *)locationDataSourceArray{
    if (!_locationDataSourceArray){
        _locationDataSourceArray =[NSMutableArray array];
        NSString *path =[[NSBundle mainBundle]pathForResource:@"City" ofType:@"plist"];
        NSArray *arr =[NSArray arrayWithContentsOfFile:path];
        NSMutableArray *cityModels = [NSMutableArray array];
        //获取全部城市cityModel
        for (NSDictionary *dic in arr){
            for (NSDictionary *dict in dic[@"children"]){
                SDCityModel *cityModel = [SDCityModel cityWithDict:dict];
                [cityModels addObject:cityModel];
            }
        }
        //获取首字母
        NSMutableArray *indexArr =
        [[cityModels valueForKeyPath:@"firstLetter"] valueForKeyPath:@"@distinctUnionOfObjects.self"];
        //遍历数组
        for (NSString *indexStr in indexArr) {
            SDCityInitial *cityInitial =[[SDCityInitial alloc]init];
            cityInitial.initial = indexStr;
            NSMutableArray *cityArrs =[NSMutableArray array];
            for ( SDCityModel *cityModel in cityModels) {
                if ([indexStr isEqualToString:cityModel.firstLetter]) {
                    [cityArrs addObject:cityModel];
                }
            }
            cityInitial.cityArrs = cityArrs;
            [_locationDataSourceArray addObject:cityInitial];
        }
        [_locationDataSourceArray insertObjects:self.hotArr atIndexes:[NSIndexSet indexSetWithIndex:0]];
        [_locationDataSourceArray insertObjects:self.historyArr atIndexes:[NSIndexSet indexSetWithIndex:0]];
        [_locationDataSourceArray insertObjects:self.selectArr atIndexes:[NSIndexSet indexSetWithIndex:0]];
    }
    return _locationDataSourceArray;
}

- (void)initLocationManager {
    [AMapServices sharedServices].apiKey = AMAP_API_KEY;
    [AMapServices sharedServices].enableHTTPS = YES;
    [self configLocationManager];
}

- (void)configLocationManager {
    self.locationManager = [[AMapLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    [self startSerialLocation];
}

- (void)startSerialLocation {
    //开始定位
    [self.locationManager startUpdatingLocation];
}

- (void)stopSerialLocation {
    //停止定位
    [self.locationManager stopUpdatingLocation];
}

- (void)initWithlocation:(CLLocation *)location {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (placemarks.count > 0){
            SDCityInitial *cityInitial =[[SDCityInitial alloc]init];
            cityInitial.initial = @"定位";
            SDCityModel *city = [[SDCityModel alloc]init];
            city.name = [[placemarks objectAtIndex:0].locality substringToIndex:[placemarks objectAtIndex:0].locality.length-1];
            NSMutableArray *selectArrs =[NSMutableArray array];
            [selectArrs addObject:city];
            cityInitial.cityArrs = selectArrs;
            [self.selectArr replaceObjectAtIndex:0 withObject:cityInitial];
            [self.locationBtn setTitle:city.name forState:0];
            [_locationDataSourceArray replaceObjectAtIndex:0 withObject:self.selectArr];
            
            [self configDataStore:location withCity:city.name updateCity:YES];
        }
    }];
}

- (void)convertCoordinate:(NSString *)address {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:address completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (placemarks.count > 0) {
            CLPlacemark *mark = [placemarks lastObject];
            CLLocation *loc=mark.location;
            [self configDataStore:loc withCity:address updateCity:NO];
        }
    }];
}

- (void)configDataStore:(CLLocation *)location withCity:(NSString *)address updateCity:(BOOL)update {
    //获取经纬度了
    NSString *latitude = @(location.coordinate.latitude).stringValue;
    if (latitude.length>15) {
        latitude = [latitude substringToIndex:15];
    }
    NSString *longitude = @(location.coordinate.longitude).stringValue;
    if (longitude.length>15) {
        longitude = [longitude substringToIndex:15];
    }
    [DataStore sharedDataStore].city = address;
    [DataStore sharedDataStore].latitude = latitude;
    [DataStore sharedDataStore].longitude = longitude;
    if (update) {
        [self updateCoordinate];
    }
}

- (void)updateCoordinate {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if ([DataStore sharedDataStore].token) {
        [dic setObject:[DataStore sharedDataStore].token forKey:@"token"];
    }
    if ([DataStore sharedDataStore].city) {
        [dic setObject:[DataStore sharedDataStore].city forKey:@"last_city"];
    }
    if ([DataStore sharedDataStore].latitude) {
        [dic setObject:[DataStore sharedDataStore].latitude forKey:@"lat"];
    }
    if ([DataStore sharedDataStore].longitude) {
        [dic setObject:[DataStore sharedDataStore].longitude forKey:@"lon"];
    }
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@member/index",HttpURLString] Paremeters:dic successOperation:^(id object) {
        if (isKindOfNSDictionary(object)){
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
        }
        
    } failoperation:^(NSError *error) {
    }];
}

#pragma mark - AMapViewDelegate
- (void)amapLocationManager:(AMapLocationManager *)manager didFailWithError:(NSError *)error {
    //定位错误
    NSLog(@"%s, amapLocationManager = %@, error = %@", __func__, [manager class], error);
}

- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location {
    //定位结果
    NSLog(@"location:{lat:%f; lon:%f; accuracy:%f}", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy);
    [self initWithlocation:location];
    [self stopSerialLocation];
}

#pragma mark - tableview refresh
//头部刷新方法
- (void)refreshHead {
    self.currentPage = 1;
    [self homeDataRequest];
    [self.contentTableview.mj_header endRefreshing];
}
//尾部刷新方法
- (void)refreshFooter {
    self.currentPage ++;
    [self homeDataRequest];
    [self.contentTableview.mj_footer endRefreshing];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //改变状态栏颜色，隐藏原来的navi，改变状态栏颜色
    self.navigationController.navigationBar.hidden = YES;
    [self.contentTableview addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
    [self.contentTableview removeObserver:self forKeyPath:@"contentOffset"];
}

//懒加载
- (NSMutableArray*)intelligentArray {
    if (!_intelligentArray){
        _intelligentArray = [NSMutableArray array];
    }
    return _intelligentArray;
}
- (NSMutableArray*)bannerAry {
    if (!_bannerAry){
        _bannerAry = [NSMutableArray array];
    }
    return _bannerAry;
}

//搜索页面的跳转方法
- (void)searchView:(UIButton*)sender{
    //因为第三方登录后直接获取userinfo服务器的token会与当前不符，故在首页进行点击行为时才获取userinfo
    if (![EBUtility isBlankString:[DataStore sharedDataStore].token]){
        [UserNameTool reloadPersonalData:^{
        }];
    }
    SearchViewController* vc = [[SearchViewController alloc]init];
    [self.navigationController pushViewController:vc animated:1];
}

//跳转个人页面的通知方法
- (void)pushMineView:(NSNotification *)notification{
    [self.tabBarController setSelectedIndex:3];
}
- (void)refreshMessage:(NSNotification *)notification{
    for (UIView* i in [UIApplication sharedApplication].keyWindow.subviews){
        if ([i isKindOfClass:[CustomAlertView class]]){
            [i removeFromSuperview];
        }
    }
    [self.tabBarController setSelectedIndex:2];
}

#pragma mark - tableviewDelegate/DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView.tag == 111) {
        return 1;
    }
    return self.intelligentArray.count+1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == 111) {
        return self.informationAry.count;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 111) {
        return 17.5;
    }
    if (indexPath.section == 0) {
        return 135+55;
    }
    return 180+55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView.tag == 111) {
        return 0.1;
    }
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 111) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell_id"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell_id"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NewsModel *model = self.informationAry[indexPath.row];
        cell.textLabel.text = model.title;
        cell.textLabel.font = [UIFont systemFontOfSize:11.0];
        cell.textLabel.textColor = [UIColor colorFromHexString:@"444444"];
        if (model.cat_id.integerValue == 1) {
            cell.imageView.image = [UIImage imageNamed:@"home_news"];
        }
        else {
            cell.imageView.image = [UIImage imageNamed:@"home_hr"];
        }
        return cell;
    }
    HomeIntelligentTableViewCell *homeCell = [tableView dequeueReusableCellWithIdentifier:INTELLIGENT_TABLEVIEW_IDENTIFIER];
    homeCell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSMutableArray *dataArray = NSMutableArray.array;
    CGFloat height = 0;
    if (indexPath.section == 0) {
        homeCell.leftTitleLabel.text = @"热门主播";
        homeCell.type = ContentTypeLive;
        dataArray = self.anchorAry;
        height = 135;
    }
    else {
        ContentModel *model = self.intelligentArray[indexPath.section-1];
        homeCell.leftTitleLabel.text = model.name;
        homeCell.type = ContentTypeIntelligent;
        dataArray = model.data;
        height = 180;
    }
    if (dataArray.count >= 6) {
        homeCell.contentScrollView.contentSize = CGSizeMake(145*6+100+15, height);
    }
    else {
        homeCell.contentScrollView.contentSize = CGSizeMake(145*dataArray.count+15, height);
    }
    [homeCell createScrollViewWithIntelligent:dataArray];
    homeCell.rightAllBtn.tag = indexPath.section;
    [homeCell.rightAllBtn addTarget:self action:@selector(clickAllBtn:) forControlEvents:UIControlEventTouchUpInside];
    WEAKSELF
    typeof(homeCell) __weak weakCell = homeCell;
    typeof(dataArray) __weak weakDataArray = dataArray;
    homeCell.clickInformationBlock = ^(NSInteger index, ContentType type) {
        [self clickInformationArray:weakDataArray WithIndex:index ContentType:type];
    };
    homeCell.clickLookMoreBlock = ^{
        [weakSelf clickAllBtn:weakCell.rightAllBtn];
    };
    return homeCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 111) {
        [self.tabBarController setSelectedIndex:1];
    }
}

- (void)clickAllBtn:(UIButton *)btn {
    if (btn.tag == 0) {
        LiveShowViewController *showCon = [LiveShowViewController new];
        [self.navigationController pushViewController:showCon animated:YES];
    }
    else {
        ContentModel *model = self.intelligentArray[btn.tag-1];
        PartTimeViewController* vc = [[PartTimeViewController alloc]init];
        vc.ptOrBaby = YES;
        vc.groupId = model.id;
        [self.navigationController pushViewController:vc animated:1];
    }
}

- (void)clickInformationArray:(NSMutableArray *)array WithIndex:(NSInteger)index ContentType:(ContentType)type {
    //跳转主播详情页面
    IntelligentModel *model = array[index];
    if (type == ContentTypeLive) {
        EmployeeDetailViewController *vc = [[EmployeeDetailViewController alloc] init];
        vc.type = 2;
        vc.employeeId = model.id;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (type == ContentTypeIntelligent) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        GameBabyDetailViewController* vc = [sb instantiateViewControllerWithIdentifier:@"gbd"];
        vc.gbId = model.id;
        [self.navigationController pushViewController:vc animated:YES];
    }
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
