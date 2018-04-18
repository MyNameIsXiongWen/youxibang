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

#define historyCityFilepath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"historyCity.data"]

@interface HomeViewController ()<SDCycleScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, AMapLocationManagerDelegate>

@property (nonatomic,strong)UICollectionView* collectionView;
@property (nonatomic,strong)NSMutableArray* dataAry;
@property (nonatomic,strong)NSMutableArray* bannerAry;
@property (nonatomic,assign)int currentPage;

@property (strong, nonatomic) UIButton *locationBtn;
@property (nonatomic, strong) AMapLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *dataArr;

/**
 热门
 */
@property (nonatomic,strong)NSMutableArray *hotArr;


/**
 历史
 */
@property (nonatomic,strong)NSMutableArray *historyArr;


/**
 当前选择
 */
@property (nonatomic,strong)NSMutableArray *selectArr;

@property (nonatomic,strong)UIButton *btn; //左按钮
@property (nonatomic,strong)NSMutableArray *historySelectArr;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"首页";
    [self initLocationManager];
    self.currentPage = 1;
    self.view.backgroundColor = UIColor.whiteColor;
    //白色的navi
    UIView* navView = [EBUtility viewfrome:CGRectMake(0, -20, SCREEN_WIDTH, 84) andColor:[UIColor whiteColor] andView:self.view];
    UILabel* title = [EBUtility labfrome:CGRectMake(0, 0, 100, 30) andText:@"爱上播" andColor:[UIColor blackColor] andView:navView];
    title.font = [UIFont systemFontOfSize:18];
    [title sizeToFit];
    title.centerX = navView.centerX;
    title.centerY = navView.height - 22;
    //搜索按钮
    UIButton* searchBtn = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH-35, 50, 20, 20) andText:@"" andColor:nil andimg:[UIImage imageNamed:@"ico_search"] andView:navView];
    [searchBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 5, 0, -5)];
    [searchBtn addTarget:self action:@selector(searchView:) forControlEvents:UIControlEventTouchUpInside];
    
    //定位按钮
    self.locationBtn = [EBUtility btnfrome:CGRectMake(15, 50, 50, 20) andText:self.historySelectArr.count==0?@"全国":((SDCityModel *)self.historySelectArr.firstObject).name andColor:UIColor.grayColor andimg:[UIImage imageNamed:@"arrow_down"] andView:navView];
    [self.locationBtn setImageEdgeInsets:UIEdgeInsetsMake(2, 22, -2, -22)];
    [self.locationBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 20)];
    self.locationBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [self.locationBtn addTarget:self action:@selector(locationUser:) forControlEvents:UIControlEventTouchUpInside];
    
    //collection部分
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setHeaderReferenceSize:CGSizeMake(SCREEN_WIDTH, 340)];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [layout setHeaderReferenceSize:CGSizeMake(SCREEN_WIDTH, 560)];
    }
    layout.minimumInteritemSpacing = 20;
    layout.minimumLineSpacing = 15;
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64 -44) collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self.collectionView registerClass:[HomeCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self initHeadView];
    
    [self.view addSubview:self.collectionView];
    //refresh
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshHead)];
    self.collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshFooter)];
    
    //下载数据
    [self downloadInfo];
    [self downloadBanner];
    
    //这个通知是付款完成后跳转个人页面的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushMineView:) name:@"pushMineView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMessage:) name:@"refreshMessage" object:nil];
}

#pragma mark - location
- (void)locationUser:(UIButton *)btn {
    SDCityPickerViewController *city =[[SDCityPickerViewController alloc]init];
    city.cityPickerBlock = ^(SDCityModel *city)
    {
        self.navigationItem.title = city.name;
        [self.historyArr insertObject:city atIndex:0];
        [self setSelectCityModel:city];
        [self.locationBtn setTitle:city.name forState:0];
        [self convertCoordinate:city.name];
    };
    city.dataArr = [NSMutableArray arrayWithArray:self.dataArr];
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
    [self.dataArr replaceObjectsAtIndexes:[NSIndexSet indexSetWithIndex:1] withObjects:self.historyArr];
}


