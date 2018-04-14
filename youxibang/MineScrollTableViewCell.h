//
//  MineScrollTableViewCell.h
//  ChuXing
//
//  Created by dingyi on 2017/10/9.
//  Copyright © 2017年 Dingyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MineScrollTableViewCell;
@protocol MineScrollDelegate<NSObject>

-(void)mineScroll:(MineScrollTableViewCell *)cell withIndex:(NSInteger)index;
@end
@interface MineScrollTableViewCell : UITableViewCell<UIScrollViewDelegate>
@property(nonatomic,strong) UIScrollView* scrollView;

@property (nonatomic, strong)NSMutableArray * dataArray;
@property (nonatomic, assign)id<MineScrollDelegate> delegate;
@property (nonatomic, assign)NSInteger page;
@property (nonatomic, copy)NSString *ids;
-(void)initCellWithAry:(NSArray*)ary;
@end

