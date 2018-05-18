//
//  DiscountViewController.m
//  youxibang
//
//  Created by y on 2018/2/28.
//

#import "DiscountViewController.h"

@interface DiscountViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,strong)NSMutableArray* dataAry;
@end

@implementation DiscountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"我的优惠券";
    self.tableView.tableFooterView = [UIView new];
    //下载
    [self downloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSMutableArray*)dataAry{
    if (!_dataAry){
        _dataAry = [NSMutableArray array];
    }
    return _dataAry;
}
- (void)downloadData{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setObject:UserModel.sharedUser.token forKey:@"token"];
    
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Member/mycoupon.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            
            if (code == 1) {
                [self.dataAry addObjectsFromArray:object[@"data"]];
                [self.tableView reloadData];
            }else{
//                [SVProgressHUD showErrorWithStatus:msg];
            }
        }
        
    } failoperation:^(NSError *error) {
        
        [SVProgressHUD dismiss];
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络信号差，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
    }];
}

#pragma mark - tableViewDelegate/DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataAry.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (self.dataAry.count > indexPath.row){
        UILabel* typename = [cell viewWithTag:10];
        typename.text = [NSString stringWithFormat:@"%@",self.dataAry[indexPath.row][@"typename"]];
        
        UILabel* time = [cell viewWithTag:11];
        time.text = [NSString stringWithFormat:@"%@",self.dataAry[indexPath.row][@"endtime"]];
        
        UILabel* title = [cell viewWithTag:12];
        title.text = [NSString stringWithFormat:@"%@",self.dataAry[indexPath.row][@"title"]];
        
        UILabel* desc = [cell viewWithTag:13];
        desc.text = [NSString stringWithFormat:@"%@",self.dataAry[indexPath.row][@"desc"]];
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(selectSomeThing:AndId:)]){
        [self.delegate selectSomeThing:[NSString stringWithFormat:@"%@元",self.dataAry[indexPath.row][@"money"]] AndId:[NSString stringWithFormat:@"%@",self.dataAry[indexPath.row][@"id"]]];
        [self.navigationController popViewControllerAnimated:1];
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
