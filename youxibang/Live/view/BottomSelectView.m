//
//  BottomSelectView.m
//  AJCash
//
//  Created by 撒加 on 17/6/7.
//  Copyright © 2017年 熊文. All rights reserved.
//

#import "BottomSelectView.h"
#import "BottomSelectTableViewCell.h"


static NSString * Bank_Bottom = @"bankBottom";
@interface BottomSelectView()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)UIView *bkgView;
@property (nonatomic, strong)NSArray *dataArray;
@property (nonatomic, copy)NSString *titleString;
@property (nonatomic, assign)NSInteger selectedNum;
@end
@implementation BottomSelectView

- (instancetype)initWithBottomWithTitle:(NSString *)title stringsArray:(NSArray *)array selectedNumber:(NSInteger)num{
    if (self = [super init]) {
        self.backgroundColor = [UIColor colorFromHexString:@"f6f6f6"];
        self.dataArray = [NSMutableArray arrayWithArray:array];
        self.titleString = title;
        self.selectedNum = num;
    }
    return self;
}

- (void)show {
    if (self.dataArray.count <= 5) {//最多同时显示5个
            self.frame = CGRectMake(0, SCREEN_HEIGHT -1, SCREEN_WIDTH, self.dataArray.count*44+44+44+10);
    }else {
            self.frame = CGRectMake(0, SCREEN_HEIGHT -1, SCREEN_WIDTH, 5*44+44+44+10);
    }

    UILabel *titleLabel = [self setWithMainLabelFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44) titleString:self.titleString];
    [self addSubview:titleLabel];
    [self initWithConfignTableView];
    UIButton *cancleButton = [self setWithCancleButton];
    [self addSubview:cancleButton];
    self.bkgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.bkgView.backgroundColor = UIColor.blackColor;
    self.bkgView.alpha = 0.5;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickOnbkgView:)];
    self.bkgView.userInteractionEnabled = YES;
    [self.bkgView addGestureRecognizer:tap];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.bkgView];
    [window addSubview:self];
    [self.tableView reloadData];
    [UIView animateWithDuration:0.25f animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, -self.bounds.size.height);
    }];
}

- (void)dismiss {
    [UIView animateWithDuration:0.25f animations:^{
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self.bkgView removeFromSuperview];
        [self removeFromSuperview];
    }];
}

- (void)clickOnbkgView:(UITapGestureRecognizer *)sender {
    if ([self.delegate respondsToSelector:@selector(BottomSelectViewClickedOnCell:clickedTag:WithDataArray:)]) {
        [self.delegate BottomSelectViewClickedOnCell:self clickedTag:self.selectedNum WithDataArray:self.dataArray];
    }
    [self dismiss];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *string = self.dataArray[indexPath.row];
    BottomSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Bank_Bottom forIndexPath:indexPath];
    cell.mainLabel.text = string;
    if (indexPath.row == self.selectedNum) {
        cell.choiceImageView.hidden = NO;
    }else {
        cell.choiceImageView.hidden = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.delegate respondsToSelector:@selector(BottomSelectViewClickedOnCell:clickedTag:WithDataArray:)]) {
        [self.delegate BottomSelectViewClickedOnCell:self clickedTag:indexPath.row WithDataArray:self.dataArray];
    }
    [self dismiss];
}

- (UILabel *)setWithMainLabelFrame:(CGRect)frame titleString:(NSString *)title {
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
    label.text = title;
    label.textColor = [UIColor colorFromHexString:@"333333"];
    label.font = [UIFont systemFontOfSize:16];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

- (UIButton *)setWithCancleButton {
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, self.bounds.size.height - 44, SCREEN_WIDTH, 44)];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button addTarget:self action:@selector(clickedOnCancleButton:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"取消" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorFromHexString:@"333333"] forState:UIControlStateNormal];
    button.backgroundColor = UIColor.whiteColor;
    return button;
}

- (void)clickedOnCancleButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(BottomSelectViewClickedOnCancleButton:)]) {
        [self.delegate BottomSelectViewClickedOnCancleButton:self];
    }
    [self dismiss];
}

- (void)initWithConfignTableView {
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, self.bounds.size.height - 44- 10 -44) style:UITableViewStylePlain];
    [self addSubview:self.tableView];
    self.tableView.backgroundColor = [UIColor colorFromHexString:@"f6f6f6"];
    self.tableView.delegate = self;
    self.tableView.dataSource  = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"BottomSelectTableViewCell" bundle:nil] forCellReuseIdentifier:Bank_Bottom];
}


@end
