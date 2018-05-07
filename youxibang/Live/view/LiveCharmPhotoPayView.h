//
//  LiveCharmPhotoPayView.h
//  youxibang
//
//  Created by jiazhuo1 on 2018/5/2.
//

#import <UIKit/UIKit.h>

typedef void(^ConfirmPayBlock)(NSInteger indexTag);
typedef void(^DismissBlock)(void);
@interface LiveCharmPhotoPayView : UIView {
    NSString *payPrice;
    NSInteger indexTag;
}

- (instancetype)initWithFrame:(CGRect)frame Price:(NSString *)price Index:(NSInteger)index;

@property (nonatomic, copy) DismissBlock dismissBlock;
@property (nonatomic, copy) ConfirmPayBlock confirmPayBlock;
@property (nonatomic, strong) UIView *blackView;
- (void)show;
- (void)dismiss;
- (void)showInSuperView:(UIView *)superView;

@end
