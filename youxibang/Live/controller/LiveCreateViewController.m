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
}

//地区相关
@property (strong, nonatomic) NSDictionary *pickerDic;
@property (strong, nonatomic) NSArray *provinceArray;
@property (strong, nonatomic) NSArray *cityArray;
@property (strong, nonatomic) NSArray *selectedArray;

@property (strong, nonatomic) IBOutlet UIPickerView *areaPickerView;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) NSMutableArray *picArray;
@property (strong, nonatomic) NSArray *filterArray;

@end

@implementation LiveCreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"我是主播";
    [self.tableview registerNib:[UINib nibWithNibName:@"LiveCreateTableViewCell" bundle:nil] forCellReuseIdentifier:LIVECREATA_TABLEVIEW_ID];
    self.tableview.tableFooterView = UIView.new;
    self.picArray = [[NSMutableArray alloc] init];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setTitle:@"保存" forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [rightBtn setTitleColor:[UIColor colorFromHexString:@"437fed"] forState:UIControlStateNormal];
    rightBtn.bounds = CGRectMake(0, 0, 40, 30);
    [rightBtn addTarget:self action:@selector(saveCreate) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    [self getPickerData];
}

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
    NSMutableDictionary *dic = @{@"token":[DataStore sharedDataStore].token
                                 }.mutableCopy;
    if (anchor_typeString) {
        [dic setObject:anchor_typeString forKey:@"anchor_type"];
    }
    if (expString) {
        [dic setObject:expString forKey:@"exp"];
    }
    if (self_evaluateString) {
        [dic setObject:self_evaluateString forKey:@"self_evaluate"];
    }
    [dic setObject:areaString forKey:@"area"];
    if ([typeString isEqualToString:@"全职"]) {
        [dic setObject:@"1" forKey:@"type"];
    }
    else {
        [dic setObject:@"2" forKey:@"type"];
    }
    [dic setObject:platformString forKey:@"platform"];
    [dic setObject:room_numberString forKey:@"room_number"];
    [dic setObject:wechatString forKey:@"wechat"];
    [dic setObject:wish_salaryString forKey:@"wish_salary"];
    [dic setObject:brokerage_agencyString forKey:@"brokerage_agency"];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@anchor/set_anchor",HttpURLString] Paremeters:dic successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (self.picArray.count > 0) {
            WEAKSELF
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf updataCharmImageWithImgArray:self.picArray];
            });
        }
        
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            if (code == 1) {
                [self.navigationController popViewControllerAnimated:YES];
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

- (NSArray *)filterArray {
    if (!_filterArray) {
        _filterArray = @[@"",
                         @{@"直播类型":@[@"兼职",@"全职"]},
                         @{@"所属平台":@[@"花椒",@"映客",@"虎牙",@"斗鱼",@"战旗",@"熊猫",@"YY直播",@"一直播",@"六间房",@"龙珠直播",@"Now直播",@"来疯直播",@"触手直播",@"繁星直播",@"全民直播",@"KK直播",@"Live直播",@"陌陌直播",@"喵播",@"快手",@"其他"]},
                         @"",
                         @{@"主播类型":@[@"电竞",@"电商",@"体育",@"教育",@"游戏",@"户外",@"其他"]},
                         @{@"直播经验":@[@"1年",@"2年",@"3年",@"4年以上"]},
                         @"",
                         @{@"期望薪资":@[@"2000-3000",@"3000-5000",@"5000-7000",@"7000-10000",@"面议"]}];
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
    cell.rightLabel.text = rightArray[indexPath.row];
    cell.rightTextField.text = rightArray[indexPath.row];
    if (indexPath.row == 0 || indexPath.row == 3 || indexPath.row == 6 || indexPath.row == 8) {
        if (indexPath.row ==0) {
            cell.rightTextField.inputView = self.areaPickerView;
        }
        cell.rightLabel.hidden = YES;
        cell.rightTextField.hidden = NO;
        cell.rightTextField.delegate = self;
        cell.rightTextField.tag = indexPath.row;
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

- (void)textFieldDidEndEditing:(UITextField *)textField {
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
            [btn addTarget:self action:@selector(addPhotoClick) forControlEvents:UIControlEventTouchUpInside];
            if (i == 5) {
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
#pragma mark - Action Minddle Pic Select
- (void)addPhotoClick {
    [self.view endEditing:YES];
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
/** 相册 */
- (void)photoFromPhotoLib {
    ZLPhotoPickerViewController *pickerVc = [[ZLPhotoPickerViewController alloc] init];
    pickerVc.maxCount = 16 - self.picArray.count;
    
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
        [strongSelf uploadImage:array ExecuteHandle:NO completeHandler:nil];
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
/**
 *  拍照
 */
- (void)cameraBtnClick {
    [self.view endEditing:YES];
    // 拍照
    __weak typeof(self)weakSelf = self;
    ZLCameraViewController *cameraVC = [[ZLCameraViewController alloc]init];
    cameraVC.maxCount = 16 - self.picArray.count;
    cameraVC.callback = ^(id img){
        STRONGSELF
        for (ZLCamera *cameraObject in img) {
            UIImage *uploadImage = [strongSelf scaleImage:cameraObject.photoImage toScale:.8];
            [strongSelf uploadImage:@[uploadImage] ExecuteHandle:NO completeHandler:nil];
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
                                                               [self.picArray removeObjectAtIndex:button.tag];
                                                               [self.tableview reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
                                                           }];
    [alertVC addAction:actionCancel];
    [alertVC addAction:actionConfirm];
    [self presentViewController:alertVC animated:YES completion:nil];
}

//上传图片
- (void)uploadImage:(NSArray *)imgArray ExecuteHandle:(BOOL)execute completeHandler:(void (^)(NSString *imagePath))handler {
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
                if (execute) {
                    handler(response[@"image"][0]);
                    return;
                }
                for (NSString *str in response[@"image"]) {
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

- (void)updataCharmImageWithImgArray:(NSMutableArray *)imgArray {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    NSMutableDictionary *dic = @{@"token":[DataStore sharedDataStore].token,
                                 @"fee":@"0",
                                 @"is_chang":@"0",
                                 @"img_arr":[imgArray componentsJoinedByString:@"|"],
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
