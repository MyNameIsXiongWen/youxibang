//
//  LiveCreateViewController.m
//  youxibang
//
//  Created by jiazhuo1 on 2018/4/26.
//

#import "LiveCreateViewController.h"
#import "ZLPhotoAssets.h"
#import "UIImage+ZLPhotoLib.h"
#import "ZLPhotoPickerBrowserViewController.h"
#import "LiveCreateTableViewCell.h"
#import "BottomSelectView.h"
#import "LiveCreateMyEvaluateViewController.h"
#import "LiveCreateFreeView.h"
#import "LiveCharmPhotoModel.h"

#define MAXPHOTOCOUNT 16

static NSString *const LIVECREATA_TABLEVIEW_ID = @"livecreate_tableview_id";
@interface LiveCreateViewController () <UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, BottomSelectViewDelegate, UITextFieldDelegate> {
    NSString *provinceString;
    NSString *cityString;
    
    NSString *areaString;
    NSString *typeString;
    NSString *platformString;
    NSString *room_numberString;
    NSString *anchor_typeString;
    NSString *expString;
    NSString *wechatString;
    NSString *wish_salaryString;
    NSString *brokerage_agencyString;
    NSString *self_evaluateString;
    
    NSString *idString;//主播ID
    NSString *moneyString;//上传照片是收费
}

//地区相关
@property (strong, nonatomic) NSDictionary *pickerDic;
@property (strong, nonatomic) NSArray *provinceArray;
@property (strong, nonatomic) NSArray *cityArray;
@property (strong, nonatomic) NSArray *selectedArray;

@property (strong, nonatomic) IBOutlet UIPickerView *areaPickerView;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) NSMutableArray *filterArray;

//收费分开，因为一次只能上传一种收费的
@property (strong, nonatomic) NSMutableArray *picArray;//所有的照片，方便显示
@property (strong, nonatomic) NSMutableArray *oneArray;
@property (strong, nonatomic) NSMutableArray *twoArray;
@property (strong, nonatomic) NSMutableArray *threeArray;
@property (strong, nonatomic) NSMutableArray *freeArray;

@end

@implementation LiveCreateViewController

- (NSArray *)filterArray {
    if (!_filterArray) {
        _filterArray = @[@"",
                         @{@"直播类型":@[@"兼职",@"全职"]},
                         @{@"所属平台":@[@"花椒",@"映客",@"虎牙",@"斗鱼",@"战旗",@"熊猫",@"YY直播",@"一直播",@"六间房",@"龙珠直播",@"Now直播",@"来疯直播",@"触手直播",@"繁星直播",@"全民直播",@"KK直播",@"Live直播",@"陌陌直播",@"喵播",@"快手",@"其他"]},
                         @"",
                         @{@"主播类型":@[@"电竞",@"电商",@"体育",@"教育",@"游戏",@"户外",@"其他"]},
                         @{@"直播经验":@[@"1年",@"2年",@"3年",@"4年以上"]},
                         @"",
                         @{@"期望薪资":@[@"2000-3000",@"3000-5000",@"5000-7000",@"7000-10000",@"面议"]}].mutableCopy;
    }
    return _filterArray;
}


