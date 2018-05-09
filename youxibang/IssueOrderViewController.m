//
//  IssueOrderViewController.m
//  youxibang
//
//  Created by y on 2018/1/29.
//

#import "IssueOrderViewController.h"
#import "RemarksTextViewTableViewCell.h"
#import "NumberTableViewCell.h"
#import "DiscountViewController.h"
#import "LocationTableViewCell.h"

@interface IssueOrderViewController ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,UITextFieldDelegate,DiscountViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,copy) NSString* hour;
@property (nonatomic,strong) NSMutableArray* dataAry;//游戏列表
@property (nonatomic,copy) NSString* gameId;//游戏id
@property (nonatomic,copy) NSString* date;
@property (nonatomic,copy) NSString* locationAddress;
@end

@implementation IssueOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.hour = @"1";
    //下载游戏列表
    [self downLoadInfo];
    self.tableView.tableFooterView = [UIView new];
    self.title = @"发布任务";
    self.locationAddress = @"全国";
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
- (void)downLoadInfo{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Currency/gmlists.html",HttpURLString] Paremeters:nil successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            
            if (code == 1) {
                self.dataAry = [NSMutableArray arrayWithArray:object[@"data"]];
                
            }else{
                [SVProgressHUD showErrorWithStatus:msg];
            }

        }
        
    } failoperation:^(NSError *error) {
        
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        [SVProgressHUD showErrorWithStatus:@"网络信号差，请稍后再试"];
    }];
}
//提交
- (IBAction)commitOrder:(UIButton *)sender {
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UITextField* title = [cell viewWithTag:1];
    if ([EBUtility isBlankString:title.text]){
        [SVProgressHUD showErrorWithStatus:@"标题不能为空"];
        return;
    }
    if ([EBUtility isBlankString:self.gameId]){
        [SVProgressHUD showErrorWithStatus:@"品类不能为空"];
        return;
    }
    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    UITextField* price = [cell viewWithTag:1];
    if ([EBUtility isBlankString:price.text]){
        [SVProgressHUD showErrorWithStatus:@"单价不能为空"];
        return;
    }
    RemarksTextViewTableViewCell *cell1 = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:6 inSection:0]];
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[DataStore sharedDataStore].token forKey:@"token"];
    [dict setObject:title.text forKey:@"title"];
    [dict setObject:self.gameId forKey:@"pid"];
    [dict setObject:self.date forKey:@"stime"];
    [dict setObject:self.hour forKey:@"num"];
    [dict setObject:price.text forKey:@"price"];
    [dict setObject:cell1.tv.text forKey:@"note"];
    if ([self.locationAddress isEqualToString:[DataStore sharedDataStore].city]) {
        [dict setObject:[DataStore sharedDataStore].city forKey:@"city"];
    }
    if ([DataStore sharedDataStore].latitude) {
        [dict setObject:[DataStore sharedDataStore].latitude forKey:@"lat"];
    }
    if ([DataStore sharedDataStore].longitude) {
        [dict setObject:[DataStore sharedDataStore].longitude forKey:@"lon"];
    }

    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Parttime/publishpart.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        NSInteger code = [object[@"errcode"] integerValue];
        NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
        NSLog(@"输出 %@--%@",object,msg);
        
        if (code == 1) {
            CustomAlertView* alert = [[CustomAlertView alloc]initWithType:7];
            alert.resultIndex = ^(NSInteger index) {
                [self.navigationController popViewControllerAnimated:1];
            };
            alert.resultRemove = ^(NSString *str) {
                [self.navigationController popViewControllerAnimated:1];
            };
            [alert showAlertView];
        }else{
            [SVProgressHUD showErrorWithStatus:msg];
        }
    } failoperation:^(NSError *error) {
        
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        [SVProgressHUD showErrorWithStatus:@"网络信号差，请稍后再试"];
    }];
}
//调整小时数
- (IBAction)reduceHour:(UIButton*)sender {
    if ([self.hour integerValue] > 1){
        self.hour = [NSString stringWithFormat:@"%ld",[self.hour integerValue] - 1];
        NumberTableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
        cell.numberLab.text = self.hour;
        [self calculate];
    }
}
- (IBAction)addHour:(id)sender {
    if ([self.hour integerValue] < 99){
        self.hour = [NSString stringWithFormat:@"%ld",[self.hour integerValue] + 1];
        NumberTableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
        cell.numberLab.text = self.hour;
        [self calculate];
    }
}
//计算总价
- (void)calculate{
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    UITextField* price = [cell viewWithTag:1];
    
    NSInteger p = price.text.integerValue * self.hour.integerValue;
    
    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:7 inSection:0]];
    UILabel* l = [cell viewWithTag:1];
    l.text = [NSString stringWithFormat:@"¥%ld",p];
    
}
#pragma mark - tableViewDelegate/DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 8;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 4){//小时数cell
       NumberTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"cell%ld",indexPath.row]];
        return cell;
    }else if (indexPath.row == 5){//定位cell
        LocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"cell%ld",indexPath.row]];
        cell.locationLabel.text = [DataStore sharedDataStore].city?:@"全国";
        [cell.locationSwitch addTarget:self action:@selector(switchLocation:) forControlEvents:UIControlEventValueChanged];
        self.locationAddress = cell.locationLabel.text;
        return cell;
    }else if (indexPath.row == 6){//备注cell
        RemarksTextViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"cell%ld",indexPath.row]];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.firstLineHeadIndent = 42.f;    /**首行缩进宽度*/
        paragraphStyle.alignment = NSTextAlignmentJustified;
        NSDictionary *attributes = @{
                                     NSFontAttributeName:[UIFont systemFontOfSize:15],
                                     NSParagraphStyleAttributeName:paragraphStyle
                                     };
        cell.tv.attributedText = [[NSAttributedString alloc] initWithString:@" " attributes:attributes];
        return cell;
    }
    //其他cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"cell%ld",indexPath.row]];
    if (indexPath.row == 3){
        UITextField* tf = [cell viewWithTag:1];
        [tf addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    
    return cell;
}

- (void)switchLocation:(UISwitch *)sender {
    LocationTableViewCell *cell = (LocationTableViewCell *)sender.superview.superview;
    if (sender.isOn) {
        cell.locationLabel.text = [DataStore sharedDataStore].city?:@"全国";
    }
    else {
        cell.locationLabel.text = @"全国";
    }
    self.locationAddress = cell.locationLabel.text;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView endEditing:1];
    if (indexPath.row == 1){
        NSMutableArray* ary = [NSMutableArray array];
        for (NSDictionary* i in self.dataAry){
            [ary addObject:i[@"title"]];
        }
        //选择游戏，将游戏列表传入
        CustomAlertView* alart = [[CustomAlertView alloc]initWithPicker:ary];
        alart.resultDate = ^(NSString *date) {
            UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
            UILabel* l = [cell viewWithTag:1];
            l.text = self.dataAry[date.integerValue][@"title"];
            l.textColor = [UIColor blackColor];
            self.gameId = [NSString stringWithFormat:@"%@",self.dataAry[date.integerValue][@"id"]];
        };
        [alart showAlertView];
    }else if (indexPath.row == 2){//选择日期
        CustomAlertView* alart = [[CustomAlertView alloc] initWithSpecialDatePicker];
        alart.resultDate = ^(NSString *date) {
            UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
//            cell.detailTextLabel.text = date;
            UILabel* l = [cell viewWithTag:1];
            l.text = date;
            l.textColor = [UIColor blackColor];
            
            NSArray* ary = [date componentsSeparatedByString:@" "];
            
            NSDate * selectDate = [NSDate date];
            if ([ary[0] isEqualToString:@"明天"]){
                NSTimeInterval i = [selectDate timeIntervalSince1970];
                selectDate = [NSDate dateWithTimeIntervalSince1970:i + 86400];
            }else if ([ary[0] isEqualToString:@"后天"]){
                NSTimeInterval i = [selectDate timeIntervalSince1970];
                selectDate = [NSDate dateWithTimeIntervalSince1970:i + 86400*2];
            }
            NSDateFormatter *formater = [[NSDateFormatter alloc] init];
            [formater setDateFormat:@"yyyy-MM-dd"];

            //转换格式
            self.date = [NSString stringWithFormat:@"%@ %@:%@",[formater stringFromDate:selectDate],[ary[1] substringToIndex:((NSString*)ary[1]).length -1],[ary[2] substringToIndex:((NSString*)ary[2]).length -1]];
            
        };
        [alart showAlertView];
    }/*else if (indexPath.row == 5){ //优惠券  弃用
        DiscountViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"dvc"];
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:1];
    }*/
}

