//
//  BottomSelectView.h
//  AJCash
//
//  Created by 撒加 on 17/6/7.
//  Copyright © 2017年 熊文. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BottomSelectView;
@protocol BottomSelectViewDelegate <NSObject>
@optional

- (void)BottomSelectViewClickedOnCancleButton:(BottomSelectView *)view;

- (void)BottomSelectViewClickedOnCell:(BottomSelectView *)view clickedTag:(NSInteger)tag WithDataArray:(NSArray *)array;

@end
@interface BottomSelectView : UIView
@property (nonatomic, assign)id<BottomSelectViewDelegate>delegate;
- (instancetype)initWithBottomWithTitle:(NSString *)title stringsArray:(NSArray *)array selectedNumber:(NSInteger)num;
- (void)show;
- (void)dismiss;
@end
