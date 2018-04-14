//
//  SetPasswordViewController.h
//  youxibang
//
//  Created by y on 2018/1/30.
//

#import "BaseViewController.h"

@interface SetPasswordViewController : BaseViewController
@property (copy,nonatomic)NSString* phoneNum;
@property (nonatomic,copy)NSString* type;
@property (nonatomic,copy)NSString* threetoken;
@property (nonatomic,copy)NSString* unionid;//微信unionid
@end
