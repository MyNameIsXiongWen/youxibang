//
//  DiscountViewController.h
//  youxibang
//
//  Created by y on 2018/2/28.
//

#import "BaseViewController.h"
@protocol DiscountViewControllerDelegate<NSObject>
//回调优惠券id的delegate
-(void)selectSomeThing:(NSString*)name AndId:(NSString*)pid;
@end
@interface DiscountViewController : BaseViewController
@property (nonatomic,assign)id<DiscountViewControllerDelegate> delegate;
@end
