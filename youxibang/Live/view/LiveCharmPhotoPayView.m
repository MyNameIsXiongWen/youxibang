//
//  LiveCharmPhotoPayView.m
//  youxibang
//
//  Created by jiazhuo1 on 2018/5/2.
//

#import "LiveCharmPhotoPayView.h"

@implementation LiveCharmPhotoPayView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame Price:(NSString *)price Index:(NSInteger)index {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        payPrice = price;
        indexTag = index;
    }
    return self;
}

- (void)tapBlackView {
    [self dismiss];
}

- (void)configUIWithSuperView:(UIView *)superView {
    self.blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.blackView.backgroundColor = [UIColor blackColor];
    self.blackView.alpha = 0;
    [superView addSubview:self.blackView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBlackView)];
    self.blackView.userInteractionEnabled = YES;
    [self.blackView addGestureRecognizer:tap];
    
    UIButton *closeBtn = [EBUtility btnfrome:CGRectMake((171-21)/2, 0, 21, 21) andText:@"" andColor:nil andimg:[UIImage imageNamed:@"live_charm_pay_close"] andView:self];
    [closeBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    UIView *line = [EBUtility viewfrome:CGRectMake((171-21)/2+10, 21, 0.5, 29) andColor:UIColor.whiteColor andView:self];
    
    UIImageView *bkgImgView = [EBUtility imgfrome:CGRectMake(0, 50, 171, 127) andImg:[UIImage imageNamed:@"live_charm_pay_bkg"] andView:self];
    UILabel *priceLabel = [EBUtility labfrome:CGRectMake(0, 74, self.frame.size.width, 30) andText:[NSString stringWithFormat:@"%@元",payPrice] andColor:[UIColor colorFromHexString:@"f9d854"] andView:self];
    priceLabel.font = [UIFont systemFontOfSize:16.0];
    
    UIButton *payBtn = [EBUtility btnfrome:bkgImgView.frame andText:@"" andColor:nil andimg:nil andView:self];
    [payBtn addTarget:self action:@selector(paySelector) forControlEvents:UIControlEventTouchUpInside];
}

- (void)paySelector {
    if (self.confirmPayBlock) {
        self.confirmPayBlock(indexTag);
    }
}

- (void)show {
    [self configUIWithSuperView:[UIApplication sharedApplication].keyWindow];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25f animations:^{
            self.blackView.alpha = 0.5;
            self.alpha = 1;
        }completion:^(BOOL finished) {
            self.blackView.hidden = NO;
        }];
    });
}

- (void)dismiss {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25f animations:^{
            self.blackView.alpha = 0;
            self.alpha = 0;
        } completion:^(BOOL finished) {
            self.blackView.hidden = YES;
            [self removeFromSuperview];
            [self.blackView removeFromSuperview];
        }];
    });
    if (self.dismissBlock) {
        self.dismissBlock();
    }
}

- (void)showInSuperView:(UIView *)superView {
    [self configUIWithSuperView:superView];
    [superView addSubview:self];
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25f animations:^{
            self.blackView.alpha = 0.5;
            self.alpha = 1;
        }completion:^(BOOL finished) {
            self.blackView.hidden = NO;
        }];
    });
}

@end
