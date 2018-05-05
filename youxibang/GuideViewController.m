//
//  GuideViewController.m
//  ecbao
//
//  Created by 熊文 on 16/8/30.
//  Copyright © 2016年 Hangzhou AIJU Technology Co.,Ltd. All rights reserved.
//

#import "GuideViewController.h"
#import "AppDelegate.h"

@interface GuideViewController () <UIScrollViewDelegate,UIGestureRecognizerDelegate,UIActionSheetDelegate>

@property (assign, nonatomic) int index;
@property (retain, nonatomic) NSArray *imgArray;
@property (weak, nonatomic) IBOutlet UIScrollView *photoScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end

@implementation GuideViewController

/**
 *  author keluo
 *  reviewer lufei
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.imgArray = @[@"aj_launch_image1",@"aj_launch_image2",@"aj_launch_image3"];
    self.photoScrollView.contentSize = CGSizeMake(SCREEN_WIDTH*self.imgArray.count, 0);
    for (int i=0; i<self.imgArray.count; i++) {
        UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*i, -20, SCREEN_WIDTH, SCREEN_HEIGHT)];
        scroll.delegate = self;
        scroll.showsHorizontalScrollIndicator = NO;
        scroll.showsVerticalScrollIndicator = NO;
        scroll.backgroundColor = [UIColor clearColor];
        
        UIImageView *imgview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, scroll.frame.size.width, scroll.frame.size.height)];
        [imgview setImage:[UIImage imageNamed:self.imgArray[i]]];
        imgview.userInteractionEnabled = YES;
        imgview.contentMode = UIViewContentModeScaleAspectFit;
        [scroll addSubview:imgview];
        if (i == 2) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitle:@"立即开启" forState:UIControlStateNormal];
            btn.frame = CGRectMake((SCREEN_WIDTH - 100)/2, SCREEN_HEIGHT - 60, 100, 30);
            btn.layer.borderColor = [UIColor colorFromHexString:@"457fea"].CGColor;
            btn.layer.borderWidth = 0.5;
            btn.layer.cornerRadius = 5;
            btn.layer.masksToBounds = YES;
            [btn setTitleColor:[UIColor colorFromHexString:@"457fea"] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(goMainTabbarController) forControlEvents:UIControlEventTouchUpInside];
            [imgview addSubview:btn];
        }
        [self.photoScrollView addSubview:scroll];
    }
    [self.photoScrollView setContentOffset:CGPointMake(SCREEN_WIDTH*self.index, 0)];
    self.pageControl.numberOfPages = self.imgArray.count;
    [self.pageControl setCurrentPage:self.index];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goMainTabbarController {
    MainTabBarController *mainTab = [[MainTabBarController alloc] init];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.window.rootViewController = mainTab;
}

#pragma mark - scroll delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.index = scrollView.contentOffset.x/SCREEN_WIDTH;
    [self.pageControl setCurrentPage:self.index];
}

@end
