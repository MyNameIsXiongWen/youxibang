//
//  NumberTableViewCell.m
//  youxibang
//
//  Created by y on 2018/1/26.
//

#import "NumberTableViewCell.h"

@implementation NumberTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.add.layer.borderWidth = 1;
    self.add.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.reduce.layer.borderWidth = 1;
    self.reduce.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.numberLab.layer.borderWidth = 1;
    self.numberLab.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
