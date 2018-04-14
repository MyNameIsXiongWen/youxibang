//
//  TaskTableViewCell.h
//  youxibang
//
//  Created by y on 2018/2/6.
//

#import <UIKit/UIKit.h>
@protocol TaskTableViewCellDelegate<NSObject>

-(void)selectSomeThing:(NSString*)name AndRow:(NSInteger)row;
@end
@interface TaskTableViewCell : UITableViewCell
@property (nonatomic,weak)UILabel* name;
@property (nonatomic,weak)UILabel* title;
@property (nonatomic,weak)UILabel* price;
@property (nonatomic,weak)UILabel* time;
@property (nonatomic,weak)UILabel* deposit;
@property (nonatomic,weak)UILabel* status;
@property (nonatomic,strong)UIView* btnView;
@property (nonatomic,assign)NSInteger row;

@property (nonatomic,assign)id<TaskTableViewCellDelegate> delegate;
- (void)setViewWithDic:(NSDictionary*)dic;
@end
