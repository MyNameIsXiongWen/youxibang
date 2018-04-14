//
//  SystemSettingViewController.m
//  youxibang
//
//  Created by y on 2018/1/30.
//

#import "SystemSettingViewController.h"
#import "LoginViewController.h"
#import "MessagePromptViewController.h"
#import "NewPhoneViewController.h"
#import "ForgotPasswordViewController.h"

@interface SystemSettingViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,copy)NSString* fileCachePath;
@end

@implementation SystemSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.tableFooterView = [UIView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64);
    
    self.title = @"系统设置";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)exitUser:(UIButton*)sender{
    
    //云信登出账号
    [[[NIMSDK sharedSDK] loginManager] logout:^(NSError *error) {
        
    }];
    [UserNameTool cleanloginData];
    [DataStore sharedDataStore].userid = nil;
    [DataStore sharedDataStore].mobile = nil;
    [DataStore sharedDataStore].yxuser = nil;
    [DataStore sharedDataStore].yxpwd = nil;
    [DataStore sharedDataStore].token = nil;
    [JPUSHService setAlias:@"" completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {

    } seq:1];
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController* vc = [sb instantiateViewControllerWithIdentifier:@"loginPWD"];
    [self.navigationController pushViewController:vc animated:1];
}

-(CGFloat) getCacheSize
{
    //获取文件管理器对象
    NSFileManager * fileManger = [NSFileManager defaultManager];
    
    //获取缓存沙盒路径
    NSString * cachePath =  [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    //先定义一个缓存目录总大小的变量
    NSInteger fileTotalSize = 0;
    
    if ([fileManger fileExistsAtPath:cachePath]) {
        // 目录下的文件计算大小
        NSArray *childrenFile = [fileManger subpathsAtPath:cachePath];
        for (NSString *fileName in childrenFile) {
            NSString *absolutePath = [cachePath stringByAppendingPathComponent:fileName];
            fileTotalSize += [fileManger attributesOfItemAtPath:absolutePath error:nil].fileSize;
        }
        //SDWebImage的缓存计算
        fileTotalSize += [[SDImageCache sharedImageCache] getSize]/1024.0/1024.0;
        // 将大小转化为M,size单位b,转，KB,MB除以两次1024
        return fileTotalSize / 1024.0 / 1024.0;
    }
    
    return 0;
}
- (void)cleanCaches:(NSString *)path{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *childrenFiles = [fileManager subpathsAtPath:path];
        for (NSString *fileName in childrenFiles) {
            // 拼接路径
            NSString *absolutePath = [path stringByAppendingPathComponent:fileName];
            // 将文件删除
            [fileManager removeItemAtPath:absolutePath error:nil];
        }
    }
    //SDWebImage的清除功能
    [[SDImageCache sharedImageCache] clearMemory];
}

#pragma mark - tableViewDelegate/DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 6;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 60;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView* fv = [EBUtility viewfrome:CGRectMake(0, 0, SCREEN_WIDTH, 60) andColor:[UIColor groupTableViewBackgroundColor] andView:nil];
    UIButton* exit = [EBUtility btnfrome:CGRectMake(0, 20, SCREEN_WIDTH, 40) andText:@"退出账号" andColor:[UIColor blackColor] andimg:nil andView:fv];
    exit.backgroundColor = [UIColor whiteColor];
    [exit addTarget:self action:@selector(exitUser:) forControlEvents:UIControlEventTouchUpInside];
    return fv;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray* ary = @[@"修改手机号",@"密码管理",@"消息提醒",@"给我评分",@"清除缓存",@"版本号"];//,@"产品反馈"
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    cell.textLabel.text = ary[indexPath.row];
    if (indexPath.row == 4){
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f M",[self getCacheSize]];
    }else if (indexPath.row == 5){
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        CFShow((__bridge CFTypeRef)(infoDictionary));
        cell.detailTextLabel.text = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    }else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0){//更改电话
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        NewPhoneViewController* vc = [sb instantiateViewControllerWithIdentifier:@"np"];
        [self.navigationController pushViewController:vc animated:1];
    }else if (indexPath.row == 1){//更改密码
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ForgotPasswordViewController *vc = [sb instantiateViewControllerWithIdentifier:@"fpw"];
        vc.titleText = @"修改密码";
        [self.navigationController pushViewController:vc animated:1];
    }else if (indexPath.row == 2){//消息设置
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MessagePromptViewController* vc = [sb instantiateViewControllerWithIdentifier:@"mpv"];
        
        [self.navigationController pushViewController:vc animated:1];
    }else if (indexPath.row == 3){//评分
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1352635838&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"]];
    }else if (indexPath.row == 4){
        //删除缓存目录下所有缓存文件
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask,YES);
        NSString *cachesDir = [paths lastObject];
        [self cleanCaches:cachesDir];
        
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.detailTextLabel.text = @"0.00M";
    }
}

#pragma mark - otherDelegate/DataSource
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
