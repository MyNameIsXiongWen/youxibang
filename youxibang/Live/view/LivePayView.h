//
//  LivePayView.h
//  youxibang
//
//  Created by jiazhuo1 on 2018/4/27.
//

#import <UIKit/UIKit.h>

typedef void(^ConfirmSelecrBlock)(NSInteger index);

@interface LivePayView : UIView <UITableViewDelegate, UITableViewDataSource> {
    NSString *payPrice;
}

- (instancetype)initWithFrame:(CGRect)frame Price:(NSString *)price;
@property (nonatomic, copy) ConfirmSelecrBlock confirmSelecrBlock;
@property (nonatomic, strong) UIView *blackView;
@property (nonatomic, assign) BOOL showBuyVip;
@property (nonatomic, copy) NSString *titleString;
- (void)show;
- (void)dismiss;

@end
