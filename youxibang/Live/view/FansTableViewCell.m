//
//  FansTableViewCell.m
//  youxibang
//
//  Created by jiazhuo1 on 2018/4/25.
//

#import "FansTableViewCell.h"

@implementation FansTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.headImgView.layer.cornerRadius = 20;
    self.headImgView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
