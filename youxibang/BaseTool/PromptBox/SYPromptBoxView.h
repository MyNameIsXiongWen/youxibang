//
//  SYPromptBoxView.h
//  AJCash
//
//  Created by 熊文 on 16/11/11.
//  Copyright © 2016年 熊文. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    PromptBoxLocationBottom,
    PromptBoxLocationCenter,
    PromptBoxLocationTop,
} PromptBoxLocation;

@interface SYPromptBoxView : UIView

+ (instancetype)sharedInstance ;
- (void)setPromptViewMessage:(NSString *)message
                 andDuration:(NSTimeInterval)duration
              PromptLocation:(PromptBoxLocation)location;

@end
