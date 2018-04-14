//
//  BabyTableViewCell.m
//  youxibang
//
//  Created by y on 2018/3/2.
//

#import "BabyTableViewCell.h"

@implementation BabyTableViewCell

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
    self.name = [EBUtility labfrome:CGRectZero andText:@"名称" andColor:[UIColor blackColor] andView:self.viewForLastBaselineLayout];
    self.name.font = [UIFont systemFontOfSize:18];
    [self.name sizeToFit];
    self.grade = [EBUtility labfrome:CGRectZero andText:@"♂" andColor:[UIColor whiteColor] andView:self.viewForLastBaselineLayout];
    self.grade.backgroundColor = Nav_color;
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
    
    [self.grade mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.name.mas_bottom).offset(10);
        make.left.equalTo(self.imgv.mas_right).offset(10);
        
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
- (void)setViewWithDic:(NSDictionary*)dic{
}
@end
