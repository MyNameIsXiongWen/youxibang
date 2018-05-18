//
//  BaseTableViewController.m
//  ChuXing
//
//  Created by dingyi on 2017/9/28.
//  Copyright © 2017年 Dingyi. All rights reserved.
//

#import "BaseTableViewController.h"
#import "LoginViewController.h"

@interface BaseTableViewController ()<UIGestureRecognizerDelegate>

@end

@implementation BaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(InfoNotificationAction:) name:@"Logout" object:nil];
}

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
//    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    LoginViewController* vc = [sb instantiateViewControllerWithIdentifier:@"loginPWD"];
//    MainNavigationController * HomePageNVC = [[MainNavigationController alloc] initWithRootViewController:vc];
//    [self.navigationController presentViewController:HomePageNVC animated:YES completion:nil];
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController* vc = [sb instantiateViewControllerWithIdentifier:@"loginPWD"];
    [self.navigationController pushViewController:vc animated:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)  style:UITableViewStylePlain];
        _tableView.showsVerticalScrollIndicator = NO;
        self.edgesForExtendedLayout = UIRectEdgeNone;
        _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        UIView *v = [[UIView alloc]init];
        v.backgroundColor = [UIColor clearColor];
        _tableView.tableFooterView = v;
        UITapGestureRecognizer *tapSuperGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSuperView:)];
        tapSuperGesture.delegate = self;
        [_tableView addGestureRecognizer:tapSuperGesture];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}
- (void)tapSuperView:(UITapGestureRecognizer *)tapSuperGesture{
    [self.tableView endEditing:1];
}
#pragma mark - tableViewDelegate/DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - otherDelegate/DataSource
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return NO;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceivePress:(UIPress *)press {
    return NO;
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
