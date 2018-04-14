//
//  ScrollTitleView.h
//  deshanglouyu
//
//  Created by y on 2017/11/16.
//

#import <UIKit/UIKit.h>

@protocol ScrollTitleViewDelegate <NSObject>

-(void)touchTitle:(NSInteger)tag;
@end

@interface ScrollTitleView : UIView
@property (nonatomic, strong)NSMutableArray * btnAry;
@property (nonatomic,strong)UIButton* selectedTitleButton;
@property (nonatomic,strong)UIView* indicatorView;
@property (nonatomic, strong)UIColor * color;

-(void)initCellWithTitles:(NSArray*)titles Tag:(NSInteger)tag WithColor:(UIColor *)color;

@property (nonatomic,weak)id<ScrollTitleViewDelegate> delegate;

@end

