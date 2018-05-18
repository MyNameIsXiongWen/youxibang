//
//  GameBabyDetailViewController.m
//  youxibang
//
//  Created by y on 2018/2/1.
//

#import "GameBabyDetailViewController.h"
#import "OrderViewController.h"
#import "MineScrollTableViewCell.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "EmployeeDetailViewController.h"
#import "LoginViewController.h"

@interface GameBabyDetailViewController ()<UITableViewDelegate,UITableViewDataSource,MineScrollDelegate,AVAudioPlayerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic)AVAudioPlayer* player;//播放器
@property (nonatomic,strong)NSMutableDictionary* dataInfo;//宝贝数据
@property (nonatomic,strong)NSMutableArray* awardAry;//打赏列表
@property (nonatomic,strong)NSMutableArray* commentAry;//评论列表
@property(nonatomic,assign)int awardPage;//打赏列表页码
@property (strong, nonatomic) UIImageView *animationImg;//音频播放的动画img

@property(nonatomic,assign)int commentPage;//评论列表页码
@end

@implementation GameBabyDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"技能详情";
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshHead)];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshFooter)];
    self.tableView.tableFooterView = [UIView new];
    [self refreshHead];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated{
    //view消失时释放播放器
    if (self.player){
        if (self.player.isPlaying){
            [self.player stop];
        }
        self.player = nil;
    }
}

- (NSMutableArray*)awardAry{
    if (!_awardAry){
        _awardAry = [NSMutableArray array];
    }
    return _awardAry;
}
- (NSMutableArray*)commentAry{
    if (!_commentAry){
        _commentAry = [NSMutableArray array];
    }
    return _commentAry;
}
-(void)refreshHead{
    self.awardPage = 1;
    self.commentPage = 1;
    [self.commentAry removeAllObjects];
    [self.awardAry removeAllObjects];
    [self downloadInfo];
    [self downloadComment];
    [self downloadAward];
    [self.tableView.mj_header endRefreshing];
}
-(void)refreshFooter{
    self.commentPage ++;
    [self downloadComment];
    [self.tableView.mj_footer endRefreshing];
}
//下载信息
- (void)downloadInfo{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:self.gbId forKey:@"id"];
    if (![EBUtility isBlankString:UserModel.sharedUser.userid]){
        [dict setObject:UserModel.sharedUser.userid forKey:@"userid"];
    }
    
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Gamebaby/babydetail.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            
            if (code == 1) {
                [self.dataInfo removeAllObjects];
                self.dataInfo = [NSMutableDictionary dictionaryWithDictionary:object[@"data"]];
                [self.tableView reloadData];
            }else{
                [SVProgressHUD showErrorWithStatus:msg];
                [self.navigationController popViewControllerAnimated:1];
            }

            
        }
        
    } failoperation:^(NSError *error) {
        
        [SVProgressHUD dismiss];
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络信号差，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
    }];
    
}
//下载打赏列表
- (void)downloadAward{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:self.gbId forKey:@"id"];
    if (![EBUtility isBlankString:UserModel.sharedUser.userid]){
        [dict setObject:UserModel.sharedUser.userid forKey:@"userid"];
    }
    [dict setObject:[NSString stringWithFormat:@"%d",self.awardPage] forKey:@"p"];
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Gamebaby/awardlist.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);

            if (code == 1) {
                [self.awardAry addObjectsFromArray:object[@"data"]];
                [self.tableView reloadData];
            }else{
                //[SVProgressHUD showErrorWithStatus:msg];
            }
            
        }
        
    } failoperation:^(NSError *error) {
        
//        [SVProgressHUD dismiss];
//        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络信号差，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
    }];
}
//下载评论列表
- (void)downloadComment{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:self.gbId forKey:@"id"];
    if (![EBUtility isBlankString:UserModel.sharedUser.userid]){
        [dict setObject:UserModel.sharedUser.userid forKey:@"userid"];
    }
    [dict setObject:[NSString stringWithFormat:@"%d",self.commentPage] forKey:@"p"];
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Gamebaby/commentlist.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);

            if (code == 1) {
                [self.commentAry addObjectsFromArray:object[@"data"]];
                [self.tableView reloadData];
            }else{
                //                [SVProgressHUD showErrorWithStatus:msg];
            }

            
        }
        
    } failoperation:^(NSError *error) {
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络信号差，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
    }];
}

