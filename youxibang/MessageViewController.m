//
//  MessageViewController.m
//  youxibang
//
//  Created by y on 2018/1/18.
//

#import "MessageViewController.h"
#import "OrderMessageViewController.h"
#import "WalletMessageViewController.h"
#import "SystemMessageViewController.h"
#import "LoginViewController.h"
#import "NIMKitInfoFetchOption.h"

@interface MessageViewController ()
@property (nonatomic,strong)NSMutableDictionary* dataInfo;
@property(nonatomic,assign)int currentPage;
@end

@implementation MessageViewController
//这个页面继承自云信的最近聊天列表，增加了tableview的headview
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"消息";
    //付款后跳转个人的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushMineView:) name:@"pushMineView" object:nil];
    //收到推送后刷新此页面的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMessage:) name:@"refreshMessage" object:nil];
    //token过期时跳转登录页面的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(InfoNotificationAction:) name:@"Logout" object:nil];
    
    //下拉刷新
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshHead)];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshFooter)];
    self.tableView.tableFooterView = [UIView new];
    self.currentPage = 1;
    
}

- (void)viewWillAppear:(BOOL)animated{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    NSInteger allUnReadCount = [[[NIMSDK sharedSDK] conversationManager] allUnreadCount];
    if (allUnReadCount>0) {
        [self.tabBarController.tabBar.items objectAtIndex:2].badgeValue = [NSString stringWithFormat:@"%ld",(long)allUnReadCount];
    }
    else {
        [self.tabBarController.tabBar.items objectAtIndex:2].badgeValue = nil;
    }
    
    //获取聊天列表中的人物信息
    NSMutableArray* ary = [NSMutableArray array];
    for (NIMRecentSession *i in self.recentSessions) {
        [ary addObject:i.session.sessionId];
    }
    [[NIMSDK sharedSDK].userManager fetchUserInfos:ary completion:^(NSArray<NIMUser *> * _Nullable users, NSError * _Nullable error) {
        //获取系统通知等
        [self downloadData];
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)refreshHead{
    self.currentPage = 1;
    self.dataInfo = nil;
    [self downloadData];
    [self.tableView.mj_header endRefreshing];
}
-(void)refreshFooter{
    self.currentPage ++;
    [self downloadData];
    [self.tableView.mj_footer endRefreshing];
}
//获取系统消息等
- (void)downloadData{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setObject:UserModel.sharedUser.token forKey:@"token"];
    
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Message/mymessage.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
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
                //                [SVProgressHUD showErrorWithStatus:msg];
            }
        }
        
    } failoperation:^(NSError *error) {
        
        [SVProgressHUD dismiss];
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络信号差，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
    }];
}
//通知触发方法
- (void)pushMineView:(NSNotification *)notification{
    [self.tabBarController setSelectedIndex:3];
}
- (void)refreshMessage:(NSNotification *)notification{
    [self downloadData];
}
//token过期跳转登录的方法
- (void)InfoNotificationAction:(NSNotification *)notification{
    //云信登出账号
    [[[NIMSDK sharedSDK] loginManager] logout:^(NSError *error) {
        
    }];
    [UserNameTool cleanloginData];
    UserModel.sharedUser.userid = nil;
    UserModel.sharedUser.yxuser = nil;
    UserModel.sharedUser.yxpwd = nil;
    UserModel.sharedUser.token = nil;
    [JPUSHService setAlias:@"" completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
        
    } seq:1];
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController* vc = [sb instantiateViewControllerWithIdentifier:@"loginPWD"];
    [self.navigationController pushViewController:vc animated:1];
}

//跳转订单消息，系统通知，钱包消息等页面
- (void) messagePush:(UIButton*)sender{
    if (sender.tag == 0){//订单消息
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        OrderMessageViewController* vc = [sb instantiateViewControllerWithIdentifier:@"om"];
        [self.navigationController pushViewController:vc animated:1];
        
        UILabel* dot = [self.view viewWithTag:100];
        dot.hidden = YES;
    }else if (sender.tag == 1){//系统通知
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        SystemMessageViewController* vc = [sb instantiateViewControllerWithIdentifier:@"smvc"];
        [self.navigationController pushViewController:vc animated:1];
        
        UILabel* dot = [self.view viewWithTag:101];
        dot.hidden = YES;
    }else if (sender.tag == 2){//钱包消息
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        WalletMessageViewController* vc = [sb instantiateViewControllerWithIdentifier:@"wmvc"];
        [self.navigationController pushViewController:vc animated:1];
        
        UILabel* dot = [self.tableView viewWithTag:102];
        dot.hidden = YES;
    }
}

