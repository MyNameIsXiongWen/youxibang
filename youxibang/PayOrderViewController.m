//
//  PayOrderViewController.m
//  youxibang
//
//  Created by y on 2018/1/25.
//

#import "PayOrderViewController.h"
#import "UserPhotoTableViewCell.h"
#import "PayOrderTableViewCell.h"
#import <AlipaySDK/AlipaySDK.h>
#import "WXApi.h"
#import "WXApiObject.h"
#import "RetrievePayPasswordViewController.h"
#import "SetPayPasswordViewController.h"

@interface PayOrderViewController ()<UITableViewDelegate,UITableViewDataSource,WXApiDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic)NSMutableArray* btnAry;
@property (nonatomic,strong)NSMutableDictionary* dataInfo;
@property (nonatomic,copy) NSString* way;//支付方式 1 微信  2 支付宝  3 余额  这里是因为框架写出来之后，接口才开始写，所以框架默认的顺序与接口的顺序不一样
@end

@implementation PayOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.title = @"支付";
    self.way = @"1";
    
    [self downloadInfo];
    //完成支付的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completePay:) name:@"completePay" object:nil];
}
- (NSMutableArray*)btnAry{
    if (!_btnAry){
        _btnAry = [NSMutableArray array];
    }
    return _btnAry;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)downloadInfo{

    if ([EBUtility isBlankString:self.orderId]){
        [SVProgressHUD showErrorWithStatus:@"订单编号为空"];
        [self.navigationController popViewControllerAnimated:1];
    }
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if ([self.type isEqualToString:@"OrderDetailViewController"]){//支付保证金
        [dict setObject:[DataStore sharedDataStore].userid forKey:@"userid"];
        [dict setObject:self.purposemoney forKey:@"purposemoney"];
        [dict setObject:self.orderId forKey:@"id"];
        
        [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Parttime/orderSubmit.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
            [SVProgressHUD dismiss];
            [SVProgressHUD setDefaultMaskType:1];
            if (isKindOfNSDictionary(object)){
                NSInteger code = [object[@"errcode"] integerValue];
                NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
                NSLog(@"输出 %@--%@",object,msg);
                
                if (code == 1) {
                    self.dataInfo = [NSMutableDictionary dictionaryWithDictionary:object[@"data"]];
                    [self.tableView reloadData];
                    self.orderId = [NSString stringWithFormat:@"%@",object[@"data"][@"orderid"]];
                }else{
                    [SVProgressHUD showErrorWithStatus:msg];
                    [self.navigationController popViewControllerAnimated:1];
                }
            }
            
        } failoperation:^(NSError *error) {
            
            [SVProgressHUD dismiss];
            [SVProgressHUD setDefaultMaskType:1];
            [SVProgressHUD showErrorWithStatus:@"网络信号差，请稍后再试"];
            [self.navigationController popViewControllerAnimated:1];
        }];
    }else if ([self.type isEqualToString:@"OrderViewController"]){//直接向宝贝下单
        [dict setObject:@"1" forKey:@"otype"];
        [dict setObject:self.orderId forKey:@"orderid"];
        
        [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Gamebaby/orderbabydetail.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
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
            [SVProgressHUD setDefaultMaskType:1];
            [SVProgressHUD showErrorWithStatus:@"网络信号差，请稍后再试"];
            [self.navigationController popViewControllerAnimated:1];
        }];
    }else if ([self.type isEqualToString:@"OrderSelectViewController"]){//宝贝抢单后选择宝贝付款
        [dict setObject:@"3" forKey:@"otype"];
        [dict setObject:self.orderId forKey:@"orderid"];
        
        [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Gamebaby/orderbabydetail.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
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
            [SVProgressHUD setDefaultMaskType:1];
            [SVProgressHUD showErrorWithStatus:@"网络信号差，请稍后再试"];
            [self.navigationController popViewControllerAnimated:1];
        }];
    }
}

