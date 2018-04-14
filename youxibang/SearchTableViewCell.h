//
//  SearchTableViewCell.h
//  youxibang
//
//  Created by y on 2018/1/19.
//

#import <UIKit/UIKit.h>

@interface SearchTableViewCell : UITableViewCell
@property (nonatomic,strong)UIImageView* imgv;
@property (nonatomic,strong)UILabel* name;
@property (nonatomic,strong)UILabel* grade;
@property (nonatomic,strong)UILabel* price;
@property (nonatomic,strong)UILabel* times;
@property (nonatomic,strong)UILabel* age;
@property (nonatomic,strong)UIView* tagImage;
- (void)setViewWithDic:(NSDictionary*)dic withType:(int)type; 
@end
