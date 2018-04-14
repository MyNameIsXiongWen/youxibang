//
//  HomeCollectionViewCell.h
//  youxibang
//
//  Created by y on 2018/1/18.
//

#import <UIKit/UIKit.h>

@interface HomeCollectionViewCell : UICollectionViewCell
@property (nonatomic,strong) UIImageView* imgv;
@property (nonatomic,strong) UIImageView* tagImage;
@property (nonatomic,strong) UILabel* gradeLab;
@property (nonatomic,strong) UILabel* priceLab;
@property (nonatomic,strong) UILabel* timeLab;
@property (nonatomic,strong) UILabel* nameLab;
- (void)setInfoWith:(NSDictionary*)dic;
@end
