//
//  CALayer+Addition.m
//  youxibang
//
//  Created by y on 2018/1/31.
//

#import "CALayer+Addition.h"
#import <objc/runtime.h>

@implementation CALayer (Additions)

- (UIColor *)borderColorFromUIColor {
    
    return objc_getAssociatedObject(self, @selector(borderColorFromUIColor));
    
}

-(void)setBorderColorFromUIColor:(UIColor *)color

{
    
    objc_setAssociatedObject(self, @selector(borderColorFromUIColor), color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setBorderColorFromUI:[self borderColorFromUIColor]];
    
}

- (void)setBorderColorFromUI:(UIColor *)color

{
    
    self.borderColor = color.CGColor;
    
    //    NSLog(@"%@", color);
    
}


@end
