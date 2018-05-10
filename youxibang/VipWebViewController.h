//
//  VipWebViewController.h
//  youxibang
//
//  Created by jiazhuo1 on 2018/5/4.
//

#import <UIKit/UIKit.h>

typedef void(^PaySuccessBlock)(void);

@interface VipWebViewController : UIViewController

@property (copy, nonatomic) NSString *loadUrlString;
@property (nonatomic, copy) PaySuccessBlock paySuccessBlock;

@end
