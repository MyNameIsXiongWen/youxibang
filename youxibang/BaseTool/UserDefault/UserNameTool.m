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

//清除历史记录数据
+ (void)cleanloginData {
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"loginInfo"];
}

+ (void)updateSomeData:(NSDictionary *)dic {
    NSMutableDictionary *oldDic = [[[NSUserDefaults standardUserDefaults] objectForKey:@"loginInfo"] mutableCopy];
    [oldDic addEntriesFromDictionary:dic];
    [[NSUserDefaults standardUserDefaults] setObject:oldDic forKey:@"loginInfo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSMutableDictionary *)readLoginData {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"loginInfo"] mutableCopy];
}

+ (void)reloadPersonalData:(void (^ __nullable)(void))completion {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[DataStore sharedDataStore].token forKey:@"token"];
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Member/userinfo.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"-------输出 %@--%@",object,msg);
            if (code == 1) {
                NSMutableDictionary* dataInfo = [NSMutableDictionary dictionaryWithDictionary:object[@"data"]];
                [UserModel keyarchiveUserModelWithDict:dataInfo];
                if (completion){
                    completion();
                }
            }else{
                [[SYPromptBoxView sharedInstance] setPromptViewMessage:msg andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
            }
        }
    } failoperation:^(NSError *error) {
    }];
}

@end
