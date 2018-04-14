//
//  UIImageView+Extension.m
//  DChang
//
//  Created by 戎博 on 2017/9/20.
//  Copyright © 2017年 昆博. All rights reserved.
//

#import "UIImageView+Extension.h"
#import <objc/runtime.h>



@implementation UIImageView (Extension)

+(UIImage*) OriginImage:(UIImage *)image scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);  //size 为CGSize类型，即你所需要的图片尺寸
    
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;   //返回的就是已经改变的图片
}
-(NSString *)url
{
    return objc_getAssociatedObject(self, @"url");
}

-(void)setUrl:(NSString *)url 
{
    objc_setAssociatedObject(self, @"url", url, OBJC_ASSOCIATION_COPY_NONATOMIC);
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer * PrivateLetterTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickImageView:)];
    PrivateLetterTap.numberOfTouchesRequired = 1; //手指数
    PrivateLetterTap.numberOfTapsRequired = 1; //tap次数

    [self.viewForFirstBaselineLayout addGestureRecognizer:PrivateLetterTap];
}

-(void)clickImageView:(UITapGestureRecognizer *)tap
{
//    UIViewController *vc = [self getCurrentViewController];
    if (self.url.count != 0) {
        CustomAlertView* alert = [[CustomAlertView alloc]initWithImages:self.url Index:self.tag];
        [alert showAlertView];
    }
    
}
-(UIViewController *)getCurrentViewController{
    UIResponder *next = [self nextResponder];
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        next = [next nextResponder];
    } while (next != nil);
    return nil;
}
@end
