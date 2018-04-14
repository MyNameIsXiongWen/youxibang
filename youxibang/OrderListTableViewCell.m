//
//  OrderListTableViewCell.m
//  youxibang
//
//  Created by y on 2018/2/7.
//

#import "OrderListTableViewCell.h"

@implementation OrderListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
/*
5 任务发布者本人访问 && 未开始（催单，取消订单）status 1

6 任务发布者本人访问 && 打单中（申请取消）status 2

7 任务发布者本人访问 && 主动退单（撤销申请，申请仲裁）status 3

8 任务发布者本人访问 && 被动退单（同意退单，拒绝退单）status 4

9 任务发布者本人访问 && 仲裁中（撤销申请）status 5

10 任务发布者本人访问 && 打单完成（评价，打赏）status 7

11 游戏宝贝访问 && 未开始（开始打单，计时lab）status 1

12 游戏宝贝访问 && 打单中（上传进度，申请取消）status 2

13 任务发布者本人访问 && 被动退单（同意退单，拒绝退单）status 3

14 任务发布者本人访问 && 主动退单（撤销申请，申请仲裁）status 4

15 任务发布者本人访问 && 仲裁中（撤销申请）status 5
 */
- (void)setViewWithDic:(NSDictionary*)dic{
    [self.photo sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",dic[@"photo"]]] placeholderImage:[UIImage imageNamed:@"ico_head"]];
    
    self.status.text = [NSString stringWithFormat:@"%@",dic[@"tname"]];
    self.name.text = [NSString stringWithFormat:@"%@",dic[@"nickname"]];
    self.date.text = [NSString stringWithFormat:@"%@",dic[@"addtime"]];
    self.orderNum.text = [NSString stringWithFormat:@"订单号：%@",dic[@"order_sn"]];
    self.content.text = [NSString stringWithFormat:@"%@ 总时间：%@小时",dic[@"title"],dic[@"hours"]];
    self.price.text = [NSString stringWithFormat:@"¥%@",dic[@"totalprice"]];
    if ([[NSString stringWithFormat:@"%@",dic[@"typeid"]] isEqualToString:@"1"]){
        self.knockTag.hidden = YES;
    }
    
    for (UIButton* i in self.btnView.subviews){
        [i removeFromSuperview];
    }
    if ([[NSString stringWithFormat:@"%@",dic[@"is_baby"]] isEqualToString:@"2"]){
        if ([[NSString stringWithFormat:@"%@",dic[@"status"]] isEqualToString:@"0"]){
            UIButton* btn = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH - 75, 8, 65, 25) andText:@"催单" andColor:[UIColor whiteColor] andimg:nil andView:self.btnView];
            [btn addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            btn.backgroundColor = Nav_color;
            btn.layer.cornerRadius = 10;
            btn.layer.masksToBounds = YES;
            btn.titleLabel.font = [UIFont systemFontOfSize:13];
            
            UIButton* btn1 = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH - 75 - 75, 8, 65, 25) andText:@"取消订单" andColor:Nav_color andimg:nil andView:self.btnView];
            [btn1 addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            btn1.layer.borderColor = Nav_color.CGColor;
            btn1.layer.borderWidth = 1;
            btn1.layer.cornerRadius = 10;
            btn1.layer.masksToBounds = YES;
            btn1.titleLabel.font = [UIFont systemFontOfSize:13];
        }else if ([[NSString stringWithFormat:@"%@",dic[@"status"]] isEqualToString:@"1"]){
            UIButton* btn = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH - 75, 8, 65, 25) andText:@"申请取消" andColor:Nav_color andimg:nil andView:self.btnView];
            [btn addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            btn.layer.borderColor = Nav_color.CGColor;
            btn.layer.borderWidth = 1;
            btn.layer.cornerRadius = 10;
            btn.layer.masksToBounds = YES;
            btn.titleLabel.font = [UIFont systemFontOfSize:13];
            
        }else if ([[NSString stringWithFormat:@"%@",dic[@"status"]] isEqualToString:@"2"]){
            UIButton* btn = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH - 75, 8, 65, 25) andText:@"申请仲裁" andColor:[UIColor whiteColor] andimg:nil andView:self.btnView];
            [btn addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            btn.backgroundColor = Nav_color;
            btn.layer.cornerRadius = 10;
            btn.layer.masksToBounds = YES;
            btn.titleLabel.font = [UIFont systemFontOfSize:13];
            
            UIButton* btn1 = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH - 75 - 75, 8, 65, 25) andText:@"撤销申请" andColor:Nav_color andimg:nil andView:self.btnView];
            [btn1 addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            btn1.layer.borderColor = Nav_color.CGColor;
            btn1.layer.borderWidth = 1;
            btn1.layer.cornerRadius = 10;
            btn1.layer.masksToBounds = YES;
            btn1.titleLabel.font = [UIFont systemFontOfSize:13];
            
        }else if ([[NSString stringWithFormat:@"%@",dic[@"status"]] isEqualToString:@"3"]){
            UIButton* btn = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH - 75, 8, 65, 25) andText:@"同意退单" andColor:[UIColor whiteColor] andimg:nil andView:self.btnView];
            [btn addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            btn.backgroundColor = Nav_color;
            btn.layer.cornerRadius = 10;
            btn.layer.masksToBounds = YES;
            btn.titleLabel.font = [UIFont systemFontOfSize:13];
            
            UIButton* btn1 = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH - 75 - 75, 8, 65, 25) andText:@"拒绝退单" andColor:Nav_color andimg:nil andView:self.btnView];
            [btn1 addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            btn1.layer.borderColor = Nav_color.CGColor;
            btn1.layer.borderWidth = 1;
            btn1.layer.cornerRadius = 10;
            btn1.layer.masksToBounds = YES;
            btn1.titleLabel.font = [UIFont systemFontOfSize:13];
            
        }else if ([[NSString stringWithFormat:@"%@",dic[@"status"]] isEqualToString:@"4"]){
            
            UIButton* btn = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH - 75, 8, 65, 25) andText:@"撤销仲裁" andColor:Nav_color andimg:nil andView:self.btnView];
            [btn addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            btn.layer.borderColor = Nav_color.CGColor;
            btn.layer.borderWidth = 1;
            btn.layer.cornerRadius = 10;
            btn.layer.masksToBounds = YES;
            btn.titleLabel.font = [UIFont systemFontOfSize:13];
            
        }else if ([[NSString stringWithFormat:@"%@",dic[@"status"]] isEqualToString:@"5"]){
            UIButton* btn = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH - 75, 8, 65, 25) andText:@"打赏" andColor:[UIColor whiteColor] andimg:nil andView:self.btnView];
            [btn addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            btn.backgroundColor = Nav_color;
            btn.layer.cornerRadius = 10;
            btn.layer.masksToBounds = YES;
            btn.titleLabel.font = [UIFont systemFontOfSize:13];
            
            UIButton* btn1 = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH - 75 - 75, 8, 65, 25) andText:@"评价" andColor:Nav_color andimg:nil andView:self.btnView];
            [btn1 addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            btn1.layer.borderColor = Nav_color.CGColor;
            btn1.layer.borderWidth = 1;
            btn1.layer.cornerRadius = 10;
            btn1.layer.masksToBounds = YES;
            btn1.titleLabel.font = [UIFont systemFontOfSize:13];
            
        }else if ([[NSString stringWithFormat:@"%@",dic[@"status"]] isEqualToString:@"6"]){
            UIButton* btn = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH - 75, 8, 65, 25) andText:@"评价" andColor:[UIColor whiteColor] andimg:nil andView:self.btnView];
            [btn addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            btn.backgroundColor = Nav_color;
            btn.layer.cornerRadius = 10;
            btn.layer.masksToBounds = YES;
            btn.titleLabel.font = [UIFont systemFontOfSize:13];
            
        }else if ([[NSString stringWithFormat:@"%@",dic[@"status"]] isEqualToString:@"99"]){
            UIButton* btn = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH - 75, 8, 65, 25) andText:@"去支付" andColor:[UIColor whiteColor] andimg:nil andView:self.btnView];
            [btn addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            btn.backgroundColor = Nav_color;
            btn.layer.cornerRadius = 10;
            btn.layer.masksToBounds = YES;
            btn.titleLabel.font = [UIFont systemFontOfSize:13];
            
            UIButton* btn1 = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH - 75 - 75, 8, 65, 25) andText:@"取消订单" andColor:Nav_color andimg:nil andView:self.btnView];
            [btn1 addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            btn1.layer.borderColor = Nav_color.CGColor;
            btn1.layer.borderWidth = 1;
            btn1.layer.cornerRadius = 10;
            btn1.layer.masksToBounds = YES;
            btn1.titleLabel.font = [UIFont systemFontOfSize:13];
            
        }
    }else if ([[NSString stringWithFormat:@"%@",dic[@"is_baby"]] isEqualToString:@"1"]){
        if ([[NSString stringWithFormat:@"%@",dic[@"status"]] isEqualToString:@"0"]){
            UIButton* btn = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH - 75, 8, 65, 25) andText:@"开始打单" andColor:[UIColor whiteColor] andimg:nil andView:self.btnView];
            [btn addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            btn.backgroundColor = Nav_color;
            btn.layer.cornerRadius = 10;
            btn.layer.masksToBounds = YES;
            btn.titleLabel.font = [UIFont systemFontOfSize:13];
            
            UIButton* btn1 = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH - 75 - 75, 8, 65, 25) andText:@"取消订单" andColor:Nav_color andimg:nil andView:self.btnView];
            [btn1 addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            btn1.layer.borderColor = Nav_color.CGColor;
            btn1.layer.borderWidth = 1;
            btn1.layer.cornerRadius = 10;
            btn1.layer.masksToBounds = YES;
            btn1.titleLabel.font = [UIFont systemFontOfSize:13];
        }else if ([[NSString stringWithFormat:@"%@",dic[@"status"]] isEqualToString:@"1"]){
            UIButton* btn = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH - 75, 8, 65, 25) andText:@"上传进度" andColor:[UIColor whiteColor] andimg:nil andView:self.btnView];
            [btn addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            btn.backgroundColor = Nav_color;
            btn.layer.cornerRadius = 10;
            btn.layer.masksToBounds = YES;
            btn.titleLabel.font = [UIFont systemFontOfSize:13];
            
            UIButton* btn1 = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH - 75 - 75, 8, 65, 25) andText:@"申请取消" andColor:Nav_color andimg:nil andView:self.btnView];
            [btn1 addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            btn1.layer.borderColor = Nav_color.CGColor;
            btn1.layer.borderWidth = 1;
            btn1.layer.cornerRadius = 10;
            btn1.layer.masksToBounds = YES;
            btn1.titleLabel.font = [UIFont systemFontOfSize:13];
        }else if ([[NSString stringWithFormat:@"%@",dic[@"status"]] isEqualToString:@"2"]){
            UIButton* btn = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH - 75, 8, 65, 25) andText:@"同意退单" andColor:[UIColor whiteColor] andimg:nil andView:self.btnView];
            [btn addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            btn.backgroundColor = Nav_color;
            btn.layer.cornerRadius = 10;
            btn.layer.masksToBounds = YES;
            btn.titleLabel.font = [UIFont systemFontOfSize:13];
            
            UIButton* btn1 = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH - 75 - 75, 8, 65, 25) andText:@"拒绝退单" andColor:Nav_color andimg:nil andView:self.btnView];
            [btn1 addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            btn1.layer.borderColor = Nav_color.CGColor;
            btn1.layer.borderWidth = 1;
            btn1.layer.cornerRadius = 10;
            btn1.layer.masksToBounds = YES;
            btn1.titleLabel.font = [UIFont systemFontOfSize:13];
            
        }else if ([[NSString stringWithFormat:@"%@",dic[@"status"]] isEqualToString:@"3"]){
            UIButton* btn = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH - 75, 8, 65, 25) andText:@"申请仲裁" andColor:[UIColor whiteColor] andimg:nil andView:self.btnView];
            [btn addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            btn.backgroundColor = Nav_color;
            btn.layer.cornerRadius = 10;
            btn.layer.masksToBounds = YES;
            btn.titleLabel.font = [UIFont systemFontOfSize:13];
            
            UIButton* btn1 = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH - 75 - 75, 8, 65, 25) andText:@"撤销申请" andColor:Nav_color andimg:nil andView:self.btnView];
            [btn1 addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            btn1.layer.borderColor = Nav_color.CGColor;
            btn1.layer.borderWidth = 1;
            btn1.layer.cornerRadius = 10;
            btn1.layer.masksToBounds = YES;
            btn1.titleLabel.font = [UIFont systemFontOfSize:13];
            
        }else if ([[NSString stringWithFormat:@"%@",dic[@"status"]] isEqualToString:@"4"]){
            UIButton* btn = [EBUtility btnfrome:CGRectMake(SCREEN_WIDTH - 75, 8, 65, 25) andText:@"撤销仲裁" andColor:Nav_color andimg:nil andView:self.btnView];
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
