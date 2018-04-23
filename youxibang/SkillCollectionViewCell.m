//
//  SkillCollectionViewCell.m
//  youxibang
//
//  Created by y on 2018/2/6.
//

#import "SkillCollectionViewCell.h"

@implementation SkillCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addAllViews];
    }
    return self;
}

- (void)addAllViews{
    for (UIView *i in self.viewForLastBaselineLayout.subviews){
        [i removeFromSuperview];
    }
    UIImageView* img = [EBUtility imgfrome:CGRectMake(0, 0, 60, 60) andImg:[UIImage imageNamed:@"ico_dota"] andView:self.viewForLastBaselineLayout];
    img.center = CGPointMake(self.viewForLastBaselineLayout.width/2, self.viewForLastBaselineLayout.height/2 - 5);
    self.imgv = img;
    img.layer.cornerRadius = 5;
    img.layer.masksToBounds = YES;
    
    UILabel* lab = [EBUtility labfrome:CGRectMake(0, 0, self.viewForLastBaselineLayout.width, 20) andText:@"技能名" andColor:[UIColor blackColor] andView:self.viewForLastBaselineLayout];
    lab.textAlignment = 1;
    lab.center = CGPointMake(self.viewForLastBaselineLayout.width/2, self.viewForLastBaselineLayout.height/2 + 40);
    self.nameLab = lab;
}
- (void)setInfoWith:(NSDictionary*)dic{
    [self.imgv sd_setImageWithURL:[NSURL URLWithString:dic[@"image"]]];
    self.nameLab.text = dic[@"title"];
    self.pid = [NSString stringWithFormat:@"%@",dic[@"id"]];
}
@end
