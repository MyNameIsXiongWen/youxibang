//
//  OrderListTableViewCell.h
//  youxibang
//
//  Created by y on 2018/2/7.
//

#import <UIKit/UIKit.h>
@protocol OrderListTableViewCellDelegate<NSObject>

-(void)selectSomeThing:(NSString*)name AndRow:(NSInteger)row;
@end
@interface OrderListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *orderNum;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *content;
@property (weak, nonatomic) IBOutlet UIImageView *knockTag;
@property (weak, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UIView *btnView;
@property (nonatomic,assign)NSInteger row;
@property (nonatomic,assign)id<OrderListTableViewCellDelegate> delegate;
- (void)setViewWithDic:(NSDictionary*)dic;
@end
