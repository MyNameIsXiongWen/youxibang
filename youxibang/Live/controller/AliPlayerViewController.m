//
//  AliPlayerViewController.m
//  youxibang
//
//  Created by jiazhuo1 on 2018/5/11.
//

#import "AliPlayerViewController.h"
#import <AliyunVodPlayerSDK/AliyunVodPlayerSDK.h>

@interface AliPlayerViewController () <AliyunVodPlayerDelegate>

@property (nonatomic,strong) AliyunVodPlayer *aliPlayer;
@property (nonatomic,strong) UIView *playerView;//播放view
@property (nonatomic,strong) UIProgressView *progressView;//加载进度
@property (nonatomic,strong) UISlider *sliderProgress;//当前播放进度，可拖拽
@property (nonatomic, strong) NSTimer *timer;//计时器，时时获取currentTime
@property (nonatomic, strong) UILabel *currentTimeLabel;//当前播放时间
@property (nonatomic, strong) UILabel *totalTimeLabel;//视频总时长
@property (nonatomic, strong) UIButton *playButton;//播放按钮

@end

@implementation AliPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configMediaPlayer];
    [self startVideoPlay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

//配置播放器相关UI
- (void)configMediaPlayer {
    //创建播放器对象，可以创建多个示例
    self.aliPlayer = [[AliyunVodPlayer alloc] init];
    //设置播放器代理
    self.aliPlayer.delegate = self;
    self.aliPlayer.circlePlay = YES;
//    self.aliPlayer.autoPlay = YES;
}

- (void)startVideoPlay {
    //使用vid+STS方式播放（点播用户推荐使用）
    if (self.aliPlayer) {
        self.playerView = self.aliPlayer.playerView;
        self.playerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        //添加播放器视图到需要展示的界面上
        [self.view addSubview:self.playerView];
        
        self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        self.progressView.frame = CGRectMake(60, SCREEN_HEIGHT-30, SCREEN_WIDTH-75, 20);
        self.progressView.progressTintColor = UIColor.whiteColor;
        self.progressView.trackTintColor = UIColor.grayColor;
        [self.playerView addSubview:self.progressView];
        
        self.sliderProgress = [[UISlider alloc] initWithFrame:self.progressView.frame];
        self.sliderProgress.maximumTrackTintColor = UIColor.whiteColor;
        self.sliderProgress.minimumTrackTintColor = UIColor.blueColor;
        //    [self.playerView addSubview:self.sliderProgress];
        
        self.currentTimeLabel = [EBUtility labfrome:CGRectMake(60, SCREEN_HEIGHT-20, 40, 15) andText:@"00:00" andColor:UIColor.whiteColor andView:self.playerView];
        self.currentTimeLabel.textAlignment = NSTextAlignmentLeft;
        self.currentTimeLabel.font = [UIFont systemFontOfSize:10.0];
        
        self.totalTimeLabel = [EBUtility labfrome:CGRectMake(SCREEN_WIDTH-55, SCREEN_HEIGHT-20, 40, 15) andText:@"00:00" andColor:UIColor.whiteColor andView:self.playerView];
        self.totalTimeLabel.textAlignment = NSTextAlignmentRight;
        self.totalTimeLabel.font = [UIFont systemFontOfSize:10.0];
        
        self.playButton = [EBUtility btnfrome:CGRectMake(10, SCREEN_HEIGHT-50, 40, 40) andText:@"暂停" andColor:UIColor.whiteColor andimg:nil andView:self.playerView];
        [self.playButton addTarget:self action:@selector(playButtonSelector) forControlEvents:UIControlEventTouchUpInside];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPlayerView)];
        [self.playerView addGestureRecognizer:tap];
        [self getVideoUploadToken];
    }
}

- (void)playButtonSelector {
    if (self.aliPlayer.playerState == 3) {
        [self.aliPlayer pause];
        [self.playButton setTitle:@"播放" forState:0];
    }
    else if (self.aliPlayer.playerState == 4) {
        [self.aliPlayer resume];
        [self.playButton setTitle:@"暂停" forState:0];
    }
}

