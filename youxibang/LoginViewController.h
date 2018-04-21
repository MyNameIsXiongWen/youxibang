//
//  LoginViewController.h
//  youxibang
//
//  Created by y on 2018/1/18.
//

#import "BaseTableViewController.h"
#import "WXApi.h"

@interface LoginViewController : UIViewController<WXApiDelegate>

@property (nonatomic,assign) BOOL codeOrPassword;
@property (nonatomic,copy) NSString *phoneNumberString;
@property (nonatomic,copy) NSString *passwordString;
@property (nonatomic,copy) NSString *codeString;

@end
