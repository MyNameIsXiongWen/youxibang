//
//  MessagePromptViewController.m
//  youxibang
//
//  Created by 戎博 on 2018/2/19.
//

#import "MessagePromptViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface MessagePromptViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *sw1;
@property (weak, nonatomic) IBOutlet UISwitch *sw2;
@property (weak, nonatomic) IBOutlet UISwitch *sw3;

@end

@implementation MessagePromptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"消息提醒";
    
    NSMutableDictionary* dic = [UserNameTool readPersonalData];
    NSString* i = [NSString stringWithFormat:@"%@",[dic objectForKey:@"is_strangercall"]];
    self.sw3.on = i.integerValue;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)newMessageAPN:(UISwitch *)sender {
    if (sender.on){

        [[UIApplication sharedApplication] registerForRemoteNotifications]; //开启推送
    }else{
        [[UIApplication sharedApplication] unregisterForRemoteNotifications]; //关闭远程推送
    }
    
}
//信息声音
- (IBAction)newMessageVoice:(UISwitch *)sender {
    if (sender.on){
//        MPMusicPlayerController* musicController = [MPMusicPlayerController applicationMusicPlayer];
//        musicController.volume = 0.3;
        MPVolumeView *volumeView = [[MPVolumeView alloc] init];
        UISlider* volumeViewSlider = nil;
        for (UIView *view in [volumeView subviews]){
            if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
                volumeViewSlider = (UISlider*)view;
                volumeViewSlider.value = 0.5;
                break;
            }
        }
    }else{
//        MPMusicPlayerController* musicController = [MPMusicPlayerController applicationMusicPlayer];
//        musicController.volume = 0;
        MPVolumeView *volumeView = [[MPVolumeView alloc] init];
        UISlider* volumeViewSlider = nil;
        for (UIView *view in [volumeView subviews]){
            if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
                volumeViewSlider = (UISlider*)view;
                volumeViewSlider.value = 0;
                break;
            }
        }
    }
}
//陌生人通话
- (IBAction)strangePhone:(UISwitch *)sender {

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[DataStore sharedDataStore].token forKey:@"token"];//typeid=$类型 （1-头像，2-昵称，3-签名，4-兴趣爱好，5-背景图，6-允许陌生人通话）

    [dict setObject:@"6" forKey:@"typeid"];
    [dict setObject:[NSString stringWithFormat:@"%d",sender.on] forKey:@"onoff"];

    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Member/edituserinfo.html",HttpURLString] Paremeters:dict successOperation:^(id object) {

        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            
            if (code == 1) {

                [UserNameTool reloadPersonalData:nil];
            }else{

            }
        }
    } failoperation:^(NSError *error) {
        
        [SVProgressHUD showErrorWithStatus:@"网络信号差，请稍后再试"];
    }];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
