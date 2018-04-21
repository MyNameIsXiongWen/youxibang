//
//  SupplementInfoViewController.m
//  youxibang
//
//  Created by y on 2018/1/30.
//

#import "SupplementInfoViewController.h"
#import "LoginViewController.h"
#import "TalkingData.h"

@interface SupplementInfoViewController ()<UIImagePickerControllerDelegate,UITextFieldDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *male;
@property (weak, nonatomic) IBOutlet UIButton *female;
@property (weak, nonatomic) IBOutlet UIButton *photo;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (copy,nonatomic)NSString* birthday;
@property (strong,nonatomic)UIImage* photoImg;
@end

@implementation SupplementInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"完善资料";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//选择生日
- (IBAction)selectBrithday:(UIButton *)sender {
    [self.view endEditing:YES];
    CustomAlertView* alert = [[CustomAlertView alloc]initWithType:0];
    alert.resultDate = ^(NSString *date) {
        self.birthday = date;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
        NSDate* d = [dateFormatter dateFromString:date];
        NSCalendar *calendar = [NSCalendar currentCalendar];//当前用户的calendar
        
        NSDateComponents * components = [calendar components: NSCalendarUnitMonth | NSCalendarUnitDay fromDate:d];
        //计算星座
        NSString* constellation = [EBUtility getAstroWithMonth:components.month day:components.day];
        
        [sender setTitle:[NSString stringWithFormat:@"%@ %@座",date,constellation] forState:0];
    };
    [alert showAlertView];
}
//选择性别
- (IBAction)selectSex:(UIButton*)sender {
    if (sender == self.male){
        self.female.selected = NO;
    }else{
        self.male.selected = NO;
    }
    sender.selected = YES;
}
//完成
- (IBAction)finishBtn:(id)sender {
    if ([EBUtility isBlankString:self.name.text]){
        [SVProgressHUD showErrorWithStatus:@"昵称不能为空"];
        return;
    }
    if ([EBUtility isBlankString:self.birthday]){
        [SVProgressHUD showErrorWithStatus:@"生日不能为空"];
        return;
    }
    NSString* sex;
    if (self.male.selected){
        sex = @"1";
    }else{
        sex = @"2";
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:self.phoneNum forKey:@"mobile"];
    [dict setObject:self.password forKey:@"password"];
    [dict setObject:self.password forKey:@"repassword"];
    [dict setObject:self.name.text forKey:@"nickname"];
    [dict setObject:self.birthday forKey:@"birthday"];
    [dict setObject:sex forKey:@"sex"];
    [dict setObject:self.leadercode forKey:@"leadercode"];
    [dict setObject:self.type forKey:@"typeid"];
    if (self.type.integerValue > 1){
        [dict setObject:self.threetoken forKey:@"threetoken"];
    }
    if (self.type.integerValue == 2){
        [dict setObject:self.unionid forKey:@"unionid"];
    }
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];

    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Member/regtwo.html",HttpURLString] Paremeters:dict Image:self.photoImg ImageName:@"photo" successOperation:^(id response) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(response)) {
            NSInteger msg = [[response objectForKey:@"errcode"] integerValue];
            NSString *str = [response objectForKey:@"message"];
            if (msg == 1) {
                [SVProgressHUD showSuccessWithStatus:str];
                if ([self.type isEqualToString: @"2"]){
                    [TalkingData onRegister:self.phoneNum type:TDAccountTypeWeiXin name:self.name.text];
                }else if ([self.type isEqualToString: @"3"]){
                    [TalkingData onRegister:self.phoneNum type:TDAccountTypeQQ name:self.name.text];
                }else{
                    [TalkingData onRegister:self.phoneNum type:TDAccountTypeRegistered name:self.name.text];
                }
                
                LoginViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"loginPWD"];
                vc.phoneNumberString = self.phoneNum;
                vc.passwordString = self.password;
                vc.codeOrPassword = NO;
                [self.navigationController pushViewController:vc animated:1];
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
//选择头像
- (IBAction)selectPhoto:(UIButton *)sender {
    [self amendHeadImg];
}

#pragma mark - delegate
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

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    [picker dismissViewControllerAnimated:YES completion:^{ }]; //关闭摄像头或用户相册
    
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.photo setImage:newImage forState:0]; //设置头像
        self.photoImg = newImage;
    });

}

//当用户按下return去键盘

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
    
}
//开始编辑时 视图上移 如果输入框不被键盘遮挡则不上移。

//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
//
//    CGFloat rects = self.view.frame.size.height - (textField.frame.origin.y + textField.frame.size.height + 216 +50);
//
//    NSLog(@"aa%f",rects);
//
//    if (rects <= 0) {
//
//        [UIView animateWithDuration:0.3 animations:^{
//
//            CGRect frame = self.view.frame;
//
//            frame.origin.y = rects;
//
//            self.view.frame = frame;
//
//        }];
//
//    }
//
//    return YES;
//
//}

//结束编辑时键盘下去 视图下移动画

//-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
//
//    [UIView animateWithDuration:0.3 animations:^{
//
//        CGRect frame = self.view.frame;
//
//        frame.origin.y = 64;
//
//        self.view.frame = frame;
//
//    }];
//
//
//
//    return YES;
//
//}
//空白去键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
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
