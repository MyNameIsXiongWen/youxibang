//
//  EvaluateViewController.m
//  youxibang
//
//  Created by 戎博 on 2018/2/19.
//

#import "EvaluateViewController.h"

@interface EvaluateViewController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *content;
@property (weak, nonatomic) IBOutlet UITextView *tv;//评论内容
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *btnAry;//3种评价的btn Ary
@property (nonatomic,assign)NSInteger evaluate;//评价等级
@property (nonatomic,assign)BOOL anonymousType;//是否匿名
@end

@implementation EvaluateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"评价";
    if (self.orderInfo){//同打赏
        if (self.type == 0){
            [self.photo sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.orderInfo[@"photo"]]] placeholderImage:[UIImage imageNamed:@"ico_head"]];
            self.name.text = [NSString stringWithFormat:@"%@",self.orderInfo[@"nickname"]];
            self.content.text = [NSString stringWithFormat:@"%@  %@*%@小时",self.orderInfo[@"title"],self.orderInfo[@"perprice"],self.orderInfo[@"hours"]];
            self.titleLab.text = [NSString stringWithFormat:@"为%@打分",self.orderInfo[@"nickname"]];
        }else{
            [self.photo sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.orderInfo[@"info"][@"photo"]]] placeholderImage:[UIImage imageNamed:@"ico_head"]];
            self.name.text = [NSString stringWithFormat:@"%@",self.orderInfo[@"info"][@"nickname"]];
            self.content.text = [NSString stringWithFormat:@"%@  ¥%@*%@小时",self.orderInfo[@"gamename"],self.orderInfo[@"perprice"],self.orderInfo[@"hours"]];
            self.titleLab.text = [NSString stringWithFormat:@"为%@打分",self.orderInfo[@"info"][@"nickname"]];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)anonymous:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.anonymousType = sender.selected;
}
- (IBAction)commit:(id)sender {

    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    if ([self.tv.text isEqualToString:@"评价一下达人吧"]){
        self.tv.text = @"";
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setObject:[DataStore sharedDataStore].token forKey:@"token"];
    [dict setObject:[NSString stringWithFormat:@"%@",self.orderInfo[@"order_sn"]] forKey:@"order_sn"];
    [dict setObject:self.tv.text forKey:@"content"];
    [dict setObject:[NSString stringWithFormat:@"%ld",self.evaluate] forKey:@"cmrand"];
    if (self.anonymousType){
        [dict setObject:@"1" forKey:@"anonymous"];
    }else{
        [dict setObject:@"2" forKey:@"anonymous"];
    }

    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Gamebaby/ordcomment.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
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
//选择评价等级
- (IBAction)evaluateBtn:(UIButton *)sender {
    for (UIButton *i in self.btnAry){
        i.selected = NO;
    }
    sender.selected = YES;
    self.evaluate = sender.tag;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@"评价一下达人吧"]){
        textView.text = @"";
    }
    return YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@""]){
        textView.text = @"评价一下达人吧";
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
