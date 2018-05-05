//
//  NewsReviewTableViewCell.m
//  youxibang
//
//  Created by jiazhuo1 on 2018/4/28.
//

#import "NewsReviewTableViewCell.h"

@implementation NewsReviewTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.contentLabel.numberOfLines = 0;
    [self.contentLabel sizeToFit];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