#pragma mark ALIPLAYER DELEGATE
- (void)vodPlayer:(AliyunVodPlayer *)vodPlayer onEventCallback:(AliyunVodPlayerEvent)event{
    //这里监控播放事件回调
    //主要事件如下：
    switch (event) {
        case AliyunVodPlayerEventPrepareDone:
            //播放准备完成时触发
        {
            //开始播放
            [self.aliPlayer start];
            self.aliPlayer.quality = AliyunVodPlayerVideoLD;
            
            AliyunVodPlayerVideo *videoModel = [self.aliPlayer getAliyunMediaInfo];
            if (videoModel) {
                self.totalTimeLabel.text = [self getMMSSFromSS:[NSString stringWithFormat:@"%.f",videoModel.duration]];
            }else{
                self.totalTimeLabel.text = [self getMMSSFromSS:[NSString stringWithFormat:@"%.f",self.aliPlayer.duration]];
            }
            
            [self.timer invalidate];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerRun:) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
        }
            break;
        case AliyunVodPlayerEventPlay:
            //暂停后恢复播放时触发
            break;
        case AliyunVodPlayerEventFirstFrame:
            //播放视频首帧显示出来时触发
            [SVProgressHUD dismiss];
            [SVProgressHUD setDefaultMaskType:1];
            break;
        case AliyunVodPlayerEventPause:
            //视频暂停时触发
            break;
        case AliyunVodPlayerEventStop:
            //主动使用stop接口时触发
            break;
        case AliyunVodPlayerEventFinish:
            //视频正常播放完成时触发
            //            [self.sliderProgress setValue:0];
            self.progressView.progress = 0;
            break;
        case AliyunVodPlayerEventBeginLoading:
            //视频开始载入时触发
            break;
        case AliyunVodPlayerEventEndLoading:
            //视频加载完成时触发
            break;
        case AliyunVodPlayerEventSeekDone:
            //视频Seek完成时触发
            break;
        default:
            break;
    }
}
- (void)vodPlayer:(AliyunVodPlayer *)vodPlayer playBackErrorModel:(ALPlayerVideoErrorModel *)errorModel{
    [SVProgressHUD dismiss];
    [SVProgressHUD setDefaultMaskType:1];
    //播放出错时触发，通过errorModel可以查看错误码、错误信息、视频ID、视频地址和requestId。
    [self.timer invalidate];
    //    [self.sliderProgress setValue:0];
    self.progressView.progress = 0;
    self.currentTimeLabel.text = [self getMMSSFromSS:[NSString stringWithFormat:@"%.f",0.0]];
}
- (void)vodPlayer:(AliyunVodPlayer*)vodPlayer willSwitchToQuality:(AliyunVodPlayerVideoQuality)quality{
    //将要切换清晰度时触发
}
- (void)vodPlayer:(AliyunVodPlayer *)vodPlayer didSwitchToQuality:(AliyunVodPlayerVideoQuality)quality{
    //清晰度切换完成后触发
}
- (void)vodPlayer:(AliyunVodPlayer*)vodPlayer failSwitchToQuality:(AliyunVodPlayerVideoQuality)quality{
    //清晰度切换失败触发
}
- (void)onCircleStartWithVodPlayer:(AliyunVodPlayer*)vodPlayer{
    //开启循环播放功能，开始循环播放时接收此事件。
}
- (void)onTimeExpiredErrorWithVodPlayer:(AliyunVodPlayer *)vodPlayer{
    //播放器鉴权数据过期回调，出现过期可重新prepare新的地址或进行UI上的错误提醒。
    [SVProgressHUD dismiss];
    [SVProgressHUD setDefaultMaskType:1];
    [self.timer invalidate];
    //    [self.sliderProgress setValue:0];
    self.progressView.progress = 0;
    self.currentTimeLabel.text = [self getMMSSFromSS:[NSString stringWithFormat:@"%.f",0.0]];
}
/*
 *功能：播放过程中鉴权即将过期时提供的回调消息（过期前一分钟回调）
 *参数：videoid：过期时播放的videoId
 *参数：quality：过期时播放的清晰度，playauth播放方式和STS播放方式有效。
 *参数：videoDefinition：过期时播放的清晰度，MPS播放方式时有效。
 *备注：使用方法参考高级播放器-点播。
 */
- (void)vodPlayerPlaybackAddressExpiredWithVideoId:(NSString *)videoId quality:(AliyunVodPlayerVideoQuality)quality videoDefinition:(NSString*)videoDefinition{
    //鉴权有效期为2小时，在这个回调里面可以提前请求新的鉴权，stop上一次播放，prepare新的地址，seek到当前位置
}

#pragma mark - seek
- (void)timeProgress:(UISlider *)sender {
    if (self.aliPlayer && (self.aliPlayer.playerState == AliyunVodPlayerStateLoading || self.aliPlayer.playerState == AliyunVodPlayerStatePause ||
                           self.aliPlayer.playerState == AliyunVodPlayerStatePlay)) {
        [ self.aliPlayer seekToTime:sender.value * self.aliPlayer.duration ];
    }
}
#pragma mark - timerRun
- (void)timerRun:(NSTimer *)sender{
    if (self.aliPlayer) {
        self.currentTimeLabel.text = [self getMMSSFromSS:[NSString stringWithFormat:@"%.f",self.aliPlayer.currentTime]];
        //        [self.sliderProgress setValue:self.aliPlayer.currentTime/self.aliPlayer.duration animated:YES];
        //        [self.progressView setProgress:self.aliPlayer.loadedTime/self.aliPlayer.duration];
        [self.progressView setProgress:self.aliPlayer.currentTime/self.aliPlayer.duration];
    }
}

-(NSString *)getMMSSFromSS:(NSString *)totalTime{
    NSInteger seconds = [totalTime integerValue];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
    //format of time
    //    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    NSString *format_time = [NSString stringWithFormat:@"%@:%@",str_minute,str_second];
    return format_time;
}

- (void)tapPlayerView {
    [self.aliPlayer stop];
    [self.aliPlayer releasePlayer];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getVideoUploadToken {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:DataStore.sharedDataStore.token forKey:@"token"];
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@video/get_token",HttpURLString] Paremeters:dict successOperation:^(id response) {
        if (isKindOfNSDictionary(response)) {
            NSInteger msg = [[response objectForKey:@"errcode"] integerValue];
            NSString *str = [response objectForKey:@"message"];
            if (msg == 1) {
                NSDictionary *tokenDictionary = (NSDictionary *)response;
                [self.aliPlayer prepareWithVid:self.videoIdString
                                   accessKeyId:tokenDictionary[@"data"][@"Credentials"][@"AccessKeyId"]
                               accessKeySecret:tokenDictionary[@"data"][@"Credentials"][@"AccessKeySecret"]
                                 securityToken:tokenDictionary[@"data"][@"Credentials"][@"SecurityToken"]];
            }else{
                [SVProgressHUD showErrorWithStatus:str];
            }
        }
    } failoperation:^(NSError *error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        [SVProgressHUD showErrorWithStatus:@"网络延迟，请稍后再试"];
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