#pragma mark - get data
- (void)getPickerData {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Address" ofType:@"plist"];
    self.pickerDic = [[NSDictionary alloc] initWithContentsOfFile:path];
    self.provinceArray = [self.pickerDic allKeys];
    self.selectedArray = [self.pickerDic objectForKey:[[self.pickerDic allKeys] objectAtIndex:0]];
    if (self.selectedArray.count > 0) {
        self.cityArray = [[self.selectedArray objectAtIndex:0] allKeys];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"我是主播";
    [self.tableview registerNib:[UINib nibWithNibName:@"LiveCreateTableViewCell" bundle:nil] forCellReuseIdentifier:LIVECREATA_TABLEVIEW_ID];
    self.tableview.tableFooterView = UIView.new;
    
    self.picArray = [[NSMutableArray alloc] init];
    self.freeArray = [[NSMutableArray alloc] init];
    self.oneArray = [[NSMutableArray alloc] init];
    self.twoArray = [[NSMutableArray alloc] init];
    self.threeArray = [[NSMutableArray alloc] init];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setTitle:@"保存" forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [rightBtn setTitleColor:[UIColor colorFromHexString:@"437fed"] forState:UIControlStateNormal];
    rightBtn.bounds = CGRectMake(0, 0, 40, 30);
    [rightBtn addTarget:self action:@selector(saveCreate) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    [self getPickerData];
    [self getLiveInformation];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self getSelectTypeRequestWithType:1];
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        [self getSelectTypeRequestWithType:2];
    });
}