- (IBAction)payOrderBtnApi:(UIButton *)sender {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[DataStore sharedDataStore].userid forKey:@"userid"];
    [dict setObject:[NSString stringWithFormat:@"%@",self.dataInfo[@"orderid"]] forKey:@"id"];
    
    if ([self.type isEqualToString:@"OrderDetailViewController"]){
        [dict setObject:@"2" forKey:@"otype"];
    }else if ([self.type isEqualToString:@"OrderViewController"]){
        [dict setObject:@"1" forKey:@"otype"];
    }else if ([self.type isEqualToString:@"OrderSelectViewController"]){
        [dict setObject:@"3" forKey:@"otype"];
    }
    
    if ([self.way isEqualToString:@"1"]){
        [dict setObject:@"2" forKey:@"paytype"];
        [self commitOrder:dict];
    }else if ([self.way isEqualToString:@"2"]){
        [dict setObject:@"1" forKey:@"paytype"];
        [self commitOrder:dict];
    }else if ([self.way isEqualToString:@"3"]){
        NSMutableDictionary* dic = [UserNameTool readPersonalData];
        NSString* i = [NSString stringWithFormat:@"%@",dic[@"is_paypwd"]];
        if ([i isEqualToString:@"0"]){
            SetPayPasswordViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"spp"];
            [self.navigationController pushViewController:vc animated:1];
            return;
        }
        //弹起支付密码alert
        CustomAlertView* alert = [[CustomAlertView alloc] initWithType:6];
        alert.resultDate = ^(NSString *date) {
            [dict setObject:date forKey:@"pwd"];
            [dict setObject:@"3" forKey:@"paytype"];
            [self commitOrder:dict];
        };
        alert.resultIndex = ^(NSInteger index) {
            RetrievePayPasswordViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"rpp"];
            [self.navigationController pushViewController:vc animated:1];
        };
        [alert showAlertView];
    }
    
}
//提交支付
- (void)commitOrder:(NSMutableDictionary*)dic{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Payment/paymethods.html",HttpURLString] Paremeters:dic successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            
            if (code == 1) {
                if ([self.way isEqualToString:@"1"]){//跳转微信
                    
                    PayReq *request = [[PayReq alloc] init];
                    
                    request.partnerId = [NSString stringWithFormat:@"%@",object[@"data"][@"partnerid"]];
                    request.prepayId = [NSString stringWithFormat:@"%@",object[@"data"][@"prepayid"]];
                    request.package = [NSString stringWithFormat:@"%@",object[@"data"][@"package"]];
                    request.nonceStr = [NSString stringWithFormat:@"%@",object[@"data"][@"noncestr"]];
                    request.timeStamp = [NSString stringWithFormat:@"%@",object[@"data"][@"timestamp"]].intValue;
                    request.sign= [NSString stringWithFormat:@"%@",object[@"data"][@"sign"]];
                    [WXApi sendReq:request];
                }else if ([self.way isEqualToString:@"2"]){//跳转支付宝
                    [[AlipaySDK defaultService] payOrder:[NSString stringWithFormat:@"%@",object[@"data"]] fromScheme:@"alipayYouxibang" callback:^(NSDictionary *resultDic) {

                    }];
                }else if ([self.way isEqualToString:@"3"]){
                    
                    [self completePay:nil];
                }
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

- (void)completePay:(NSNotification *)notification{
    [UserNameTool reloadPersonalData:nil];
    CustomAlertView* alert = [[CustomAlertView alloc]initWithTitle:@"温馨提示" Text:@"支付完成，即将跳转到个人页面。" AndType:0];
    alert.resultIndex = ^(NSInteger index) {
        NSNotification *notification = [NSNotification notificationWithName:@"pushMineView" object:nil userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        [self.navigationController popToRootViewControllerAnimated:1];
    };
    [alert showAlertView];
}
#pragma mark - tableViewDelegate/DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.dataInfo){
        return 4;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0){
        return 2;
    }
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1){
        return 40;
    }else if (section == 0){
        return 0;
    }
    return 10;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView* v = [EBUtility viewfrome:CGRectMake(0, 0, SCREEN_WIDTH, 10) andColor:[UIColor groupTableViewBackgroundColor] andView:nil];
    if (section == 0){
        return nil;
    }else if (section == 1){
        UILabel* lab = [EBUtility labfrome:CGRectMake(10, 10, 70, 20) andText:@"支付方式" andColor:[UIColor blackColor] andView:v];
        lab.font = [UIFont systemFontOfSize:16];
    }
    return v;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        if (indexPath.row == 0){
            UserPhotoTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell1"];
            if (self.dataInfo){
                cell.name.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"nickname"]];
                [cell.photo sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.dataInfo[@"photo"]]] placeholderImage:[UIImage imageNamed:@"ico_head"]];
            }
            return cell;
        }else if (indexPath.row == 1){
           UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
            cell.imageView.image = [UIImageView OriginImage:[UIImage imageNamed:@"ico_dota"] scaleToSize:CGSizeMake(30, 30)];

            cell.imageView.layer.masksToBounds = 1;
            cell.imageView.layer.cornerRadius = 10;
            
            cell.textLabel.text = @"技能名";
            cell.detailTextLabel.text = @"1小时";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            for (UILabel* i in cell.viewForLastBaselineLayout.subviews){
                if (i.tag == 1){
                    [i removeFromSuperview];
                }
            }
            UILabel* lab = [EBUtility labfrome:CGRectMake(SCREEN_WIDTH - 160, 0, 150, 20) andText:@"¥0" andColor:[UIColor redColor] andView:cell.viewForLastBaselineLayout];
            lab.centerY = cell.viewForLastBaselineLayout.centerY;
            lab.textAlignment = 2;
            lab.tag = 1;
            if (self.dataInfo){
                if ([self.type isEqualToString:@"OrderDetailViewController"]){
                    cell.textLabel.text = @"保证金额";
                    lab.text = [NSString stringWithFormat:@"¥%@",self.dataInfo[@"deposit"]];
                    cell.imageView.image = nil;
                    cell.detailTextLabel.text = @"";
                }else if ([self.type isEqualToString:@"OrderViewController"] || [self.type isEqualToString:@"OrderSelectViewController"]){
                    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.dataInfo[@"image"]]]];
                    cell.textLabel.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"title"]];
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",(self.dataInfo[@"hours"]) ? (self.dataInfo[@"hours"]) : @""];
                    lab.text = [NSString stringWithFormat:@"¥%@",self.dataInfo[@"payamout"]];
                }
            }
            return cell;
        }
    }else if(indexPath.section == 1){
        PayOrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"wxpay"];
        if ([NSString stringWithFormat:@"%@",self.dataInfo[@"deposit"]].intValue == 0 && [self.type isEqualToString:@"OrderDetailViewController"]){
            cell.selectBtn.selected = NO;
        }else{
            cell.selectBtn.selected = YES;
            self.way = @"1";
        }
        [self.btnAry addObject:cell.selectBtn];
        return cell;
    }else if(indexPath.section == 2){
        PayOrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"alipay"];

        [self.btnAry addObject:cell.selectBtn];
        return cell;
    }else if(indexPath.section == 3){//余额cell  判断余额是否足够
        PayOrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"yepay"];
        
        NSMutableDictionary* dic = [UserNameTool readPersonalData];
        NSString* i = [NSString stringWithFormat:@"%@",(dic[@"user_money"]) ? (dic[@"user_money"]) : @"0"];
        UILabel* lab = [cell viewWithTag:1];
        lab.text = [NSString stringWithFormat:@"¥%@",i];
        
        if ([self.type isEqualToString:@"OrderDetailViewController"] ){//在保证金为0时，只能选择余额支付
            if ([NSString stringWithFormat:@"%@",self.dataInfo[@"deposit"]].intValue > i.intValue){
                lab.textColor = [UIColor darkGrayColor];
                UILabel* lab1 = [cell viewWithTag:2];
                lab1.hidden = NO;
                
                UIButton* btn = [cell viewWithTag:3];
                btn.userInteractionEnabled = NO;
                
                UIImageView* img = [cell viewWithTag:4];
                img.image = [UIImage imageNamed:@"ico_ye1"];
            }
            if ([NSString stringWithFormat:@"%@",self.dataInfo[@"deposit"]].intValue == 0){
                cell.selectBtn.selected = YES;
                self.way = @"3";
            }else{
                cell.selectBtn.selected = NO;
            }
        }else if ([self.type isEqualToString:@"OrderViewController"] || [self.type isEqualToString:@"OrderSelectViewController"]){
            if ([NSString stringWithFormat:@"%@",self.dataInfo[@"payamout"]].intValue > i.intValue){
                lab.textColor = [UIColor darkGrayColor];
                UILabel* lab1 = [cell viewWithTag:2];
                lab1.hidden = NO;
                
                UIButton* btn = [cell viewWithTag:3];
                btn.userInteractionEnabled = NO;
                
                UIImageView* img = [cell viewWithTag:4];
                img.image = [UIImage imageNamed:@"ico_ye1"];
                
            }
            
        }
        
        [self.btnAry addObject:cell.selectBtn];
        return cell;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.type isEqualToString:@"OrderDetailViewController"]){
        if ([NSString stringWithFormat:@"%@",self.dataInfo[@"deposit"]].intValue == 0){
            return;
        }
    }
    
    if (indexPath.section == 1 || indexPath.section == 2 || indexPath.section == 3 ){//判断余额是否充足
        if (indexPath.section == 3){
            NSMutableDictionary* dic = [UserNameTool readPersonalData];
            NSString* i = [NSString stringWithFormat:@"%@",(dic[@"user_money"]) ? (dic[@"user_money"]) : @"0"];
            if ([self.type isEqualToString:@"OrderDetailViewController"]){
                if (((NSString*)self.dataInfo[@"deposit"]).intValue > i.intValue){
                    return;
                }
            }else if ([self.type isEqualToString:@"OrderViewController"] || [self.type isEqualToString:@"OrderSelectViewController"]){
                if (((NSString*)self.dataInfo[@"payamout"]).intValue > i.intValue){
                    return;
                }
            }
            
        }
        for (UIButton* i in self.btnAry){
            i.selected = NO;
            if (i.tag == indexPath.section){
                i.selected = YES;
                self.way = [NSString stringWithFormat:@"%ld",i.tag];
            }
        }
    }
    
    
}

#pragma mark - otherDelegate/DataSource
//微信支付回调
//-(void)onResp:(BaseResp*)resp{
//    if ([resp isKindOfClass:[PayResp class]]){
//        PayResp *response=(PayResp *)resp;
//
//        if (response.errCode == WXSuccess){
//            NSLog(@"支付成功");
//            NSNotification *notification = [NSNotification notificationWithName:@"completePay" object:nil userInfo:nil];
//            [[NSNotificationCenter defaultCenter] postNotification:notification];
//        }else{
//            NSLog(@"支付失败，retcode=%d",resp.errCode);
//        }
////        switch(response.errCode){
////            caseWXSuccess:
////                //服务器端查询支付通知或查询API返回的结果再提示成功
////                NSLog(@"支付成功");
////                [self completePay];
////                break;
////            default:
////                NSLog(@"支付失败，retcode=%d",resp.errCode);
////                break;
////        }
//    }
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
