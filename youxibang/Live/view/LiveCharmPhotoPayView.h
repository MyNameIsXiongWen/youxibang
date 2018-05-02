//
//  LiveCharmPhotoPayView.h
//  youxibang
//
//  Created by jiazhuo1 on 2018/5/2.
//

#import <UIKit/UIKit.h>

typedef void(^ConfirmPayBlock)(void);
@interface LiveCharmPhotoPayView : UIView {
    NSString *payPrice;
}

- (instancetype)initWithFrame:(CGRect)frame Price:(NSString *)price;
@property (nonatomic, copy) ConfirmPayBlock confirmPayBlock;
@property (nonatomic, strong) UIView *blackView;
- (void)show;
- (void)dismiss;

@end
