//
//  FansTableViewCell.h
//  youxibang
//
//  Created by jiazhuo1 on 2018/4/25.
//

#import <UIKit/UIKit.h>

@interface FansTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sexImgView;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *vipImgView;
@property (weak, nonatomic) IBOutlet UIImageView *realnameImgView;
@property (weak, nonatomic) IBOutlet UIButton *attentionButton;

@end
