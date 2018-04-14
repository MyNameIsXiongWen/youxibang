//
//  MineScrollTableViewCell.m
//  ChuXing
//
//  Created by dingyi on 2017/10/9.
//  Copyright © 2017年 Dingyi. All rights reserved.
//

#import "MineScrollTableViewCell.h"


@implementation MineScrollTableViewCell

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
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.page = 1;
    if (self) {
        self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH - 20, 100)];
        self.scrollView.delegate = self;
        [self.viewForLastBaselineLayout addSubview:self.scrollView];
        
    }
    
    return self;
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    CGFloat x = scrollView.contentOffset.x+SCREEN_WIDTH;
    if (x >= scrollView.contentSize.width + 50) {
        
        self.page ++;
        if ([self.delegate respondsToSelector:@selector(mineScroll:withIndex:)]) {
            [self.delegate mineScroll:self withIndex:self.page];
        }
    }
}



-(void)initCellWithAry:(NSArray*)ary{
    for (UIView* i in self.scrollView.subviews){
        if (i.tag == 100){
            [i removeFromSuperview];
        }
    }
    self.scrollView.contentSize = CGSizeMake(ary.count * 60, 0);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.backgroundColor = [UIColor whiteColor];
    for(int i = 0; i < ary.count; i++){
        UIView* view = [[UIView alloc]initWithFrame:CGRectMake(i * 60, 10, 60, 100)];
        view.tag = 100;
        view.backgroundColor = [UIColor whiteColor];
        NSMutableDictionary *model = ary[i];
        UIImageView* img = [EBUtility imgfrome:CGRectMake(5, 0, 50, 50) andImg:[UIImage imageNamed:@"ico_head"] andView:view];
        [img sd_setImageWithURL:[NSURL URLWithString:model[@"photo"]] placeholderImage:[UIImage imageNamed:@"ico_head"]];
        img.layer.masksToBounds = 1;
        img.layer.cornerRadius = 25;
        
        UILabel* lab1 = [EBUtility labfrome:CGRectZero andText:[NSString stringWithFormat:@"¥%@",model[@"price"]] andColor:[UIColor blackColor] andView:view];
        lab1.textAlignment = 0;
        lab1.numberOfLines = 2;
        
        [lab1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(img.mas_centerX);
            make.top.equalTo(img.mas_bottom).offset(10);
            
            make.height.equalTo(@15);
        }];
//        ids = model[@"ids"];
        [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickSmallScroll:)]];
        [self.scrollView addSubview:view];
    }
    
    [self reloadInputViews];
}

-(void)clickSmallScroll:(UITapGestureRecognizer *)tap
{
//    CarDetailsViewController *vc = [[CarDetailsViewController alloc] initWithId:ids];
//    [[self getCurrentViewController].navigationController pushViewController:vc animated:YES];
}

-(UIViewController *)getCurrentViewController{
    UIResponder *next = [self nextResponder];
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        next = [next nextResponder];
    } while (next != nil);
    return nil;
}
@end

