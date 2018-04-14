//
//  PayOrderTableViewCell.m
//  youxibang
//
//  Created by y on 2018/1/25.
//

#import "PayOrderTableViewCell.h"

@implementation PayOrderTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectBtn.userInteractionEnabled = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
