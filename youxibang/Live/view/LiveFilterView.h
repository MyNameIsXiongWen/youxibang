//
//  LiveFilterView.h
//  youxibang
//
//  Created by jiazhuo1 on 2018/4/24.
//

#import <UIKit/UIKit.h>

typedef void(^DismissFilterBlock)(void);
typedef void(^ConfirmFilterBlock)(NSMutableArray *array);

@interface LiveFilterView : UIView <UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *selectedIndexArray;
}

@property (nonatomic, strong) UITableView *tableview;
@property (copy, nonatomic) DismissFilterBlock dismissFilterBlock;
@property (copy, nonatomic) ConfirmFilterBlock confirmFilterBlock;
@property (nonatomic, strong) UIView *blackView;
@property (nonatomic, strong) NSArray *filterArray;
- (instancetype)initWithFrame:(CGRect)frame WithFilterArray:(NSArray *)array AndSelectedIndexArray:(NSMutableArray *)array;

- (void)show;
- (void)dismiss;

@end
