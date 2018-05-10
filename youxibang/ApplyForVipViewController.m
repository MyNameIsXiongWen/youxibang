//
//  ApplyForVipViewController.m
//  youxibang
//
//  Created by y on 2018/2/3.
//

#import "ApplyForVipViewController.h"

@interface ApplyForVipViewController ()<UITextFieldDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UIImage* photoZ;
@property (nonatomic,strong)UIImage* photoF;
@property (weak, nonatomic) IBOutlet UIView *sucView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,assign)NSInteger editingphotoNum;
@property (nonatomic,assign)NSInteger qualifications;
@end

@implementation ApplyForVipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"申请加V";
    
    self.tableView.tableFooterView = [UIView new];
    
    UserModel *userModel = UserModel.sharedUser;
    NSString* i = [NSString stringWithFormat:@"%@",userModel.is_vip];
    if ([i isEqualToString:@"2"]){
        self.sucView.hidden = NO;
        UILabel* lab = [self.sucView viewWithTag:1];
        lab.text = [NSString stringWithFormat:@"%@",userModel.is_vipstr];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)commitInfo:(UIButton*)sender{

    NSMutableArray<UITextField*>* ary = [NSMutableArray array];
    for (int i = 1; i < 10; i ++){
        if (i == 4){
            continue;
        }
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        UITextField* tf = [cell viewWithTag:1];
        if ([EBUtility isBlankString:tf.text]){
            [SVProgressHUD showErrorWithStatus:@"内容不能为空"];
            return;
        }
        [ary addObject:tf];
    }
    
    if (!(self.photoZ && self.photoF)){
        [SVProgressHUD showErrorWithStatus:@"请上传证件照"];
    }
//    　　　　realname=$真实姓名
//
//    　　　　idcard=$身份证号码
//
//    　　　　school=$就读学校
//
//    　　　　education=$学历 （此处直接使用字符串：大专、本科）
//
//    　　　　grade=$年级
//
//    　　　　major=$专业
//
//    　　　　alipay=$支付宝账号
//
//    　　　　xuexin=$学信网账号
//
//    　　　　xxpwd=$学信网密码
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[DataStore sharedDataStore].token forKey:@"token"];
    [dict setObject:ary[0].text forKey:@"realname"];
    [dict setObject:ary[1].text forKey:@"idcard"];
    [dict setObject:ary[2].text forKey:@"school"];
    [dict setObject:ary[3].text forKey:@"grade"];
    [dict setObject:ary[4].text forKey:@"major"];
    [dict setObject:ary[5].text forKey:@"alipay"];
    [dict setObject:ary[6].text forKey:@"xuexin"];
    [dict setObject:ary[7].text forKey:@"xxpwd"];
    if (self.qualifications == 0){
        [dict setObject:@"大专" forKey:@"education"];
    }else{
        [dict setObject:@"本科" forKey:@"education"];
    }
    
    [[NetWorkEngine shareNetWorkEngine] postImageAryInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Member/getuservip.html",HttpURLString] Paremeters:dict Image:@[self.photoZ,self.photoF] ImageName:@[@"idcardpo",@"idcardop"] successOperation:^(id response) {
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
                [SVProgressHUD showErrorWithStatus:str];
            }
        }
    } failoperation:^(NSError *error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        [SVProgressHUD showErrorWithStatus:@"网络延迟，请稍后再试"];
    }];
}
- (IBAction)addPhoto:(UIButton *)sender {
    self.editingphotoNum = sender.tag;
    [self amendHeadImg];
}
- (IBAction)select:(UIButton*)sender {
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
    if (sender.tag == 1){

        UIButton* btn = [cell viewWithTag:2];
        btn.selected = NO;
    }else{

        UIButton* btn = [cell viewWithTag:1];
        btn.selected = NO;
    }
    self.qualifications = sender.tag - 1;
    sender.selected = YES;
}
#pragma mark - tableViewDelegate/DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 11;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"cell%ld",(long)indexPath.row]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView endEditing:1];
}

#pragma mark - otherDelegate/DataSource
-(void)amendHeadImg
{
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
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [navigationController.navigationBar setBarStyle:(UIBarStyleBlackTranslucent)];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
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
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        UIButton* btn = [cell viewWithTag:self.editingphotoNum];
        [btn setBackgroundImage:newImage forState:0];
        
    });
    
}

//当用户按下return去键盘

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
//    if ([textField.superview convertRect:textField.frame toView:self.view].origin.y > 300){
//        [UIView animateWithDuration:0.3 animations:^{
//
//            CGRect frame = self.view.frame;
//
//            frame.origin.y = 64;
//
//            self.view.frame = frame;
//
//        }];
//    }
    return YES;
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.tableView endEditing:1];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
//    if ([textField.superview convertRect:textField.frame toView:self.view].origin.y > 300){
//        [UIView animateWithDuration:0.3 animations:^{
//            
//            CGRect frame = self.view.frame;
//            
//            frame.origin.y = - 130;
//            
//            self.view.frame = frame;
//            
//        }];
//    }
    
    return YES;
}

//结束编辑时键盘下去 视图下移动画

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    if ([textField.superview convertRect:textField.frame toView:self.view].origin.y < 300){
        [UIView animateWithDuration:0.3 animations:^{
            
            CGRect frame = self.view.frame;
            
            frame.origin.y = 64;
            
            self.view.frame = frame;
            
        }];
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
