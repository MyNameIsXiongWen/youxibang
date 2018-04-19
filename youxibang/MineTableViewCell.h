//
//  MineTableViewCell.h
//  youxibang
//
//  Created by jiazhuo1 on 2018/4/9.
//

#import <UIKit/UIKit.h>

@interface MineTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightLabelTrailingConstraint;

@end