//播放语音
- (IBAction)voiceIntroduce:(id)sender {
    if (self.player){
        if (self.player.isPlaying){
            [self.player stop];
            [SVProgressHUD showInfoWithStatus:@"停止播放"];
            if (self.animationImg){
                [self.animationImg stopAnimating];
            }
        }else{
            NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.dataInfo[@"audiofile"]]]];
            self.player = [[AVAudioPlayer alloc]initWithData:data error:nil];
            
            [self.player play];
            if ([self.player isPlaying]){
                if (self.animationImg){
                    [self.animationImg startAnimating];
                }
            }
        }
    }else{
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.dataInfo[@"audiofile"]]]];
        self.player = [[AVAudioPlayer alloc]initWithData:data error:nil];
        
        [self.player play];
        if ([self.player isPlaying]){
            UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
            UIImageView* animation = [cell viewWithTag:1000];
            NSMutableArray* imgAry = [NSMutableArray array];
            for (int i = 1; i < 10; i++){
                [imgAry addObject:[UIImage imageNamed:[NSString stringWithFormat:@"%d",i]]];
            }
            [imgAry addObject:[UIImage imageNamed:@"1"]];
            animation.animationImages = imgAry;
            
            AVURLAsset* audioAsset =[AVURLAsset URLAssetWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.dataInfo[@"audiofile"]]] options:nil];
            CMTime audioDuration = audioAsset.duration;
            float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
            
            animation.animationDuration = 0.65f;
            animation.animationRepeatCount = audioDurationSeconds/0.65f ? audioDurationSeconds/0.65f : 1;
            [animation startAnimating];
            self.animationImg = animation;
        }
        else {
            [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"暂未录制语音" andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
        }
    }
    
    
}
//拨打虚拟电话
- (IBAction)telePhone:(id)sender {
    if ([EBUtility isBlankString:UserModel.sharedUser.token]){
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController* vc = [sb instantiateViewControllerWithIdentifier:@"loginPWD"];
        [self.navigationController pushViewController:vc animated:1];
        return;
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",self.dataInfo[@"mobile"]]]];
}
//聊天
- (IBAction)chat:(id)sender {
    if ([EBUtility isBlankString:UserModel.sharedUser.token]){
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController* vc = [sb instantiateViewControllerWithIdentifier:@"loginPWD"];
        [self.navigationController pushViewController:vc animated:1];
        return;
    }
    if ([NSString stringWithFormat:@"%@",self.dataInfo[@"istalk"]].integerValue == 1){
        NIMSession *session = [NIMSession session:[NSString stringWithFormat:@"%@",self.dataInfo[@"invitecode"]] type:NIMSessionTypeP2P];
        ChatViewController *vc = [[ChatViewController alloc] initWithSession:session];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        CustomAlertView* alert = [[CustomAlertView alloc]initWithType:5];
        alert.resultIndex = ^(NSInteger index) {
            if (index == 0){
                [self getOrder:@""];
            }
        };
        [alert showAlertView];
    }
    
}

//下单
- (IBAction)getOrder:(id)sender {
    if ([EBUtility isBlankString:UserModel.sharedUser.token]){
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController* vc = [sb instantiateViewControllerWithIdentifier:@"loginPWD"];
        [self.navigationController pushViewController:vc animated:1];
        return;
    }
    OrderViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"order"];
    vc.userId = [NSString stringWithFormat:@"%@",self.dataInfo[@"user_id"]];
    vc.skillId = [NSString stringWithFormat:@"%@",self.dataInfo[@"id"]];
    [self.navigationController pushViewController:vc animated:1];
}
//点击头像
- (IBAction)tapHeadImg:(UIButton *)sender {
    EmployeeDetailViewController* vc = [[EmployeeDetailViewController alloc]init];
    vc.type = 0;
    vc.employeeId = [NSString stringWithFormat:@"%@",self.dataInfo[@"user_id"]];
    [self.navigationController pushViewController:vc animated:1];
}

