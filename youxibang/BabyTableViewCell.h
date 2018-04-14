//
//  BabyTableViewCell.h
//  youxibang
//
//  Created by y on 2018/3/2.
//

#import <UIKit/UIKit.h>

@interface BabyTableViewCell : UITableViewCell
@property (nonatomic,strong)UIImageView* imgv;
@property (nonatomic,strong)UILabel* name;
@property (nonatomic,strong)UILabel* grade;
@property (nonatomic,strong)UILabel* price;
@property (nonatomic,strong)UILabel* times;
- (void)setViewWithDic:(NSDictionary*)dic;
@end
