//
//  RealNameViewController.m
//  youxibang
//
//  Created by y on 2018/2/3.
//

#import "RealNameViewController.h"
#import "JKCountDownButton.h"

@interface RealNameViewController ()<UITextFieldDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *phone;
@property (weak, nonatomic) IBOutlet UITextField *code;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *idCard;
@property (nonatomic,assign)NSInteger editingphotoNum;
@property (weak, nonatomic) IBOutlet UIView *sucView;
@property (nonatomic,strong)UIImage* photoZ;
@property (weak, nonatomic) IBOutlet JKCountDownButton *codeBtn;
@property (weak, nonatomic) IBOutlet UIView *backgroundContainerView;
@property (nonatomic,strong)UIImage* photoF;
@end

@implementation RealNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"实名认证";
    UserModel *userModel = UserModel.sharedUser;
    if ([NSString stringWithFormat:@"%@",userModel.is_realauth].integerValue == 2){
        self.sucView.hidden = NO;
        UILabel* lab = [self.sucView viewWithTag:1];
        lab.text = [NSString stringWithFormat:@"%@",userModel.is_realauthstr];
    }
//    self.phone.text = UserModel.sharedUser.mobile;
//    self.phone.userInteractionEnabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)getCode:(JKCountDownButton *)sender {
    [self gainCodeRequest:self.phone.text];
}

- (void)gainCodeRequest:(NSString *)phoneString {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:phoneString forKey:@"mobile"];
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Currency/sendsms.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
        
        NSInteger code = [object[@"errcode"] integerValue];
        NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]];
        NSLog(@"验证码输出 %@--%@",object,msg);
        if (code == 1) {
            [SVProgressHUD showSuccessWithStatus:msg];
            self.codeBtn.enabled = NO;
            [self.codeBtn startWithSecond:60];
            
            [self.codeBtn didChange:^NSString *(JKCountDownButton *countDownButton,int second) {
                NSString *title = [NSString stringWithFormat:@"剩余%d秒",second];
                return title;
            }];
            [self.codeBtn didFinished:^NSString *(JKCountDownButton *countDownButton, int second) {
                countDownButton.enabled = YES;
                return @"获取验证码";
            }];
        }else
        {
            [SVProgressHUD showErrorWithStatus:msg];
            
        }
    } failoperation:^(NSError *error) {
        NSLog(@"errr %@",error);
        
    }];
}

- (IBAction)commitInfo:(id)sender {
    if (!self.photoZ){
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"请上传身份证正面" andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
        return;
    }
    if (!self.photoF){
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"请上传身份证反面" andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
        return;
    }
    if ([EBUtility isBlankString:self.name.text]) {
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"姓名不能为空" andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
        return;
    }
    if ([EBUtility isBlankString:self.idCard.text]) {
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"身份证号码不能为空" andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
        return;
    }
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:UserModel.sharedUser.token forKey:@"token"];
    [dict setObject:UserModel.sharedUser.mobile forKey:@"mobile"];
    [dict setObject:self.name.text forKey:@"realname"];
    [dict setObject:self.idCard.text forKey:@"idcard"];
    
    [[NetWorkEngine shareNetWorkEngine] postImageAryInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Member/userrealauth.html",HttpURLString] Paremeters:dict Image:@[self.photoZ,self.photoF] ImageName:@[@"idcardpo",@"idcardop"] successOperation:^(id response) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(response)) {
            NSInteger msg = [[response objectForKey:@"errcode"] integerValue];
            NSString *str = [response objectForKey:@"message"];
            if (msg == 1) {
                [UserNameTool reloadPersonalData:^{
                    self.sucView.hidden = NO;
                }];
            }if (msg == 2) {
                self.sucView.hidden = NO;
            }else{
                [[SYPromptBoxView sharedInstance] setPromptViewMessage:str andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
            }
        }
    } failoperation:^(NSError *error) {
        [SVProgressHUD dismiss];
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络延迟，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
    }];
}
- (IBAction)uploadPhoto:(UIButton *)sender {
    self.editingphotoNum = sender.tag;
    [self amendHeadImg];
}
- (void)amendHeadImg {
    UIAlertController *alertController = [[UIAlertController alloc]init];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"点击取消");
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"点击相册");
        if([UIImagePickerController isSourceTypeAvailable:(UIImagePickerControllerSourceTypePhotoLibrary)]) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.navigationBar.tintColor = self.view.window.tintColor;
            
            [picker setSourceType:(UIImagePickerControllerSourceTypePhotoLibrary)]; //资源类型为图片库
            [picker setAllowsEditing:YES]; //设置选择后的图片可被编辑
            [picker setDelegate:self];
            [self presentViewController:picker animated:YES completion:^{ }];
            
            //                UIImagePickerControllerSourceTypePhotoLibrary,
            //                UIImagePickerControllerSourceTypeCamera,
            //                UIImagePickerControllerSourceTypeSavedPhotosAlbum
        }
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"点击拍照");
        if ([UIImagePickerController isSourceTypeAvailable:(UIImagePickerControllerSourceTypeCamera)]) { //判断是否有摄像头
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            [picker setSourceType:(UIImagePickerControllerSourceTypeCamera)]; //资源类型为照相机
            [picker setAllowsEditing:YES]; //设置拍照后的图片可被编辑
            [picker setDelegate:self];
            [self presentViewController:picker animated:YES completion:^{ }];
        }
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [navigationController.navigationBar setBarStyle:(UIBarStyleBlackTranslucent)];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    [picker dismissViewControllerAnimated:YES completion:^{ }]; //关闭摄像头或用户相册
    
    //DBLOG(@"加载图片中...");
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    if (self.editingphotoNum == 100){
        self.photoZ = newImage;
    }else{
        self.photoF = newImage;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIButton* btn = [self.backgroundContainerView viewWithTag:self.editingphotoNum];
        [btn setImage:newImage forState:0];//设置头像
    });
}

//当用户按下return去键盘

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:1];
    [self.backgroundContainerView endEditing:1];
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
