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

#import <VODUpload/VODUploadSVideoClient.h>
#import <AssetsLibrary/AssetsLibrary.h>

//最大录制视频时间
#define VideoMaximumDuration 10
//最大上传视频大小M
#define VideoMaximumMemory 5
//图片URL路径
#define ImageUrlPath [NSTemporaryDirectory() stringByAppendingString:@"image.png"]

@interface PersonalInfoViewController ()<EditInfoViewControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate, UIAlertViewDelegate, VODUploadSVideoClientDelegate> {
    NSDictionary *tokenDictionary;
    NSString *VideoUploadedPath;
}
@property (strong, nonatomic) NSMutableArray *picArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) VODUploadSVideoClient *client;

@end

static NSString *const PERSONAL_TABLEVIEW_IDENTIFIER = @"personal_tableview_identifier";
@implementation PersonalInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"完善信息";
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerNib:[UINib nibWithNibName:@"MineTableViewCell" bundle:nil] forCellReuseIdentifier:PERSONAL_TABLEVIEW_IDENTIFIER];
    self.picArray = [[NSMutableArray alloc] initWithArray:UserModel.sharedUser.bgimg];
    
    self.client = [[VODUploadSVideoClient alloc] init];
    self.client.delegate = self;
    self.client.transcode = YES;
    [self getVideoUploadToken:NO UploadVideo:NO VideoPath:@"" ImagePath:@"" VideoInfo:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)configPhotoImageViewWithCell:(UITableViewCell *)cell {
    for (int i = 0; i < self.picArray.count+1; i++) {
        CGFloat perWidth = (SCREEN_WIDTH-30-30)/4;
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(15+(perWidth+10)*(i%4), 25+10+(perWidth+10)*(i/4), perWidth, perWidth)];
        [cell addSubview:imgView];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.layer.masksToBounds = YES;
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
        [strongSelf uploadImage:array ExecuteHandle:NO completeHandler:nil];
    };
    [pickerVc showPickerVc:self];
}

- (void)photoBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser photoDidSelectView:(UIView *)scrollBoxView atIndex:(NSInteger)index {
    [self.navigationController popViewControllerAnimated:YES];
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
-(void)cameraBtnClick {
    [self.view endEditing:YES];
    // 拍照
    __weak typeof(self)weakSelf = self;
    ZLCameraViewController *cameraVC = [[ZLCameraViewController alloc]init];
    cameraVC.maxCount = 5 - self.picArray.count;
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
                                                            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
                                                            [self uploadBackgroundImage:self.picArray];
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
        if ([response[@"errcode"] intValue] == 1) {
            if ([response[@"image"] isKindOfClass:[NSArray class]]) {
                if (execute) {
                    handler(response[@"image"][0]);
                    return;
                }
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
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络延迟，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
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
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络延迟，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
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
        return 6;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 50+(SCREEN_WIDTH-45)/2;
    }
    else if (indexPath.section == 1) {
        return ((SCREEN_WIDTH-30-30)/4+10)*(self.picArray.count/4+1) + 10+25;
    }
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 2) {
        return 15;
    }
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell0"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImageView *photoImg = [cell viewWithTag:1];
        photoImg.layer.masksToBounds = YES;
        UIImageView *videoImg = [cell viewWithTag:3];
        videoImg.layer.masksToBounds = YES;
        [photoImg sd_setImageWithURL:[NSURL URLWithString:UserModel.sharedUser.photo] placeholderImage:[UIImage imageNamed:@"ico_tx_l"]];
        [videoImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",UserModel.sharedUser.video_img]] placeholderImage:[UIImage imageNamed:@"add_video"]];
        UITapGestureRecognizer *photoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImageView:)];
        UITapGestureRecognizer *videoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImageView:)];
//        photoImg.userInteractionEnabled = YES;
        [photoImg addGestureRecognizer:photoTap];