#pragma mark - tableViewDelegate/DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.dataInfo){
        return 4;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 1){
        return 1;
    }else if (section == 3){
        return self.commentAry.count + 1;
    }
    return 2;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 3){
        return 45;
    }
    return 10;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 2 && indexPath.row == 1){
        return 100;
    }
    return UITableViewAutomaticDimension;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    if (indexPath.section == 2 && indexPath.row == 1){
        return 100;
    }
    return UITableViewAutomaticDimension;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 3 && indexPath.row > 0){//评论列表
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell31"];
        UILabel* name = [cell viewWithTag: 1];
        if (self.commentAry.count > 0){
            name.text = self.commentAry[indexPath.row-1][@"nickname"];
            
            UIImageView* imv = [cell viewWithTag: 2];
            [imv sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.commentAry[indexPath.row-1][@"photo"]]] placeholderImage:[UIImage imageNamed:@"ico_head"]];
            
            UILabel* content = [cell viewWithTag: 3];
            content.text = self.commentAry[indexPath.row-1][@"content"];
            
            UILabel* addtime = [cell viewWithTag: 4];
            addtime.text = self.commentAry[indexPath.row-1][@"addtime"];
            
            UIImageView* express = [cell viewWithTag: 5];
            [express sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.commentAry[indexPath.row-1][@"express"]]] placeholderImage:[UIImage imageNamed:@"ico_xiao"]];
        }
        
        return cell;
    }else if (indexPath.section == 2 && indexPath.row > 0){//打赏列表
        MineScrollTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MineScrollTableViewCell"];
        if (!cell) {
            cell = [[MineScrollTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MineScrollTableViewCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        [cell initCellWithAry:self.awardAry];
        cell.delegate = self;
        return cell;
    }
    //宝贝信息cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"cell%ld%ld",indexPath.section,indexPath.row]];
    if (self.dataInfo){
        if (indexPath.section == 0){
            if (indexPath.row == 0){
                UIImageView* img = [cell viewWithTag: 1];
                [img sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.dataInfo[@"image"]]] placeholderImage:[UIImage imageNamed:@"placeholder_media"]];
            }else if (indexPath.row == 1){
                
                UILabel* title = [cell viewWithTag: 1];
                title.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"title"]];
                
                UILabel* grade = [cell viewWithTag: 2];
                grade.text = [NSString stringWithFormat:@" %@\t",self.dataInfo[@"duanwei"]];
                grade.backgroundColor = [EBUtility colorWithHexString:[NSString stringWithFormat:@"%@",self.dataInfo[@"fontcolor"]] alpha:1];
                
                UILabel* price = [cell viewWithTag: 3];
                price.text = [NSString stringWithFormat:@"¥%@/小时",self.dataInfo[@"price"]];
                
                UILabel* times = [cell viewWithTag: 4];
                times.text = [NSString stringWithFormat:@"接单%@次",self.dataInfo[@"ordernum"]?:@"0"];
            }
        }else if (indexPath.section == 1){
            UIImageView* img = [cell viewWithTag: 1];
            [img sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.dataInfo[@"photo"]]] placeholderImage:[UIImage imageNamed:@"ico_head"]];
            
            UILabel* name = [cell viewWithTag: 2];
            name.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"nickname"]];
            
            UILabel* age = [cell viewWithTag: 3];
            if ([NSString stringWithFormat:@"%@",self.dataInfo[@"sex"]].integerValue == 1){
                age.text = [NSString stringWithFormat:@" ♂%@岁\t",self.dataInfo[@"birthday"]];
                age.backgroundColor = Nav_color;
            }else{
                age.text = [NSString stringWithFormat:@" ♀%@岁\t",self.dataInfo[@"birthday"]];
                age.backgroundColor = Pink_color;
            }
            
            UILabel* selfdesc = [cell viewWithTag: 4];
            selfdesc.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"selfdesc"]];
            
            if ([NSString stringWithFormat:@"%@",self.dataInfo[@"is_strangercall"]].integerValue == 0){
                UIButton* phone = [cell viewWithTag: 5];
                phone.hidden = YES;
            }else{
                UIButton* phone = [cell viewWithTag: 5];
                phone.hidden = NO;
            }
        }else if (indexPath.section == 2){
            if (indexPath.row == 0){
                UILabel* num = [cell viewWithTag: 1];
                num.text = [NSString stringWithFormat:@"(%@人）",self.dataInfo[@"awardcount"]];
            }
        }else if (indexPath.section == 3){
            if (indexPath.row == 0){
                UILabel* num = [cell viewWithTag: 1];
                num.text = [NSString stringWithFormat:@"(%@条）",self.dataInfo[@"commentcount"]];
                UILabel* praiserate = [cell viewWithTag: 2];
                praiserate.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"praiserate"]];
            }
            if ([NSString stringWithFormat:@"%@",self.dataInfo[@"isable"]].integerValue == 2){
                UIView* v = [self.view viewWithTag: 99];
                v.hidden = YES;
                
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - otherDelegate/DataSource
//滑动加载打赏列表
-(void)mineScroll:(MineScrollTableViewCell *)cell withIndex:(NSInteger)index
{
    self.awardPage ++;
    [self downloadAward];
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
