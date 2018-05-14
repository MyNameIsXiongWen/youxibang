//
//  LiveShowViewController.m
//  youxibang
//
//  Created by jiazhuo1 on 2018/4/23.
//

#import "LiveShowViewController.h"
#import "GameBabyDetailViewController.h"
#import "LiveCollectionViewCell.h"
#import "LiveFilterView.h"
#import "ContentModel.h"
#import "EmployeeDetailViewController.h"

static NSString *const COLLECTIONVIEW_IDENTIFIER = @"collectionview_id";
@interface LiveShowViewController () <UICollectionViewDelegate, UICollectionViewDataSource> {
    NSString *orderby;
    int distanceType;
    int ageType;
    NSString *type;//0.全部 1.全职 2.兼职
    NSString *exp;//0.全部 工作经验
    NSString *anchor_type;//0.全部 主播类型
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIButton *distanceButton;
@property (weak, nonatomic) IBOutlet UIButton *ageButton;
@property (weak, nonatomic) IBOutlet UIButton *filtButton;
- (IBAction)clickTopConditionBtn:(id)sender;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic,assign) int currentPage;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) LiveFilterView *filterView;

@property (strong, nonatomic) NSMutableArray *filterArray;
@property (strong, nonatomic) NSMutableArray *selectedIndexArray;

@end

@implementation LiveShowViewController

- (void)dealloc {
    
}

- (NSMutableArray *)filterArray {
    if (!_filterArray) {
        _filterArray = @[
  @{@"主播类型":@[@"全部",@"电竞",@"电商",@"体育",@"教育",@"游戏",@"户外",@"其他"]},
  @{@"直播经验":@[@"全部",@"1年",@"2年",@"3年",@"4年以上"]},
  @{@"直播类型":@[@"全部",@"全职",@"兼职"]}].mutableCopy;
    }
    return _filterArray;
}

- (NSMutableArray *)selectedIndexArray {
    if (!_selectedIndexArray) {
        _selectedIndexArray = @[@(9999),@(9999),@(9999)].mutableCopy;
    }
    return _selectedIndexArray;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.filterView) {
        [self.filterView dismiss];
        self.filterView = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"主播展示";
    self.currentPage = 1;
    [self configCollectionView];
    [self getLiveListRequest];
    distanceType = 0;
    ageType = 0;
    [self getSelectTypeRequestWithType:2];
}

- (void)configCollectionView {
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 10;
    self.collectionView.collectionViewLayout = layout;
    self.collectionView.backgroundColor = [UIColor colorFromHexString:@"e7eff6"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"LiveCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:COLLECTIONVIEW_IDENTIFIER];
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshHead)];
    self.collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshFooter)];
    if (@available(iOS 11.0, *)) {
        self.topViewTopConstraint.constant = 0;
    }
    else {
        self.topViewTopConstraint.constant = -64;
    }
}

- (void)getLiveListRequest {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    NSMutableDictionary *dic = @{@"page":[NSString stringWithFormat:@"%d",self.currentPage]}.mutableCopy;
    if (orderby) {
        [dic setObject:orderby forKey:@"orderby"];
    }
    if (type) {
        [dic setObject:type forKey:@"type"];
    }
    if (exp) {
        [dic setObject:exp forKey:@"exp"];
    }
    if (anchor_type) {
        [dic setObject:anchor_type forKey:@"anchor_type"];
    }
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@anchor/anchor_list",HttpURLString] Paremeters:dic successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            if (code == 1) {
                if (self.currentPage == 1) {
                    self.dataArray = [IntelligentModel mj_objectArrayWithKeyValuesArray:object[@"data"]];
                }
                else {
                    [self.dataArray addObjectsFromArray:[IntelligentModel mj_objectArrayWithKeyValuesArray:object[@"data"]]];
                }
                [self.collectionView reloadData];
            }else {
                [[SYPromptBoxView sharedInstance] setPromptViewMessage:msg andDuration:2.0];
            }
        }
    } failoperation:^(NSError *error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        [SVProgressHUD showErrorWithStatus:@"网络信号差，请稍后再试"];
    }];
}

