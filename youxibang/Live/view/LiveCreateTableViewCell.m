//
//  LiveCreateTableViewCell.m
//  youxibang
//
//  Created by jiazhuo1 on 2018/4/26.
//

#import "LiveCreateTableViewCell.h"

@implementation LiveCreateTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.rightTextField setValue:[UIColor colorFromHexString:@"999999"] forKeyPath:@"_placeholderLabel.textColor"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
