//
//  TaskTableViewCell.m
//  youxibang
//
//  Created by y on 2018/2/6.
//

#import "TaskTableViewCell.h"

@implementation TaskTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initCellView];
    }
    return self;
}
- (void)initCellView{
    self.title = [EBUtility labfrome:CGRectZero andText:@"订单主题" andColor:[UIColor blackColor] andView:self.viewForLastBaselineLayout];
    self.title.font = [UIFont systemFontOfSize:17];
    [self.title sizeToFit];
    self.name = [EBUtility labfrome:CGRectZero andText:@"发布者:" andColor:[UIColor blackColor] andView:self.viewForLastBaselineLayout];
    self.name.font = [UIFont systemFontOfSize:15];
    [self.name sizeToFit];
    self.price = [EBUtility labfrome:CGRectZero andText:@"¥60.00" andColor:[UIColor redColor] andView:self.viewForLastBaselineLayout];
    self.price.font = [UIFont systemFontOfSize:18];
    [self.price sizeToFit];
    self.time = [EBUtility labfrome:CGRectZero andText:@"总时间:" andColor:[UIColor blackColor] andView:self.viewForLastBaselineLayout];
    self.time.font = [UIFont systemFontOfSize:15];
    [self.time sizeToFit];
    self.deposit = [EBUtility labfrome:CGRectZero andText:@"保证金:" andColor:[UIColor blackColor] andView:self.viewForLastBaselineLayout];
    self.deposit.font = [UIFont systemFontOfSize:15];
    [self.deposit sizeToFit];
    self.status = [EBUtility labfrome:CGRectZero andText:@"审核中" andColor:[UIColor blackColor] andView:self.viewForLastBaselineLayout];
    self.status.font = [UIFont systemFontOfSize:13];
    [self.status sizeToFit];
    
    self.btnView = [EBUtility viewfrome:CGRectZero andColor:[UIColor whiteColor] andView:self.viewForLastBaselineLayout];
    
    UILabel* grayLine = [EBUtility labfrome:CGRectZero andText:@"" andColor:nil andView:self.viewForLastBaselineLayout];
    grayLine.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    UILabel* grayView = [EBUtility labfrome:CGRectZero andText:@"" andColor:nil andView:self.viewForLastBaselineLayout];
    grayView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.viewForLastBaselineLayout.mas_top).offset(10);
        make.left.equalTo(self.viewForLastBaselineLayout.mas_left).offset(10);
        
    }];
    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.title.mas_bottom).offset(10);
        make.left.equalTo(self.viewForLastBaselineLayout.mas_left).offset(10);
        
    }];
    [self.deposit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.name.mas_bottom).offset(10);
        make.left.equalTo(self.viewForLastBaselineLayout.mas_left).offset(10);
        
    }];
    [self.time mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.name.mas_bottom).offset(10);
        make.left.equalTo(self.deposit.mas_right).offset(50);
        
    }];
    [self.price mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.title.mas_bottom).offset(10);
        make.right.equalTo(self.viewForLastBaselineLayout.mas_right).offset(-10);
        
    }];
    [self.status mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.viewForLastBaselineLayout.mas_top).offset(10);
        make.right.equalTo(self.viewForLastBaselineLayout.mas_right).offset(-10);
    }];

    [grayLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.deposit.mas_bottom).offset(10);
        make.left.equalTo(self.viewForLastBaselineLayout.mas_left).offset(10);
        make.right.equalTo(self.viewForLastBaselineLayout.mas_right).offset(-10);
        make.height.equalTo(@1);
    }];
    [self.btnView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.deposit.mas_bottom).offset(11);
        make.left.equalTo(self.viewForLastBaselineLayout.mas_left);
        make.right.equalTo(self.viewForLastBaselineLayout.mas_right);
        make.bottom.equalTo(grayView.mas_top);
    }];
    [grayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(grayLine.mas_bottom).offset(40);
        make.bottom.equalTo(self.viewForLastBaselineLayout.mas_bottom);
        make.left.equalTo(self.viewForLastBaselineLayout.mas_left);
        make.right.equalTo(self.viewForLastBaselineLayout.mas_right);
        make.height.equalTo(@10);
    }];
}
- (void)setViewWithDic:(NSDictionary*)dic{
    self.title.text = [NSString stringWithFormat:@"%@",dic[@"title"]];
    self.name.text = [NSString stringWithFormat:@"发布者：%@",dic[@"nickname"]];
    self.deposit.text = [NSString stringWithFormat:@"保证金：¥%@",dic[@"deposit"]];
    self.time.text = [NSString stringWithFormat:@"总时间：%@小时",dic[@"num"]];
    self.price.text = [NSString stringWithFormat:@"¥%@",dic[@"totalprice"]];
    
    self.status.text = [NSString stringWithFormat:@"%@",dic[@"statusname"]];
    for (UIButton* i in self.btnView.subviews){
        [i removeFromSuperview];
    }
    if ([dic[@"type"] isEqualToString:@"1"]){
        if ([[NSString stringWithFormat:@"%@",dic[@"partstatus"]] isEqualToString:@"0"]){
            UIButton* btn = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH - 75, 8, 65, 25) andText:@"取消任务" andColor:Nav_color andimg:nil andView:self.btnView];
            [btn addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            btn.layer.borderColor = Nav_color.CGColor;
            btn.layer.borderWidth = 1;
            btn.layer.cornerRadius = 10;
            btn.layer.masksToBounds = YES;
            btn.titleLabel.font = [UIFont systemFontOfSize:13];

        }else if ([[NSString stringWithFormat:@"%@",dic[@"partstatus"]] isEqualToString:@"1"]){
            UIButton* btn = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH - 75, 8, 65, 25) andText:@"取消任务" andColor:Nav_color andimg:nil andView:self.btnView];
            [btn addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            btn.layer.borderColor = Nav_color.CGColor;
            btn.layer.borderWidth = 1;
            btn.layer.cornerRadius = 10;
            btn.layer.masksToBounds = YES;
            btn.titleLabel.font = [UIFont systemFontOfSize:13];
        }else if ([[NSString stringWithFormat:@"%@",dic[@"partstatus"]] isEqualToString:@"2"]){
            UIButton* btn = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH - 75, 8, 65, 25) andText:@"选择宝贝" andColor:[UIColor whiteColor] andimg:nil andView:self.btnView];
            [btn addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            btn.backgroundColor = Nav_color;
            btn.layer.cornerRadius = 10;
            btn.layer.masksToBounds = YES;
            btn.titleLabel.font = [UIFont systemFontOfSize:13];
            
            UIButton* btn1 = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH - 75 - 75, 8, 65, 25) andText:@"取消任务" andColor:Nav_color andimg:nil andView:self.btnView];
            [btn1 addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            btn1.layer.borderColor = Nav_color.CGColor;
            btn1.layer.borderWidth = 1;
            btn1.layer.cornerRadius = 10;
            btn1.layer.masksToBounds = YES;
            btn1.titleLabel.font = [UIFont systemFontOfSize:13];
        }else if ([[NSString stringWithFormat:@"%@",dic[@"partstatus"]] isEqualToString:@"3"]){
            UIButton* btn = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH - 75, 8, 65, 25) andText:@"去付款" andColor:[UIColor whiteColor] andimg:nil andView:self.btnView];
            [btn addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            btn.backgroundColor = Nav_color;
            btn.layer.cornerRadius = 10;
            btn.layer.masksToBounds = YES;
            btn.titleLabel.font = [UIFont systemFontOfSize:13];
            
            UIButton* btn1 = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH - 75 - 75, 8, 65, 25) andText:@"取消任务" andColor:Nav_color andimg:nil andView:self.btnView];
            [btn1 addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            btn1.layer.borderColor = Nav_color.CGColor;
            btn1.layer.borderWidth = 1;
            btn1.layer.cornerRadius = 10;
            btn1.layer.masksToBounds = YES;
            btn1.titleLabel.font = [UIFont systemFontOfSize:13];
        }else if ([[NSString stringWithFormat:@"%@",dic[@"partstatus"]] isEqualToString:@"4"]){
            UIButton* btn = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH - 75, 8, 65, 25) andText:@"查看订单" andColor:Nav_color andimg:nil andView:self.btnView];
            [btn addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            btn.layer.borderColor = Nav_color.CGColor;
            btn.layer.borderWidth = 1;
            btn.layer.cornerRadius = 10;
            btn.layer.masksToBounds = YES;
            btn.titleLabel.font = [UIFont systemFontOfSize:13];
        }
    }else if ([dic[@"type"] isEqualToString:@"2"]){
        if ([[NSString stringWithFormat:@"%@",dic[@"partstatus"]] isEqualToString:@"1"]){
            UIButton* btn = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH - 75, 8, 65, 25) andText:@"取消抢单" andColor:Nav_color andimg:nil andView:self.btnView];
            btn.titleLabel.font = [UIFont systemFontOfSize:13];
            [btn addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            btn.layer.borderColor = Nav_color.CGColor;
            btn.layer.borderWidth = 1;
            btn.layer.cornerRadius = 10;
            btn.layer.masksToBounds = YES;
        }else if ([[NSString stringWithFormat:@"%@",dic[@"partstatus"]] isEqualToString:@"2"]){
            UIButton* btn = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH - 75, 8, 65, 25) andText:@"查看订单" andColor:Nav_color andimg:nil andView:self.btnView];
            [btn addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            btn.layer.borderColor = Nav_color.CGColor;
            btn.layer.borderWidth = 1;
            btn.layer.cornerRadius = 10;
            btn.layer.masksToBounds = YES;
            btn.titleLabel.font = [UIFont systemFontOfSize:13];
        }
    }
    
}
- (void)touchBtn:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(selectSomeThing: AndRow:)]){
        [self.delegate selectSomeThing:sender.titleLabel.text AndRow:self.row];
    }
}
@end
