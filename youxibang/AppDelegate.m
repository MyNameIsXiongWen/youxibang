//
//  AppDelegate.m
//  youxibang
//
//  Created by y on 2018/1/18.
//

#import "AppDelegate.h"
#import "TalkingData.h"
#import "WXApi.h"
#import "LoginViewController.h"
#import "BaseTool/QQFramework/TencentOpenAPI.framework/Headers/TencentOAuth.h"
#import <AlipaySDK/AlipaySDK.h>
#import "TopUpAndWithdrawViewController.h"
#import <Bugly/Bugly.h>

@interface AppDelegate ()<WXApiDelegate,JPUSHRegisterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //iconfont注册
    [TBCityIconFont setFontName:@"iconfont"];
    //从userdefault中获取信息自动登录
    NSDictionary *user =  [UserNameTool readLoginData];
    if (user.count) {
        [self lg:user];
    }
    //微信注册
    [WXApi registerApp:WX_APP_ID];
    //talkingdata注册
    [TalkingData sessionStarted:@"7AF6493B08F141FC8EF2450B65B3C0B2" withChannelId:@"iOS正式版"];
    [TalkingData setExceptionReportEnabled:YES];
    [Bugly startWithAppId:@"98eee6832c"];
    
    //Jpush
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 可以添加自定义categories
        // NSSet<UNNotificationCategory *> *categories for iOS10 or later
        // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    [JPUSHService setupWithOption:launchOptions appKey:@"00ba7b47099c1870085c0f5a"
                          channel:@"App Store"
                 apsForProduction:YES];

    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(networkDidReceiveMessage:) name:kJPFNetworkDidReceiveMessageNotification object:nil];
    
    //自定义tabbar
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    MainTabBarController *minTa = [[MainTabBarController alloc] init];
    
    _window.rootViewController = minTa;
    return YES;
}
//自动登录方法
- (void)lg:(NSDictionary*)dic{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Member/login.html",HttpURLString] Paremeters:dic successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object))
        {
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]];
            NSLog(@"登录输出 %@--%@",object,msg);
            if (code == 1) {
                NSDictionary* user = object[@"data"];

                DataStore.sharedDataStore.userid = [NSString stringWithFormat:@"%@",user[@"userid"]];
                DataStore.sharedDataStore.mobile = [NSString stringWithFormat:@"%@",user[@"mobile"]];
                DataStore.sharedDataStore.yxuser = [NSString stringWithFormat:@"%@",user[@"yxuser"]];
                DataStore.sharedDataStore.yxpwd = [NSString stringWithFormat:@"%@",user[@"yxpwd"]];
                DataStore.sharedDataStore.token = [NSString stringWithFormat:@"%@",user[@"token"]];
                
                [UserNameTool saveLoginData:dic];
                
                //jpush
                [JPUSHService setAlias:DataStore.sharedDataStore.userid completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
                    NSLog(@"Alias   %@",iAlias);
                } seq:1];
                
                [TalkingData onRegister:DataStore.sharedDataStore.mobile type:TDAccountTypeRegistered name:user[@"data"][@"mobile"]];
                
                //云信注册
                [[NIMSDK sharedSDK] registerWithAppID:@"d27ffe90d087aaeb5c579f7485a2dcb6" cerName:nil];
                //云信的自动https支持
                NIMServerSetting *setting = [[NIMServerSetting alloc] init];
                setting.httpsEnabled = NO;
                [[NIMSDK sharedSDK] setServerSetting:setting];
                //云信登录
                [[NIMSDK sharedSDK].userManager fetchUserInfos:@[[NSString stringWithFormat:@"%@",user[@"yxuser"]]] completion:nil];
                
                [[NIMSDK sharedSDK].loginManager login:[NSString stringWithFormat:@"%@",user[@"yxuser"]] token:[NSString stringWithFormat:@"%@",user[@"yxpwd"]] completion:^(NSError *error) {
                    if (!error) {
                        NSLog(@"登录成功");
                        
                    }else{
                        NSLog(@"登录失败");
                        
                    }
                }];
                [UserNameTool reloadPersonalData:^{
                }];
            }else{
//                [SVProgressHUD showErrorWithStatus:msg];
            }
        }
    } failoperation:^(NSError *error) {
        NSLog(@"errr %@",error);
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
//        [SVProgressHUD showErrorWithStatus:@"网络有误，请稍后再试"];
    }];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSString *string =[url absoluteString];
    //qq登录回调
    if ([string hasPrefix:@"tencent"]){
        return [TencentOAuth HandleOpenURL:url];
    }else if ([string hasPrefix:@"alipayYouxibang://safepay/"]){//支付宝回调
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            if ([[NSString stringWithFormat:@"%@",resultDic[@"resultStatus"]] isEqualToString:@"9000"]){
                NSNotification *notification = [NSNotification notificationWithName:@"completePay" object:nil userInfo:nil];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
            }
        }];
        
    }else if ([string hasPrefix:@"wx9409b172842c7d01://pay/"]){//微信支付回调，直接用通知
        if ([string hasSuffix:@"ret=0"]){
            NSNotification *notification = [NSNotification notificationWithName:@"completePay" object:nil userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        }
        
        //        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        //        TopUpAndWithdrawViewController* vc = [sb instantiateViewControllerWithIdentifier:@"tuaw"];
        //        return [WXApi handleOpenURL:url delegate:vc];
        
    }else if ([string hasPrefix:@"wx"]){//微信登录回调
        
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController* vc = [sb instantiateViewControllerWithIdentifier:@"loginPWD"];
        return [WXApi handleOpenURL:url delegate:vc];
        
    }
    
    return false;
}
//与上同
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    NSString *string =[url absoluteString];

    if ([string hasPrefix:@"tencent"]){
        return [TencentOAuth HandleOpenURL:url];
    }else if ([string hasPrefix:@"alipayYouxibang://safepay/"]){
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            if ([[NSString stringWithFormat:@"%@",resultDic[@"resultStatus"]] isEqualToString:@"9000"]){
                NSNotification *notification = [NSNotification notificationWithName:@"completePay" object:nil userInfo:nil];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
            }
        }];

    }else if ([string hasPrefix:@"wx9409b172842c7d01://pay/"]){
        if ([string hasSuffix:@"ret=0"]){
            NSNotification *notification = [NSNotification notificationWithName:@"completePay" object:nil userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        }

//        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        TopUpAndWithdrawViewController* vc = [sb instantiateViewControllerWithIdentifier:@"tuaw"];
//        return [WXApi handleOpenURL:url delegate:vc];
        
    }else if ([string hasPrefix:@"wx"]){
        
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController* vc = [sb instantiateViewControllerWithIdentifier:@"loginPWD"];
        return [WXApi handleOpenURL:url delegate:vc];

    }
    
    return false;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
    
    /// Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
    NSLog(@"极光推送注册成功");
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}
// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    if (@available(iOS 10.0, *)) {
        if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
            [JPUSHService handleRemoteNotification:userInfo];
        }
        completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionBadge);// 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
    } else {
        // Fallback on earlier versions
    }
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[UIApplication sharedApplication].applicationIconBadgeNumber + 1];
    

}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required

    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler();  // 系统要求执行这个方法
    
    NSNotification *n = [NSNotification notificationWithName:@"refreshMessage" object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:n];

    
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {

    // Required, iOS 7 Support
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
    
    if (application.applicationState == UIApplicationStateActive || application.applicationState == UIApplicationStateBackground) {
        NSLog(@"acitve or background");

    }else//杀死状态下，直接跳转到跳转页面。
    {
        MainTabBarController* tabbar = self.window.rootViewController;
        [tabbar setIndex:1];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {

    // Required,For systems with less than or equal to iOS6
    [JPUSHService handleRemoteNotification:userInfo];
}
//jpush接收推送触发方法
- (void)networkDidReceiveMessage:(NSNotification *)notification {
    
    NSDictionary * userInfo = [notification userInfo];
    NSString *content = [userInfo valueForKey:@"content"];
    NSData *jsonData = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSLog(@"推送消息  %@",content);
    
    NSNotification *n = [NSNotification notificationWithName:@"refreshMessage" object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:n];
    if(err) {
        NSLog(@"json解析失败：%@",err);
    }
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
