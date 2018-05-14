//
//  LivePayView.m
//  youxibang
//
//  Created by jiazhuo1 on 2018/4/27.
//

#import "LivePayView.h"

@implementation LivePayView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (instancetype)initWithFrame:(CGRect)frame Price:(NSString *)price {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        payPrice = price;
    }
    return self;
}

- (void)tapBlackView {
    [self dismiss];
}

- (void)configUI {
    self.blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.blackView.backgroundColor = [UIColor blackColor];
    self.blackView.alpha = 0;
    [[UIApplication sharedApplication].keyWindow addSubview:self.blackView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBlackView)];
    self.blackView.userInteractionEnabled = YES;
    [self.blackView addGestureRecognizer:tap];
    
    UIImageView *bkgImgView = [EBUtility imgfrome:self.bounds andImg:[UIImage imageNamed:@"live_pay_bkg"] andView:self];
    UILabel *titleLabel = [EBUtility labfrome:CGRectMake(0, 100, self.frame.size.width, 25) andText:self.titleString andColor:[UIColor colorFromHexString:@"333333"] andView:self];
    titleLabel.font = [UIFont systemFontOfSize:17.0];
    UILabel *lineLabel = [EBUtility labfrome:CGRectMake(0, 150, self.frame.size.width, 0.5) andText:@"" andColor:nil andView:self];
    lineLabel.backgroundColor = [UIColor colorFromHexString:@"b2b2b2"];
    UITableView *tableview = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableview.backgroundColor = UIColor.clearColor;
    tableview.delegate = self;
    tableview.dataSource = self;
    tableview.scrollEnabled = NO;
    tableview.rowHeight = 45;
    [self addSubview:tableview];
    [tableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(10);
        make.right.mas_equalTo(self.mas_right).offset(-25);
        make.top.mas_equalTo(lineLabel.mas_bottom);
        make.bottom.mas_equalTo(self.mas_bottom);
    }];
}

- (void)show {
    [self configUI];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25f animations:^{
            self.blackView.alpha = 0.5;
            self.alpha = 1;
        }completion:^(BOOL finished) {
            self.blackView.hidden = NO;
        }];
    });
}

- (void)dismiss {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25f animations:^{
            self.blackView.alpha = 0;
            self.alpha = 0;
        } completion:^(BOOL finished) {
            self.blackView.hidden = YES;
            [self removeFromSuperview];
            [self.blackView removeFromSuperview];
        }];
    });
}

#pragma mark - tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.showBuyVip) {
        return 3;
    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *titleArray = @[[NSString stringWithFormat:@"付费解锁（%@元）",payPrice],@"取消"];
    if (self.showBuyVip) {
        titleArray = @[[NSString stringWithFormat:@"付费解锁（%@元）",payPrice],@"成为会员，免费观看",@"取消"];
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"identifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"identifier"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    UILabel *label = [EBUtility labfrome:CGRectMake(0, 10, self.frame.size.width-25, 25) andText:titleArray[indexPath.row] andColor:[UIColor colorFromHexString:@"457fea"] andView:cell.contentView];
    label.backgroundColor = UIColor.clearColor;
    label.font = [UIFont systemFontOfSize:16.0];
    if (indexPath.row == 0) {
        label.textColor = [UIColor colorFromHexString:@"ff3b30"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.showBuyVip) {
        if (indexPath.row == 2) {
            [self dismiss];
        }
        else {
            if (self.confirmSelecrBlock) {
                self.confirmSelecrBlock(indexPath.row);
            }
        }
    }
    else {
        if (indexPath.row == 1) {
            [self dismiss];
        }
        else {
            if (self.confirmSelecrBlock) {
                self.confirmSelecrBlock(indexPath.row);
            }
        }
    }
}

@end
