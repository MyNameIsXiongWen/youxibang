//
//  SigninViewController.m
//  youxibang
//
//  Created by jiazhuo1 on 2018/5/2.
//

#import "SigninViewController.h"
#import "SigninTableViewCell.h"
#import "SigninCoinHistoryViewController.h"
#import "InviteViewController.h"
#import "LoginViewController.h"

static NSString *const SIGNTABLEVIEW_ID = @"signtableview_id";
@interface SigninViewController () <UITableViewDelegate ,UITableViewDataSource> {
    UIButton *signinBtn;
    UILabel *countLabel;
    NSMutableDictionary *dataInfo;
}

@property (weak, nonatomic) IBOutlet UITableView *tableview;

@end

@implementation SigninViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"我的金币";
    self.tableview.rowHeight = 70;
    self.tableview.tableFooterView = UIView.new;
    self.tableview.tableHeaderView = [self configTableviewHeaderview];
    [self.tableview registerNib:[UINib nibWithNibName:@"SigninTableViewCell" bundle:nil] forCellReuseIdentifier:SIGNTABLEVIEW_ID];
    if (UserModel.sharedUser.token) {
        [self getDataInfoRequest];
    }
}

- (void)getDataInfoRequest {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    NSDictionary *dic = NSDictionary.dictionary;
    dic = @{@"token":UserModel.sharedUser.token};
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@member/get_my_gold",HttpURLString] Paremeters:dic successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            if (code == 1) {
                dataInfo = object[@"data"];
                self.tableview.tableHeaderView = [self configTableviewHeaderview];
                [self.tableview reloadData];
            }else{
                [[SYPromptBoxView sharedInstance] setPromptViewMessage:msg andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
            }
        }
    } failoperation:^(NSError *error) {
        [SVProgressHUD dismiss];
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络信号差，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
    }];
}

- (UIView *)configTableviewHeaderview {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, (418+33)*ADAPTATIONRATIO)];
    headerView.backgroundColor = UIColor.whiteColor;
    
    UIImageView *bkg = [EBUtility imgfrome:CGRectMake(0, 0, SCREEN_WIDTH, 418*ADAPTATIONRATIO) andImg:[UIImage imageNamed:@"signin_bkg"] andView:headerView];
    UIView *bkgview = [EBUtility viewfrome:CGRectMake(15, 20, 100, 30) andColor:UIColor.blackColor andView:headerView];
    bkgview.alpha = 0.45;
    bkgview.layer.cornerRadius = 15;
    bkgview.layer.masksToBounds = YES;
    UIImageView *coinImg = [EBUtility imgfrome:CGRectMake(25, 26, 18, 18) andImg:[UIImage imageNamed:@"signin_coin"] andView:headerView];
    countLabel = [EBUtility labfrome:CGRectMake(48, 26, 60, 18) andText:@"0" andColor:UIColor.whiteColor andView:headerView];
    countLabel.tag = 111;
    countLabel.textAlignment = NSTextAlignmentLeft;
    UIButton *intoBtn = [EBUtility btnfrome:bkgview.frame andText:@"" andColor:nil andimg:[UIImage imageNamed:@"signin_into"] andView:headerView];
    intoBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 30, 0, -30);
    [intoBtn addTarget:self action:@selector(intoSelector) forControlEvents:UIControlEventTouchUpInside];
    signinBtn = [EBUtility btnfrome:CGRectMake((SCREEN_WIDTH-135)/2, CGRectGetMaxY(headerView.frame)-70-35, 135, 35) andText:@"" andColor:nil andimg:[UIImage imageNamed:@"signin_signin"] andView:headerView];
    signinBtn.tag = 222;
    [signinBtn addTarget:self action:@selector(signSelector:) forControlEvents:UIControlEventTouchUpInside];
    UILabel *taskLabel = [EBUtility labfrome:CGRectMake(15, CGRectGetMaxY(headerView.frame)-15, 150, 15) andText:@"每日任务" andColor:[UIColor colorFromHexString:@"333333"] andView:headerView];
    taskLabel.textAlignment = NSTextAlignmentLeft;
    
    if (dataInfo) {
        countLabel.text = [NSString stringWithFormat:@"%@",dataInfo[@"gold"]];
        if ([dataInfo[@"is_sign"] integerValue] == 1) {
            [signinBtn setImage:[UIImage imageNamed:@"signin_signined"] forState:0];
            signinBtn.enabled = NO;
        }
    }
    
    return headerView;
}

- (void)intoSelector {
    if (!UserModel.sharedUser.token) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController* vc = [sb instantiateViewControllerWithIdentifier:@"loginPWD"];
        [self.navigationController pushViewController:vc animated:1];
        return;
    }
    SigninCoinHistoryViewController *historyCon = [SigninCoinHistoryViewController new];
    [self.navigationController pushViewController:historyCon animated:YES];
}

