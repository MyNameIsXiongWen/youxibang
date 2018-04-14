//
//  ReVokeViewController.h
//  youxibang
//
//  Created by y on 2018/1/31.
//

#import "BaseViewController.h"

@interface ReVokeViewController : BaseViewController
@property (nonatomic,assign)NSInteger type;//0 提交异常  1 申请取消订单  2 提交仲裁
@property (nonatomic,copy)NSString* orderId;//订单id
@property (nonatomic,assign)NSInteger withdrawOrderType;//取消订单3种情况  0 雇主申请取消（不显示取消保证金） 1 宝贝申请取消（无保证金） 2 宝贝申请取消（有保证金）
@end
