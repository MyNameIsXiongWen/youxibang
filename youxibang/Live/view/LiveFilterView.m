//
//  LiveFilterView.m
//  youxibang
//
//  Created by jiazhuo1 on 2018/4/24.
//

#import "LiveFilterView.h"
#import <Masonry.h>
#import "LiveFilterTableViewCell.h"

static NSString *const LIVEFILTERTABLEVIEW_ID = @"live_filter_tableview_id";
@implementation LiveFilterView 

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame WithFilterArray:(NSArray *)filterArray AndSelectedIndexArray:(NSMutableArray *)selectedArray {
    self = [super initWithFrame:frame];
    if (self) {
//        self.filterArray = @[@{@"是否在线":@[@"全部",@"在线",@"离线"]},@{@"直播类型":@[@"全部",@"游戏",@"娱乐",@"体育",@"户外",@"教育",@"其他"]},@{@"工作形式":@[@"全部",@"全职",@"兼职"]},@{@"直播经验":@[@"全部",@"1年",@"2年",@"3年",@"4年以上"]}];
        self.filterArray = filterArray;
        selectedIndexArray = selectedArray;
    }
    return self;
}

- (void)tapBlackView {
    [self dismiss];
}

- (void)configUI {
    self.blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 64+40, SCREEN_WIDTH, SCREEN_HEIGHT-40-64)];
    self.blackView.backgroundColor = [UIColor blackColor];
    self.blackView.alpha = 0;
    [[UIApplication sharedApplication].keyWindow addSubview:self.blackView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBlackView)];
    self.blackView.userInteractionEnabled = YES;
    [self.blackView addGestureRecognizer:tap];
    
    self.tableview = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
//    [self.tableview registerNib:[UINib nibWithNibName:@"LiveFilterTableViewCell" bundle:nil] forCellReuseIdentifier:LIVEFILTERTABLEVIEW_ID];
    [self addSubview:self.tableview];
    
    UIButton *clearBtn = [EBUtility btnfrome:CGRectZero andText:@"清除" andColor:[UIColor colorFromHexString:@"777777"] andimg:nil andView:self];
    clearBtn.backgroundColor = UIColor.whiteColor;
    [clearBtn addTarget:self action:@selector(clearFilter) forControlEvents:UIControlEventTouchUpInside];
    UIButton *confirmBtn = [EBUtility btnfrome:CGRectZero andText:@"确定" andColor:[UIColor whiteColor] andimg:nil andView:self];
    confirmBtn.backgroundColor = [UIColor colorFromHexString:@"4382ec"];
    [confirmBtn addTarget:self action:@selector(confirmFilter) forControlEvents:UIControlEventTouchUpInside];
    UILabel *lineLabel = [EBUtility labfrome:CGRectZero andText:@"" andColor:nil andView:self];
    lineLabel.backgroundColor = [UIColor colorFromHexString:@"cccccc"];
    [clearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-150*ADAPTATIONRATIO);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH/2, 52));
    }];
    [confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-150*ADAPTATIONRATIO);
        make.size.equalTo(clearBtn);
    }];
    [lineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self);
        make.height.mas_equalTo(0.5);
        make.bottom.mas_equalTo(clearBtn.mas_top);
    }];
    [self.tableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self);
        make.bottom.mas_equalTo(lineLabel.mas_top);
    }];
}

- (void)clearFilter {
    selectedIndexArray = NSMutableArray.array;
    for (id dic in self.filterArray) {
        [selectedIndexArray addObject:@(9999)];
    }
    [self.tableview reloadData];
    if (self.clearFilterBlock) {
        self.clearFilterBlock();
    }
}

- (void)confirmFilter {
    if (self.confirmFilterBlock) {
        self.confirmFilterBlock(selectedIndexArray);
    }
    [self dismiss];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filterArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger count = [[self.filterArray[indexPath.row] allValues].lastObject count];
    if (count%3 == 0) {
        count = (count/3);
    }
    else {
        count = (count/3 + 1);
    }
    return count*30+(count-1)*15+30+34;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [NSString stringWithFormat:@"cell%ld%ld",indexPath.section,indexPath.row];
    LiveFilterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"LiveFilterTableViewCell" owner:self options:nil] lastObject];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.typeLabel.text = [self.filterArray[indexPath.row] allKeys].lastObject;
    cell.typeNameArray = [self.filterArray[indexPath.row] allValues].lastObject;
    cell.selectedIndex = [selectedIndexArray[indexPath.row] integerValue];
    cell.selectedTypeBlock = ^(NSInteger index) {
        [selectedIndexArray replaceObjectAtIndex:indexPath.row withObject:@(index)];
    };
    return cell;
}

@end