//获取选择项
- (void)getSelectTypeRequestWithType:(NSInteger)type {
    NSDictionary *dic = @{@"type":@"anchor_type"};
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@currency/get_conf",HttpURLString] Paremeters:dic successOperation:^(id object) {
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            if (code == 1) {
                NSMutableArray *tempArray = object[@"data"];
                [tempArray insertObject:@"全部" atIndex:0];
                NSDictionary *typeDic = @{@"主播类型":tempArray};
                [self.filterArray replaceObjectAtIndex:0 withObject:typeDic];
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

#pragma mark - collectionview refresh
//头部刷新方法
- (void)refreshHead {
    self.currentPage = 1;
    [self getLiveListRequest];
    [self.collectionView.mj_header endRefreshing];
}
//尾部刷新方法
- (void)refreshFooter {
    self.currentPage ++;
    [self getLiveListRequest];
    [self.collectionView.mj_footer endRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - collectionDelegate/DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((SCREEN_WIDTH - 10)/2, (SCREEN_WIDTH - 10)/2+45);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LiveCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:COLLECTIONVIEW_IDENTIFIER forIndexPath:indexPath];
    IntelligentModel *model = self.dataArray[indexPath.row];
    [cell.photoImageView sd_setImageWithURL:[NSURL URLWithString:model.photo] placeholderImage:[UIImage imageNamed:@"placeholder_anchor_list"]];
    cell.ageLabel.text = [NSString stringWithFormat:@"%@岁",model.age];
    cell.timeLabel.text = model.last_login;
    cell.nameLabel.text = model.nickname;
    if (model.sex.integerValue == 2) {
        cell.sexImageView.image = [UIImage imageNamed:@"live_female"];
        cell.ageLabel.textColor = [UIColor colorFromHexString:@"f335a0"];
    }
    else {
        cell.sexImageView.image = [UIImage imageNamed:@"live_male"];
        cell.ageLabel.textColor = [UIColor colorFromHexString:@"5aa7f9"];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //跳转主播详情页面
    IntelligentModel *model = self.dataArray[indexPath.row];
    EmployeeDetailViewController* vc = [[EmployeeDetailViewController alloc]init];
    vc.type = 2;
    vc.employeeId = model.id;
    [self.navigationController pushViewController:vc animated:1];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)clickTopConditionBtn:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (btn.tag == 1) {
        if (distanceType == 0) {
            distanceType = 1;
            orderby = @"4";
            [btn setImage:[UIImage imageNamed:@"live_triangle_up"] forState:0];
            [btn setTitleColor:[UIColor colorFromHexString:@"457fea"] forState:0];
        }
        else if (distanceType == 1) {
            distanceType = 2;
            orderby = @"5";
            [btn setImage:[UIImage imageNamed:@"live_triangle_down"] forState:0];
            [btn setTitleColor:[UIColor colorFromHexString:@"457fea"] forState:0];
            
        }
        else if (distanceType == 2) {
            distanceType = 0;
            orderby = nil;
            [btn setImage:[UIImage imageNamed:@"live_triangle"] forState:0];
            [btn setTitleColor:[UIColor colorFromHexString:@"333333"] forState:0];
        }
        ageType = 0;
        [self.ageButton setImage:[UIImage imageNamed:@"live_triangle"] forState:UIControlStateNormal];
        [self.ageButton setTitleColor:[UIColor colorFromHexString:@"333333"] forState:0];
        [self getLiveListRequest];
    }
    else if (btn.tag == 2) {
        if (ageType == 0) {
            ageType = 1;
            orderby = @"3";
            [btn setImage:[UIImage imageNamed:@"live_triangle_up"] forState:0];
            [btn setTitleColor:[UIColor colorFromHexString:@"457fea"] forState:0];
        }
        else if (ageType == 1) {
            ageType = 2;
            orderby = @"2";
            [btn setImage:[UIImage imageNamed:@"live_triangle_down"] forState:0];
            [btn setTitleColor:[UIColor colorFromHexString:@"457fea"] forState:0];
            
        }
        else if (ageType == 2) {
            ageType = 0;
            orderby = nil;
            [btn setImage:[UIImage imageNamed:@"live_triangle"] forState:0];
            [btn setTitleColor:[UIColor colorFromHexString:@"333333"] forState:0];
        }
        distanceType = 0;
        [self.distanceButton setImage:[UIImage imageNamed:@"live_triangle"] forState:UIControlStateNormal];
        [self.distanceButton setTitleColor:[UIColor colorFromHexString:@"333333"] forState:0];
        [self getLiveListRequest];
    }
    else if (btn.tag == 3) {
        if (!self.filterView) {
            self.filterView = [[LiveFilterView alloc] initWithFrame:CGRectMake(0, StatusBarHeight+44+40, SCREEN_WIDTH, SCREEN_HEIGHT-(StatusBarHeight+44)-40-150) WithFilterArray:self.filterArray AndSelectedIndexArray:self.selectedIndexArray];
            [self.filterView show];
            [btn setImage:[UIImage imageNamed:@"live_filter_selected"] forState:0];
            [btn setTitleColor:[UIColor colorFromHexString:@"457fea"] forState:0];
            WEAKSELF
            self.filterView.dismissFilterBlock = ^{
                [weakSelf.filterView dismiss];
                weakSelf.filterView = nil;
                [weakSelf.filtButton setImage:[UIImage imageNamed:@"live_filter_unselected"] forState:0];
                [weakSelf.filtButton setTitleColor:[UIColor colorFromHexString:@"333333"] forState:0];
            };
            self.filterView.confirmFilterBlock = ^(NSMutableArray *array) {
                _selectedIndexArray = array;
                NSArray *tempDataArray0 = [[weakSelf.filterArray[0] allValues] lastObject];
                NSArray *tempDataArray1 = [[weakSelf.filterArray[1] allValues] lastObject];
                if ([array[2] integerValue] != 9999) {
                    if ([array[2] integerValue] == 0) {
                        type = nil;
                    }
                    else {
                        type = array[2];
                    }
                }
                else {
                    type = nil;
                }
                if ([array[1] integerValue] != 9999) {
                    if ([array[1] integerValue] == 0) {
                        exp = nil;
                    }
                    else {
                        exp = [tempDataArray1 objectAtIndex:[array[1] integerValue]];
                    }
                }
                else {
                    exp = nil;
                }
                if ([array[0] integerValue] != 9999) {
                    if ([array[0] integerValue] == 0) {
                        anchor_type = nil;
                    }
                    else {
                        anchor_type = [tempDataArray0 objectAtIndex:[array[0] integerValue]];
                    }
                }
                else {
                    anchor_type = nil;
                }
                [weakSelf.filterView dismiss];
                weakSelf.filterView = nil;
                [weakSelf getLiveListRequest];
            };
            return;
        }
    }
    if (self.filterView) {
        [self.filterView dismiss];
        self.filterView = nil;
        [self.filtButton setImage:[UIImage imageNamed:@"live_filter_unselected"] forState:0];
        [self.filtButton setTitleColor:[UIColor colorFromHexString:@"333333"] forState:0];
    }
}
@end
