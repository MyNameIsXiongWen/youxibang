//
//  MainTabBarController.m
//  MSMKProject
//
//  Created by 甬创先河－开发 on 16/1/18.
//  Copyright © 2016年 甬创先河－开发. All rights reserved.
//

#import "MainTabBarController.h"
#import "TBCityIconFont.h"
#import "UIImage+TBCityIconFont.h"
#import "LoginViewController.h"

@interface MainTabBarController ()<UITabBarControllerDelegate>
@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITabBar *tabBar = [[UITabBar alloc] init];
    tabBar.delegate = self;
//    [self removeTabarTopLine:tabBar];
    [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];
    [UITabBar appearance].translucent = NO;//这句表示取消tabBar的透明效果。
    [self setValue:tabBar forKeyPath:@"tabBar"];
    [SVProgressHUD setMinimumDismissTimeInterval:1];
    [self setupChildVcs];
 
}

- (void)setupChildVcs {
    //设置子控制器
//    NSArray *tabBarItemImages = @[@"\U0000e612", @"\U0000e630", @"\U0000e615"];
    NSArray *tabBarItemImages = @[@"tabbar_home_unselected",@"tabbar_news_unselected", @"tabbar_msg_unselected", @"tabbar_mine_unselected"];
    NSArray *tabBarItemSelectedImages = @[@"tabbar_home_selected",@"tabbar_news_selected", @"tabbar_msg_selected", @"tabbar_mine_selected"];
    NSArray *tabBarItemTitles = @[@"首页",@"资讯",@"消息", @"我的"];
    NSArray* vcAry = @[@"HomeViewController",@"NewsViewController",@"MessageViewController",@"MineViewController"];
    
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = 0; i < vcAry.count; i ++ ) {
        NSString *image = [tabBarItemImages objectAtIndex:i];
        NSString *selectedImage = [tabBarItemSelectedImages objectAtIndex:i];
        NSString *title = [tabBarItemTitles objectAtIndex:i];
        
        BaseTableViewController *vc = [[NSClassFromString(vcAry[i]) alloc] init];
        MainNavigationController* navigation = [[MainNavigationController alloc]initWithRootViewController:vc];
        navigation.tabBarItem.tag = i;
        navigation.tabBarItem.title = title;
        navigation.tabBarItem.image = [[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        navigation.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [navigation.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorFromHexString:@"7c88a4"],NSFontAttributeName:[UIFont systemFontOfSize:10]}
                                                  forState:UIControlStateNormal];
        [navigation.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName :[UIColor colorFromHexString:@"457fea"],NSFontAttributeName:[UIFont systemFontOfSize:10]}
                                                  forState:UIControlStateSelected];
        //    childController.tabBarItem.imageInsets = UIEdgeInsetsMake(-1, 0, 1, 0);
        navigation.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -1);
        [array addObject:navigation];
    }

    self.viewControllers = array;
  
    self.delegate= self;
    
}

//去掉tabBar顶部线条
//- (void)removeTabarTopLine:(UITabBar *)tab {
//    CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
//    UIGraphicsBeginImageContext(rect.size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
//    CGContextFillRect(context, rect);
//    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    [tab setBackgroundImage:img];
//    [tab setShadowImage:img];
//}
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if (viewController.tabBarItem.tag == 2 || viewController.tabBarItem.tag == 3) {
        if (![EBUtility isBlankString:UserModel.sharedUser.token]){
               return YES;
            }else{
                [self skipLoginPage];
                return NO;
            }
    }else {
        return YES;
    }
}


- (void)skipLoginPage {
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController* vc = [sb instantiateViewControllerWithIdentifier:@"loginPWD"];
    MainNavigationController * HomePageNVC = [[MainNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:HomePageNVC animated:YES completion:nil];
}

@end
