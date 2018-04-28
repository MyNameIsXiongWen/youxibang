//
//  LiveCreateFreeView.h
//  youxibang
//
//  Created by jiazhuo1 on 2018/4/27.
//

#import <UIKit/UIKit.h>

typedef void(^ConfirmSelecrBlock)(NSString *money);

@interface LiveCreateFreeView : UIView <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) ConfirmSelecrBlock confirmSelecrBlock;

@property (nonatomic, strong) UIView *blackView;
@property (nonatomic, assign) NSInteger selectedIndex;
- (void)show;
- (void)dismiss;

@end
