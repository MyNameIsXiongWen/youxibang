//
//  PartTimeTableViewCell.h
//  youxibang
//
//  Created by y on 2018/1/26.
//

#import <UIKit/UIKit.h>

@interface PartTimeTableViewCell : UITableViewCell
@property (nonatomic,strong)UILabel* name;
@property (nonatomic,strong)UILabel* title;
@property (nonatomic,strong)UILabel* price;
@property (nonatomic,strong)UILabel* time;
@property (nonatomic,strong)UILabel* deposit;

- (void)setViewWithDic:(NSDictionary*)dic;
@end
