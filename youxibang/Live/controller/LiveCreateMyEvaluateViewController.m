//
//  LiveCreateMyEvaluateViewController.m
//  youxibang
//
//  Created by jiazhuo1 on 2018/4/26.
//

#import "LiveCreateMyEvaluateViewController.h"

@interface LiveCreateMyEvaluateViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textview;

@end

@implementation LiveCreateMyEvaluateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"我的特点";
    self.textview.frame = CGRectMake(15, StatusBarHeight+44+15, SCREEN_WIDTH-30, 150);
    self.textview.text = self.evaluateString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (self.editEvaluateBlock) {
        self.editEvaluateBlock(textView.text);
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
