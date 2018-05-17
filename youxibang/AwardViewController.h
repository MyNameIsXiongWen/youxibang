//
//  AwardViewController.h
//  youxibang
//
//  Created by y on 2018/2/7.
//

#import "BaseViewController.h"

typedef void(^AwardSuccessBlock)(void);
@interface AwardViewController : BaseViewController

@property (nonatomic,strong)NSMutableDictionary* orderInfo;
@property (nonatomic,assign)NSInteger type;//0 从订单列表跳入   1 从订单详情跳入     这里是因为info结构不一样，所以区分方便布置个人信息  2.从主播详情页跳入
@property (nonatomic,copy) AwardSuccessBlock awardSuccessBlock;
@end
