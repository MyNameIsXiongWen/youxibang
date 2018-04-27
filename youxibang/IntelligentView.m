//
//  IntelligentView.m
//  youxibang
//
//  Created by jiazhuo1 on 2018/4/23.
//

#import "IntelligentView.h"

@implementation IntelligentView

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
        self.layer.borderColor = [UIColor colorFromHexString:@"dddddd"].CGColor;
        self.layer.borderWidth = 0.5;
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
    UILabel *sepLabel = [EBUtility labfrome:CGRectMake(0, 135, 135, 0.5) andText:@"" andColor:nil andView:self];
    sepLabel.backgroundColor = [UIColor colorFromHexString:@"dddddd"];
    self.nameLabel = [EBUtility labfrome:CGRectMake(5, 140, 125, 14.5) andText:@"" andColor:[UIColor colorFromHexString:@"333333"] andView:self];
    self.nameLabel.textAlignment = NSTextAlignmentLeft;
    self.nameLabel.font = [UIFont systemFontOfSize:12.0];
    self.priceLabel = [EBUtility labfrome:CGRectMake(5, 160, 65, 15) andText:@"" andColor:[UIColor colorFromHexString:@"457fea"] andView:self];
    self.priceLabel.textAlignment = NSTextAlignmentLeft;
    self.priceLabel.font = [UIFont systemFontOfSize:12.0];
    self.timeLabel = [EBUtility labfrome:CGRectMake(70, 160, 50, 15) andText:@"" andColor:[UIColor colorFromHexString:@"aaaaaa"] andView:self];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    self.timeLabel.font = [UIFont systemFontOfSize:11.0];
    
}

@end
