//
//  SetPasswordViewController.h
//  youxibang
//
//  Created by y on 2018/1/30.
//

#import "BaseViewController.h"

@interface SetPasswordViewController : BaseViewController

@property (copy,nonatomic) NSString *phoneNum;
@property (copy,nonatomic) NSString *type;
@property (copy,nonatomic) NSString *threetoken;
@property (copy,nonatomic) NSString *unionid;//微信unionid
@property (copy,nonatomic) NSString *inviteCode;//邀请码

@end