//获取选择项
- (void)getSelectTypeRequestWithType:(NSInteger)type {
    NSString *typeString = @"";
    if (type == 1) {
        typeString = @"platform";
    }
    else {
        typeString = @"anchor_type";
    }
    NSDictionary *dic = @{@"type":typeString};
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@currency/get_conf",HttpURLString] Paremeters:dic successOperation:^(id object) {
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            if (code == 1) {
                if (type == 1) {
                    NSDictionary *typeDic = @{@"所属平台":object[@"data"]};
                    [self.filterArray replaceObjectAtIndex:2 withObject:typeDic];
                }
                else {
                    NSDictionary *typeDic = @{@"主播类型":object[@"data"]};
                    [self.filterArray replaceObjectAtIndex:4 withObject:typeDic];
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

//获取主播资料
- (void)getLiveInformation {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    NSMutableDictionary *dic = @{@"token":[DataStore sharedDataStore].token}.mutableCopy;
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@anchor/get_anchor_info",HttpURLString] Paremeters:dic successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            NSDictionary *dic = object[@"data"];
            if (code == 1) {
                idString = dic[@"id"];
                areaString = dic[@"city"];
                if ([dic[@"type"] integerValue] == 2) {
                    typeString = @"兼职";
                }
                else {
                    typeString = @"全职";
                }
                platformString = dic[@"platform"];
                room_numberString = dic[@"room_number"];
                anchor_typeString = dic[@"anchor_type"];
                expString = dic[@"exp"];
                wechatString = dic[@"wechat"];
                wish_salaryString = dic[@"wish_salary"];
                brokerage_agencyString = dic[@"brokerage_agency"];
                self_evaluateString = dic[@"self_evaluate"];
                for (NSDictionary *imgdic in dic[@"img_arr"]) {
                    LiveCharmPhotoModel *model = [LiveCharmPhotoModel mj_objectWithKeyValues:imgdic];
                    model.type = 2;
                    model.url = imgdic[@"url"];
                    if ([imgdic[@"fee"] integerValue] == 1) {
                        [self.oneArray addObject:model];
                    }
                    if ([imgdic[@"fee"] integerValue] == 2) {
                        [self.twoArray addObject:model];
                    }
                    if ([imgdic[@"fee"] integerValue] == 3) {
                        [self.threeArray addObject:model];
                    }
                    if ([imgdic[@"fee"] integerValue] == 0) {
                        [self.freeArray addObject:model];
                    }
                    [self.picArray addObject:imgdic[@"url"]];
                }
                [self.tableview reloadData];
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

//上传主播资料
- (void)saveCreate {
    if (!areaString) {
        [SVProgressHUD showErrorWithStatus:@"请选择城市"];
        return;
    }
    if (!typeString) {
        [SVProgressHUD showErrorWithStatus:@"请选择直播类型"];
        return;
    }
    if (!platformString) {
        [SVProgressHUD showErrorWithStatus:@"请选择平台"];
        return;
    }
    if (!room_numberString) {
        [SVProgressHUD showErrorWithStatus:@"请填写房间号"];
        return;
    }
    if (!wechatString) {
        [SVProgressHUD showErrorWithStatus:@"请填写微信号"];
        return;
    }
    if (!wish_salaryString) {
        [SVProgressHUD showErrorWithStatus:@"请选择期望薪资"];
        return;
    }
    if (!brokerage_agencyString) {
        [SVProgressHUD showErrorWithStatus:@"请填写经纪公司"];
        return;
    }
    NSMutableDictionary *dic = @{@"token":[DataStore sharedDataStore].token,
                                 @"city":areaString,
                                 @"platform":platformString,
                                 @"room_number":room_numberString,
                                 @"wechat":wechatString,
                                 @"wish_salary":wish_salaryString,
                                 @"brokerage_agency":brokerage_agencyString
                                 }.mutableCopy;
    if (idString) {
        [dic setObject:idString forKey:@"id"];
    }
    if (anchor_typeString) {
        [dic setObject:anchor_typeString forKey:@"anchor_type"];
    }
    if (expString) {
        [dic setObject:expString forKey:@"exp"];
    }
    if (self_evaluateString) {
        [dic setObject:self_evaluateString forKey:@"self_evaluate"];
    }
    if ([typeString isEqualToString:@"全职"]) {
        [dic setObject:@"1" forKey:@"type"];
    }
    else {
        [dic setObject:@"2" forKey:@"type"];
    }
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@anchor/set_anchor",HttpURLString] Paremeters:dic successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            if (code == 1) {
                [self.navigationController popViewControllerAnimated:YES];
                WEAKSELF
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf updataCharmImageWithImgArray:self.oneArray Fee:@"1" IsCharge:@"1"];
                });
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf updataCharmImageWithImgArray:self.twoArray Fee:@"2" IsCharge:@"1"];
                });
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf updataCharmImageWithImgArray:self.threeArray Fee:@"3" IsCharge:@"1"];
                });
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf updataCharmImageWithImgArray:self.freeArray Fee:@"0" IsCharge:@"0"];
                });
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 10;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if (self.picArray.count == 16) {
            return ((SCREEN_WIDTH-30-30)/4+10)*(self.picArray.count/4) + 10+25;
        }
        return ((SCREEN_WIDTH-30-30)/4+10)*(self.picArray.count/4+1) + 10+25;
    }
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 15;
    }
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bgcell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"bgcell"];
        }
        for (UIView *subView in cell.subviews) {
            [subView removeFromSuperview];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        UILabel *xingxiang = [EBUtility labfrome:CGRectMake(15, 10, 100, 15) andText:@"主播魅力" andColor:[UIColor colorFromHexString:@"333333"] andView:cell];
        xingxiang.textAlignment = NSTextAlignmentLeft;
        xingxiang.font = [UIFont systemFontOfSize:14.0];
        [self configPhotoImageViewWithCell:cell];
        return cell;
    }
    NSArray *leftArray = @[@"城市",@"直播类型",@"所属平台",@"平台房间号",@"主播类型(选填)",@"直播经验(选填)",@"微信",@"期望薪资",@"经纪公司",@"我的特点(选填)"];
    NSArray *rightArray = @[areaString?:@"",typeString?:@"请选择",platformString?:@"请选择",room_numberString?:@"",anchor_typeString?:@"请选择",expString?:@"请选择",wechatString?:@"",wish_salaryString?:@"请选择",brokerage_agencyString?:@"",self_evaluateString?:@"请填写"];
    LiveCreateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LIVECREATA_TABLEVIEW_ID];
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:leftArray[indexPath.row]];
    NSRange range = [leftArray[indexPath.row] rangeOfString:@"(选填)"];
    [attributeStr addAttributes:@{NSForegroundColorAttributeName:[UIColor colorFromHexString:@"ff9102"],NSFontAttributeName:[UIFont systemFontOfSize:12.0]} range:range];
    cell.leftLabel.attributedText = attributeStr;
    cell.rightLabel.text = [NSString stringWithFormat:@"%@",rightArray[indexPath.row]];
    cell.rightTextField.text = [NSString stringWithFormat:@"%@",rightArray[indexPath.row]];
    if (indexPath.row == 0 || indexPath.row == 3 || indexPath.row == 6 || indexPath.row == 8) {
        if (indexPath.row ==0) {
            cell.rightTextField.inputView = self.areaPickerView;
        }
        cell.rightLabel.hidden = YES;
        cell.rightTextField.hidden = NO;
        cell.rightTextField.delegate = self;
        cell.rightTextField.tag = indexPath.row;
        [cell.rightTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    else {
        cell.rightLabel.hidden = NO;
        cell.rightTextField.hidden = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 4 || indexPath.row == 5 || indexPath.row == 7) {
        NSString *title = @"";
        NSArray *dataArray = NSArray.array;
        id object = self.filterArray[indexPath.row];
        if ([object isKindOfClass:NSDictionary.class]) {
            dataArray = [[(NSDictionary *)object allValues] lastObject];
            title = [NSString stringWithFormat:@"请选择%@",[[(NSDictionary *)object allKeys] lastObject]];
        }
        NSInteger selectedNum = 0;
        if (indexPath.row == 1) {
            if (typeString) {
                selectedNum = [dataArray indexOfObject:typeString];
            }
        }
        else if (indexPath.row == 2) {
            if (platformString) {
                selectedNum = [dataArray indexOfObject:platformString];
            }
        }
        else if (indexPath.row == 4) {
            if (anchor_typeString) {
                selectedNum = [dataArray indexOfObject:anchor_typeString];
            }
        }
        else if (indexPath.row == 5) {
            if (expString) {
                selectedNum = [dataArray indexOfObject:expString];
            }
        }
        else if (indexPath.row == 7) {
            if (wish_salaryString) {
                selectedNum = [dataArray indexOfObject:wish_salaryString];
            }
        }
        BottomSelectView *view = [[BottomSelectView alloc]initWithBottomWithTitle:title stringsArray:dataArray selectedNumber:selectedNum];
        view.tag = indexPath.row;
        view.delegate = self;
        [view show];
        [self.view endEditing:YES];
    }
    else if (indexPath.row == 9) {
        LiveCreateMyEvaluateViewController *evaluateCon = [LiveCreateMyEvaluateViewController new];
        evaluateCon.evaluateString = self_evaluateString;
        WEAKSELF
        evaluateCon.editEvaluateBlock = ^(NSString *evaluate) {
            self_evaluateString = evaluate;
            [weakSelf.tableview reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:9 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        };
        [self.navigationController pushViewController:evaluateCon animated:YES];
    }
}

- (void)BottomSelectViewClickedOnCell:(BottomSelectView *)view clickedTag:(NSInteger)tag WithDataArray:(NSArray *)array {
    if (view.tag == 1) {
        typeString = array[tag];
    }
    else if (view.tag == 2) {
        platformString = array[tag];
    }
    else if (view.tag == 4) {
        anchor_typeString = array[tag];
    }
    else if (view.tag == 5) {
        expString = array[tag];
    }
    else if (view.tag == 7) {
        wish_salaryString = array[tag];
    }
    [self.tableview reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:view.tag inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)textFieldDidChange:(UITextField *)textField {
    if (textField.tag == 0) {
        [self selectPickerView:self.areaPickerView];
    }
    else if (textField.tag == 3) {
        room_numberString = textField.text;
    }
    else if (textField.tag == 6) {
        wechatString = textField.text;
    }
    else if (textField.tag == 8) {
        brokerage_agencyString = textField.text;
    }
    [self.tableview reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:textField.tag inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)selectPickerView:(id)pickerView {
    provinceString = [self.provinceArray objectAtIndex:[pickerView selectedRowInComponent:0]];
    cityString = [self.cityArray objectAtIndex:[pickerView selectedRowInComponent:1]];
    areaString = [NSString stringWithFormat:@"%@%@",provinceString,cityString];
}

#pragma mark - pickerView delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return self.provinceArray.count;
    }
    return self.cityArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        return [self.provinceArray objectAtIndex:row];
    }
    return [self.cityArray objectAtIndex:row];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if (component == 0) {
        return 150*ADAPTATIONRATIO;
    }
    return 200*ADAPTATIONRATIO;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        self.selectedArray = [self.pickerDic objectForKey:[self.provinceArray objectAtIndex:row]];
        if (self.selectedArray.count > 0) {
            self.cityArray = [[self.selectedArray objectAtIndex:0] allKeys];
        }
        else {
            self.cityArray = nil;
        }
        [pickerView reloadComponent:1];
        [pickerView selectRow:0 inComponent:1 animated:YES];
    }
}

