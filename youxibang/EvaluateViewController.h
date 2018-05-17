//
//  EvaluateViewController.h
//  youxibang
//
//  Created by 戎博 on 2018/2/19.
//

#import "BaseViewController.h"

typedef void(^EvaluateSuccessBlock)(void);
@interface EvaluateViewController : BaseViewController
@property (nonatomic,assign)NSInteger type;//同打赏
@property (nonatomic,strong)NSDictionary* orderInfo;
@property (nonatomic,copy)EvaluateSuccessBlock evaluateSuccessBlock;
@end
