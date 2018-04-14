//
//  ApplyAdvanceViewController.m
//  youxibang
//
//  Created by y on 2018/3/29.
//

#import "ApplyAdvanceViewController.h"

@interface ApplyAdvanceViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) UIButton* selectImage;
@property (strong,nonatomic) UIImage* IDcardZheng;
@property (strong,nonatomic) UIImage* IDcardFan;
@property (strong,nonatomic) UIImage* zhimaxinyong;
@property (strong, nonatomic) NSMutableArray *moneyAry;
@property (strong, nonatomic) NSMutableArray *operatorAry;
@property (assign, nonatomic) NSInteger operator;
@property (weak, nonatomic) IBOutlet UIView *sucView;
@property (strong,nonatomic) NSMutableDictionary* dataInfo;
@end

@implementation ApplyAdvanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"预支工资申请";
    
    self.operator = 1;
    //增加监听，当键盘出现或改变时
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    //增加监听，当键退出时
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    UIImageView* img = [[UIImageView alloc]initWithFrame:CGRectMake(0, 10, 10, 20)];
    img.image = [UIImage imageNamed:@"back"];
    UIButton *leftBtn = [[UIButton alloc]initWithFrame:CGRectMake(-15, 0, 40, 40)];
    [leftBtn addSubview:img];
    [leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    
    [self downloadInfo];
}
- (void)back{
    
    if (self.sucView.hidden){
        [self.navigationController popViewControllerAnimated:1];
    }else{
        [self.navigationController popToRootViewControllerAnimated:1];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)downloadInfo{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[DataStore sharedDataStore].token forKey:@"token"];
    
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Member/realdetail.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            
            if (code == 1) {
                self.dataInfo = [NSMutableDictionary dictionaryWithDictionary:object[@"data"]];
                [self.tableView reloadData];
            }
        }
        
    } failoperation:^(NSError *error) {
        
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];

    }];
}
- (void)commit:(UIButton*)sender{
    [self.tableView endEditing:1];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    
    [self.dic setObject:@"1" forKey:@"beyond"];
    
    //    　　　　account=$金额
    UITextField* account = [self.tableView viewWithTag:10];
    [self.dic setObject:account.text forKey:@"account"];
//    　　　　realname=$真实姓名
    [self.dic setObject:[NSString stringWithFormat:@"%@",_dataInfo[@"realname"]] forKey:@"realname"];
//    　　　　idcard=$身份证号码
    [self.dic setObject:[NSString stringWithFormat:@"%@",_dataInfo[@"idcard"]] forKey:@"idcard"];
//    　　　　alipay=$支付宝账号
    [self.dic setObject:[NSString stringWithFormat:@"%@",_dataInfo[@"alipay"]] forKey:@"alipay"];
//    　　　　qq=$QQ号码
    UITextField* qq = [self.tableView viewWithTag:22];
    if ([EBUtility isBlankString:qq.text]){
        [SVProgressHUD showErrorWithStatus:@"qq为空"];
        return;
    }else{
        [self.dic setObject:qq.text forKey:@"qq"];
    }
//    　　　　mobile=$手机号码
    [self.dic setObject:[NSString stringWithFormat:@"%@",_dataInfo[@"mobile"]] forKey:@"mobile"];
//    　　　　mobilepwd=$运营商服务密码
    UITextField* mobilepwd = [self.tableView viewWithTag:42];
    if ([EBUtility isBlankString:mobilepwd.text]){
        [SVProgressHUD showErrorWithStatus:@"运营商服务密码为空"];
        return;
    }else{
        [self.dic setObject:mobilepwd.text forKey:@"mobilepwd"];
    }
//    　　　　operator=$运营商 （1-移动，2-联通，3-电信）
    [self.dic setObject:[NSString stringWithFormat:@"%ld",self.operator] forKey:@"operator"];

//    　　　　contacts1=$联系人1姓名
    UITextField* contacts1 = [self.tableView viewWithTag:60];
    if ([EBUtility isBlankString:contacts1.text]){
        [SVProgressHUD showErrorWithStatus:@"联系人1姓名为空"];
        return;
    }else{
        [self.dic setObject:contacts1.text forKey:@"contacts1"];
    }
//    　　　　contactstel1=$联系人1电话
    UITextField* contactstel1 = [self.tableView viewWithTag:61];
    if ([EBUtility isBlankString:contactstel1.text]){
        [SVProgressHUD showErrorWithStatus:@"联系人1电话为空"];
        return;
    }else{
        [self.dic setObject:contactstel1.text forKey:@"contactstel1"];
    }
//    　　　　relation1=$联系人1与用户的关系
    UITextField* relation1 = [self.tableView viewWithTag:62];
    if ([EBUtility isBlankString:relation1.text]){
        [SVProgressHUD showErrorWithStatus:@"联系人1与用户的关系"];
        return;
    }else{
        [self.dic setObject:relation1.text forKey:@"relation1"];
    }
    //    　　　　contacts2=$联系人2姓名
    UITextField* contacts2 = [self.tableView viewWithTag:63];
    if ([EBUtility isBlankString:contacts2.text]){
        [SVProgressHUD showErrorWithStatus:@"联系人2姓名为空"];
        return;
    }else{
        [self.dic setObject:contacts2.text forKey:@"contacts2"];
    }
    //    　　　　contactstel2=$联系人2电话
    UITextField* contactstel2 = [self.tableView viewWithTag:64];
    if ([EBUtility isBlankString:contactstel2.text]){
        [SVProgressHUD showErrorWithStatus:@"联系人2电话为空"];
        return;
    }else{
        [self.dic setObject:contactstel2.text forKey:@"contactstel2"];
    }
    //    　　　　relation2=$联系人2与用户的关系
    UITextField* relation2 = [self.tableView viewWithTag:65];
    if ([EBUtility isBlankString:relation2.text]){
        [SVProgressHUD showErrorWithStatus:@"联系人2与用户的关系"];
        return;
    }else{
        [self.dic setObject:relation2.text forKey:@"relation2"];
    }
    
    if (!self.IDcardFan){
        [SVProgressHUD showErrorWithStatus:@"未上传身份证反面"];
        return;
    }
    if (!self.IDcardZheng){
        [SVProgressHUD showErrorWithStatus:@"未上传身份证正面"];
        return;
    }
    if (!self.zhimaxinyong){
        [SVProgressHUD showErrorWithStatus:@"未上传芝麻信用截图"];
        return;
    }

    [[NetWorkEngine shareNetWorkEngine] postImageAryInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Member/withdrawalsu.html",HttpURLString] Paremeters:self.dic Image:@[self.IDcardZheng,self.IDcardFan,self.zhimaxinyong] ImageName:@[@"idcardpo",@"idcardop",@"zmxyimg"] successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            
            if (code == 1) {
                [SVProgressHUD showSuccessWithStatus:msg];
                self.sucView.hidden = NO;
                
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
- (IBAction)addImage:(UIButton *)sender {
    [self.tableView endEditing:1];
    self.selectImage = sender;
    [self amendHeadImg];
}

- (void)selectMoney:(UIButton*)sender{
    [self.tableView endEditing:1];
    for (UIButton* i in self.moneyAry){
        i.selected = NO;
    }
    sender.selected = YES;
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    UITextField* tf = [cell viewWithTag:10];
    tf.text = [NSString stringWithFormat:@"%ld",sender.tag];
}
- (void)selectOperator:(UIButton*)sender{
    [self.tableView endEditing:1];
    for (UIButton* i in self.operatorAry){
        i.selected = NO;
    }
    sender.selected = YES;
    self.operator = sender.tag;
}
//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect frame = self.view.frame;
        
        frame.origin.y = - height + 64;
        
        self.view.frame = frame;
        
    }];
}

