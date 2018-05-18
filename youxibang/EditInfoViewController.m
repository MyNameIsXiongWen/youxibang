//
//  EditInfoViewController.m
//  youxibang
//
//  Created by y on 2018/2/3.
//

#import "EditInfoViewController.h"

@interface EditInfoViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *tf;
@property (nonatomic,strong) NSMutableArray* titleAry; 
@property (nonatomic,strong) NSMutableArray* btnAry;
@end

@implementation EditInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.type == 0){
        self.title = @"编辑昵称";
        self.tf.placeholder = @"编辑昵称";
        self.tf.text = UserModel.sharedUser.nickname;
        [self.tf becomeFirstResponder];
    }else if (self.type == 4){
        self.title = @"编辑签名";
        self.tf.placeholder = @"编辑签名";
        self.tf.text = UserModel.sharedUser.mysign;
        [self.tf becomeFirstResponder];
    }else if (self.type == 5){
        self.title = @"兴趣爱好";
        self.tf.hidden = YES;
        self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _titleAry = [NSMutableArray array];
        for (NSMutableDictionary* i in UserModel.sharedUser.interest){
            [_titleAry addObject:[@{@"name":[NSString stringWithFormat:@"%@",i[@"name"]],@"selected":[NSString stringWithFormat:@"%@",i[@"selected"]]} mutableCopy]];
        }
        [_titleAry addObject:@{@"name":@"自定义",@"selected":@"1"}];
        [self initInterestingBtn];
    }
    UIView* rv = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 55, 25)];
    UIButton* btn = [EBUtility greenBtnfrome:CGRectMake(0, 0, 65, 25) andText:@"完成" andColor:[UIColor whiteColor] andimg:nil andView:rv];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [btn setTitleColor:[UIColor colorFromHexString:@"333333"] forState:UIControlStateNormal];
    
    [btn addTarget:self action:@selector(commitInfo:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rv];
}

- (NSMutableArray*)btnAry{
    if (!_btnAry){
        _btnAry = [NSMutableArray array];
    }
    return _btnAry;
}
- (void)initInterestingBtn{
    for (UIView* i in self.view.subviews){
        [i removeFromSuperview];
    }
    [self.btnAry removeAllObjects];
    CGFloat startX = 10;
    CGFloat startY = StatusBarHeight+64;
    CGFloat buttonHeight = 40;
    for(int i = 0; i < self.titleAry.count; i++) {
        UIButton *btn = [[UIButton alloc]init];
        
        btn.backgroundColor = [UIColor whiteColor];
        btn.layer.cornerRadius = 5;
        btn.layer.masksToBounds = 1;
        btn.tag = i;
        [btn setTitle:_titleAry[i][@"name"] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [btn setBackgroundImage:[UIImage imageNamed:@"navi_bg"] forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(selectInterestingBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        [self.btnAry addObject:btn];
        if ([NSString stringWithFormat:@"%@",_titleAry[i][@"selected"]].integerValue == 1){
            btn.selected = 1;
        }
        
        CGSize titleSize = [_titleAry[i][@"name"] sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:btn.titleLabel.font.fontName size:btn.titleLabel.font.pointSize]}];
        titleSize.height = 20;
        titleSize.width += 20;
        
        if(startX + titleSize.width > [UIScreen mainScreen].bounds.size.width){
            startX = 10;
            startY = startY + buttonHeight + 10;
        }
        btn.frame = CGRectMake(startX, startY, titleSize.width, buttonHeight);
        startX = CGRectGetMaxX(btn.frame) + 10;
    }
}
- (void)selectInterestingBtn:(UIButton*)sender{
    if (sender.tag == _titleAry.count - 1){
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"添加标签" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"不超过20字";
        }];
        [alert.textFields[0] addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *content = [alert.textFields[0].text stringByReplacingOccurrencesOfString:@" " withString:@""];
            if (content.length > 20){
                UIButton *btn =UIButton.new;
                btn.tag = _titleAry.count-1;
                [self selectInterestingBtn:btn];
                [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"兴趣爱好不能超过20字符" andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
            }
            else if (content.length == 0) {
                UIButton *btn =UIButton.new;
                btn.tag = _titleAry.count-1;
                [self selectInterestingBtn:btn];
                [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"兴趣爱好不能为空" andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
            }
            else {
                [self.titleAry insertObject:[@{@"name":alert.textFields[0].text,@"selected":@"0"} mutableCopy] atIndex:self.titleAry.count - 1];
                [self initInterestingBtn];
            }
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alert animated:1 completion:nil];
    }else{
        sender.selected = !sender.selected;
        for (NSMutableDictionary* i in self.titleAry){
            if ([[NSString stringWithFormat:@"%@",i[@"name"]] isEqualToString:sender.titleLabel.text]){
                
                [i setObject:[NSString stringWithFormat:@"%d",sender.selected] forKey:@"selected"];
            }
        }
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)commitInfo:(UIButton*)sender{
    NSString* interest = @"";
    if ([self.title isEqualToString:@"兴趣爱好"]){
        for (int i = 0;i < self.btnAry.count - 1; i++){
            UIButton* btn = self.btnAry[i];
            if (btn.selected){
                interest = [NSString stringWithFormat:@"%@##%@",interest,btn.titleLabel.text];
            }
        }
    }else{
        if ([EBUtility isBlankString:self.tf.text]){
            if ([self.title isEqualToString:@"编辑昵称"]) {
                [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"昵称不能为空" andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
                return;
            }
        }
    }
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:UserModel.sharedUser.token forKey:@"token"];//typeid=$类型 （1-头像，2-昵称，3-签名，4-兴趣爱好，5-背景图）
    if ([self.title isEqualToString:@"编辑昵称"]){
        [dict setObject:@"2" forKey:@"typeid"];
        [dict setObject:self.tf.text forKey:@"nickname"];
    }else if ([self.title isEqualToString:@"编辑签名"]){
        [dict setObject:@"3" forKey:@"typeid"];
        [dict setObject:self.tf.text forKey:@"mysign"];
    }else if ([self.title isEqualToString:@"兴趣爱好"]){
        [dict setObject:@"4" forKey:@"typeid"];
        [dict setObject:interest forKey:@"interest"];
    }
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Member/edituserinfo.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            if (code == 1) {
                if ([self.title isEqualToString:@"编辑昵称"]){
                    UserModel.sharedUser.nickname = self.tf.text;
                }else if ([self.title isEqualToString:@"编辑签名"]){
                    UserModel.sharedUser.mysign = self.tf.text;
                }else if ([self.title isEqualToString:@"兴趣爱好"]){
                    NSMutableArray *tempArray = NSMutableArray.array;
                    for (int i = 0;i < self.btnAry.count - 1; i++){
                        UIButton* btn = self.btnAry[i];
                        [tempArray addObject:@{@"name":btn.titleLabel.text,@"selected":@(btn.selected)}];
                    }
                    UserModel.sharedUser.interest = tempArray;
                }
                [SVProgressHUD showSuccessWithStatus:msg];
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [SVProgressHUD showErrorWithStatus:msg];
            }
        }
    } failoperation:^(NSError *error) {
        [SVProgressHUD dismiss];
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络信号差，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
    }];
}

//当用户按下return去键盘
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.tf resignFirstResponder];
}

- (void)textFieldDidChange:(UITextField *)textField {
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]" options:0 error:nil];
    NSString *noEmojiStr = [regularExpression stringByReplacingMatchesInString:textField.text options:0 range:NSMakeRange(0, textField.text.length) withTemplate:@""];
    if (![noEmojiStr isEqualToString:textField.text]) {
        textField.text = noEmojiStr;
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
