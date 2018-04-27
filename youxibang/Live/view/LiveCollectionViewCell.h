//
//  LiveCollectionViewCell.h
//  youxibang
//
//  Created by jiazhuo1 on 2018/4/24.
//

#import <UIKit/UIKit.h>

@interface LiveCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sexImageView;

@end
