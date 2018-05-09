//
//  LiveFansViewController.m
//  youxibang
//
//  Created by jiazhuo1 on 2018/4/25.
//

#import "LiveFansViewController.h"
#import "FansTableViewCell.h"
#import "ContentModel.h"

static NSString *const FANSTABLEVIEW_ID = @"fanstableview_id";
@interface LiveFansViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *fansArray;
@property (weak, nonatomic) IBOutlet UITableView *fansTableview;
@property (nonatomic,assign) int currentPage;

@end

@implementation LiveFansViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"我的粉丝";
    self.currentPage = 1;
    [self.fansTableview registerNib:[UINib nibWithNibName:@"FansTableViewCell" bundle:nil] forCellReuseIdentifier:FANSTABLEVIEW_ID];
    self.fansTableview.rowHeight = 60;
    self.fansTableview.tableFooterView = [UIView new];
    self.fansTableview.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshHead)];
    self.fansTableview.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshFooter)];
    [self getFansListRequest];
}

- (void)getFansListRequest {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    NSMutableDictionary *dic = @{@"page":[NSString stringWithFormat:@"%d",self.currentPage],
                                @"token":DataStore.sharedDataStore.token
                                 }.mutableCopy;
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@member/fans_list",HttpURLString] Paremeters:dic successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            if (code == 1) {
                if (self.currentPage == 1) {
                    self.fansArray = [IntelligentModel mj_objectArrayWithKeyValuesArray:object[@"data"]];
                }
                else {
                    [self.fansArray addObjectsFromArray:[IntelligentModel mj_objectArrayWithKeyValuesArray:object[@"data"]]];
                }
                [self.fansTableview reloadData];
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
    [self getFansListRequest];
    [self.fansTableview.mj_header endRefreshing];
}
//尾部刷新方法
- (void)refreshFooter {
    self.currentPage ++;
    [self getFansListRequest];
    [self.fansTableview.mj_footer endRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fansArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IntelligentModel *model = self.fansArray[indexPath.row];
    FansTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FANSTABLEVIEW_ID];
    [cell.headImgView sd_setImageWithURL:[NSURL URLWithString:model.photo] placeholderImage:[UIImage imageNamed:@"placeholder_fans"]];
    cell.nameLabel.text = model.nickname;
    if (model.sex.integerValue == 2) {
        cell.ageLabel.textColor = [UIColor colorFromHexString:@"f335a0"];
        cell.sexImgView.image = [UIImage imageNamed:@"live_female"];
    }
    else {
        cell.ageLabel.textColor = [UIColor colorFromHexString:@"457fea"];
        cell.sexImgView.image = [UIImage imageNamed:@"live_male"];
    }
    if (model.is_follow.integerValue == 1) {
        cell.attentionButton.selected = YES;
        [cell.attentionButton setImage:[UIImage imageNamed:@"live_fans_attentioned"] forState:0];
    }
    else {
        cell.attentionButton.selected = NO;
        [cell.attentionButton setImage:[UIImage imageNamed:@"live_fans_attention"] forState:0];
    }
    if (model.is_realauth.integerValue == 1) {
        [cell.realnameImgView setImage:[UIImage imageNamed:@"live_detail_realnamed"]];
    }
    cell.vipImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"vip_grade_%@",model.vip_grade]];
    [cell.attentionButton addTarget:self action:@selector(payAttentionTo:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)payAttentionTo:(UIButton *)sender {
    IntelligentModel *model = self.fansArray[sender.tag];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:model.user_id forKey:@"target_id"];
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
                    [sender setImage:[UIImage imageNamed:@"live_fans_attentioned"] forState:UIControlStateNormal];
                }
                else {
                    [sender setImage:[UIImage imageNamed:@"live_fans_attention"] forState:UIControlStateNormal];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
