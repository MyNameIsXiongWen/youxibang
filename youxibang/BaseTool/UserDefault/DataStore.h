//
//  DataStore.h
//  XianGui
//
//  Created by 洛水寒 on 17/5/11.
//  Copyright © 2017年 洛水寒. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataStore : NSObject
@property(nonatomic, strong) NSString *userid;//用户id
@property(nonatomic, strong) NSString *mobile;//userName
@property(nonatomic, strong) NSString *token;//APP全局token
@property(nonatomic, strong) NSString *UserIcon;//头像
@property(nonatomic, strong) NSString *Sex;//性别

@property(nonatomic, strong) NSString *city;//城市
@property(nonatomic, strong) NSString *latitude;//纬度
@property(nonatomic, strong) NSString *longitude;//经度

@property(nonatomic, strong) NSString *yxuser;//云信账号
@property(nonatomic, strong) NSString *yxpwd;//云信密码
+ (DataStore *)sharedDataStore;
+ (void )addDataStore:(NSDictionary*)dic;
@end