/**
 定位选择
 */
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
/**
 历史
 */
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
/**
 热门
 */
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

-(NSMutableArray *)dataArr{
    if (!_dataArr){
        _dataArr =[NSMutableArray array];
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
            [_dataArr addObject:cityInitial];
        }
        [_dataArr insertObjects:self.hotArr atIndexes:[NSIndexSet indexSetWithIndex:0]];
        [_dataArr insertObjects:self.historyArr atIndexes:[NSIndexSet indexSetWithIndex:0]];
        [_dataArr insertObjects:self.selectArr atIndexes:[NSIndexSet indexSetWithIndex:0]];
    }
    return _dataArr;
}

- (void)initLocationManager {
    [AMapServices sharedServices].apiKey = @"5982a470da137fca97a2e41ac2a63160";
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
            [_dataArr replaceObjectAtIndex:0 withObject:self.selectArr];
            
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
    [self downloadInfo];
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
    [self downloadBanner];
    [self downloadInfo];
    [self.collectionView.mj_header endRefreshing];
}
//尾部刷新方法
- (void)refreshFooter {
    self.currentPage ++;
    [self downloadInfo];
    [self.collectionView.mj_footer endRefreshing];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated {
    //改变状态栏颜色，隐藏原来的navi，改变状态栏颜色
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.hidden = YES;
    
}
- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

//懒加载
- (NSMutableArray*)dataAry {
    if (!_dataAry){
        _dataAry = [NSMutableArray array];
    }
    return _dataAry;
}
- (NSMutableArray*)bannerAry {
    if (!_bannerAry){
        _bannerAry = [NSMutableArray array];
    }
    return _bannerAry;
}
//下载banner图的方法
- (void)downloadBanner {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@"1" forKey:@"typeid"];
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Currency/bannerlist.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
        
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]];
            NSLog(@"输出 %@--%@",object,msg);
            
            if (code == 1) {
                self.bannerAry = [NSMutableArray arrayWithArray:object[@"data"]];
                [self initHeadView];
            }else{
                //[SVProgressHUD showErrorWithStatus:msg];
            }
        }
        
    } failoperation:^(NSError *error) {
        
        
    }];
}

//下载数据的方法
- (void)downloadInfo{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    
    NSMutableDictionary *dic = @{@"p":[NSString stringWithFormat:@"%d",self.currentPage],
                                 @"psize":@"20"}.mutableCopy;
    
    if ([DataStore sharedDataStore].city) {
        [dic setObject:[DataStore sharedDataStore].city forKey:@"city"];
    }
    if ([DataStore sharedDataStore].latitude) {
        [dic setObject:[DataStore sharedDataStore].latitude forKey:@"lat"];
    }
    if ([DataStore sharedDataStore].longitude) {
        [dic setObject:[DataStore sharedDataStore].longitude forKey:@"lon"];
    }
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Gamebaby/babylist.html",HttpURLString] Paremeters:dic successOperation:^(id object) {
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
                [self.collectionView reloadData];
            }else{
                if (self.currentPage == 1) {
                    [self.dataAry removeAllObjects];
                }
                [self.collectionView reloadData];
                [SVProgressHUD showErrorWithStatus:msg];
            }
        }
    } failoperation:^(NSError *error) {
        
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        [SVProgressHUD showErrorWithStatus:@"网络信号差，请稍后再试"];
    }];
    
}

