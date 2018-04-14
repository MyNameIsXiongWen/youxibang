//
//  UIImageView+Extension.h
//  DChang
//
//  Created by 戎博 on 2017/9/20.
//  Copyright © 2017年 昆博. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIImageView (Extension)

@property (nonatomic, strong)NSArray * url;
-(void)clickImageView:(UITapGestureRecognizer *)tap;
+(UIImage*) OriginImage:(UIImage *)image scaleToSize:(CGSize)size;

@end
