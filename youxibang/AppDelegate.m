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
#import <AlipaySDK/AlipaySDK.h>
#import "TopUpAndWithdrawViewController.h"
#import <Bugly/Bugly.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <Weibo_SDK/WeiboSDK.h>
#import "GuideViewController.h"

@interface AppDelegate ()<WXApiDelegate,JPUSHRegisterDelegate, QQApiInterfaceDelegate, WeiboSDKDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self registerThirdSDKWithOptions:launchOptions];

    if (UserModel.sharedUser.token) {
        [self loginThirdSDK];
    }

    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(networkDidReceiveMessage:) name:kJPFNetworkDidReceiveMessageNotification object:nil];
    
    //自定义tabbar
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:FIRST_INTO]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:FIRST_INTO];
        GuideViewController *guideController = [[GuideViewController alloc] init];
        MainNavigationController *nav = [[MainNavigationController alloc] initWithRootViewController:guideController];
        self.window.rootViewController = nav;
    }
    else {
        MainTabBarController *mainTab = [[MainTabBarController alloc] init];
        self.window.rootViewController = mainTab;
    }
    return YES;
}

- (void)registerThirdSDKWithOptions:(NSDictionary *)launchOptions {
    //iconfont注册
    [TBCityIconFont setFontName:@"iconfont"];
    
    //微信注册
    [WXApi registerApp:WX_APP_ID];
    [[TencentOAuth alloc] initWithAppId:QQ_OPEN_ID andDelegate:nil];
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:SINA_APP_KEY];
    //talkingdata注册
    [TalkingData sessionStarted:@"7AF6493B08F141FC8EF2450B65B3C0B2" withChannelId:@"iOS正式版"];
    [TalkingData setExceptionReportEnabled:YES];
    [Bugly startWithAppId:@"98eee6832c"];
    
    //Jpush
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    [JPUSHService setupWithOption:launchOptions appKey:JPUSH_KEY
                          channel:@"App Store"
                 apsForProduction:YES];
}

