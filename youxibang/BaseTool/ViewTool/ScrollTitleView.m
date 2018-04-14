//
//  ScrollTitleView.m
//  deshanglouyu
//
//  Created by y on 2017/11/16.
//

#import "ScrollTitleView.h"

@implementation ScrollTitleView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


-(void)initCellWithTitles:(NSArray*)titles Tag:(NSInteger)tag WithColor:(UIColor *)color{
    self.btnAry = [[NSMutableArray alloc]init];
    self.backgroundColor = [UIColor whiteColor];
    UIScrollView *titlesView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 35)];
    titlesView.backgroundColor = [UIColor clearColor];
    [self.viewForLastBaselineLayout addSubview:titlesView];
    titlesView.contentSize = CGSizeMake(0, 0);
    titlesView.showsHorizontalScrollIndicator = NO;
    //self.titlesView = titlesView;
    
    NSUInteger count = titles.count;
    CGFloat titleButtonW = titlesView.width / count;
    CGFloat titleButtonH = titlesView.height;
    for (NSUInteger i = 0; i < count; i++) {
        UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        titleButton.tag = i;
        [titleButton addTarget:self action:@selector(titleClick:) forControlEvents:UIControlEventTouchUpInside];
        [titleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [titleButton setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        
        [titleButton setAttributedTitle:[[NSAttributedString alloc]initWithString:titles[i] attributes:@{NSFontAttributeName :[UIFont systemFontOfSize:15]}] forState:UIControlStateNormal];
        [titlesView addSubview:titleButton];
        
        // 设置数据
        [titleButton setTitle:titles[i] forState:UIControlStateNormal];
        
        // 设置frame
        titleButton.frame = CGRectMake(i * titleButtonW, 0, titleButtonW, titleButtonH);
        [self.btnAry addObject:titleButton];
    }
    
    // 按钮的选中颜色
    UIButton *firstTitleButton = self.btnAry[tag];
    
    // 底部的指示器
    UIView *indicatorView = [[UIView alloc] init];
    indicatorView.backgroundColor = color;
    indicatorView.height = 1.5;
    indicatorView.y = titlesView.height - indicatorView.height;
    [titlesView addSubview:indicatorView];
    self.indicatorView = indicatorView;
    
    // 立刻根据文字内容计算label的宽度
    [firstTitleButton.titleLabel sizeToFit];
    indicatorView.width = firstTitleButton.titleLabel.width + 10;//(SCREEN_WIDTH - 80)/titles.count;
    indicatorView.centerX = firstTitleButton.centerX;
    
    // 默认情况 : 选中最前面的标题按钮
    firstTitleButton.selected = YES;
    self.selectedTitleButton = firstTitleButton; 
    
    
}

- (void)titleClick:(UIButton *)titleButton
{
    // 控制按钮状态
    self.selectedTitleButton.selected = NO;
    titleButton.selected = YES;
    self.selectedTitleButton = titleButton;
    
    // 指示器
    [UIView animateWithDuration:0.25 animations:^{
        self.indicatorView.width = titleButton.titleLabel.width+ 10;
        self.indicatorView.centerX = titleButton.centerX;
        
    }];
    if ([self.delegate respondsToSelector:@selector(touchTitle:)] ){
        [self.delegate touchTitle:titleButton.tag];
    }
}
@end


