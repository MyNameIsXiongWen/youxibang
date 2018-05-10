//
//  BaseViewController.m
//  DChang
//
//  Created by 戎博 on 2017/8/1.
//  Copyright © 2017年 昆博. All rights reserved.
//

#import "BaseViewController.h"
#import "LoginViewController.h"
@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(InfoNotificationAction:) name:@"Logout" object:nil];
}
- (void)InfoNotificationAction:(NSNotification *)notification{
    //云信登出账号
    [[[NIMSDK sharedSDK] loginManager] logout:^(NSError *error) {
        
    }];
    [UserNameTool cleanloginData];
    [DataStore sharedDataStore].userid = nil;
    [DataStore sharedDataStore].mobile = nil;
    [DataStore sharedDataStore].yxuser = nil;
    [DataStore sharedDataStore].yxpwd = nil;
    [DataStore sharedDataStore].token = nil;
    [JPUSHService setAlias:@"" completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
        
    } seq:1];
//    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    LoginViewController* vc = [sb instantiateViewControllerWithIdentifier:@"loginPWD"];
//    MainNavigationController * HomePageNVC = [[MainNavigationController alloc] initWithRootViewController:vc];
//    [self presentViewController:HomePageNVC animated:YES completion:nil];
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController* vc = [sb instantiateViewControllerWithIdentifier:@"loginPWD"];
    [self.navigationController pushViewController:vc animated:1];
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