#pragma mark - tableViewDelegate/DataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 220;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0){
        UIView* v = [EBUtility viewfrome:CGRectMake(0, 0, SCREEN_WIDTH, 220) andColor:[UIColor groupTableViewBackgroundColor] andView:nil];
        NSArray* imgAry = @[@"ico_order_news",@"ico_set_news",@"ico_qb_news"];
        NSArray* titleAry = @[@"订单消息",@"系统通知",@"钱包消息"];
        
        NSMutableArray* subAry = [NSMutableArray arrayWithObjects:@"",@"",@"", nil];
        NSMutableArray* timeAry = [NSMutableArray arrayWithObjects:@"",@"",@"", nil];
        NSMutableArray* dotAry = [NSMutableArray arrayWithObjects:@"",@"",@"", nil];
        
        if (self.dataInfo){
            subAry[0] = [NSString stringWithFormat:@"%@",self.dataInfo[@"ordermsg"][@"content"]];
            subAry[1] = [NSString stringWithFormat:@"%@",self.dataInfo[@"sysmsg"][@"content"]];
            subAry[2] = [NSString stringWithFormat:@"%@",self.dataInfo[@"walletmsg"][@"content"]];
            
            timeAry[0] = [NSString stringWithFormat:@"%@",self.dataInfo[@"ordermsg"][@"addtime"]];
            timeAry[1] = [NSString stringWithFormat:@"%@",self.dataInfo[@"sysmsg"][@"addtime"]];
            timeAry[2] = [NSString stringWithFormat:@"%@",self.dataInfo[@"walletmsg"][@"addtime"]];
            
            dotAry[0] = [NSString stringWithFormat:@"%@",self.dataInfo[@"ordermsg"][@"status"]];
            dotAry[1] = [NSString stringWithFormat:@"%@",self.dataInfo[@"sysmsg"][@"status"]];
            dotAry[2] = [NSString stringWithFormat:@"%@",self.dataInfo[@"walletmsg"][@"status"]];
        }
        //布置信息
        for (int i = 0;i < 3; i++){
            UIButton* cell = [EBUtility btnfrome:CGRectMake(0, 70* i +1, SCREEN_WIDTH, 70) andText:@"" andColor:[UIColor whiteColor] andimg:nil andView:v];
            cell.backgroundColor = [UIColor whiteColor];
            cell.tag = i;
            [cell addTarget:self action:@selector(messagePush:) forControlEvents:UIControlEventTouchUpInside];
            UIImageView* img = [EBUtility imgfrome:CGRectMake(10, 10, 50, 50) andImg:[UIImage imageNamed:imgAry[i]] andView:cell];

            UILabel* titleLab = [EBUtility labfrome:CGRectZero andText:titleAry[i] andColor:[UIColor blackColor] andView:cell];
            titleLab.font = [UIFont systemFontOfSize:18];
            [titleLab sizeToFit];
            UILabel* subTitleLab = [EBUtility labfrome:CGRectZero andText:subAry[i] andColor:[UIColor lightGrayColor] andView:cell];
            subTitleLab.textAlignment = 0;
            [subTitleLab sizeToFit];
            UILabel* timeLab = [EBUtility labfrome:CGRectZero andText:@"" andColor:[UIColor lightGrayColor] andView:cell];
            [timeLab sizeToFit];
            //红点
            UILabel* dot = [EBUtility labfrome:CGRectZero andText:@"" andColor:nil andView:cell];
            dot.backgroundColor = [UIColor redColor];
            dot.tag = i + 100;
            dot.layer.masksToBounds = 1.5;
            dot.layer.cornerRadius = 3;
            dot.hidden = YES;
            
            [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(img.mas_top).offset(5);
                make.left.equalTo(img.mas_right).offset(10);
                
            }];
            [subTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(titleLab.mas_bottom).offset(10);
                make.left.equalTo(img.mas_right).offset(10);
                make.width.equalTo(@280);
            }];
            [timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(img.mas_top).offset(5);
                make.right.equalTo(cell.mas_right).offset(-10);
                
            }];
            [dot mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(img.mas_top).offset(-2);
                make.right.equalTo(img.mas_right).offset(2);
                make.width.equalTo(@6);
                make.height.equalTo(@6);
            }];
            
            if (self.dataInfo){
                subTitleLab.text = subAry[i];
                timeLab.text = timeAry[i];
                if ([dotAry[i] isEqualToString:@"1"]){
                    dot.hidden = NO;
                }
            }
        }
        return v;
    }
    return nil;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

//云信跳转聊天页面
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NIMRecentSession *recentSession = self.recentSessions[indexPath.row];
    [self onSelectedRecent:recentSession atIndexPath:indexPath];
}
- (void)onSelectedRecent:(NIMRecentSession *)recentSession atIndexPath:(NSIndexPath *)indexPath{
    ChatViewController *vc = [[ChatViewController alloc] initWithSession:recentSession.session];
    [self.navigationController pushViewController:vc animated:YES];
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