#pragma mark - otherDelegate/DataSource

- (void)textFieldDidChange:(UITextField *)textField{
    [self calculate];
    if (textField.text.length > 4){
        textField.text = [textField.text substringToIndex:6];
    }
}
- (void)selectSomeThing:(NSString *)name AndId:(NSString *)pid{//优惠券回调 弃用
//    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:6 inSection:0]];
//    UILabel* lab = [cell viewWithTag:1];
//    lab.text = name;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView{
    //字数限制
    if (textView.text.length >= 200){
        textView.text = [textView.text substringToIndex:200];
    }
    
    RemarksTextViewTableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:6 inSection:0]];
    cell.zsbd.text = [NSString stringWithFormat:@"(%lu/200)",(unsigned long)textView.text.length];
    
}

//当用户按下return去键盘
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]){
        [textView  resignFirstResponder];
        return NO;
        
    }
    return YES;
    
}
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    RemarksTextViewTableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:6 inSection:0]];
    cell.placeholdLab.hidden = YES;
    if ([textView.text isEqualToString:@" "]){
        textView.text = @"";
    }
//    [UIView animateWithDuration:0.3 animations:^{
//        
//        CGRect frame = self.view.frame;
//        
//        frame.origin.y = - 20;
//        
//        self.view.frame = frame;
//        
//    }];
    
    
    return YES;
}

//结束编辑时键盘下去 视图下移动画

-(BOOL)textViewShouldEndEditing:(UITextView *)textField{
    
//    [UIView animateWithDuration:0.3 animations:^{
//
//        CGRect frame = self.view.frame;
//
//        frame.origin.y = 64;
//
//        self.view.frame = frame;
//
//    }];
    if ([textField.text isEqualToString:@""]){
        RemarksTextViewTableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:6 inSection:0]];
        cell.placeholdLab.hidden = NO;
        cell.zsbd.text = @"(0/200)";
    }
    return YES;
    
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
