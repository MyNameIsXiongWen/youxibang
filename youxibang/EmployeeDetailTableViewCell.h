//
//  EmployeeDetailTableViewCell.h
//  youxibang
//
//  Created by y on 2018/1/19.
//

#import <UIKit/UIKit.h>

@interface EmployeeDetailTableViewCell : UITableViewCell
@property (nonatomic,strong)UIImageView* imgv;
@property (nonatomic,strong)UILabel* name;
@property (nonatomic,strong)UILabel* grade;
@property (nonatomic,strong)UILabel* describe;
@property (nonatomic,strong)UILabel* price;
@property (nonatomic,strong)UILabel* times;
- (void)setViewWithDic:(NSDictionary*)dic;
@end