- (void)configPhotoImageViewWithCell:(UITableViewCell *)cell {
    for (int i = 0; i < self.picArray.count+1; i++) {
        CGFloat perWidth = (SCREEN_WIDTH-30-30)/4;
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(15+(perWidth+10)*(i%4), 25+10+(perWidth+10)*(i/4), perWidth, perWidth)];
        [cell addSubview:imgView];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = imgView.frame;
        [cell addSubview:btn];
        if (i == self.picArray.count) {
            imgView.image = [UIImage imageNamed:@"add_photo"];
            [btn addTarget:self action:@selector(isPhotoFree) forControlEvents:UIControlEventTouchUpInside];
            if (i == MAXPHOTOCOUNT) {
                imgView.hidden = YES;
                btn.hidden = YES;
            }
            else {
                imgView.hidden = NO;
                btn.hidden = NO;
            }
        }
        else {
            // 如果是本地ZLPhotoAssets就从本地取，否则从网络取
            if ([[self.picArray objectAtIndex:i] isKindOfClass:[ZLPhotoAssets class]]
                || [[self.picArray objectAtIndex:i] isKindOfClass:[ZLCamera class]]) {
                imgView.image = [self.picArray[i] thumbImage];
            }else if([[self.picArray objectAtIndex:i] isKindOfClass:[UIImage class]]){
                imgView.image = self.picArray[i];
                
            }else{
                [imgView sd_setImageWithURL:[NSURL URLWithString:self.picArray[i % (self.picArray.count)]] placeholderImage:[UIImage imageNamed:@"ico_tx_s"]];
            }
            btn.tag = i;
            [btn addTarget:self action:@selector(tapBrowser:) forControlEvents:UIControlEventTouchUpInside];
            imgView.hidden = NO;
            btn.hidden = NO;
        }
    }
}

