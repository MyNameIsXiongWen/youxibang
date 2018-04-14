//
//  SupplementInfoViewController.h
//  youxibang
//
//  Created by y on 2018/1/30.
//

#import "BaseViewController.h"

@interface SupplementInfoViewController : BaseViewController
@property (copy,nonatomic)NSString* phoneNum;
@property (copy,nonatomic)NSString* password;
@property (copy,nonatomic)NSString* leadercode;
@property (nonatomic,copy)NSString* type;
@property (nonatomic,copy)NSString* threetoken;
@property (nonatomic,copy)NSString* unionid;//微信unionid
@end
