//
//  LoanDelegateViewController.m
//  youxibang
//
//  Created by y on 2018/2/1.
//

#import "LoanDelegateViewController.h"
#import "ApplyAdvanceViewController.h"

@interface LoanDelegateViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *confrimBtn;
@property (weak, nonatomic) IBOutlet UIView *sucView;

@end

@implementation LoanDelegateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlStr]]];
    self.sucView.hidden = NO;
    if (self.dic){
        self.sucView.hidden = YES;
    }
    self.title = @"协议";
    
    UIImageView* img = [[UIImageView alloc]initWithFrame:CGRectMake(0, 10, 10, 20)];
    img.image = [UIImage imageNamed:@"back_black"];
    UIButton *leftBtn = [[UIButton alloc]initWithFrame:CGRectMake(-15, 0, 40, 40)];
    [leftBtn addSubview:img];
    [leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
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
- (IBAction)con:(UIButton *)sender {
    self.confrimBtn.selected = !self.confrimBtn.selected;
}
- (IBAction)commitBtn:(UIButton *)sender {
    if (!self.confrimBtn.selected){
        [SVProgressHUD showInfoWithStatus:@"请同意此协议"];
        return;
    }
    ApplyAdvanceViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"aavc"];
    vc.dic = [NSMutableDictionary dictionaryWithDictionary:self.dic];
    [self.navigationController pushViewController:vc animated:1];
    
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