//        videoImg.userInteractionEnabled = YES;
        [videoImg addGestureRecognizer:videoTap];
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *xingxiang = [EBUtility labfrome:CGRectMake(15, 10, 100, 15) andText:@"形象照" andColor:[UIColor colorFromHexString:@"333333"] andView:cell];
        xingxiang.textAlignment = NSTextAlignmentLeft;
        xingxiang.font = [UIFont systemFontOfSize:14.0];
        [self configPhotoImageViewWithCell:cell];
        return cell;
    }
    else {
        NSString *interest = @"";
        NSMutableArray *temp = NSMutableArray.array;
        for (int i = 0;i < UserModel.sharedUser.interest.count; i++){
            NSDictionary* dic = UserModel.sharedUser.interest[i];
            if ([dic[@"selected"] integerValue] == 1){
                [temp addObject:dic[@"name"]];
            }
        }
        interest = [temp componentsJoinedByString:@","];
        NSArray* title = @[@"昵称",@"ID",@"生日",@"性别",@"签名",@"兴趣爱好"];
        NSArray* img = @[@"ico_nc",@"ico_id",@"ico_sr",@"ico_xb",@"ico_qm",@"ico_ah"];
        NSArray* detail = @[UserModel.sharedUser.nickname?:@"",DataStore.sharedDataStore.userid?:@"",UserModel.sharedUser.birthday?:@"",UserModel.sharedUser.sexstr?:@"",UserModel.sharedUser.mysign?:@"",interest];
        MineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PERSONAL_TABLEVIEW_IDENTIFIER];
        cell.leftLabel.text = title[indexPath.row];
        cell.rightLabel.text = detail[indexPath.row];
        cell.iconImageView.image = [UIImage imageNamed:img[indexPath.row]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3){
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.rightLabelTrailingConstraint.constant = 15;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.rightLabelTrailingConstraint.constant = 7;
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView endEditing:1];
    if (indexPath.section == 2) {
        if (indexPath.row == 0 || indexPath.row == 4 || indexPath.row == 5){
            EditInfoViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ei"];
            vc.delegate = self;
            vc.type = indexPath.row;
            [self.navigationController pushViewController:vc animated:1];
        }
    }
}

- (void)clickImageView:(UITapGestureRecognizer *)tap {
    UIImageView *imgView = (UIImageView *)tap.view;
    [self amendHeadImg:imgView];
}

#pragma mark - otherDelegate/DataSource
- (void)editNickName:(NSString *)name{
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    cell.detailTextLabel.text = name;
}

- (void)amendHeadImg:(UIImageView *)sender {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    NSString *libraryDes = @"";
    NSString *cameraDes = @"";
    if (sender.tag == 1) {
        libraryDes = @"从相册选择";
        cameraDes = @"拍照";
    }
    else if (sender.tag == 3) {
        libraryDes = @"从视频库选择";
        cameraDes = @"视频拍摄";
    }
    UIAlertAction *actionPhoto = [UIAlertAction actionWithTitle:libraryDes style:0 handler:^(UIAlertAction * action) {
        if (sender.tag == 1) {
            [self clickAlertControllerType:0];
        }
        else if (sender.tag == 3) {
            [self clickAlertControllerType:3];
        }
    }];
    UIAlertAction *actionCamera = [UIAlertAction actionWithTitle:cameraDes style:0 handler:^(UIAlertAction * action) {
        if (sender.tag == 1) {
            [self clickAlertControllerType:1];
        }
        else if (sender.tag == 3) {
            [self clickAlertControllerType:2];
        }
    }];
    [alertVC addAction:actionCamera];
    [alertVC addAction:actionPhoto];
    [alertVC addAction:actionCancel];
    alertVC.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:alertVC animated:YES completion:nil];
//    UIPopoverPresentationController *popover = alertVC.popoverPresentationController;
//    if (popover){
//        popover.sourceView = sender.superview;
//        popover.sourceRect = sender.superview.bounds;
//        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
//    }
}
- (void)clickAlertControllerType:(int)type {
    NSUInteger sourceType = 0;
    // 判断是否支持相机
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        if (type == 0 || type == 3) {
            sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        else if (type == 1 || type == 2) {
            sourceType = UIImagePickerControllerSourceTypeCamera;
        }
    }
    else {
        if (type == 1 || type == 2) {
            return;
        } else {
            sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        }
    }
    // 跳转到相机或相册页面
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    imagePickerController.sourceType = sourceType;
    if (type == 2 || type == 3) {
        NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        if ([availableMediaTypes containsObject:(NSString *)kUTTypeMovie]) {
        }
        imagePickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
        imagePickerController.mediaTypes = @[(NSString *)kUTTypeMovie];
        imagePickerController.videoMaximumDuration = VideoMaximumDuration;
    }
    [self presentViewController:imagePickerController animated:YES completion:^{}];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [navigationController.navigationBar setBarStyle:(UIBarStyleBlackTranslucent)];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    //获取用户选择或拍摄的是照片还是视频
    NSURL *videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        UIImageView* i = [cell viewWithTag:3];
        UIImage *preimage = [self getVideoPreViewImageWithPath:videoUrl];
        [i setImage:preimage];
        NSData *imageData = UIImagePNGRepresentation(preimage);
        [imageData writeToFile:ImageUrlPath atomically:YES];
        NSURL *newImageUrl = [NSURL fileURLWithPath:ImageUrlPath];
        NSFileManager *filemanager = [NSFileManager defaultManager];
        NSString *imagePath = newImageUrl.path;
        if ([filemanager fileExistsAtPath:newImageUrl.path]) {
            imagePath = newImageUrl.path;
        }
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoUrl.path)) {
                UISaveVideoAtPathToSavedPhotosAlbum(videoUrl.path, self, @selector(video:didFinishSavingWithError:contextInfo:), NULL);
            }
        }
