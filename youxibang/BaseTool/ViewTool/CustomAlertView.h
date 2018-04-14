//
//  CustomAlertView.h
//  ChuXing
//
//  Created by dingyi on 2017/10/9.
//  Copyright © 2017年 Dingyi. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^AlertResult)(NSInteger index);
typedef void(^AlertResult2)(NSString* date);
typedef void(^AlertResult3)(NSString* str);
@interface CustomAlertView : UIView
@property (nonatomic,copy) AlertResult resultIndex;
@property (nonatomic,copy) AlertResult2 resultDate;
@property (nonatomic,copy) AlertResult3 resultRemove;

@property (nonatomic,strong)UIImageView* img;
@property (nonatomic,strong)NSMutableString* textInput;
@property (nonatomic,strong)UIButton* btn;

- (instancetype)initWithImages:(NSArray*)ary Index:(NSInteger)tag;
- (instancetype)initWithVedio:(NSURL*)url;
- (instancetype)initWithType:(NSInteger)type;
- (instancetype)initWithUrl:(NSString*)url;
- (instancetype)initWithAry:(NSArray*)ary;
- (instancetype)initWithPicker:(NSArray *)ary;
- (instancetype)initWithCustomerDic:(NSDictionary*)dic;
- (instancetype)initWithSpecialDatePicker;
- (instancetype)initWithHeight:(float)height AndAry:(NSArray*)ary;
- (instancetype)initWithSiftWithHeight:(float)height AndTitleAry:(NSArray*)titleAry;
- (instancetype)initWithSiftList;
- (instancetype)initWithTitle:(NSString*)title Text:(NSString*)text AndType:(NSInteger)type;
- (void)showAlertView;
@end
