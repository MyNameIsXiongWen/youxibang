//
//  LoginViewController.h
//  youxibang
//
//  Created by y on 2018/1/18.
//

#import "BaseTableViewController.h"
#import "WXApi.h"

@interface LoginViewController : UIViewController<WXApiDelegate>
@property (nonatomic,assign)BOOL codeOrPassword;
@end
