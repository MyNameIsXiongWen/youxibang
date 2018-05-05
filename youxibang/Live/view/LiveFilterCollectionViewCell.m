//
//  LiveFilterCollectionViewCell.m
//  youxibang
//
//  Created by jiazhuo1 on 2018/4/24.
//

#import "LiveFilterCollectionViewCell.h"

@implementation LiveFilterCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.typeName.layer.borderWidth = 0.5;
    self.typeName.layer.cornerRadius = 2;
    self.typeName.layer.masksToBounds = YES;
}

@end
