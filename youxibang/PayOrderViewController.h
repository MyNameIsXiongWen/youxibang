//
//  PayOrderViewController.h
//  youxibang
//
//  Created by y on 2018/1/25.
//

#import "BaseTableViewController.h"


@interface PayOrderViewController : BaseViewController
@property (nonatomic,copy)NSString* type;//type为进入此页面的类名
@property (nonatomic,copy)NSString* orderId;//订单ID 或者 任务ID
@property (nonatomic,copy)NSString* purposemoney;//任务保证金
@end
