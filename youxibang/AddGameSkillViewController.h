//
//  AddGameSkillViewController.h
//  youxibang
//
//  Created by y on 2018/2/6.
//

#import "BaseViewController.h"
@protocol AddGameSkillViewControllerDelegate<NSObject>
//选择游戏的回调delegate
-(void)selectSomeThing:(NSString*)name AndId:(NSString*)pid;
@end
@interface AddGameSkillViewController : BaseViewController
@property (nonatomic,assign)id<AddGameSkillViewControllerDelegate> delegate;
@end
