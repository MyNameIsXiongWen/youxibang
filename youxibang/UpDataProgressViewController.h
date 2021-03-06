//
//  UpDataProgressViewController.h
//  youxibang
//
//  Created by y on 2018/1/31.
//

#import "BaseViewController.h"

typedef void(^UploadSuccessBlock)(NSString *type);

@interface UpDataProgressViewController : BaseViewController
@property (nonatomic,copy)NSString* orderSn;//订单编号
@property (nonatomic,copy)NSString* type;//1 上号   2 下号
@property (nonatomic,copy)UploadSuccessBlock uploadSuccessBlock;
@end