//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification{
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect frame = self.view.frame;
        
        frame.origin.y = 64;
        
        self.view.frame = frame;
        
    }];
}

#pragma mark - tableViewDelegate/DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 8;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 2){
        return 5;
    }else if (section == 4){
        return 3;
    }else if (section == 6){
        return 6;
    }else if (section == 7){
        return 0;
    }
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0 || section == 7){
        return 0;
    }
    return 30;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView* hv = [EBUtility viewfrome:CGRectMake(0, 0, SCREEN_WIDTH, 30) andColor:[UIColor clearColor] andView:nil];
    UILabel* lab = [EBUtility labfrome:CGRectMake(15, 12.5, SCREEN_WIDTH, 15) andText:@"" andColor:Nav_color andView:hv];
    lab.textAlignment = 0;
    switch (section) {
        case 1:
            lab.text = @"您的要求是预发：";
            break;
        case 2:
            lab.text = @"请详细填写一下您的资料：";
            break;
        case 3:
            lab.text = @"身份证正反面上传：";
            break;
        case 4:
            lab.text = @"运营商信息：";
            break;
        case 5:
            lab.text = @"个人芝麻信用积分截图：";
            break;
        case 6:
            lab.text = @"紧急联系人（2人）：";
            break;
        default:
            break;
    }
    return hv;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 7) {
        return 75;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView* fv = [EBUtility viewfrome:CGRectMake(0, 0, SCREEN_WIDTH, 75) andColor:[UIColor clearColor] andView:nil];
    UIButton* commit = [EBUtility btnfrome:CGRectMake(12, 15, 350, 40) andText:@"提交申请" andColor:[UIColor whiteColor] andimg:nil andView:fv];
    commit.layer.masksToBounds = YES;
    commit.layer.cornerRadius = 10;
    [commit setBackgroundColor:Nav_color];
    [commit addTarget:self action:@selector(commit:) forControlEvents:UIControlEventTouchUpInside];
    return fv;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"cell%ld%ld",indexPath.section,indexPath.row]];
    
    if (indexPath.section == 1 && indexPath.row == 0){
        if (!self.moneyAry){
            self.moneyAry = [NSMutableArray array];
            for (int i = 1; i < 11; i++){
                UIButton* btn = [cell viewWithTag:i*1000];
                [self.moneyAry addObject:btn];
                [btn addTarget:self action:@selector(selectMoney:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        UITextField* account = [cell viewWithTag:10];
        account.text = self.dic[@"account"];
    }else if (indexPath.section == 4 && indexPath.row == 0){
        if (!self.operatorAry){
            self.operatorAry = [NSMutableArray array];
            for (int i = 1; i < 4; i++){
                UIButton* btn = [cell viewWithTag:i];
                [self.operatorAry addObject:btn];
                [btn addTarget:self action:@selector(selectOperator:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
    if (self.dataInfo){
        if (indexPath.section == 2){
            if (indexPath.row == 0){
                UITextField* name = [cell viewWithTag:20];
                name.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"realname"]];
                name.userInteractionEnabled = NO;
            }else if (indexPath.row == 1){
                UITextField* idcard = [cell viewWithTag:21];
                idcard.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"idcard"]];
                idcard.userInteractionEnabled = NO;
            }else if (indexPath.row == 3){
                UITextField* alipay = [cell viewWithTag:23];
                alipay.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"alipay"]];
                alipay.userInteractionEnabled = NO;
            }
        }else if (indexPath.section == 4){
            if (indexPath.row == 1){
                UITextField* mobile = [cell viewWithTag:41];
                mobile.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"mobile"]];
                mobile.userInteractionEnabled = NO;
            }
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView endEditing:1];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView)
    {
        CGFloat sectionHeaderHeight = 30;
        if (scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0) {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        } else if (scrollView.contentOffset.y >= sectionHeaderHeight) {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
    }
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

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    [picker dismissViewControllerAnimated:YES completion:^{ }]; //关闭摄像头或用户相册
    //DBLOG(@"加载图片中...");
    
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *data= UIImageJPEGRepresentation(newImage, 0.1);
    UIImage* img = [UIImage imageWithData:data];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.selectImage setImage:newImage forState:UIControlStateNormal];
        switch (self.selectImage.tag) {
            case 101:
                self.IDcardZheng = img;
                break;
            case 102:
                self.IDcardFan = img;
                break;
            case 103:
                self.zhimaxinyong = img;
                break;
            default:
                break;
        }
        self.selectImage = nil;
    });
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
    
}
//当用户按下return去键盘
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]){
        [textView  resignFirstResponder];
        return NO;
        
    }
    
    return YES;
    
}
-(BOOL)textFieldShouldBeginEditing:(UITextView *)textField{
    if (textField.tag == 10){
        for (UIButton* i in self.moneyAry){
            i.selected = NO;
        }
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
