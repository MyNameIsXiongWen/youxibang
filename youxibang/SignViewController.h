//
//  SignViewController.h
//  youxibang
//
//  Created by y on 2018/1/26.
//

#import "BaseViewController.h"

@interface SignViewController : UIViewController
@property (nonatomic,copy)NSString* type;// (0-账号密码、1-短信、2-微信、3-QQ) 
@property (nonatomic,copy)NSString* threetoken;//绑定第三方时获得的token
@property (nonatomic,copy)NSString* unionid;//微信unionid
@end
