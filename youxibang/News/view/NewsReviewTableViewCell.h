//
//  NewsReviewTableViewCell.h
//  youxibang
//
//  Created by jiazhuo1 on 2018/4/28.
//

#import <UIKit/UIKit.h>

@interface NewsReviewTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgview;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
