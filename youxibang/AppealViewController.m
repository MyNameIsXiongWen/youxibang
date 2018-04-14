//
//  AppealViewController.m
//  youxibang
//
//  Created by 戎博 on 2018/2/19.
//

#import "AppealViewController.h"

@interface AppealViewController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *content;
@property (weak, nonatomic) IBOutlet UITextView *tv;//投诉内容
@property (weak, nonatomic) IBOutlet UILabel *titleLab;

@end

@implementation AppealViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"投诉";
    
    if (self.orderInfo){

        [self.photo sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.orderInfo[@"info"][@"photo"]]] placeholderImage:[UIImage imageNamed:@"ico_head"]];
        self.name.text = [NSString stringWithFormat:@"%@",self.orderInfo[@"info"][@"nickname"]];
        self.content.text = [NSString stringWithFormat:@"%@  ¥%@*%@小时",self.orderInfo[@"gamename"],self.orderInfo[@"perprice"],self.orderInfo[@"hours"]];
        self.titleLab.text = [NSString stringWithFormat:@"为%@打分",self.orderInfo[@"info"][@"nickname"]];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//提交
- (IBAction)commit:(id)sender {

    if ([EBUtility isBlankString:self.tv.text ]){
        [SVProgressHUD showErrorWithStatus:@"描述不能为空"];
        return;
    }
    if ([self.tv.text isEqualToString:@"问题描述"]){
        [SVProgressHUD showErrorWithStatus:@"描述不能为空"];
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    
    [dict setObject:[DataStore sharedDataStore].token forKey:@"token"];
    [dict setObject:self.tv.text forKey:@"desc"];
    [dict setObject:[NSString stringWithFormat:@"%@",self.orderInfo[@"order_sn"]] forKey:@"order_sn"];
    [dict setObject:@"3" forKey:@"type"];
    
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Orders/arbitrorabnor.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
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
        [SVProgressHUD setDefaultMaskType:1];
        [SVProgressHUD showErrorWithStatus:@"网络信号差，请稍后再试"];
    }];
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@"问题描述"]){
        textView.text = @"";
    }
    return YES;
}
-(void)textViewDidEndEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@""]){
        textView.text = @"问题描述";
    }
}
//当用户按下return去键盘

- (BOOL)textViewShouldReturn:(UITextView *)textField
{
    [textField resignFirstResponder];
    
    return YES;
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.tv resignFirstResponder];
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
