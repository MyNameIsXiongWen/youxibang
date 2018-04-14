//
//  HomeCollectionViewCell.m
//  youxibang
//
//  Created by y on 2018/1/18.
//

#import "HomeCollectionViewCell.h"

@implementation HomeCollectionViewCell
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
    UIImageView* img = [EBUtility imgfrome:CGRectZero andImg:[UIImage imageNamed:@"navi_bg"] andView:self.viewForLastBaselineLayout];
    self.imgv = img;
    img.layer.cornerRadius = 5;
    img.layer.masksToBounds = YES;
    [img mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.viewForLastBaselineLayout.mas_top);
        make.left.equalTo(self.viewForLastBaselineLayout.mas_left);
        make.right.equalTo(self.viewForLastBaselineLayout.mas_right);
        make.height.equalTo(self.viewForLastBaselineLayout.mas_width);
    }];
    
    UILabel* nameLab = [EBUtility labfrome:CGRectZero andText:@"昵称" andColor:[UIColor blackColor] andView:self.viewForLastBaselineLayout];
    self.nameLab = nameLab;
    nameLab.textAlignment = 0;
    nameLab.font = [UIFont systemFontOfSize:15];
    
    UIImageView* tag = [EBUtility imgfrome:CGRectZero andImg:[UIImage imageNamed:@"ico_dota"] andView:self.viewForLastBaselineLayout];
    tag.layer.cornerRadius = 3;
    tag.layer.masksToBounds = YES;
    self.tagImage = tag;
    
    self.gradeLab = [EBUtility labfrome:CGRectZero andText:@" 法师\t" andColor:[UIColor whiteColor] andView:self.viewForLastBaselineLayout];
    self.gradeLab.backgroundColor = [UIColor purpleColor];
    self.gradeLab.layer.cornerRadius = 5;
    self.gradeLab.font = [UIFont systemFontOfSize:11];
    self.gradeLab.layer.masksToBounds = YES;
    
    UILabel* price = [EBUtility labfrome:CGRectZero andText:@"15元/小时" andColor:[UIColor redColor] andView:self.viewForLastBaselineLayout];
    self.priceLab = price;
    price.font = [UIFont systemFontOfSize:14];
    price.textAlignment = 2;
    [price sizeToFit];
    UILabel* time = [EBUtility labfrome:CGRectZero andText:@"1小时前" andColor:[UIColor grayColor] andView:self.viewForLastBaselineLayout];
    self.timeLab = time;
    time.font = [UIFont systemFontOfSize:13];
    time.textAlignment = 2;
    [nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(img.mas_bottom).offset(5);
        make.left.equalTo(self.viewForLastBaselineLayout.mas_left);

    }];
    [tag mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameLab.mas_bottom).offset(5);
        make.left.equalTo(self.viewForLastBaselineLayout.mas_left);
        make.width.equalTo(@20);
        make.height.equalTo(@20);
    }];
    [self.gradeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameLab.mas_bottom).offset(5);
        make.left.equalTo(tag.mas_right).offset(5);
        make.height.equalTo(@20);
    }];
    [price mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(img.mas_bottom).offset(6);
        make.right.equalTo(self.viewForLastBaselineLayout.mas_right);
        make.left.equalTo(nameLab.mas_right).offset(5);

    }];
    [time mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(price.mas_bottom).offset(7);
        make.right.equalTo(self.viewForLastBaselineLayout.mas_right);
        make.left.equalTo(self.gradeLab.mas_right);
        
    }];
    
}
- (void)setInfoWith:(NSDictionary*)dic{
    self.nameLab.text = [NSString stringWithFormat:@"%@",dic[@"nickname"]];
    self.priceLab.text = [NSString stringWithFormat:@"%@",dic[@"price"]];
    self.timeLab.text = [NSString stringWithFormat:@"%@",dic[@"last_login"]];
    self.gradeLab.text = [NSString stringWithFormat:@" %@\t",dic[@"duanwei"]];
    self.gradeLab.backgroundColor = [EBUtility colorWithHexString:[NSString stringWithFormat:@"%@",dic[@"fontcolor"]] alpha:1];
    if (iPhone5){
        self.nameLab.font = [UIFont systemFontOfSize:10];
        self.priceLab.font = [UIFont systemFontOfSize:10];
        self.timeLab.font = [UIFont systemFontOfSize:10];
        self.gradeLab.font = [UIFont systemFontOfSize:10];
        if (self.timeLab.text.length > 7){
            self.timeLab.text = [[NSString stringWithFormat:@"%@",dic[@"last_login"]] substringToIndex:self.timeLab.text.length - 5];
        }
    }
    
    [self.imgv sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",dic[@"photo"]]] placeholderImage:[UIImage imageNamed:@"ico_head"]];
    [self.tagImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",dic[@"image"]]] placeholderImage:[UIImage imageNamed:@"ico_dota"]];
}
@end