//        生成视频名称
        NSString *title = [self getVideoTitleBaseCurrentTime];
        NSURL *newVideoUrl = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:title]];
        WEAKSELF
        [self convertVideoQuailtyWithInputURL:videoUrl outputURL:newVideoUrl completeHandler:nil pathBlock:^(NSString *videoPath) {
            VodSVideoInfo *info = [[VodSVideoInfo alloc] init];
            info.title = title;
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
            [SVProgressHUD show];
            if (tokenDictionary) {
                [weakSelf.client uploadWithVideoPath:videoPath imagePath:imagePath svideoInfo:info accessKeyId:tokenDictionary[@"data"][@"Credentials"][@"AccessKeyId"] accessKeySecret:tokenDictionary[@"data"][@"Credentials"][@"AccessKeySecret"] accessToken:tokenDictionary[@"data"][@"Credentials"][@"SecurityToken"]];
            }
            else {
                [self getVideoUploadToken:NO UploadVideo:YES VideoPath:videoPath ImagePath:imagePath VideoInfo:info];
            }
        }];
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *tempImage = info[UIImagePickerControllerEditedImage];
        UIGraphicsBeginImageContext(tempImage.size);
        [tempImage drawInRect:CGRectMake(0,0,tempImage.size.width,tempImage.size.height)];
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            UIImageView* i = [cell viewWithTag:1];
            [i setImage:newImage]; //设置头像
            [self uploadHeadImage:newImage];
        });
    }
}

// 视频保存回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo {
    NSLog(@"%@",videoPath);
    NSLog(@"%@",error);
}

//以当前时间合成视频名称
- (NSString *)getVideoNameBaseCurrentTime {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH-mm-ss"];
    return [[dateFormatter stringFromDate:[NSDate date]] stringByAppendingString:@".MOV"];
}
//以当前时间合成视频名称
- (NSString *)getVideoTitleBaseCurrentTime {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    return [[dateFormatter stringFromDate:[NSDate date]] stringByAppendingString:@".mp4"];
}

//上传视频
- (void)postVideoWithPath:(NSString *)videopath Name:(NSString *)videoName {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    NSDictionary *dict = @{@"token":[DataStore sharedDataStore].token};
    [[NetWorkEngine shareNetWorkEngine] postVideoFromServerWithUrlStr:[NSString stringWithFormat:@"%@index/upload_video",HttpURLString] Paremeters:dict VideoPath:videopath VideoName:videoName successOperation:^(id response) {
        if (isKindOfNSDictionary(response)) {
            NSInteger msg = [[response objectForKey:@"errcode"] integerValue];
            NSString *str = [response objectForKey:@"message"];
            if (msg == 1) {
                [self uploadVideoWithPath:[response objectForKey:@"video"] VideoImg:@""];
            }else{
                [SVProgressHUD showErrorWithStatus:str];
            }
        }
    } failoperation:^(NSError *error) {
        [SVProgressHUD dismiss];
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络延迟，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
    }];
}
//上传视频地址
- (void)uploadVideoWithPath:(NSString *)videopath VideoImg:(NSString *)videoImg {
    NSDictionary *dict = @{@"token":[DataStore sharedDataStore].token,
                           @"video":videopath,
                           @"video_img":videoImg};
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@member/update_video",HttpURLString] Paremeters:dict successOperation:^(id response) {
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
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络延迟，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
    }];
}

- (void)getVideoUploadToken:(BOOL)uploadToken UploadVideo:(BOOL)uploadVideo VideoPath:(NSString *)videoPath ImagePath:(NSString *)imagePath VideoInfo:(VodSVideoInfo *)info {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[DataStore sharedDataStore].token forKey:@"token"];
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@video/get_token",HttpURLString] Paremeters:dict successOperation:^(id response) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(response)) {
            NSInteger msg = [[response objectForKey:@"errcode"] integerValue];
            NSString *str = [response objectForKey:@"message"];
            if (msg == 1) {
                tokenDictionary = (NSDictionary *)response;
                if (uploadToken) {
                    [self.client refreshWithAccessKeyId:tokenDictionary[@"data"][@"Credentials"][@"AccessKeyId"] accessKeySecret:tokenDictionary[@"data"][@"Credentials"][@"AccessKeySecret"] accessToken:tokenDictionary[@"data"][@"Credentials"][@"SecurityToken"] expireTime:tokenDictionary[@"data"][@"Credentials"][@"Expiration"]];
                }
                if (uploadVideo) {
                    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
                    [SVProgressHUD show];
                    [self.client uploadWithVideoPath:videoPath imagePath:imagePath svideoInfo:info accessKeyId:tokenDictionary[@"data"][@"Credentials"][@"AccessKeyId"] accessKeySecret:tokenDictionary[@"data"][@"Credentials"][@"AccessKeySecret"] accessToken:tokenDictionary[@"data"][@"Credentials"][@"SecurityToken"]];
                }
            }else{
                [SVProgressHUD showErrorWithStatus:str];
            }
        }
    } failoperation:^(NSError *error) {
    }];
}

