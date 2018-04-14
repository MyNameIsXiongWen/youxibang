//
//  TopUpTableViewCell.m
//  ChuXing
//
//  Created by dingyi on 2017/9/30.
//  Copyright © 2017年 Dingyi. All rights reserved.
//

#import "TopUpTableViewCell.h"

@implementation TopUpTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
-(void)initCell{
    for (UIView* i in self.viewForLastBaselineLayout.subviews){
        [i removeFromSuperview];
    }
    NSArray* title = @[@"充值",@"提现",@"余额明细"];
    NSArray* img = @[@"ico_cz",@"ico_tx",@"ico_yemx"];
    UIView* backView = [EBUtility viewfrome:CGRectMake(0, 0, SCREEN_WIDTH - 30, 50) andColor:[UIColor whiteColor] andView:self.viewForLastBaselineLayout];
    for (int i = 0; i < 3; i++){
        UIView* view = [EBUtility viewfrome:CGRectMake((backView.width)/3 *i, 0, (backView.width)/3, 80) andColor:nil andView:backView];
        
        YHYButton* btn = [[YHYButton alloc]initWithFrame:CGRectMake(0, 5, 55, 30) ImageFrame:CGSizeMake(15, 15) TextFont:13 AndType:YHYButtonTypeBottom];
        [btn setTitle:title[i] forState:0];
        [btn setTitleColor:[UIColor darkGrayColor] forState:0];
        [btn setImage:[UIImage imageNamed:img[i]] forState:0];
        btn.tag = i;
        [btn addTarget:self action:@selector(pushVC:) forControlEvents:UIControlEventTouchUpInside];
        btn.centerX = view.width/2;
        [view addSubview:btn];

    }
}
-(void)pushVC:(UIButton *)btn{
    if ([self.delegate respondsToSelector:@selector(pushTopUpView:)]) {
        [self.delegate pushTopUpView:btn.tag];
    }
}
@end

