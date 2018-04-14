//
//  OrderDetailViewController.h
//  youxibang
//
//  Created by y on 2018/1/30.
//

#import "BaseViewController.h"

@interface OrderDetailViewController : BaseViewController
//是否是订单  N 任务  Y 订单
@property (nonatomic,assign)BOOL isOrder;
@property (nonatomic,copy)NSString* itemId;//任务id或订单id
@end
