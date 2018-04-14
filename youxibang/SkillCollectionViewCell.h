//
//  SkillCollectionViewCell.h
//  youxibang
//
//  Created by y on 2018/2/6.
//

#import <UIKit/UIKit.h>

@interface SkillCollectionViewCell : UICollectionViewCell
@property (nonatomic,strong) UIImageView* imgv;
@property (nonatomic,copy) NSString* pid;
@property (nonatomic,strong) UILabel* nameLab;
- (void)setInfoWith:(NSDictionary*)dic;
@end
