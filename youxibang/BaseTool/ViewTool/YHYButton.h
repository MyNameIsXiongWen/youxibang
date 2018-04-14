//
//  YHYButton.h
//  deshanglouyu
//
//  Created by y on 2017/11/13.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, YHYButtonType) {
    YHYButtonTypeBottom = 0,
    YHYButtonTypeRight  = 1,
    YHYButtonTypeLeft   = 2,
    YHYButtonTypeTop    = 3
};
@interface YHYButton : UIButton
@property(nonatomic)YHYButtonType type;
@property(nonatomic,assign)float fontSize;
@property(nonatomic)CGSize imgSize;
- (instancetype)initWithFrame:(CGRect)frame ImageFrame:(CGSize)imgSize TextFont:(NSInteger)fontSize AndType:(YHYButtonType)type;
@end
