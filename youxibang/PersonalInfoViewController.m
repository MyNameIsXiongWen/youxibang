//
//  PersonalInfoViewController.m
//  youxibang
//
//  Created by y on 2018/2/3.
//

#import "PersonalInfoViewController.h"
#import "EditInfoViewController.h"
#import "MineTableViewCell.h"
#import <Colours.h>

#import "ZLPhotoAssets.h"
#import "UIImage+ZLPhotoLib.h"
#import "ZLPhotoPickerBrowserViewController.h"

@interface PersonalInfoViewController ()<EditInfoViewControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate, UIAlertViewDelegate> {
    
}
@property (strong, nonatomic) NSMutableArray *picArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

static NSString *const PERSONAL_TABLEVIEW_IDENTIFIER = @"personal_tableview_identifier";
@implementation PersonalInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"完善信息";
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerNib:[UINib nibWithNibName:@"MineTableViewCell" bundle:nil] forCellReuseIdentifier:PERSONAL_TABLEVIEW_IDENTIFIER];
    self.picArray = [[NSMutableArray alloc] initWithArray:self.dataInfo[@"bgimg"]];
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
            imgView.image = [UIImage imageNamed:@"ico_add1"];
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
    pickerVc.maxCount = 5 - self.picArray.count;
    
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

- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
/**
 *  拍照
 */
-(void)cameraBtnClick
{
    [self.view endEditing:YES];
    // 拍照
    __weak typeof(self)weakSelf = self;
    ZLCameraViewController *cameraVC = [[ZLCameraViewController alloc]init];
    cameraVC.maxCount = 5 - self.picArray.count;
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
                                                            [self.picArray removeObjectAtIndex:button.tag];
                                                            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
                                                            [self uploadBackgroundImage:self.picArray];
                                                        }];
    [alertVC addAction:actionCancel];
    [alertVC addAction:actionConfirm];
    [self presentViewController:alertVC animated:YES completion:nil];
}

//上传图片
- (void)uploadImage:(NSArray *)imgArray {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    NSDictionary *dic = @{@"token":[DataStore sharedDataStore].token,
                          @"path":@"bgimg"};
    WEAKSELF
    [[NetWorkEngine shareNetWorkEngine] onlyPostImageAryInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@index/upload_image",HttpURLString] Paremeters:dic Image:imgArray ImageName:imgArray successOperation:^(id response) {
        if ([response[@"errcode"] intValue] == 1) {
            if ([response[@"image"] isKindOfClass:[NSArray class]]) {
                for (NSString *str in response[@"image"]) {
                    [weakSelf.picArray addObject:str];
                }
                [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
                [self uploadBackgroundImage:weakSelf.picArray];
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

//上传背景图片
- (void)uploadBackgroundImage:(NSMutableArray *)urlArray {
    NSDictionary *dic = @{@"token":[DataStore sharedDataStore].token,
                          @"img_arr":[urlArray componentsJoinedByString:@"|"]};
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@member/update_bimg",HttpURLString] Paremeters:dic successOperation:^(id response) {
        if ([response[@"errcode"] intValue] == 1) {
            [SVProgressHUD dismiss];
            [SVProgressHUD setDefaultMaskType:1];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableViewDelegate/DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 2) {
        return 5;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 215;
    }
    else if (indexPath.section == 1) {
        return ((SCREEN_WIDTH-30-30)/4+10)*(self.picArray.count/4+1) + 10+25;
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell0"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (self.dataInfo){
            UIImageView* img = [cell viewWithTag:1];
            [img sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.dataInfo[@"photo"]]] placeholderImage:[UIImage imageNamed:@"ico_tx_l"]];
            img.width = (SCREEN_WIDTH-40)/2;
        }
        return cell;
    }
    else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bgcell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"bgcell"];
        }
        for (UIView *subView in cell.subviews) {
            [subView removeFromSuperview];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        UILabel *xingxiang = [EBUtility labfrome:CGRectMake(15, 10, 100, 15) andText:@"形象照" andColor:[UIColor colorFromHexString:@"333333"] andView:cell];
        xingxiang.textAlignment = NSTextAlignmentLeft;
        xingxiang.font = [UIFont systemFontOfSize:14.0];
        [self configPhotoImageViewWithCell:cell];
        return cell;
    }
    else {
        NSArray* title = @[@"昵称",@"生日",@"性别",@"签名",@"兴趣爱好"];
        NSArray* img = @[@"ico_nc",@"ico_sr",@"ico_xb",@"ico_qm",@"ico_ah"];
        NSArray* detail = @[self.dataInfo[@"nickname"],self.dataInfo[@"birthday"],self.dataInfo[@"sexstr"],@"",@""];
        MineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PERSONAL_TABLEVIEW_IDENTIFIER];
        cell.leftLabel.text = title[indexPath.row];
        cell.rightLabel.text = detail[indexPath.row];
        cell.iconImageView.image = [UIImage imageNamed:img[indexPath.row]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.row == 1 || indexPath.row == 2){
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView endEditing:1];
    if (indexPath.section == 0){
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [self amendHeadImg:cell];
    }
    else if (indexPath.section == 2) {
        if (indexPath.row == 0 || indexPath.row == 3 || indexPath.row == 4){
            EditInfoViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ei"];
            vc.delegate = self;
            vc.type = indexPath.row;
            vc.dataInfo = [NSMutableDictionary dictionaryWithDictionary:self.dataInfo];
            [self.navigationController pushViewController:vc animated:1];
        }
    }
}

