//
//  TopUpTableViewCell.h
//  ChuXing
//
//  Created by dingyi on 2017/9/30.
//  Copyright © 2017年 Dingyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TopUpTableViewCell;

@protocol TopUpTableViewCellDelegate <NSObject>

-(void)pushTopUpView:(NSInteger)tag;
@end

@interface TopUpTableViewCell : UITableViewCell
@property (nonatomic,weak)id<TopUpTableViewCellDelegate> delegate;
-(void)initCell;
@end

