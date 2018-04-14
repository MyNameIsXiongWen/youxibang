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
@property (nonatomic,strong)UIButton* centerBtn;
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

- (void)setupChildVcs
{
    //设置子控制器
    NSArray *tabBarItemImages = @[@"\U0000e612", @"\U0000e630", @"\U0000e615"];

    NSArray *tabBarItemTitles = @[@"首页",@"消息", @"我的"];
    
    NSArray* vcAry = @[@"HomeViewController",@"MessageViewController",@"MineViewController"];
    
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = 0; i < vcAry.count; i ++ ) {

        NSString *image = [tabBarItemImages objectAtIndex:i];
        NSString *title = [tabBarItemTitles objectAtIndex:i];
        
        BaseTableViewController *vc = [[NSClassFromString(vcAry[i]) alloc] init];
        
        MainNavigationController* navigation = [[MainNavigationController alloc]initWithRootViewController:vc];
        
        navigation.tabBarItem.image = [[UIImage iconWithInfo:TBCityIconInfoMake(image,26,[UIColor blackColor])] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        navigation.tabBarItem.selectedImage = [[UIImage iconWithInfo:TBCityIconInfoMake(image,26,Nav_color)] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        navigation.tabBarItem.title = title;
        
        self.tabBarController.tabBar.tintColor = Nav_color;
        navigation.tabBarItem.tag = i;
        NSMutableDictionary *textArray1 = [NSMutableDictionary dictionary];
        textArray1[NSForegroundColorAttributeName] = [UIColor blackColor];
        
        NSMutableDictionary *textArray2 = [NSMutableDictionary dictionary];
        textArray2[NSForegroundColorAttributeName] = Nav_color;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ) {
            
        }
        [navigation.tabBarItem setTitleTextAttributes:textArray1 forState:UIControlStateNormal];
        [navigation.tabBarItem setTitleTextAttributes:textArray2 forState:UIControlStateSelected];
        
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
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if (viewController.tabBarItem.tag != 2) {
        self.centerBtn.selected = NO;
    }else{
        self.centerBtn.selected = YES;
    }
//    NSLog(@"输出--tabbaritem.title--%@---tag %ld",viewController.tabBarItem.title,(long)viewController.tabBarItem.tag);

    if (viewController.tabBarItem.tag == 2 ||viewController.tabBarItem.tag == 1)
    {
        
        if (![EBUtility isBlankString:[DataStore sharedDataStore].token]){
               return YES;
            }else{
                [self skipLoginPage];
                return NO;
            }

    }else
    {
        return YES;
    }
}


-(void)skipLoginPage
{
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController* vc = [sb instantiateViewControllerWithIdentifier:@"loginPWD"];
    MainNavigationController * HomePageNVC = [[MainNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:HomePageNVC animated:YES completion:nil];
}

@end
