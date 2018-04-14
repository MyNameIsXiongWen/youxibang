//
//  MainNavigationController.m
//  DChang
//
//  Created by 戎博 on 17/7/21.
//  Copyright © 2017年 昆博. All rights reserved.
//

#import "MainNavigationController.h"

@interface MainNavigationController ()
{
    BOOL state;
}
@end

@implementation MainNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpNavi];

}
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([UIDevice currentDevice].systemVersion.floatValue < 10.0) return;
    if ([navigationController isKindOfClass:[UIImagePickerController class]] &&
        ((UIImagePickerController *)navigationController).sourceType == UIImagePickerControllerSourceTypeCamera) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    }
}

-(void)setUpNavi {
    self.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"navi_bg"] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    for (UIViewController *vc in self.childViewControllers) {
        UIImageView* img = [[UIImageView alloc]initWithFrame:CGRectMake(0, 10, 10, 20)];
        img.image = [UIImage imageNamed:@"back"];
        UIButton *leftBtn = [[UIButton alloc]initWithFrame:CGRectMake(-15, 0, 40, 40)];
//        [leftBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [leftBtn addSubview:img];
        [leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        vc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
        vc.hidesBottomBarWhenPushed = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    state = NO;

    if ((self.childViewControllers.count > 0 && !state) ) {
        
        UIView* view = [[UIView alloc]initWithFrame: CGRectMake(0, 0, 50, 40)];
        UIImageView* img = [[UIImageView alloc]initWithFrame:CGRectMake(0, 10, 10, 20)];
        img.image = [UIImage imageNamed:@"back"];
        UIButton *leftBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 40)];
        [leftBtn addSubview:img];
        [leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:leftBtn];
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:view];
        
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
}


-(void)back
{
    state = NO;
    if (self.childViewControllers.count == 2) {
        for (UIViewController *vc in self.childViewControllers) {
            if ([NSStringFromClass(vc.class) isEqualToString:@"MineViewController"] ||[NSStringFromClass(vc.class) isEqualToString:@"MessageViewController"] ||[NSStringFromClass(vc.class) isEqualToString:@"HomeViewController"] ) {
                state = YES;
            }
            self.childViewControllers[0].tabBarController.tabBar.hidden = NO;
        }

        if (!state)
        [self setUpNavi];
    }
    [self popViewControllerAnimated:YES];
}


@end