//初始化collection的headView，即轮播图和3个按钮
- (void)initHeadView{

    NSMutableArray* ary = [NSMutableArray array];
    for (NSDictionary* i in self.bannerAry){
        [ary addObject:i[@"adimg"]];
    }
    //轮播图
    SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 175) imageNamesGroup:ary];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        cycleScrollView.height = 375;
    }
    cycleScrollView.infiniteLoop = YES;
    cycleScrollView.delegate = self;
    cycleScrollView.hideBkgView = YES;
    cycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleClassic;
    [self.collectionView addSubview:cycleScrollView];
    
    //三个按钮
    NSArray *textAry = @[@"兼职接单",@"游戏达人",@"发布任务"];
    NSArray *imgAry = @[@"ico_order",@"ico_baby",@"ico_assignment"];
    for (int i = 0;i < 3;i ++){
        UIView* v = [EBUtility viewfrome:CGRectMake(i * (SCREEN_WIDTH - 5)/3 , cycleScrollView.height, (SCREEN_WIDTH - 50)/3, 135) andColor:nil andView:self.collectionView];
        
        UIButton* btn = [EBUtility btnfrome:CGRectMake(0, 15, (SCREEN_WIDTH - 50)/3, 83) andText:@"" andColor:nil andimg:[UIImage imageNamed:imgAry[i]] andView:v];
        btn.tag = i;
        [btn addTarget:self action:@selector(pushOrder:) forControlEvents:UIControlEventTouchUpInside];
        btn.centerX = SCREEN_WIDTH/6;
        UILabel* lab = [EBUtility labfrome:CGRectMake(0, 100, 100, 25) andText:textAry[i] andColor:[UIColor blackColor] andView:v];
        lab.centerX = SCREEN_WIDTH/6;
    }
    
    //分界线与section title
    UILabel *blackLine = [EBUtility labfrome:CGRectMake(0, 310, SCREEN_WIDTH, 10) andText:@"" andColor:nil andView:self.collectionView];
    blackLine.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UILabel* textLab = [EBUtility labfrome:CGRectMake(35, 328, 100, 15) andText:@"游戏达人" andColor:[UIColor blackColor] andView:self.collectionView];
    [textLab sizeToFit];
    UIImageView* img = [EBUtility imgfrome:CGRectMake(10, 325, 18, 20) andImg:[UIImage imageNamed:@"ico_yxbb"] andView:self.collectionView];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        blackLine.y = 510;
        textLab.y = 528;
        img.y = 525;
    }
}
//兼职，游戏宝贝，发布三个按钮的方法，发布任务必须登陆后才能进入
- (void)pushOrder:(UIButton*)sender{
    //因为第三方登录后直接获取userinfo服务器的token会与当前不符，故在首页进行点击行为时才获取userinfo
    if (![EBUtility isBlankString:[DataStore sharedDataStore].token]){
        [UserNameTool reloadPersonalData:^{
            
        }];
    }
    //兼职
    if (sender.tag == 0){
        PartTimeViewController* vc = [[PartTimeViewController alloc]init];
        [self.navigationController pushViewController:vc animated:1];
    }else if (sender.tag == 1){//游戏宝贝
        PartTimeViewController* vc = [[PartTimeViewController alloc]init];
        vc.ptOrBaby = YES;
        [self.navigationController pushViewController:vc animated:1];
    }else{//发布任务
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
    [self.tabBarController setSelectedIndex:2];
}
- (void)refreshMessage:(NSNotification *)notification{
    for (UIView* i in [UIApplication sharedApplication].keyWindow.subviews){
        if ([i isKindOfClass:[CustomAlertView class]]){
            [i removeFromSuperview];
        }
    }
    [self.tabBarController setSelectedIndex:1];
}

#pragma mark - collectionDelegate/DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataAry.count;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(15, 10, 15, 10);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return CGSizeMake((SCREEN_WIDTH - 50)/2, (SCREEN_WIDTH - 50) *3 /5);
    }else if (iPhone5){
        return CGSizeMake((SCREEN_WIDTH - 50)/2, 170);
    }
    return CGSizeMake((SCREEN_WIDTH - 40)/2, 230);
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HomeCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    //字典传值
    [cell setInfoWith: self.dataAry[indexPath.row]];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //因为第三方登录后直接获取userinfo服务器的token会与当前不符，故在首页进行点击行为时才获取userinfo
    if (![EBUtility isBlankString:[DataStore sharedDataStore].token]){
        [UserNameTool reloadPersonalData:^{
            
        }];
    }
    //跳转游戏宝贝详情页面
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    GameBabyDetailViewController* vc = [sb instantiateViewControllerWithIdentifier:@"gbd"];
    vc.gbId = [NSString stringWithFormat:@"%@",self.dataAry[indexPath.row][@"id"]];
    [self.navigationController pushViewController:vc animated:1];
}
#pragma mark - otherDelegate

//轮播图片点击事件
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
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
