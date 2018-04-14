//
//  UserNameTool.m
//  同盟圈
//
//  Created by 我的 on 16/4/13.
//  Copyright © 2016年 ym. All rights reserved.
//

#import "UserNameTool.h"

@implementation UserNameTool

+ (void)saveLoginData:(NSDictionary *)dic {
    
    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:@"loginInfo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(void)updateSomeData:(NSDictionary *)dic{

    NSMutableDictionary *oldDic = [[[NSUserDefaults standardUserDefaults] objectForKey:@"loginInfo"] mutableCopy];
    [oldDic addEntriesFromDictionary:dic];
    [[NSUserDefaults standardUserDefaults] setObject:oldDic forKey:@"loginInfo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSMutableDictionary *)readLoginData {
    
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"loginInfo"] mutableCopy];
}


+(void)updatePersonalData:(NSDictionary *)dic{

    NSMutableDictionary *oldDic = [[[NSUserDefaults standardUserDefaults] objectForKey:@"personalInfo"] mutableCopy];
    if (!oldDic){
        oldDic = [NSMutableDictionary dictionary];
    }
    [oldDic addEntriesFromDictionary:dic];
    [[NSUserDefaults standardUserDefaults] setObject:oldDic forKey:@"personalInfo"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}
+ (NSMutableDictionary *)readPersonalData {

    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"personalInfo"] mutableCopy];
}

+ (void)loginStatus:(BOOL)login{
    
    [[NSUserDefaults standardUserDefaults] setBool:login forKey:@"isLogin"];

}

+ (BOOL)isLogin{
    
   return  [[NSUserDefaults standardUserDefaults] boolForKey:@"isLogin"];
    
}
//清除历史记录数据
+ (void)cleanloginData {
    
//    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
//    NSString *path=[paths objectAtIndex:0];
//        NSLog(@"path = %@",path);
//    NSString *filename=[path stringByAppendingPathComponent:@"loginnData.plist"];
//    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:0];
//    [dic writeToFile:filename atomically:YES];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"personalInfo"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"loginInfo"];
}

+ (void)reloadPersonalData:(void (^ __nullable)(void))completion{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[DataStore sharedDataStore].token forKey:@"token"];
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Member/userinfo.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            if (code == 1) {
                NSMutableDictionary* dataInfo = [NSMutableDictionary dictionaryWithDictionary:object[@"data"]];
                [UserNameTool updatePersonalData:dataInfo];
                if (completion){
                    completion();
                }
            }else{
                [SVProgressHUD showErrorWithStatus:msg];
            }
        }
    } failoperation:^(NSError *error) {
    }];
}
@end
