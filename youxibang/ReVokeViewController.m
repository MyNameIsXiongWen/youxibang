 //
//  ReVokeViewController.m
//  youxibang
//
//  Created by y on 2018/1/31.
//

#import "ReVokeViewController.h"
#import "RemarksTextViewTableViewCell.h"

@interface ReVokeViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,LPDQuoteImagesViewDelegate,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong)LPDQuoteImagesView *quoteImagesView;
@property (nonatomic,strong)UIView *footerView;
@property (nonatomic,strong)NSMutableDictionary* dataInfo;
@end

@implementation ReVokeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.type == 0){
        self.title = @"提交异常";
    }else if (self.type == 1){
        self.title = @"取消订单";
        [self downloadData];
    }else if (self.type == 2){
        self.title = @"申请仲裁";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)downloadData{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setObject:[DataStore sharedDataStore].token forKey:@"token"];
    [dict setObject:self.orderId forKey:@"order_sn"];
    
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Orders/orderrefund.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            if (isKindOfNSDictionary(object[@"data"])){
                if (code == 1) {
                    self.dataInfo = [NSMutableDictionary dictionaryWithDictionary:object[@"data"]];
                    [self.tableView reloadData];
                }else{
                    [SVProgressHUD showErrorWithStatus:msg];
                }
            }
        }
        
    } failoperation:^(NSError *error) {
        
        [SVProgressHUD dismiss];
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络信号差，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
    }];
}
//底部view
- (UIView*)footerView{
    if (!_footerView){
        UIView* view = [EBUtility viewfrome:CGRectMake(0, 0, self.tableView.width, 350) andColor:[UIColor groupTableViewBackgroundColor] andView:nil];
        LPDQuoteImagesView* lpdview = [[LPDQuoteImagesView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 350) withCountPerRowInView:4 cellMargin:5];
        //初始化view的frame, view里每行cell个数， cell间距（上方的图片1 即为quoteImagesView）
        lpdview.maxSelectedCount = 1;
        //最大可选照片数
        
        lpdview.collectionView.scrollEnabled = NO;
        //view可否滑动
        lpdview.collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        lpdview.navcDelegate = self;    //self 至少是一个控制器。
        //委托（委托controller弹出picker，且不用实现委托方法）
        self.quoteImagesView = lpdview;
        [view addSubview:lpdview];
        
        UIButton* btn = [EBUtility btnfrome:CGRectMake(0, 110, view.width, 45) andText:self.title andColor:[UIColor whiteColor] andimg:nil andView:view];
        btn.backgroundColor = [EBUtility colorWithHexString:@"F85E57" alpha:1];
        btn.layer.cornerRadius = 22;
        btn.layer.masksToBounds = 1;
        btn.tag = 1001;
        [btn addTarget:self action:@selector(submitRevoke) forControlEvents:UIControlEventTouchUpInside];
        _footerView = view;
    }
    return _footerView;
}
//提交
- (void)submitRevoke{
    if ([EBUtility isBlankString:self.orderId]){
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"订单号为空" andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
        [self.navigationController popViewControllerAnimated:1];
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSString* reason;
    if (self.type != 1){//非提交异常
        RemarksTextViewTableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        UITextView* tv = [cell viewWithTag:100];
        if ([EBUtility isBlankString:tv.text]){
            [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"请填写原因" andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
            return;
        }else{
            reason = tv.text;
        }
        if (self.type == 0){
            [dict setObject:@"2" forKey:@"type"];
        }else if (self.type == 2){
            [dict setObject:@"1" forKey:@"type"];
        }

    }else{//提交异常
       
        if (self.withdrawOrderType == 2){//需要退还保证金
            UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
            UITextField* deposit = [cell viewWithTag:1];
            if ([EBUtility isBlankString:deposit.text]){
                [dict setObject:@"0" forKey:@"deposit"];
            }else{
                if (deposit.text.intValue < 0){
                    [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"请输入0以上的整数" andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
                    return;
                }
                if (deposit.text.intValue > [NSString stringWithFormat:@"%@",self.dataInfo[@"deposit"]].intValue){
                    [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"保证金用不能超过预付费用" andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
                    return;
                }
                [dict setObject:[NSNumber numberWithInt:deposit.text.intValue] forKey:@"deposit"];
            }
            UITableViewCell* cell1 = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
            UITextField* totalprice = [cell1 viewWithTag:1];
            if ([EBUtility isBlankString:totalprice.text]){
                [dict setObject:@"0" forKey:@"totalprice"];
            }else{
                if (totalprice.text.intValue < 0){
                    [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"请输入0以上的整数" andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
                    return;
                }
                if (totalprice.text.intValue > [NSString stringWithFormat:@"%@",self.dataInfo[@"realmoney"]].intValue){
                    [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"陪练费用不能超过预付费用" andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
                    return;
                }
                [dict setObject:[NSNumber numberWithInt:totalprice.text.intValue] forKey:@"totalprice"];
            }
        }else{//只需要支付陪练费
            UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
            UITextField* totalprice = [cell viewWithTag:1];
            if ([EBUtility isBlankString:totalprice.text]){
                [dict setObject:@"0" forKey:@"totalprice"];
            }else{
                if (totalprice.text.intValue < 0){
                    [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"请输入0以上的整数" andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
                    return;
                }
                if (totalprice.text.intValue > [NSString stringWithFormat:@"%@",self.dataInfo[@"realmoney"]].intValue){
                    [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"陪练费用不能超过预付费用" andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
                    return;
                }
                [dict setObject:[NSNumber numberWithInt:totalprice.text.intValue] forKey:@"totalprice"];
            }
        }
        
        RemarksTextViewTableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        UITextView* tv = [cell viewWithTag:100];
        if ([EBUtility isBlankString:tv.text]){
            [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"请填写原因" andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
            return;
        }else{
            reason = tv.text;
        }
    }

    UIImage* img ;
    if (self.quoteImagesView.selectedPhotos.count > 0){
        img = (UIImage*)self.quoteImagesView.selectedPhotos[0];
    }
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    if (self.type != 1){//非异常
        [dict setObject:[DataStore sharedDataStore].token forKey:@"token"];
        [dict setObject:reason forKey:@"desc"];
        [dict setObject:self.orderId forKey:@"order_sn"];
        
        [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Orders/arbitrorabnor.html",HttpURLString] Paremeters:dict Image:img ImageName:@"jzbimg" successOperation:^(id object) {
            [SVProgressHUD dismiss];
            [SVProgressHUD setDefaultMaskType:1];
            if (isKindOfNSDictionary(object)){
                NSInteger code = [object[@"errcode"] integerValue];
                NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
                NSLog(@"输出 %@--%@",object,msg);
                
                if (code == 1) {
                    [SVProgressHUD showSuccessWithStatus:msg];
                    [self.navigationController popViewControllerAnimated:1];
                }else{
                    [SVProgressHUD showErrorWithStatus:msg];
                }
            }
            
        } failoperation:^(NSError *error) {
            
            [SVProgressHUD dismiss];
            [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络信号差，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
        }];
    }else{//提交异常
        [dict setObject:[DataStore sharedDataStore].token forKey:@"token"];
        [dict setObject:reason forKey:@"note"];
        [dict setObject:self.orderId forKey:@"order_sn"];
        
        [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Orders/refundapply.html",HttpURLString] Paremeters:dict Image:img ImageName:@"jzbimg" successOperation:^(id object) {
            [SVProgressHUD dismiss];
            [SVProgressHUD setDefaultMaskType:1];
            if (isKindOfNSDictionary(object)){
                NSInteger code = [object[@"errcode"] integerValue];
                NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
                NSLog(@"输出 %@--%@",object,msg);
                
                if (code == 1) {
                    [SVProgressHUD showSuccessWithStatus:msg];
                    [self.navigationController popViewControllerAnimated:1];
                }else{
                    [SVProgressHUD showErrorWithStatus:msg];
                }
            }
            
        } failoperation:^(NSError *error) {
            [SVProgressHUD dismiss];
            [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络信号差，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
        }];
    }
    
}
#pragma mark - tableViewDelegate/DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.type == 1){
        return 3;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.type == 1){
        if (section == 0){
            if (self.withdrawOrderType == 2){
                return 4;
            }
            return 2;
        }else if (section == 2){
            return 0;
        }
    }else if (section == 1 ){
        return 0;
    }
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (self.type == 1 && section == 0){
        return 10;
    }
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{

    return [UIView new];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.type == 1){
        if (section == 2){
           return 350;
        }
    }else{
        if (section == 1){
            return 350;
        }
    }
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.type == 1 && section == 2){
        return self.footerView;
    }else if (section == 1){
        return self.footerView;
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.type == 1 && indexPath.section == 0){
        if (self.withdrawOrderType == 2){
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"cell%ld",(long)indexPath.row]];
            if (indexPath.row == 0){
                UILabel* deposit = [cell viewWithTag:1];
                deposit.text = [NSString stringWithFormat:@"¥%@",self.dataInfo[@"deposit"]];
            }else if (indexPath.row == 2){
                UILabel* deposit = [cell viewWithTag:1];
                deposit.text = [NSString stringWithFormat:@"¥%@",self.dataInfo[@"realmoney"]];
            }
            
            return cell;
        }else{
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"cell%ld",(long)indexPath.row + 2]];
            if (indexPath.row == 0){
                UILabel* deposit = [cell viewWithTag:1];
                deposit.text = [NSString stringWithFormat:@"¥%@",self.dataInfo[@"realmoney"]];
            }
            return cell;
        }
    }
    RemarksTextViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tvcell"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView endEditing:1];
}

#pragma mark - otherDelegate/DataSource
//逻辑修改只能上传一张图片，如果需要上传多张图片请打开此方法
//- (void)chooseFinish{
//    UIButton* btn = [self.footerView viewWithTag:1001];
//    btn.y = 110 +(self.quoteImagesView.selectedPhotos.count)/4 * 90;
//}

//字数限制
- (void)textViewDidChange:(UITextView *)textView{
    
    if (textView.text.length >= 200){
        textView.text = [textView.text substringToIndex:200];
    }
    
    RemarksTextViewTableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if (self.type == 1){
        cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    }
    cell.zsbd.text = [NSString stringWithFormat:@"%lu/200",(unsigned long)textView.text.length];
    
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
    RemarksTextViewTableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if (self.type == 1){
        cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    }
    cell.placeholdLab.hidden = YES;
    if ([textView.text isEqualToString:@" "]){
        textView.text = @"";
    }
    return YES;
}

//结束编辑时键盘下去 视图下移动画

-(BOOL)textViewShouldEndEditing:(UITextView *)textField{
    if ([textField.text isEqualToString:@""]){
        RemarksTextViewTableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        if (self.type == 1){
            cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        }
        cell.placeholdLab.hidden = NO;
        cell.zsbd.text = @"0/200";
    }
    return YES;
    
}
//当用户按下return去键盘

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
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
