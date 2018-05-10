//
//  SYPromptBoxView.m
//  AJCash
//
//  Created by 熊文 on 16/11/11.
//  Copyright © 2016年 熊文. All rights reserved.
//

#import "SYPromptBoxView.h"

@implementation SYPromptBoxView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (SYPromptBoxView *)sharedInstance {
    static SYPromptBoxView *singletonInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singletonInstance = [[self alloc] init];
        singletonInstance.layer.cornerRadius = 15;
        singletonInstance.layer.masksToBounds = YES;
        singletonInstance.backgroundColor = [UIColor colorFromHexString:@"333333"];
    });
    return singletonInstance;
}

- (void)setPromptViewMessage:(NSString *)message
                 andDuration:(NSTimeInterval)duration{
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:14.0]};
    CGSize labelSize = [message boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 70, 40) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine attributes:dic context:nil].size;
    self.frame = CGRectMake((SCREEN_WIDTH - labelSize.width - 30) * 0.5, SCREEN_HEIGHT - 80, labelSize.width + 30, 30);
    self.alpha = 1;
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    [window addSubview:self];
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, labelSize.width, 20)];
    messageLabel.text = message;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.font = [UIFont systemFontOfSize:14.0];
    messageLabel.textColor = [UIColor whiteColor];
    [self addSubview:messageLabel];
    
    __block UIView *weakself = self;
    __block UILabel *weakLabel = messageLabel;
    [UIView animateWithDuration:duration animations:^{
        weakself.alpha = 0;
    } completion:^(BOOL finished){
        [weakLabel removeFromSuperview];
        [weakself removeFromSuperview];
    }];
}

@end
