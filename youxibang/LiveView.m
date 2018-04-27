//
//  LiveView.m
//  youxibang
//
//  Created by jiazhuo1 on 2018/4/23.
//

#import "LiveView.h"

@implementation LiveView

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
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 4;
        self.layer.masksToBounds = YES;
        [self configUI];
    }
    return self;
}

- (void)configUI {
    self.imageView = [EBUtility imgfrome:CGRectMake(0, 0, 135, 135) andImg:nil andView:self];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.userInteractionEnabled = YES;
}

@end
