//
//  MainTabBarController.h
//  MSMKProject
//
//  Created by 甬创先河－开发 on 16/1/18.
//  Copyright © 2016年 甬创先河－开发. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainTabBarController : UITabBarController<UITabBarDelegate>
@property (nonatomic, assign)NSInteger index;
- (void)setupChildVcs;
@end