- (void)loginThirdSDK {
    [self getVideoUploadToken];
    [UserNameTool reloadPersonalData:^{
    }];
    
    [JPUSHService setAlias:UserModel.sharedUser.userid completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
        NSLog(@"Alias   %@",iAlias);
    } seq:1];
    
    [TalkingData onRegister:UserModel.sharedUser.mobile type:TDAccountTypeRegistered name:UserModel.sharedUser.mobile];
    
    //云信注册
    [[NIMSDK sharedSDK] registerWithAppID:NIM_APP_ID cerName:nil];
    //云信的自动https支持
    NIMServerSetting *setting = [[NIMServerSetting alloc] init];
    setting.httpsEnabled = NO;
    [[NIMSDK sharedSDK] setServerSetting:setting];
    //云信登录
    [[NIMSDK sharedSDK].userManager fetchUserInfos:@[[NSString stringWithFormat:@"%@",UserModel.sharedUser.yxuser]] completion:nil];
    
    [[NIMSDK sharedSDK].loginManager login:[NSString stringWithFormat:@"%@",UserModel.sharedUser.yxuser] token:[NSString stringWithFormat:@"%@",UserModel.sharedUser.yxpwd] completion:^(NSError *error) {
        if (!error) {
            NSLog(@"登录成功");
        }else{
            NSLog(@"登录失败");
        }
    }];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSString *string =[url absoluteString];
    
    if ([string hasPrefix:@"tencent"]){
        [QQApiInterface handleOpenURL:url delegate:self];
        return [TencentOAuth HandleOpenURL:url];
    }
    else if ([string hasPrefix:@"alipayYouxibang://safepay/"]){//支付宝回调
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            if ([[NSString stringWithFormat:@"%@",resultDic[@"resultStatus"]] isEqualToString:@"9000"]){
                NSNotification *notification = [NSNotification notificationWithName:@"completePay" object:nil userInfo:nil];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
            }
        }];
    }
    else if ([string hasPrefix:@"wx9409b172842c7d01://pay/"]){//微信支付回调，直接用通知
        if ([string hasSuffix:@"ret=0"]){
            NSNotification *notification = [NSNotification notificationWithName:@"completePay" object:nil userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        }
    }
    else if ([string hasPrefix:@"wx"]){//微信登录回调
        return [WXApi handleOpenURL:url delegate:self];
    }
    else if ([string hasPrefix:@"wb3625368548"]) {
        return [WeiboSDK handleOpenURL:url delegate:self];
    }
    return false;
}
//与上同
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    NSString *string =[url absoluteString];

    if ([string hasPrefix:@"tencent"]){
        [QQApiInterface handleOpenURL:url delegate:self];
        return [TencentOAuth HandleOpenURL:url];
    }
    else if ([string hasPrefix:@"alipayYouxibang://safepay/"]){
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            if ([[NSString stringWithFormat:@"%@",resultDic[@"resultStatus"]] isEqualToString:@"9000"]){
                NSNotification *notification = [NSNotification notificationWithName:@"completePay" object:nil userInfo:nil];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
            }
        }];
    }
    else if ([string hasPrefix:@"wx9409b172842c7d01://pay/"]){
        if ([string hasSuffix:@"ret=0"]){
            NSNotification *notification = [NSNotification notificationWithName:@"completePay" object:nil userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        }
    }
    else if ([string hasPrefix:@"wx"]){
        return [WXApi handleOpenURL:url delegate:self];
    }
    else if ([string hasPrefix:@"wb3625368548"]) {
        return [WeiboSDK handleOpenURL:url delegate:self];
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

    }else {//杀死状态下，直接跳转到跳转页面。
        MainTabBarController* tabbar = self.window.rootViewController;
        [tabbar setIndex:2];
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
    NSError *err;
    NSLog(@"推送消息  %@",content);
    NSNotification *n = [NSNotification notificationWithName:@"refreshMessage" object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:n];
    if(err) {
        NSLog(@"json解析失败：%@",err);
    }
}

- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:SendMessageToWXResp.class]) {
        if (resp.errCode == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SHARENOTIFICATION" object:@"success"];
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SHARENOTIFICATION" object:@"fail"];
        }
    }
    else if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *temp = (SendAuthResp *)resp;
        if (temp.errCode == 0) {
            [[NetWorkEngine shareNetWorkEngine] getInfoFromServerWithUrlStr:[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",WX_APP_ID,WX_APP_SECRET,temp.code] Paremeters:nil successOperation:^(id response) {
                NSLog(@"绑定输出 %@",response);
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"threeLogin" object:nil userInfo:@{@"typeid":@"2",@"threetoken":response[@"openid"],@"unionid":response[@"unionid"]}];
            } failoperation:^(NSError *error) {
                NSLog(@"errr %@",error);
            }];
        }
    }
    else if ([resp isKindOfClass:SendMessageToQQResp.class]) {
        switch (resp.type) {
            case ESENDMESSAGETOQQRESPTYPE: {
                SendMessageToQQResp* sendResp = (SendMessageToQQResp*)resp;
                if ([sendResp.result isEqualToString:@"0"]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"SHARENOTIFICATION" object:@"success"];
                } else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"SHARENOTIFICATION" object:@"fail"];
                } break;
            }
            default: {
                break;
            }
        }
    }
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    if (response.statusCode == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SHARENOTIFICATION" object:@"success"];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SHARENOTIFICATION" object:@"fail"];
    }
}

- (void)getVideoUploadToken {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:UserModel.sharedUser.token forKey:@"token"];
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@video/get_token",HttpURLString] Paremeters:dict successOperation:^(id response) {
        if (isKindOfNSDictionary(response)) {
            NSInteger msg = [[response objectForKey:@"errcode"] integerValue];
            NSString *str = [response objectForKey:@"message"];
            if (msg == 1) {
                NSDictionary *tokenDictionary = (NSDictionary *)response;
                [[NSUserDefaults standardUserDefaults] setObject:tokenDictionary forKey:@"AliPlayerToken"];
            }else{
                [[SYPromptBoxView sharedInstance] setPromptViewMessage:str andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
            }
        }
    } failoperation:^(NSError *error) {
    }];
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