#pragma mark - otherDelegate/DataSource
- (void)editNickName:(NSString *)name{
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    cell.detailTextLabel.text = name;
}

- (void)amendHeadImg:(UITableViewCell *)sender {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *actionPhoto = [UIAlertAction actionWithTitle:@"从相册选择" style:0 handler:^(UIAlertAction * action) {
        [self clickAlertControllerType:0];
    }];
    UIAlertAction *actionCamera = [UIAlertAction actionWithTitle:@"拍照" style:0 handler:^(UIAlertAction * action) {
        [self clickAlertControllerType:1];
    }];
    [alertVC addAction:actionCamera];
    [alertVC addAction:actionPhoto];
    [alertVC addAction:actionCancel];
    alertVC.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:alertVC animated:YES completion:nil];
    UIPopoverPresentationController *popover = alertVC.popoverPresentationController;
    if (popover){
        popover.sourceView = sender;
        popover.sourceRect = sender.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
}
- (void)clickAlertControllerType:(int)type {
    NSUInteger sourceType = 0;
    // 判断是否支持相机
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        switch (type) {
            case 0:
                // 相册
                sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                break;
            case 1:
                // 相机
                sourceType = UIImagePickerControllerSourceTypeCamera;
                break;
            case 2:
                // 取消
                return;
        }
    }
    else {
        if (type == 1) {
            return;
        } else {
            type = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        }
    }
    // 跳转到相机或相册页面
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    imagePickerController.sourceType = sourceType;
    [self presentViewController:imagePickerController animated:YES completion:^{}];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [navigationController.navigationBar setBarStyle:(UIBarStyleBlackTranslucent)];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    [picker dismissViewControllerAnimated:YES completion:^{ }]; //关闭摄像头或用户相册
    
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    NSData *data= UIImageJPEGRepresentation(newImage, 0.1);
    NSString *str = [data base64Encoding];
    //    NSData *data = UIImageJPEGRepresentation(newImage, 1.0f);
    
    NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    dispatch_async(dispatch_get_main_queue(), ^{
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        UIImageView* i = [cell viewWithTag:1];
        [i setImage:newImage]; //设置头像
        [self uploadHeadImage:newImage];
    });
    
}

- (void)uploadHeadImage:(UIImage*)img{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[DataStore sharedDataStore].token forKey:@"token"];//typeid=$类型 （1-头像，2-昵称，3-签名，4-兴趣爱好，5-背景图）
    [dict setObject:@"1" forKey:@"typeid"];
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Member/edituserinfo.html",HttpURLString] Paremeters:dict Image:img ImageName:@"photo" successOperation:^(id response) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(response)) {
            NSInteger msg = [[response objectForKey:@"errcode"] integerValue];
            NSString *str = [response objectForKey:@"message"];
            if (msg == 1) {
                [SVProgressHUD showSuccessWithStatus:str];
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
