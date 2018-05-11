//
//  MainNavigationController.m
//  DChang
//
//  Created by 戎博 on 17/7/21.
//  Copyright © 2017年 昆博. All rights reserved.
//

#import "MainNavigationController.h"

@interface MainNavigationController ()

@end

@implementation MainNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationBar.backgroundColor = [UIColor whiteColor];
    self.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor colorFromHexString:@"333333"] forKey:NSForegroundColorAttributeName];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([UIDevice currentDevice].systemVersion.floatValue < 10.0) return;
    if ([navigationController isKindOfClass:[UIImagePickerController class]] &&
        ((UIImagePickerController *)navigationController).sourceType == UIImagePickerControllerSourceTypeCamera) {
        
        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
            [self prefersStatusBarHidden];
            [self preferredStatusBarStyle];
            [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        }
    }
}

//实现隐藏方法
- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    NSString *classString = NSStringFromClass(self.childViewControllers.lastObject.class);
    if ([classString isEqualToString:@"MineViewController"]) {
        return UIStatusBarStyleLightContent;
    }
    return UIStatusBarStyleDefault;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ((self.childViewControllers.count > 0) ) {
        UIView* view = [[UIView alloc]initWithFrame: CGRectMake(0, 0, 50, 40)];
        UIImageView* img = [[UIImageView alloc]initWithFrame:CGRectMake(0, 10, 10, 20)];
        img.image = [UIImage imageNamed:@"back_black"];
        UIButton *leftBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 40)];
        [leftBtn addSubview:img];
        [leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:leftBtn];
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:view];
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
}

-(void)back {
    [self popViewControllerAnimated:YES];
}

@end
