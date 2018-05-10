//
//  AddGameSkillViewController.m
//  youxibang
//
//  Created by y on 2018/2/6.
//

#import "AddGameSkillViewController.h"
#import "SkillCollectionViewCell.h"

@interface AddGameSkillViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic,strong)UICollectionView* collectionView;//右侧游戏列表
@property (nonatomic, strong)UIButton * selBtn;
@property (nonatomic, weak)UIView* leftView;//左侧类型列表
@property (nonatomic,strong)SkillCollectionViewCell* selectCell;//所选技能cell
@property (nonatomic,strong)NSMutableArray* dataAry;
@property (nonatomic,strong)NSMutableArray* titleAry;
@end

@implementation AddGameSkillViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"添加技能";
    //设置collection
    [self setUpRightView];
    
    //右上角按键
    UIView* rv = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 55, 25)];
    UIButton* btn = [EBUtility greenBtnfrome:CGRectMake(0, 0, 65, 25) andText:@"完成" andColor:[UIColor colorFromHexString:@"333333"] andimg:nil andView:rv];
    
    btn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [btn addTarget:self action:@selector(commitInfo:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rv];
    
    [self downloadInfo:@"0"];
}
- (NSMutableArray*)dataAry{
    if (!_dataAry){
        _dataAry = [NSMutableArray array];
    }
    return _dataAry;
}
- (NSMutableArray*)titleAry{
    if (!_titleAry){
        _titleAry = [NSMutableArray array];
    }
    return _titleAry;
}
//下载列表  pid 分类id
- (void)downloadInfo:(NSString*)pid{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:pid forKey:@"pid"];
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Currency/gamelist.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            
            if ([pid isEqualToString:@"0"]){
                if (code == 1) {
                    self.titleAry = [NSMutableArray arrayWithArray:object[@"data"]];
                    [self setUpLeftView];
                    [self downloadInfo:[NSString stringWithFormat:@"%@",self.titleAry[0][@"id"]]];
                }else{
                    [SVProgressHUD showErrorWithStatus:msg];
                }
            }else{
                if (code == 1) {
                    self.dataAry = [NSMutableArray arrayWithArray:object[@"data"]];
                    [self.collectionView reloadData];
                }else if (code == 2) {
                    self.dataAry = [NSMutableArray array];
                    [self.collectionView reloadData];
                }else{
                    [SVProgressHUD showErrorWithStatus:msg];
                }
            }
            
        }
        
    } failoperation:^(NSError *error) {
        
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        [SVProgressHUD showErrorWithStatus:@"网络信号差，请稍后再试"];
    }];
}
//提交
- (void)commitInfo:(UIButton*)sender{
    if ([self.delegate respondsToSelector:@selector(selectSomeThing:AndId:)]){
        [self.delegate selectSomeThing:self.selectCell.nameLab.text AndId:self.selectCell.pid];
        [self.navigationController popViewControllerAnimated:1];
    }
}
//设置分类列表
- (void)setUpLeftView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, StatusBarHeight+44, SCREEN_WIDTH /4, SCREEN_HEIGHT-(StatusBarHeight+44))];
    [self.view addSubview:view];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.leftView = view;
    
    for (NSInteger i = 0; i < self.titleAry.count; i++ ) {
        UIButton *btn = [EBUtility btnfrome:CGRectMake(0, 50 * i, view.width, 50) andText:self.titleAry[i][@"title"] andColor:[UIColor blackColor] andimg:nil andView:view];
        btn.tag = i;
        NSAttributedString *att = [[NSAttributedString alloc] initWithString:self.titleAry[i][@"title"] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]}];
        [btn setAttributedTitle:att forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i;
        NSAttributedString *att1 = [[NSAttributedString alloc] initWithString:self.titleAry[i][@"title"] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14],NSForegroundColorAttributeName : Nav_color}];
        [btn setAttributedTitle:att1 forState:UIControlStateSelected];
        
        UIView *lView = [EBUtility viewfrome:CGRectMake(0, 3, 3, 42) andColor:Nav_color andView:btn];
        lView.hidden = YES;
        lView.tag = 100;
        
        UILabel* grayLine = [EBUtility labfrome:CGRectMake(0, 50, view.width, 1) andText:@"" andColor:nil andView:btn];
        grayLine.backgroundColor = [UIColor lightGrayColor];
    }
    
    if (self.titleAry.count > 0){
        UIButton *btn = view.subviews.firstObject;
        [self btnClick:btn];
    }
}
//点击分类
-(void)btnClick:(UIButton *)btn {
    UIView *selview = [self.selBtn viewWithTag:100];
    selview.hidden = YES;
    self.selBtn.selected = NO;
    UIView *view = [btn viewWithTag:100];
    view.hidden = NO;
    self.selBtn = btn;
    [self downloadInfo:[NSString stringWithFormat:@"%@",self.titleAry[btn.tag][@"id"]]];
}
- (void)setUpRightView {
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 20;
    layout.minimumLineSpacing = 15;
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/4, 0, SCREEN_WIDTH *3/4, SCREEN_HEIGHT) collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self.collectionView registerClass:[SkillCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    
    [self.view addSubview:self.collectionView];
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
    return self.dataAry.count;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((SCREEN_WIDTH *3 /4 - 60)/3, 100);
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SkillCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    [cell setInfoWith:self.dataAry[indexPath.row]];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectCell.layer.borderColor = [UIColor whiteColor].CGColor;
    
    SkillCollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.layer.borderColor = Nav_color.CGColor;
    cell.layer.borderWidth = 1;
    cell.layer.cornerRadius = 5;
    cell.layer.masksToBounds = YES;
    
    self.selectCell = cell;
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