- (void)uploadSuccessWithVid:(NSString *)vid imageUrl:(NSString *)imageUrl {
    NSLog(@"%@-------%@",vid,imageUrl);
    [self uploadVideoWithPath:vid VideoImg:imageUrl];
    NSFileManager *filemanager = [NSFileManager defaultManager];
    if ([filemanager fileExistsAtPath:ImageUrlPath]) {
        [filemanager removeItemAtPath:ImageUrlPath error:nil];
    }
}

- (void)uploadFailedWithCode:(NSString *)code message:(NSString *)message {
    NSLog(@"%@-------%@",code,message);
    [SVProgressHUD dismiss];
    [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"上传失败" andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
}

- (void)uploadProgressWithUploadedSize:(long long)uploadedSize totalSize:(long long)totalSize {
    NSLog(@"%lld-------%lld",uploadedSize,totalSize);
}

- (void)uploadTokenExpired {
    [self getVideoUploadToken:YES UploadVideo:NO VideoPath:@"" ImagePath:@"" VideoInfo:nil];
}

- (void)uploadRetry {
    
}

- (void)uploadRetryResume {
    
}

//获取视频的第一帧截图, 返回UIImage
//需要导入AVFoundation.h
- (UIImage*)getVideoPreViewImageWithPath:(NSURL *)videoPath {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoPath options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *img = [[UIImage alloc] initWithCGImage:image];
    return img;
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
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络延迟，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
    }];
}

- (void)convertVideoQuailtyWithInputURL:(NSURL*)inputURL
                              outputURL:(NSURL*)outputURL
                        completeHandler:(void (^)(AVAssetExportSession*))handler
                              pathBlock:(void (^)(NSString *videoPath))path {
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.shouldOptimizeForNetworkUse = YES;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void) {
         switch (exportSession.status) {
             case AVAssetExportSessionStatusCancelled:
                 NSLog(@"AVAssetExportSessionStatusCancelled");
                 break;
             case AVAssetExportSessionStatusUnknown:
                 NSLog(@"AVAssetExportSessionStatusUnknown");
                 break;
             case AVAssetExportSessionStatusWaiting:
                 NSLog(@"AVAssetExportSessionStatusWaiting");
                 break;
             case AVAssetExportSessionStatusExporting:
                 NSLog(@"AVAssetExportSessionStatusExporting");
                 break;
             case AVAssetExportSessionStatusCompleted:
             {
                 NSLog(@"AVAssetExportSessionStatusCompleted");
                 NSLog(@"%@",[NSString stringWithFormat:@"%f s", [self getVideoLength:outputURL]]);
                 NSLog(@"%@", [NSString stringWithFormat:@"%.2f MB", [self getFileSize:[outputURL path]]]);
                 dispatch_sync(dispatch_get_main_queue(), ^{
                     if ([self getFileSize:[outputURL path]] > VideoMaximumMemory) {
                         UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"视频大小不能超过%dMB,请重新选择或拍摄",VideoMaximumMemory] preferredStyle:UIAlertControllerStyleAlert];
                         [alertController addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                             return;
                         }]];
                         [self presentViewController:alertController animated:YES completion:nil];
                     }else {
                         path(outputURL.path);
                     }
                 });
             }
                 break;
             case AVAssetExportSessionStatusFailed:
                 NSLog(@"AVAssetExportSessionStatusFailed");
                 break;
         }
     }];
}
//获取文件的大小,单位KB。
- (CGFloat)getFileSize:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    float filesize = - 1.0;
    if ([fileManager fileExistsAtPath:path]) {
        //获取文件的属性
        NSDictionary *fileDic = [fileManager attributesOfItemAtPath:path error:nil];
        unsigned long long size = [[fileDic objectForKey:NSFileSize] longLongValue];
        filesize = 1.0 * size / 1024 / 1024;
        
    }else {
        NSLog(@"文件不存在");
    }
    return filesize;
}
//获取视频文件的时长
- (CGFloat)getVideoLength:(NSURL *)URL {
    AVURLAsset *avUrl = [AVURLAsset assetWithURL:URL];
    CMTime time = [avUrl duration];
    int second = ceil(time.value/time.timescale);
    return second;
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
