//
//  InviteViewController.m
//  youxibang
//
//  Created by jiazhuo1 on 2018/5/4.
//

#import "InviteViewController.h"
#import "ShareView.h"

@interface InviteViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) ShareView *shareView;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *inviteCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *inviteCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *getCoinLabel;
@property (weak, nonatomic) IBOutlet UILabel *todayGetCoinLabel;

@end

@implementation InviteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"邀好友获金币/彩妆/直播设备";
    self.inviteCodeLabel.text = UserModel.sharedUser.invitecode;
    self.tableview.tableHeaderView = self.headerView;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationSelector:) name:@"SHARENOTIFICATION" object:nil];
    [self getDataInfoRequest];
}

- (void)getDataInfoRequest {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    NSDictionary *dic = NSDictionary.dictionary;
    if (DataStore.sharedDataStore.token) {
        dic = @{@"token":DataStore.sharedDataStore.token};
    }
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@member/get_my_gold",HttpURLString] Paremeters:dic successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            if (code == 1) {
                NSDictionary *dataInfo = object[@"data"];
                self.getCoinLabel.text = [NSString stringWithFormat:@"%@",dataInfo[@"gold"]];
                self.inviteCountLabel.text = [NSString stringWithFormat:@"%@",dataInfo[@"invitation_count"]];
                self.todayGetCoinLabel.text = [NSString stringWithFormat:@"%@",dataInfo[@"invitation_gold"]];
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

- (IBAction)clickInviteBtn:(id)sender {
    self.shareView = [[ShareView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-140, SCREEN_WIDTH, 140) WithShareUrl:[NSString stringWithFormat:@"%@?invitation=%@",SHARE_WEBURL,UserModel.sharedUser.invitecode] ShareTitle:SHARE_TITLE WithShareDescription:SHARE_DESCRIPTION];
    [self.shareView show];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCell.new;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
