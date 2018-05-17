//
//  OrderViewController.m
//  youxibang
//
//  Created by y on 2018/1/19.
//

#import "OrderViewController.h"
#import "UserPhotoTableViewCell.h"
#import "RemarksTextViewTableViewCell.h"
#import "NumberTableViewCell.h"
#import "PayOrderTableViewCell.h"
#import "PayOrderViewController.h"
#import "DiscountViewController.h"

@interface OrderViewController ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,DiscountViewControllerDelegate>
@property (nonatomic,strong)NSMutableDictionary* dataInfo;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *commitOrder;//提交按键
@property (nonatomic,copy) NSString* hour;
@property (nonatomic,copy) NSString* startTime;//开始时间
@property (nonatomic,assign) int price;//单价
@property (nonatomic,assign) int discountPrice;//优惠价格
@property (nonatomic,assign) NSString* discountId;//优惠券id
@property (nonatomic,assign) BOOL hasUsedDiscount;//是否使用了优惠
@end

@implementation OrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.scrollEnabled = NO;
    UIView *v = [[UIView alloc]init];
    v.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = v;
    self.hour = @"1";
    self.title = @"下单";
    
    [self downloadInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //这里的逻辑是，当在此页面选择优惠券下单后，优惠券就已经消耗掉了，如果进入下个页面，未付款便返回，就清除原有的优惠券信息刷新UI
    if (!self.hasUsedDiscount){
        self.discountId = nil;
        self.discountPrice = 0;
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:2]];
        cell.detailTextLabel.text = @"";
        
        [self calculatePrice];
    }
    
}
//下载个人信息
- (void)downloadInfo{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setObject:self.userId forKey:@"buserid"];
    if (self.skillId){
        [dict setObject:self.skillId forKey:@"id"];
    }
    
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Gamebaby/skillcart.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            
            if (code == 1) {
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
        [self.navigationController popViewControllerAnimated:1];
    }];
}
//提交
- (IBAction)cO:(UIButton *)sender {
    if ([EBUtility isBlankString:self.startTime]){
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"请填写开始时间" andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
        return;
    }
    //备注
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    UITextView* tv = [cell viewWithTag: 1];
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setObject:[DataStore sharedDataStore].userid forKey:@"userid"];
    [dict setObject:self.userId forKey:@"buserid"];
    [dict setObject:self.skillId forKey:@"id"];
    [dict setObject:self.hour forKey:@"hours"];
    [dict setObject:tv.text forKey:@"user_note"];
    [dict setObject:self.startTime forKey:@"stime"];
    if (self.discountId){
        [dict setObject:self.discountId forKey:@"couponid"];
    }
    
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Gamebaby/orderSubmit.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            
            if (code == 1) {
                [SVProgressHUD showSuccessWithStatus:msg];
                PayOrderViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"po"];
                vc.type = NSStringFromClass([self class]);
                vc.orderId = [NSString stringWithFormat:@"%@",object[@"data"][@"orderid"]];
                [self.navigationController pushViewController:vc animated:1];
            }else{
                [SVProgressHUD showErrorWithStatus:msg];
            }
        }
        
    } failoperation:^(NSError *error) {
        
        [SVProgressHUD dismiss];
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络信号差，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
    }];
}
//加减小时数
- (IBAction)reduceHour:(UIButton*)sender {
    if ([self.hour integerValue] > 1){
        self.hour = [NSString stringWithFormat:@"%ld",[self.hour integerValue] - 1];
        [self calculatePrice];
    }
}
- (IBAction)addHour:(id)sender {
    if ([self.hour integerValue] < 99){
        self.hour = [NSString stringWithFormat:@"%ld",[self.hour integerValue] + 1];
        [self calculatePrice];
    }
}
//计算总价
- (void)calculatePrice{
    NumberTableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]];
    cell.numberLab.text = self.hour;
    
    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:2]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"¥%d",self.price * self.hour.intValue - self.discountPrice];
    
}
#pragma mark - tableViewDelegate/DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 1){
        return 2;
    }else if (section == 2){
        return 4;
    }
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 3){
        return 0;
    }
    return 10;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 3){
        return nil;
    }
    UIView* fv = [EBUtility viewfrome:CGRectMake(0, 0, SCREEN_WIDTH, 10) andColor:[UIColor groupTableViewBackgroundColor] andView:nil];
    
    return fv;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        UserPhotoTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell1"];
        cell.name.text = @"昵称";
        if (self.dataInfo){
            cell.name.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"userinfo"][@"nickname"]];
            [cell.photo sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.dataInfo[@"userinfo"][@"photo"]]] placeholderImage:[UIImage imageNamed:@"ico_head"]];
        }
        return cell;
    }else if (indexPath.section == 3){//备注cell
        RemarksTextViewTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"tvcell"];
        cell.tv.delegate = self;
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
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 1){
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (indexPath.row == 0){
            cell.textLabel.text = @"品类";
            cell.detailTextLabel.text = @"请选择品类";
            if (self.dataInfo){
                for (NSDictionary* i in self.dataInfo[@"skilllist"]){
                    if ([NSString stringWithFormat:@"%@",i[@"checked"]].integerValue == 1){
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",i[@"title"]];
                        self.skillId = i[@"id"];
                    }
                }
            }
            
        }else if (indexPath.row == 1){
            cell.textLabel.text = @"时间";
            cell.detailTextLabel.text = @"请选择时间";
        }
    }else if (indexPath.section == 2){
        if (indexPath.row == 0){
            cell.textLabel.text = @"费用";
            cell.detailTextLabel.text = @"¥0";
            cell.detailTextLabel.textColor = [UIColor blackColor];
            if (self.dataInfo){
                for (NSDictionary* i in self.dataInfo[@"skilllist"]){
                    if ([NSString stringWithFormat:@"%@",i[@"checked"]].integerValue == 1){
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"¥%@/小时",i[@"price"]];
                        self.price = [NSString stringWithFormat:@"%@",i[@"price"]].intValue;
                    }
                }
            }
        }else if (indexPath.row == 1){
            NumberTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"num"];
            
            return cell;
        }else if (indexPath.row == 2){
            cell.textLabel.text = @"优惠券";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else if (indexPath.row == 3){
            cell.textLabel.text = @"应付总金额";
            cell.detailTextLabel.text = @"¥0";
            cell.detailTextLabel.textColor = [UIColor redColor];
            
            if (self.dataInfo){
                for (NSDictionary* i in self.dataInfo[@"skilllist"]){
                    if ([NSString stringWithFormat:@"%@",i[@"checked"]].integerValue == 1){
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"¥%@",i[@"price"]];
                    }
                }
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView endEditing:1];
    if (indexPath.section == 1){
        if (indexPath.row == 0){//选择技能
            NSMutableArray* ary = [NSMutableArray array];
            for (NSDictionary* i in (NSArray*)self.dataInfo[@"skilllist"]){
                [ary addObject:i[@"title"]];
            }
            CustomAlertView* alart = [[CustomAlertView alloc]initWithPicker:ary];
            alart.resultDate = ^(NSString *date) {
                
                UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"skilllist"][date.integerValue][@"title"]];
                
                cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
                self.price = [NSString stringWithFormat:@"%@",self.dataInfo[@"skilllist"][date.integerValue][@"price"]].intValue;
                cell.detailTextLabel.text = [NSString stringWithFormat:@"¥%d/小时",self.price];
                
                cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:2]];
                
                cell.detailTextLabel.text = [NSString stringWithFormat:@"¥%d",self.price * self.hour.intValue];
                
                self.skillId = [NSString stringWithFormat:@"%@",self.dataInfo[@"skilllist"][date.integerValue][@"id"]];
                
            };
            [alart showAlertView];
        }else if (indexPath.row == 1){//选择时间
            CustomAlertView* alart = [[CustomAlertView alloc] initWithSpecialDatePicker];
            alart.resultDate = ^(NSString *date) {
                UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
                cell.detailTextLabel.text = date;
                
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
                
                self.startTime = [NSString stringWithFormat:@"%@ %@:%@",[formater stringFromDate:selectDate],[ary[1] substringToIndex:((NSString*)ary[1]).length -1],[ary[2] substringToIndex:((NSString*)ary[2]).length -1]];
                
            };
            [alart showAlertView];
        }
    }else if (indexPath.section == 2){//选择优惠券
        if (indexPath.row == 2){
            DiscountViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"dvc"];
            vc.delegate = self;
            [self.navigationController pushViewController:vc animated:1];
        }
    }
}

#pragma mark - otherDelegate/DataSource
- (void)selectSomeThing:(NSString *)name AndId:(NSString *)pid{//优惠券回调
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:2]];
    cell.detailTextLabel.text = name;
    
    self.discountPrice = [name substringToIndex:name.length - 1].intValue;
    self.discountId = pid;
    [self calculatePrice];
    self.hasUsedDiscount = 1;
}

//字数限制
- (void)textViewDidChange:(UITextView *)textView{
    
    if (textView.text.length >= 200){
        textView.text = [textView.text substringToIndex:200];
    }
    
    RemarksTextViewTableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
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
    RemarksTextViewTableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    cell.placeholdLab.hidden = YES;
    if ([textView.text isEqualToString:@" "]){
        textView.text = @"";
    }
    
    
    return YES;
}

//结束编辑时键盘下去 视图下移动画

-(BOOL)textViewShouldEndEditing:(UITextView *)textField{
    if ([textField.text isEqualToString:@""]){
        RemarksTextViewTableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
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