//弹出是否收费的弹框
- (void)isPhotoFree {
    [self.view endEditing:YES];
    LiveCreateFreeView *freeView = [[LiveCreateFreeView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-261)/2, (SCREEN_HEIGHT-375)/2, 261, 375)];
    WEAKSELF
    freeView.confirmSelecrBlock = ^(NSString *money) {
        moneyString = money;
        [weakSelf addPhotoClick];
    };
    [freeView show];
}

#pragma mark - Action Minddle Pic Select
- (void)addPhotoClick {
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:nil
                                                                      message:nil
                                                               preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction * actionReplace = [UIAlertAction actionWithTitle:@"取消"
                                                             style:UIAlertActionStyleCancel
                                                           handler:nil];
    
    UIAlertAction * actionSure = [UIAlertAction actionWithTitle:@"从相册选择"
                                                          style:0
                                                        handler:^(UIAlertAction * action) {
                                                            [self photoFromPhotoLib];
                                                        }];
    UIAlertAction * actionCamera = [UIAlertAction actionWithTitle:@"拍照"
                                                            style:0
                                                          handler:^(UIAlertAction * action) {
                                                              [self cameraBtnClick];
                                                          }];
    [alertVC addAction:actionSure];
    [alertVC addAction:actionCamera];
    [alertVC addAction:actionReplace];
    [self presentViewController:alertVC animated:YES completion:nil];
}
// 相册
- (void)photoFromPhotoLib {
    ZLPhotoPickerViewController *pickerVc = [[ZLPhotoPickerViewController alloc] init];
    pickerVc.maxCount = MAXPHOTOCOUNT - self.picArray.count;
    
    pickerVc.status = PickerViewShowStatusCameraRoll;
    // Recoder Select Assets
    pickerVc.selectPickers = nil;
    // Filter: PickerPhotoStatusAllVideoAndPhotos, PickerPhotoStatusVideos, PickerPhotoStatusPhotos.
    pickerVc.photoStatus = PickerPhotoStatusPhotos;
    // Desc Show Photos, And Suppor Camera
    //    pickerVc.topShowPhotoPicker = YES;
    // CallBack
    WEAKSELF
    pickerVc.callBack = ^(NSArray<ZLPhotoAssets *> *status){
        STRONGSELF
        NSMutableArray *array = [NSMutableArray array];
        for (ZLPhotoAssets *asset in status) {
            UIImage *uploadImage = [strongSelf scaleImage:asset.originImage toScale:.8];
            [array addObject:uploadImage];
        }
        [strongSelf uploadImage:array];
    };
    [pickerVc showPickerVc:self];
}

- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize {
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

//  拍照
- (void)cameraBtnClick {
    __weak typeof(self)weakSelf = self;
    ZLCameraViewController *cameraVC = [[ZLCameraViewController alloc]init];
    cameraVC.maxCount = MAXPHOTOCOUNT - self.picArray.count;
    cameraVC.callback = ^(id img){
        STRONGSELF
        for (ZLCamera *cameraObject in img) {
            UIImage *uploadImage = [strongSelf scaleImage:cameraObject.photoImage toScale:.8];
            [strongSelf uploadImage:@[uploadImage]];
            UIImageWriteToSavedPhotosAlbum(cameraObject.photoImage, strongSelf, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
        }
    };
    [self presentViewController:cameraVC animated:YES completion:nil];
}
- (void)imageSavedToPhotosAlbum:(UIImage *)image
       didFinishSavingWithError:(NSError *)error
                    contextInfo:(void *)contextInfo {
    /*
     NSString *message = @"呵呵";
     if (!error) {
     message = @"成功保存到相册";
     }else
     {
     message = [error description];
     }
     */
}

- (void)tapBrowser:(UIButton *)button {
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:nil
                                                                      message:@"删除该照片" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * actionCancel = [UIAlertAction actionWithTitle:@"取消"
                                                            style:UIAlertActionStyleCancel
                                                          handler:nil];
    
    UIAlertAction * actionConfirm = [UIAlertAction actionWithTitle:@"确定"
                                                             style:0
                                                           handler:^(UIAlertAction * action) {
                                                               LiveCharmPhotoModel *model = [self urlArrayRemoveObjectAtIndex:button.tag];
                                                               if (model.type == 2) {
                                                                   [self deleteLiveCharmRequest:model];
                                                               }
                                                               [self.picArray removeObjectAtIndex:button.tag];
                                                               [self.tableview reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
                                                           }];
    [alertVC addAction:actionCancel];
    [alertVC addAction:actionConfirm];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (LiveCharmPhotoModel *)urlArrayRemoveObjectAtIndex:(NSInteger)index {
    LiveCharmPhotoModel *photoModel = LiveCharmPhotoModel.new;
    for (LiveCharmPhotoModel *model in self.oneArray) {
        if ([model.url isEqualToString:self.picArray[index]]) {
            photoModel = model;
            [self.oneArray removeObject:model];
            break;
        }
    }
    for (LiveCharmPhotoModel *model in self.twoArray) {
        if ([model.url isEqualToString:self.picArray[index]]) {
            photoModel = model;
            [self.twoArray removeObject:model];
            break;
        }
    }
    for (LiveCharmPhotoModel *model in self.threeArray) {
        if ([model.url isEqualToString:self.picArray[index]]) {
            photoModel = model;
            [self.threeArray removeObject:model];
            break;
        }
    }
    for (LiveCharmPhotoModel *model in self.freeArray) {
        if ([model.url isEqualToString:self.picArray[index]]) {
            photoModel = model;
            [self.freeArray removeObject:model];
            break;
        }
    }
    return photoModel;
}

//上传图片
- (void)uploadImage:(NSArray *)imgArray {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    NSDictionary *dic = @{@"token":[DataStore sharedDataStore].token,
                          @"path":@"bgimg"};
    WEAKSELF
    [[NetWorkEngine shareNetWorkEngine] onlyPostImageAryInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@index/upload_image",HttpURLString] Paremeters:dic Image:imgArray ImageName:imgArray successOperation:^(id response) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if ([response[@"errcode"] intValue] == 1) {
            if ([response[@"image"] isKindOfClass:[NSArray class]]) {
                for (NSString *str in response[@"image"]) {
                    LiveCharmPhotoModel *model = LiveCharmPhotoModel.new;
                    model.url = str;
                    model.type = 1;
                    if ([moneyString isEqualToString:@"1元"]) {
                        [weakSelf.oneArray addObject:model];
                    }
                    else if ([moneyString isEqualToString:@"2元"]) {
                        [weakSelf.twoArray addObject:model];
                    }
                    else if ([moneyString isEqualToString:@"3元"]) {
                        [weakSelf.threeArray addObject:model];
                    }
                    else if ([moneyString isEqualToString:@"0元"]) {
                        [weakSelf.freeArray addObject:model];
                    }
                    [weakSelf.picArray addObject:str];
                }
                [weakSelf.tableview reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
        else {
            [SVProgressHUD setDefaultMaskType:1];
            [SVProgressHUD showErrorWithStatus:response[@"message"]];
        }
    } failoperation:^(NSError *error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        [SVProgressHUD showErrorWithStatus:@"网络延迟，请稍后再试"];
    }];
}

- (void)updataCharmImageWithImgArray:(NSMutableArray *)imgArray Fee:(NSString *)fee IsCharge:(NSString *)isCharge {
    NSMutableArray *tempArray = NSMutableArray.array;
    for (LiveCharmPhotoModel *model in imgArray) {
        if (model.type == 1) {
            [tempArray addObject:model.url];
        }
    }
    if (tempArray.count > 0) {
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        [SVProgressHUD show];
        NSMutableDictionary *dic = @{@"token":[DataStore sharedDataStore].token,
                                     @"fee":fee,
                                     @"is_charge":isCharge,
                                     @"img_arr":[tempArray componentsJoinedByString:@"|"],
                                     }.mutableCopy;
        [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@anchor/update_image",HttpURLString] Paremeters:dic successOperation:^(id object) {
            [SVProgressHUD dismiss];
            [SVProgressHUD setDefaultMaskType:1];
            if (isKindOfNSDictionary(object)){
                NSInteger code = [object[@"errcode"] integerValue];
                NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
                NSLog(@"输出 %@--%@",object,msg);
                if (code == 1) {
                    
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
}

//删除主播魅力照片(旧的)
- (void)deleteLiveCharmRequest:(LiveCharmPhotoModel *)model {
    if (model.type == 2) {
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        [SVProgressHUD show];
        NSDictionary *dic = @{@"token":[DataStore sharedDataStore].token,@"id":model.id};
        [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@anchor/del_img",HttpURLString] Paremeters:dic successOperation:^(id object) {
            [SVProgressHUD dismiss];
            [SVProgressHUD setDefaultMaskType:1];
            if (isKindOfNSDictionary(object)){
                NSInteger code = [object[@"errcode"] integerValue];
                NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
                NSLog(@"输出 %@--%@",object,msg);
                if (code == 1) {
                    
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
