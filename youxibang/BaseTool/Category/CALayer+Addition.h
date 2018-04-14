//
//  CALayer+Addition.h
//  youxibang
//
//  Created by y on 2018/1/31.
//

#import <QuartzCore/QuartzCore.h>

#import <UIKit/UIKit.h>

@interface CALayer (Additions)

@property(nonatomic, strong) UIColor *borderColorFromUIColor;

- (void)setBorderColorFromUIColor:(UIColor *)color;
@end
