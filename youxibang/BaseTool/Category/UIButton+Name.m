//
//  UIButton+Name.m
//  DChang
//
//  Created by 戎博 on 2017/9/21.
//  Copyright © 2017年 昆博. All rights reserved.
//

#import "UIButton+Name.h"
#import <objc/runtime.h>
@implementation UIButton (Name)



-(NSString *)imageUrl
{
    return objc_getAssociatedObject(self, @"imageUrl");
}

-(void)setImageUrl:(NSString *)imageUrl
{
    objc_setAssociatedObject(self, @"imageUrl", imageUrl, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
