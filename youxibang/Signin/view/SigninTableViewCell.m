//
//  SigninTableViewCell.m
//  youxibang
//
//  Created by jiazhuo1 on 2018/5/2.
//

#import "SigninTableViewCell.h"

@implementation SigninTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.signinButton.layer.cornerRadius = 13;
    self.signinButton.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
