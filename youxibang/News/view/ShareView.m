//
//  ShareView.m
//  youxibang
//
//  Created by jiazhuo1 on 2018/5/2.
//

#import "ShareView.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <WXApi.h>
#import <Weibo_SDK/WeiboSDK.h>

@implementation ShareView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorFromHexString:@"f6f6f6"];
        [self configUI];
    }
    return self;
}

- (void)tapBlackView {
    [self dismiss];
}

- (void)configUI {
    self.blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.blackView.backgroundColor = [UIColor blackColor];
    self.blackView.alpha = 0;
    [[UIApplication sharedApplication].keyWindow addSubview:self.blackView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBlackView)];
    self.blackView.userInteractionEnabled = YES;
    [self.blackView addGestureRecognizer:tap];
    
    
    NSMutableArray *iconArray = [NSMutableArray array];
    if ([WXApi isWXAppInstalled]) {
        [iconArray addObject:@{@"name":@"朋友圈",@"icon":@"share_timeline"}];
        [iconArray addObject:@{@"name":@"微信",@"icon":@"share_wechat"}];
    }
    if ([TencentOAuth iphoneQQInstalled]) {
        [iconArray addObject:@{@"name":@"QQ",@"icon":@"share_qq"}];
    }
    else {
        if ([TencentOAuth iphoneTIMInstalled]) {
            [iconArray addObject:@{@"name":@"TIM",@"icon":@"share_tim"}];
        }
    }
    if ([WeiboSDK isWeiboAppInstalled]) {
        [iconArray addObject:@{@"name":@"微博",@"icon":@"share_weibo"}];
    }
    for (int i=0; i<iconArray.count; i++) {
        NSDictionary *dic = iconArray[i];
        CGFloat widthspace = (SCREEN_WIDTH-160)/(iconArray.count+1);
        UIButton *btn = [EBUtility btnfrome:CGRectMake((widthspace+(40+widthspace)*i), 15, 40, 40) andText:@"" andColor:nil andimg:[UIImage imageNamed:dic[@"icon"]] andView:self];
        objc_setAssociatedObject(btn, @"btn_type", dic[@"icon"], OBJC_ASSOCIATION_COPY_NONATOMIC);
        [btn addTarget:self action:@selector(shareSelector:) forControlEvents:UIControlEventTouchUpInside];
        UILabel *label = [EBUtility labfrome:CGRectMake((widthspace+(40+widthspace)*i), 48+15, 40, 15) andText:dic[@"name"] andColor:[UIColor colorFromHexString:@"333333"] andView:self];
        label.font = [UIFont systemFontOfSize:13.0];
    }
    UILabel *lineLabel = [EBUtility labfrome:CGRectMake(0, 93, self.frame.size.width, 0.5) andText:@"" andColor:nil andView:self];
    lineLabel.backgroundColor = [UIColor colorFromHexString:@"b2b2b2"];
    UIButton *btn = [EBUtility btnfrome:CGRectMake(0, 93.5, SCREEN_WIDTH, 48) andText:@"取消" andColor:[UIColor colorFromHexString:@"333333"] andimg:nil andView:self];
    [btn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
}

- (void)shareSelector:(UIButton *)sender {
    NSString *type = objc_getAssociatedObject(sender, @"btn_type");
    if (self.confirmShareBlock) {
        self.confirmShareBlock(type);
    }
}

- (void)show {
    [self configUI];
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
}

@end
