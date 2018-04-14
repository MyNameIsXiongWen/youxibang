//
//  TopUpAndWithdrawViewController.h
//  youxibang
//
//  Created by y on 2018/2/1.
//

#import "BaseViewController.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import <AlipaySDK/AlipaySDK.h>

@interface TopUpAndWithdrawViewController : BaseViewController<WXApiDelegate>
@property(nonatomic,assign)NSInteger type;//0 充值    1 提现
@end
