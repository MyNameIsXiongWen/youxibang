//
//  HomeSearchViewTableViewCell.m
//  youxibang
//
//  Created by jiazhuo1 on 2018/5/9.
//

#import "HomeSearchViewTableViewCell.h"

@implementation HomeSearchViewTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.sexageLabel.layer.cornerRadius = 7;
    self.sexageLabel.layer.masksToBounds = YES;
    self.headImgView.layer.cornerRadius = 30;
    self.headImgView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setContentViewWithDic:(NSDictionary *)dic {
    [self.headImgView sd_setImageWithURL:[NSURL URLWithString:dic[@"photo"]] placeholderImage:[UIImage imageNamed:@"ico_head"]];
    self.nameLabel.text = dic[@"nickname"];
    if ([dic[@"sex"] integerValue] == 1) {
        self.sexageLabel.text = [NSString stringWithFormat:@" ♂%@岁\t",dic[@"birthday"]];
        self.sexageLabel.backgroundColor = Nav_color;
    }else{
        self.sexageLabel.text = [NSString stringWithFormat:@" ♀%@岁\t",dic[@"birthday"]];
        self.sexageLabel.backgroundColor = Pink_color;
    }
    if (([dic[@"is_realauth"] integerValue] == 1)) {
        self.realnameImgView.hidden = NO;
    }
    else {
        self.realnameImgView.hidden = YES;
    }
    self.timeLabel.text = dic[@"last_login"];
}

@end
