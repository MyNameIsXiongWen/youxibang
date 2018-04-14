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
 *  更改登录信息
 */
+ (void)updateSomeData:(NSDictionary *)dic ;
/**
 *  读取登录信息
 */
+ (NSMutableDictionary *)readLoginData;

/**
 *  清除用户信息
 */
+ (void)cleanloginData;

/**
 *  储存用户信息
 */
+(void)updatePersonalData:(NSDictionary *)dic;

/**
 *  读取用户信息
 */
+ (NSMutableDictionary *)readPersonalData;

/**
 *  更新用户信息
 */
+ (void)reloadPersonalData:(void (^ __nullable)(void))completion; 
@end
