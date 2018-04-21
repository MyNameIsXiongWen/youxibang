//
//  SearchTableViewCell.m
//  youxibang
//
//  Created by y on 2018/1/19.
//

#import "SearchTableViewCell.h"

@implementation SearchTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initCellView];
    }
    return self;
}
- (void)initCellView{
    self.imgv = [EBUtility imgfrome:CGRectZero andImg:[UIImage imageNamed:@"navi_bg"] andView:self.viewForLastBaselineLayout];
    self.imgv.layer.masksToBounds = YES;
    self.imgv.layer.cornerRadius = 30;
    
    UIView* tag = [EBUtility viewfrome:CGRectZero andColor:nil andView:self.viewForLastBaselineLayout];
    self.tagImage = tag;
    
    self.name = [EBUtility labfrome:CGRectZero andText:@"名称" andColor:[UIColor blackColor] andView:self.viewForLastBaselineLayout];
    self.name.font = [UIFont systemFontOfSize:18];
    [self.name sizeToFit];
    
    self.age = [EBUtility labfrome:CGRectZero andText:@"♂" andColor:[UIColor whiteColor] andView:self.viewForLastBaselineLayout];
    self.age.backgroundColor = Nav_color;
    self.age.layer.cornerRadius = 5;
    self.age.font = [UIFont systemFontOfSize:11];
    self.age.layer.masksToBounds = YES;
    
    self.grade = [EBUtility labfrome:CGRectZero andText:@" 法师\t" andColor:[UIColor whiteColor] andView:self.viewForLastBaselineLayout];
    self.grade.backgroundColor = [UIColor purpleColor];
    self.grade.layer.cornerRadius = 5;
    self.grade.font = [UIFont systemFontOfSize:11];
    self.grade.layer.masksToBounds = YES;
    
    self.price = [EBUtility labfrome:CGRectZero andText:@"¥0/小时" andColor:[UIColor redColor] andView:self.viewForLastBaselineLayout];
    self.price.font = [UIFont systemFontOfSize:15];
    [self.price sizeToFit];
    self.times = [EBUtility labfrome:CGRectZero andText:@"接单次|小时前" andColor:[UIColor lightGrayColor] andView:self.viewForLastBaselineLayout];
    self.times.font = [UIFont systemFontOfSize:13];
    [self.times sizeToFit];
    [self.imgv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.viewForLastBaselineLayout.mas_top).offset(10);
        make.left.equalTo(self.viewForLastBaselineLayout.mas_left).offset(10);
        make.bottom.equalTo(self.viewForLastBaselineLayout.mas_bottom).offset(-10);
        make.height.equalTo(@60);
        make.width.equalTo(@60);
    }];
    
    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.viewForLastBaselineLayout.mas_top).offset(15);
        make.left.equalTo(self.imgv.mas_right).offset(10);
    }];
    [tag mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.name.mas_bottom).offset(5);
        make.left.equalTo(self.name.mas_left);
        make.width.equalTo(@20);
        make.height.equalTo(@20);
    }];
    [self.grade mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.tagImage.mas_centerY);
        make.left.equalTo(self.tagImage.mas_right).offset(10);
        make.height.equalTo(@20);
    }];
    [self.age mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.name.mas_centerY);
        make.left.equalTo(self.name.mas_right).offset(10);
        make.height.equalTo(@20);
    }];
    [self.price mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.viewForLastBaselineLayout.mas_top).offset(15);
        make.right.equalTo(self.viewForLastBaselineLayout.mas_right).offset(-10);
        
    }];
    [self.times mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.price.mas_bottom).offset(10);
        make.right.equalTo(self.viewForLastBaselineLayout.mas_right).offset(-10);
        
    }];
}
- (void)setViewWithDic:(NSDictionary*)dic withType:(int)type{
    self.name.text = [NSString stringWithFormat:@"%@",dic[@"nickname"]];
    self.price.text = [NSString stringWithFormat:@"¥%@",dic[@"price"]];
    self.times.text = [NSString stringWithFormat:@"接单%@次|%@",dic[@"ordernum"]?:@"0",dic[@"last_login"]];
    
    self.grade.backgroundColor = [EBUtility colorWithHexString:[NSString stringWithFormat:@"%@",dic[@"fontcolor"]] alpha:1];
    if ([NSString stringWithFormat:@"%@",dic[@"sex"]].integerValue == 1){
        self.age.text = [NSString stringWithFormat:@" ♂%@岁\t",dic[@"birthday"]];
        self.age.backgroundColor = Nav_color;
    }else{
        self.age.text = [NSString stringWithFormat:@" ♀%@岁\t",dic[@"birthday"]];
        self.age.backgroundColor = Pink_color;
    }
    
    [self.imgv sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",dic[@"photo"]]] placeholderImage:[UIImage imageNamed:@"ico_head"]];
    
    for (UIView* i in self.tagImage.subviews){
        [i removeFromSuperview];
    }
    if (type == 0){
        self.grade.hidden = YES;
        for (int i = 0; i < ((NSArray*)dic[@"image"]).count; i ++){
            UIImageView* img = [EBUtility imgfrome:CGRectMake(25 * i, 0, 20, 20) andImg:[UIImage imageNamed:@"ico_dota"] andView:self.tagImage];
            img.layer.cornerRadius = 3;
            img.layer.masksToBounds = YES;
            
            [img sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",dic[@"image"][i]]] placeholderImage:[UIImage imageNamed:@"ico_dota"]];
        }
    }else if (type == 1){
        self.grade.text = [NSString stringWithFormat:@" %@\t",dic[@"duanwei"]];
        UIImageView* img = [EBUtility imgfrome:CGRectMake(0, 0, 20, 20) andImg:[UIImage imageNamed:@"ico_dota"] andView:self.tagImage];
        img.layer.cornerRadius = 3;
        img.layer.masksToBounds = YES;
        
        [img sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",dic[@"image"]]] placeholderImage:[UIImage imageNamed:@"ico_dota"]];
    }else if (type == 2){
        self.age.hidden = YES;
        [self.tagImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@0);
        }];
        if ([NSString stringWithFormat:@"%@",dic[@"sex"]].integerValue == 1){
            self.grade.text = [NSString stringWithFormat:@" ♂%@岁\t",dic[@"birthday"]];
            self.grade.backgroundColor = Nav_color;
        }else{
            self.grade.text = [NSString stringWithFormat:@" ♀%@岁\t",dic[@"birthday"]];
            self.grade.backgroundColor = Pink_color;
        }
        self.price.text = [NSString stringWithFormat:@"¥%@",dic[@"totalprice"]];
        self.times.text = [NSString stringWithFormat:@"接单%@次",dic[@"ordernum"]?:@"0"];
    }
    
    
}
@end
