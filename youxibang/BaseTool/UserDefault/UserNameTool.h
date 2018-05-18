//
//  UserNameTool.h
//  同盟圈
//
//  Created by 我的 on 16/4/13.
//  Copyright © 2016年 ym. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserNameTool : NSObject

/**
 *  存储登录信息
 */
+ (void)saveLoginData:(NSDictionary *)dic;
/**
 *  清除登陆信息
 */
+ (void)cleanloginData;
/**
 *  更新登录信息
 */
+ (void)updateSomeData:(NSDictionary *)dic ;
/**
 *  读取登录信息
 */
+ (NSMutableDictionary *)readLoginData;

/**
 *  获取用户信息
 */
+ (void)reloadPersonalData:(void (^ __nullable)(void))completion; 

@end
