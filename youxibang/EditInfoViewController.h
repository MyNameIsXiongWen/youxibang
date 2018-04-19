//
//  EditInfoViewController.h
//  youxibang
//
//  Created by y on 2018/2/3.
//

#import "BaseViewController.h"
@protocol EditInfoViewControllerDelegate<NSObject>

-(void)editNickName:(NSString*)name;
@end

@interface EditInfoViewController : BaseViewController
@property (nonatomic,assign)NSInteger type;//1 昵称    4签名   5 爱好
@property (nonatomic,assign)id<EditInfoViewControllerDelegate> delegate;
//@property (nonatomic,strong)NSMutableDictionary *dataInfo;
@end
