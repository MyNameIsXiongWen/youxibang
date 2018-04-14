//
//  PartTimeTableViewCell.m
//  youxibang
//
//  Created by y on 2018/1/26.
//

#import "PartTimeTableViewCell.h"

@implementation PartTimeTableViewCell

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
    self.title = [EBUtility labfrome:CGRectZero andText:@"订单主题" andColor:[UIColor blackColor] andView:self.viewForLastBaselineLayout];
    self.title.font = [UIFont systemFontOfSize:17];
    [self.title sizeToFit];
    self.name = [EBUtility labfrome:CGRectZero andText:@"发布者:" andColor:[UIColor blackColor] andView:self.viewForLastBaselineLayout];
    self.name.font = [UIFont systemFontOfSize:15];
    [self.name sizeToFit];
    self.price = [EBUtility labfrome:CGRectZero andText:@"¥0.00" andColor:[UIColor redColor] andView:self.viewForLastBaselineLayout];
    self.price.font = [UIFont systemFontOfSize:18];
    [self.price sizeToFit];
    self.time = [EBUtility labfrome:CGRectZero andText:@"总时间:" andColor:[UIColor blackColor] andView:self.viewForLastBaselineLayout];
    self.time.font = [UIFont systemFontOfSize:15];
    [self.time sizeToFit];
    self.deposit = [EBUtility labfrome:CGRectZero andText:@"保证金:" andColor:[UIColor blackColor] andView:self.viewForLastBaselineLayout];
    self.deposit.font = [UIFont systemFontOfSize:15];
    [self.deposit sizeToFit];
    
    UILabel* grayLine = [EBUtility labfrome:CGRectZero andText:@"" andColor:nil andView:self.viewForLastBaselineLayout];
    grayLine.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.viewForLastBaselineLayout.mas_top).offset(10);
        make.left.equalTo(self.viewForLastBaselineLayout.mas_left).offset(10);
        
    }];
    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.title.mas_bottom).offset(10);
        make.left.equalTo(self.viewForLastBaselineLayout.mas_left).offset(10);
        
    }];
    [self.deposit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.name.mas_bottom).offset(10);
        make.left.equalTo(self.viewForLastBaselineLayout.mas_left).offset(10);
        
    }];
    [self.time mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.name.mas_bottom).offset(10);
        make.left.equalTo(self.deposit.mas_right).offset(50);
        
    }];
    [self.price mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.title.mas_bottom).offset(10);
        make.right.equalTo(self.viewForLastBaselineLayout.mas_right).offset(-10);
        
    }];
    [grayLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.deposit.mas_bottom).offset(10);
        make.bottom.equalTo(self.viewForLastBaselineLayout.mas_bottom);
        make.left.equalTo(self.viewForLastBaselineLayout.mas_left);
        make.right.equalTo(self.viewForLastBaselineLayout.mas_right);
        make.height.equalTo(@10);
    }];
}
- (void)setViewWithDic:(NSDictionary*)dic{
    self.title.text = [NSString stringWithFormat:@"%@",dic[@"title"]];
    self.price.text = [NSString stringWithFormat:@"¥%@",dic[@"price"]];
    self.time.text = [NSString stringWithFormat:@"总时间:%@小时",dic[@"num"]];
    self.deposit.text = [NSString stringWithFormat:@"保证金:%@",dic[@"deposit"]];
    self.name.text = [NSString stringWithFormat:@"发布者:%@",dic[@"nickname"]];
    if (![EBUtility isBlankString:dic[@"addtime"]]){
        UILabel *time = [EBUtility labfrome:CGRectZero andText:[NSString stringWithFormat:@"%@",dic[@"addtime"]] andColor:[UIColor darkGrayColor] andView:self.viewForLastBaselineLayout];
        time.textAlignment = NSTextAlignmentRight;
        [time mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.title.mas_top).offset(2);
            make.right.equalTo(self.viewForLastBaselineLayout.mas_right).offset(-10);
        }];
    }
}
@end
