//
//  HomeSearchViewTableViewCell.h
//  youxibang
//
//  Created by jiazhuo1 on 2018/5/9.
//

#import <UIKit/UIKit.h>

@interface HomeSearchViewTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sexageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *realnameImgView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

- (void)setContentViewWithDic:(NSDictionary *)dic;

@end