- (void)signSelector:(UIButton *)sender {
    if (!UserModel.sharedUser.token) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController* vc = [sb instantiateViewControllerWithIdentifier:@"loginPWD"];
        [self.navigationController pushViewController:vc animated:1];
        return;
    }
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    NSDictionary *dic = NSDictionary.dictionary;
    dic = @{@"token":UserModel.sharedUser.token};
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@member/sign_in",HttpURLString] Paremeters:dic successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            if (code == 1) {
                countLabel.text = [NSString stringWithFormat:@"%d",[object[@"gold"] intValue]+countLabel.text.intValue];
                [signinBtn setImage:[UIImage imageNamed:@"signin_signined"] forState:0];
                signinBtn.enabled = NO;
                [dataInfo setObject:@"1" forKey:@"is_sign"];
                [self.tableview reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                [SVProgressHUD showSuccessWithStatus:@"签到成功"];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SigninTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SIGNTABLEVIEW_ID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSArray *iconArray = @[@"signin_icon",@"signin_invite"];
    NSArray *titleArray = @[@"每日签到",@"邀请好友"];
    cell.iconImgView.image = [UIImage imageNamed:iconArray[indexPath.row]];
    cell.taskLabel.text = titleArray[indexPath.row];
    cell.signinButton.layer.borderWidth = 0.5;
    cell.signinButton.tag = indexPath.row+999;
    if (indexPath.row == 0) {
        [cell.signinButton setTitle:@"签到" forState:0];
        cell.signinButton.layer.borderColor = [UIColor colorFromHexString:@"4b8ff4"].CGColor;
        [cell.signinButton setTitleColor:[UIColor colorFromHexString:@"4b8ff4"] forState:0];
        [cell.signinButton addTarget:self action:@selector(cellBtnSelector:) forControlEvents:UIControlEventTouchUpInside];
        NSString *completestring = @"完成 0/1";
        if (dataInfo) {
            if ([dataInfo[@"is_sign"] integerValue] == 1) {
                completestring = @"完成 1/1";
                [cell.signinButton setTitle:@"已签到" forState:0];
                cell.signinButton.backgroundColor = [UIColor colorFromHexString:@"bbbbbb"];
                cell.signinButton.layer.borderColor = [UIColor colorFromHexString:@"bbbbbb"].CGColor;
                [cell.signinButton setTitleColor:[UIColor whiteColor] forState:0];
                cell.signinButton.enabled = NO;
            }
        }
        NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:completestring];
        [attribute addAttribute:NSForegroundColorAttributeName value:[UIColor colorFromHexString:@"4b8ff4"] range:NSMakeRange(3, 1)];
        cell.completeLabel.attributedText = attribute;
    }
    else {
        [cell.signinButton setTitle:@"去邀请" forState:0];
        cell.signinButton.layer.borderColor = [UIColor colorFromHexString:@"4b8ff4"].CGColor;
        [cell.signinButton setTitleColor:[UIColor colorFromHexString:@"4b8ff4"] forState:0];
        [cell.signinButton addTarget:self action:@selector(cellBtnSelector:) forControlEvents:UIControlEventTouchUpInside];
        NSString *invitestring = @"今日邀请 0 人,获取 0 金币";
        NSString *countstring = @"0";
        NSString *goldstring = @"0";
        if (dataInfo) {
            countstring = [NSString stringWithFormat:@"%@",dataInfo[@"invitation_count"]];
            goldstring = [NSString stringWithFormat:@"%@",dataInfo[@"invitation_gold"]];
        }
        invitestring = [NSString stringWithFormat:@"今日邀请 %@ 人,获取 %@ 金币",countstring,goldstring];
        NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:invitestring];
        [attribute addAttribute:NSForegroundColorAttributeName value:[UIColor colorFromHexString:@"4b8ff4"] range:NSMakeRange(5, [countstring length])];
        [attribute addAttribute:NSForegroundColorAttributeName value:[UIColor colorFromHexString:@"4b8ff4"] range:NSMakeRange(11+[countstring length], [goldstring length])];
        cell.completeLabel.attributedText = attribute;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)cellBtnSelector:(UIButton *)sender {
    if (!UserModel.sharedUser.token) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController* vc = [sb instantiateViewControllerWithIdentifier:@"loginPWD"];
        [self.navigationController pushViewController:vc animated:1];
        return;
    }
    if (sender.tag == 999) {
        [self signSelector:sender];
    }
    else {
        InviteViewController *invite = [InviteViewController new];
        [self.navigationController pushViewController:invite animated:YES];
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
