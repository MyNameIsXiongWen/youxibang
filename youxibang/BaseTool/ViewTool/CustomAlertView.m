//
//  CustomAlertView.m
//  ChuXing
//
//  Created by dingyi on 2017/10/9.
//  Copyright © 2017年 Dingyi. All rights reserved.
//

#import "CustomAlertView.h"
#import <AVFoundation/AVFoundation.h>

#import "EBUtility.h"
#import "View+MASAdditions.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+Extension.h"
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
@interface CustomAlertView()<UITextViewDelegate,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate>
@property (nonatomic,retain) UIView *alertView;
@property (nonatomic,strong) UIDatePicker *picker;
@property (nonatomic,strong) UIPickerView *pv;
@property (nonatomic,strong) UIDatePicker *timePicker;
@property (nonatomic,strong) AVPlayer* player;
@property (nonatomic,strong) UITextView* tv;
@property (nonatomic,strong) UIScrollView* scroll;
@property (nonatomic,strong) UITableView* tableView;
@property (nonatomic,strong) NSArray* dataAry;

@property (nonatomic,strong) NSMutableArray* btnAry1;
@property (nonatomic,strong) NSMutableArray* btnAry2;
@property (nonatomic,strong) NSMutableArray* btnAry3;
@property (nonatomic,strong) NSMutableArray* requirement;
@end

@implementation CustomAlertView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithType:(NSInteger)type{
    if (self = [super init]) {
        self.frame = [UIScreen mainScreen].bounds;

        self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];

        UIButton* alphaBtn = [EBUtility btnfrome:[UIScreen mainScreen].bounds andText:@"" andColor:[UIColor clearColor] andimg:nil andView:self];
        [alphaBtn addTarget:self action:@selector(remove) forControlEvents:UIControlEventTouchUpInside];
        self.alertView = [[UIView alloc] init];
        self.alertView.backgroundColor = [UIColor whiteColor];

        [self addSubview:self.alertView];

        if (type == 0){
            self.alertView.frame = CGRectMake(0, SCREEN_HEIGHT - 300, SCREEN_WIDTH, 300);
            self.alertView.backgroundColor = [UIColor groupTableViewBackgroundColor];
            UIButton* s = [EBUtility btnfrome:CGRectZero andText:@"完成" andColor:[UIColor blackColor] andimg:nil andView:self.alertView];
            [s addTarget:self action:@selector(datepick:) forControlEvents:UIControlEventTouchUpInside];
            UIDatePicker* picker = [[UIDatePicker alloc]initWithFrame:CGRectZero];
            picker.datePickerMode = UIDatePickerModeDate;
            picker.backgroundColor = [UIColor groupTableViewBackgroundColor];
            picker.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
            self.picker = picker;
            picker.maximumDate = [NSDate date];
            picker.minimumDate = [NSDate dateWithTimeIntervalSince1970:0];
            [self.alertView addSubview:picker];
            
            [s mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.alertView.mas_right);
                make.top.equalTo(self.alertView.mas_top);
                make.height.equalTo(@30);
                make.width.equalTo(@50);
            }];
            [picker mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.alertView.mas_right);
                make.top.equalTo(s.mas_bottom);
                make.bottom.equalTo(self.alertView.mas_bottom);
                make.left.equalTo(self.alertView.mas_left);
            }];

        }else if (type == 1){
            self.alertView.frame = CGRectMake(0, SCREEN_HEIGHT - 300, SCREEN_WIDTH, 300);
            self.alertView.backgroundColor = [UIColor groupTableViewBackgroundColor];
            UIButton* s = [EBUtility btnfrome:CGRectZero andText:@"完成" andColor:[UIColor blackColor] andimg:nil andView:self.alertView];
            [s addTarget:self action:@selector(dateAndTimePick:) forControlEvents:UIControlEventTouchUpInside];
            
            UILabel* lab = [EBUtility labfrome:CGRectZero andText:@"至" andColor:[UIColor blackColor] andView:self.alertView];
            
            UIDatePicker* picker = [[UIDatePicker alloc]initWithFrame:CGRectZero];
            picker.datePickerMode = UIDatePickerModeDate;
            picker.backgroundColor = [UIColor groupTableViewBackgroundColor];
            self.picker = picker;
            picker.datePickerMode = UIDatePickerModeTime;
            [self.alertView addSubview:picker];
            
            UIDatePicker* picker1 = [[UIDatePicker alloc]initWithFrame:CGRectZero];
            picker1.datePickerMode = UIDatePickerModeDate;
            picker1.backgroundColor = [UIColor groupTableViewBackgroundColor];
            self.timePicker = picker1;
            picker1.datePickerMode = UIDatePickerModeTime;
            [self.alertView addSubview:picker1];
            
            [s mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.alertView.mas_right);
                make.top.equalTo(self.alertView.mas_top);
                make.height.equalTo(@30);
                make.width.equalTo(@50);
            }];
            [lab mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(picker.mas_right);
                make.centerY.equalTo(picker.mas_centerY);
                make.height.equalTo(@30);
                make.width.equalTo(@15);
            }];
            [picker mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.alertView.mas_centerX).offset(-7.5);
                make.top.equalTo(s.mas_bottom);
                make.bottom.equalTo(self.alertView.mas_bottom);
                make.left.equalTo(self.alertView.mas_left);
            }];
            [picker1 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.alertView.mas_right);
                make.top.equalTo(s.mas_bottom);
                make.bottom.equalTo(self.alertView.mas_bottom);
                make.left.equalTo(lab.mas_right);
            }];
        }else if (type == 5){
            self.alertView.frame = CGRectMake(0, 0, 250, 150);
            self.alertView.backgroundColor = [UIColor whiteColor];
            self.alertView.center = self.center;
            self.alertView.layer.masksToBounds = YES;
            self.alertView.layer.cornerRadius = 10;
            UILabel* t = [EBUtility labfrome:CGRectMake(0, 20, 80, 20) andText:@"温馨提示" andColor:Nav_color andView:self.alertView];
            t.centerX = self.alertView.width/2;
            t.font = [UIFont systemFontOfSize:20];
            [t sizeToFit];
            UILabel* c = [EBUtility labfrome:CGRectMake(0, 55, 180, 20) andText:@"要先付费才能聊天哦!" andColor:[UIColor blackColor] andView:self.alertView];
            c.centerX = self.alertView.width/2;
            c.numberOfLines = 2;
            c.font = [UIFont systemFontOfSize:16];
            [c sizeToFit];
            UIButton* b1 = [EBUtility btnfrome:CGRectMake(0, 110, 80, 25) andText:@"去下单" andColor:[UIColor whiteColor] andimg:nil andView:self.alertView];
            b1.backgroundColor = Nav_color;
            b1.layer.cornerRadius = 12;
            b1.layer.masksToBounds = YES;
            b1.titleLabel.font = [UIFont systemFontOfSize:14];
            [b1 addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            b1.centerX = self.alertView.width/2 - 45;
            UIButton* b2 = [EBUtility btnfrome:CGRectMake(0, 110, 80, 25) andText:@"取消" andColor:[UIColor whiteColor] andimg:nil andView:self.alertView];
            b2.backgroundColor = [UIColor lightGrayColor];
            b2.layer.cornerRadius = 12;
            b2.layer.masksToBounds = YES;
            b2.titleLabel.font = [UIFont systemFontOfSize:14];
            b2.tag = 1;
            [b2 addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            b2.centerX = self.alertView.width/2 + 45;
        }else if (type == 6){
            self.alertView.frame = CGRectMake(0, SCREEN_HEIGHT-440 , SCREEN_WIDTH, 440);
            self.alertView.backgroundColor = [UIColor whiteColor];
            
            UIButton *cancleBtn = [EBUtility btnfrome:CGRectMake(13, 17, 20, 20) andText:@"" andColor:nil andimg:[UIImage imageNamed:@"ico_close"] andView:self.alertView];
            [cancleBtn addTarget:self action:@selector(remove) forControlEvents:UIControlEventTouchUpInside];
            
            UILabel* titleLab = [EBUtility labfrome:CGRectMake(0, 20, 100, 20) andText:@"请输入密码" andColor:[UIColor blackColor] andView:self.alertView];
            titleLab.font = [UIFont systemFontOfSize:20];
            [titleLab sizeToFit];
            titleLab.centerX = self.alertView.width/2;
            titleLab.centerY = cancleBtn.centerY;
            
            UILabel* grayLine = [EBUtility labfrome:CGRectMake(0, 50, SCREEN_WIDTH, 1) andText:@"" andColor:[UIColor blackColor] andView:self.alertView];
            grayLine.backgroundColor = [UIColor lightGrayColor];
            
            UIView* tfView = [EBUtility viewfrome:CGRectMake(15, 80, SCREEN_WIDTH - 30, 45) andColor:[UIColor whiteColor] andView:self.alertView];
            tfView.layer.cornerRadius = 5;
            tfView.layer.borderColor = [UIColor lightGrayColor].CGColor;
            tfView.layer.borderWidth = 1;
            tfView.layer.masksToBounds = 1;
            UITextField* tf = [EBUtility textFieldfrome:CGRectMake(25, 0, SCREEN_WIDTH - 30, 45) andText:@"" andColor:[UIColor clearColor] andView:tfView];
            tf.textColor = UIColor.clearColor;
            tf.tintColor = UIColor.clearColor;
            tf.font = [UIFont systemFontOfSize:130];
            tf.clearButtonMode = UITextFieldViewModeNever;
            tf.keyboardType = UIKeyboardTypePhonePad;
            [tf becomeFirstResponder];
            tf.delegate = self;
            [tf addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
            for (int i = 0; i < 6; i++){
                UILabel* bot = [EBUtility labfrome:CGRectMake(i * tfView.width/6, 0, tfView.width/6, tfView.height) andText:@"·" andColor:[UIColor blackColor] andView:tfView];
                bot.tag = i + 1000;
                bot.hidden = YES;
                bot.font = [UIFont systemFontOfSize:55];
                if (i < 5){
                    UILabel* gLine = [EBUtility labfrome:CGRectMake((i + 1) * tfView.width/6, 0, 1, tfView.height) andText:@"" andColor:[UIColor blackColor] andView:tfView];
                    gLine.backgroundColor = [UIColor lightGrayColor];
                }
            }
            UIButton* forget = [EBUtility btnfrome:CGRectMake(self.alertView.width - 100, 140, 90, 15) andText:@"忘记密码？" andColor:Nav_color andimg:nil andView:self.alertView];
            forget.tag = 111;
            [forget addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            forget.titleLabel.font = [UIFont systemFontOfSize:15];
        }else if (type == 7){
            self.alertView.frame = CGRectMake(0, 0, 250, 150);
            self.alertView.backgroundColor = [UIColor whiteColor];
            self.alertView.center = self.center;
            self.alertView.layer.masksToBounds = 1;
            self.alertView.layer.cornerRadius = 10;
            
            UILabel* t = [EBUtility labfrome:CGRectMake(0, 20, 80, 20) andText:@"发布成功" andColor:Nav_color andView:self.alertView];
            t.centerX = self.alertView.width/2;
            t.font = [UIFont systemFontOfSize:20];
            [t sizeToFit];
            UILabel* c = [EBUtility labfrome:CGRectMake(0, 55, self.alertView.width - 40, 20) andText:@"任务已发布，请等待审核。" andColor:[UIColor blackColor] andView:self.alertView];
            c.centerX = self.alertView.width/2;
            c.numberOfLines = 2;
            c.font = [UIFont systemFontOfSize:16];
            UIButton* b = [EBUtility btnfrome:CGRectMake(0, 110, 80, 25) andText:@"好的" andColor:[UIColor whiteColor] andimg:nil andView:self.alertView];
            b.backgroundColor = Nav_color;
            b.layer.cornerRadius = 12;
            b.layer.masksToBounds = YES;
            b.titleLabel.font = [UIFont systemFontOfSize:14];
            [b addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            b.centerX = self.alertView.width/2;
        }else if (type == 8){
            self.alertView.frame = CGRectMake(0, 0, 250, 150);
            self.alertView.backgroundColor = [UIColor whiteColor];
            self.alertView.center = self.center;
            self.alertView.layer.masksToBounds = YES;
            self.alertView.layer.cornerRadius = 10;
            
            UILabel* t = [EBUtility labfrome:CGRectMake(0, 20, 80, 20) andText:@"温馨提醒" andColor:Nav_color andView:self.alertView];
            t.centerX = self.alertView.width/2;
            t.font = [UIFont systemFontOfSize:20];
            [t sizeToFit];
            UILabel* c = [EBUtility labfrome:CGRectMake(0, 55, 180, 20) andText:@"是否更改背景图片？" andColor:[UIColor blackColor] andView:self.alertView];
            c.numberOfLines = 2;
            c.font = [UIFont systemFontOfSize:16];
            [c sizeToFit];
            c.centerX = self.alertView.width/2;
            
            UIButton* b1 = [EBUtility btnfrome:CGRectMake(0, 110, 70, 25) andText:@"确定" andColor:[UIColor whiteColor] andimg:nil andView:self.alertView];
            b1.backgroundColor = Nav_color;
            b1.layer.cornerRadius = 12;
            b1.layer.masksToBounds = YES;
            b1.titleLabel.font = [UIFont systemFontOfSize:14];
            [b1 addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            b1.centerX = self.alertView.width/2 - 45;
            UIButton* b2 = [EBUtility btnfrome:CGRectMake(0, 110, 70, 25) andText:@"取消" andColor:[UIColor whiteColor] andimg:nil andView:self.alertView];
            b2.backgroundColor = [UIColor lightGrayColor];
            b2.layer.cornerRadius = 12;
            b2.layer.masksToBounds = YES;
            b2.titleLabel.font = [UIFont systemFontOfSize:14];
            b2.tag = 1;
            [b2 addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            b2.centerX = self.alertView.width/2 + 45;
        }else if (type == 9){
            self.alertView.frame = CGRectMake(0, 0, 250, 150);
            self.alertView.backgroundColor = [UIColor whiteColor];
            self.alertView.center = self.center;
            self.alertView.layer.masksToBounds = YES;
            self.alertView.layer.cornerRadius = 10;
            
            UILabel* t = [EBUtility labfrome:CGRectMake(0, 20, 80, 20) andText:@"温馨提醒" andColor:Nav_color andView:self.alertView];
            t.centerX = self.alertView.width/2;
            t.font = [UIFont systemFontOfSize:20];
            [t sizeToFit];
            UILabel* c = [EBUtility labfrome:CGRectMake(0, 55, 180, 20) andText:@"是否更改删除支付宝账户？" andColor:[UIColor blackColor] andView:self.alertView];
            c.numberOfLines = 2;
            c.font = [UIFont systemFontOfSize:16];
            [c sizeToFit];
            c.centerX = self.alertView.width/2;
            
            UIButton* b1 = [EBUtility btnfrome:CGRectMake(0, 110, 70, 25) andText:@"确定" andColor:[UIColor whiteColor] andimg:nil andView:self.alertView];
            b1.backgroundColor = Nav_color;
            b1.layer.cornerRadius = 12;
            b1.layer.masksToBounds = YES;
            b1.titleLabel.font = [UIFont systemFontOfSize:14];
            [b1 addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            b1.centerX = self.alertView.width/2 - 45;
            UIButton* b2 = [EBUtility btnfrome:CGRectMake(0, 110, 70, 25) andText:@"取消" andColor:[UIColor whiteColor] andimg:nil andView:self.alertView];
            b2.backgroundColor = [UIColor lightGrayColor];
            b2.layer.cornerRadius = 12;
            b2.layer.masksToBounds = YES;
            b2.titleLabel.font = [UIFont systemFontOfSize:14];
            b2.tag = 1;
            [b2 addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            b2.centerX = self.alertView.width/2 + 45;
        }
    }
    return self;
}

- (instancetype)initWithTitle:(NSString*)title Text:(NSString*)text AndType:(NSInteger)type{
    if (self == [super init]) {
        self.frame = [UIScreen mainScreen].bounds;
        
        self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
        
        UIButton* alphaBtn = [EBUtility btnfrome:[UIScreen mainScreen].bounds andText:@"" andColor:[UIColor clearColor] andimg:nil andView:self];
        
        self.alertView = [[UIView alloc] init];
        self.alertView.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.alertView];
        self.alertView.frame = CGRectMake(0, 0, 250, 150);
        self.alertView.backgroundColor = [UIColor whiteColor];
        self.alertView.center = self.center;
        self.alertView.layer.masksToBounds = 1;
        self.alertView.layer.cornerRadius = 10;
        
        UILabel* t = [EBUtility labfrome:CGRectMake(0, 20, 80, 20) andText:title andColor:Nav_color andView:self.alertView];
        t.centerX = self.alertView.width/2;
        t.font = [UIFont systemFontOfSize:20];
        [t sizeToFit];
        UILabel* c = [EBUtility labfrome:CGRectMake(0, 55, self.alertView.width - 40, 20) andText:text andColor:[UIColor blackColor] andView:self.alertView];
        c.numberOfLines = 0;
        c.font = [UIFont systemFontOfSize:14];
        [c sizeToFit];
        c.centerX = self.alertView.width/2;
        
        if (type == 0){
            [alphaBtn addTarget:self action:@selector(remove) forControlEvents:UIControlEventTouchUpInside];
            UIButton* b = [EBUtility btnfrome:CGRectMake(0, 110, 80, 25) andText:@"确定" andColor:[UIColor whiteColor] andimg:nil andView:self.alertView];
            b.backgroundColor = Nav_color;
            b.layer.cornerRadius = 12;
            b.layer.masksToBounds = YES;
            b.titleLabel.font = [UIFont systemFontOfSize:14];
            [b addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            b.centerX = self.alertView.width/2;
        }else if (type == 1){
            [alphaBtn addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            UIButton* b1 = [EBUtility btnfrome:CGRectMake(0, 110, 70, 25) andText:@"确定" andColor:[UIColor whiteColor] andimg:nil andView:self.alertView];
            b1.backgroundColor = Nav_color;
            b1.layer.cornerRadius = 12;
            b1.layer.masksToBounds = YES;
            b1.titleLabel.font = [UIFont systemFontOfSize:14];
            [b1 addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            b1.centerX = self.alertView.width/2 - 50;
            UIButton* b2 = [EBUtility btnfrome:CGRectMake(0, 110, 70, 25) andText:@"跳过" andColor:[UIColor whiteColor] andimg:nil andView:self.alertView];
            b2.backgroundColor = [UIColor lightGrayColor];
            b2.layer.cornerRadius = 12;
            b2.layer.masksToBounds = YES;
            b2.titleLabel.font = [UIFont systemFontOfSize:14];
            b2.tag = 1;
            [b2 addTarget:self action:@selector(remove) forControlEvents:UIControlEventTouchUpInside];
            b2.centerX = self.alertView.width/2 + 50;
        }else if (type == 2){
            [alphaBtn addTarget:self action:@selector(remove) forControlEvents:UIControlEventTouchUpInside];
            UIButton* b1 = [EBUtility btnfrome:CGRectMake(0, 110, 70, 25) andText:@"确定" andColor:[UIColor whiteColor] andimg:nil andView:self.alertView];
            b1.backgroundColor = Nav_color;
            b1.layer.cornerRadius = 12;
            b1.layer.masksToBounds = YES;
            b1.titleLabel.font = [UIFont systemFontOfSize:14];
            [b1 addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
            b1.centerX = self.alertView.width/2 - 50;
            UIButton* b2 = [EBUtility btnfrome:CGRectMake(0, 110, 70, 25) andText:@"取消" andColor:[UIColor whiteColor] andimg:nil andView:self.alertView];
            b2.backgroundColor = [UIColor lightGrayColor];
            b2.layer.cornerRadius = 12;
            b2.layer.masksToBounds = YES;
            b2.titleLabel.font = [UIFont systemFontOfSize:14];
            b2.tag = 1;
            [b2 addTarget:self action:@selector(remove) forControlEvents:UIControlEventTouchUpInside];
            b2.centerX = self.alertView.width/2 + 50;
        }
    }
    return self;
}


- (instancetype)initWithVedio:(NSURL*)url{
    if (self == [super init]) {
        self.frame = [UIScreen mainScreen].bounds;
        
        self.backgroundColor = [UIColor blackColor];
        
        UIButton* alphaBtn = [EBUtility btnfrome:[UIScreen mainScreen].bounds andText:@"" andColor:[UIColor clearColor] andimg:nil andView:self];
        [alphaBtn addTarget:self action:@selector(remove) forControlEvents:UIControlEventTouchUpInside];
        
        AVPlayer* player = [AVPlayer playerWithURL:url];
        self.player = player;
        AVPlayerLayer* playLayer = [AVPlayerLayer playerLayerWithPlayer:player];
        playLayer.frame = self.frame;
        self.alertView = [EBUtility viewfrome:self.frame andColor:nil andView:self];
        
        [self.alertView.layer addSublayer:playLayer];
        
        [player play];
        [self bringSubviewToFront:alphaBtn];
    }
    return self;
}

- (instancetype)initWithImages:(NSArray*)ary Index:(NSInteger)tag{
    if (self == [super init]) {
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [UIColor blackColor];
        
        self.scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        for (int i = 0; i < ary.count; i++){
            UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH * i + 2, 0, SCREEN_WIDTH - 2, SCREEN_HEIGHT)];
            UIImageView* iv = [[UIImageView alloc]initWithFrame:CGRectMake(1, 0, SCREEN_WIDTH - 2, SCREEN_HEIGHT)];
            iv.tag = 100;
            iv.contentMode = UIViewContentModeScaleAspectFit;
            
            [iv sd_setImageWithURL:[NSURL URLWithString:ary[i]]];
            [scrollView addSubview:iv];
            scrollView.showsHorizontalScrollIndicator = NO;
            scrollView.showsVerticalScrollIndicator = NO;
            scrollView.contentSize = iv.size;
            scrollView.tag = i + 1;
            scrollView.delegate = self;
            //设置最大伸缩比例
            scrollView.maximumZoomScale = 3;
            //设置最小伸缩比例
            scrollView.minimumZoomScale = 1;
            [scrollView setZoomScale:1 animated:NO];
            [self.scroll addSubview:scrollView];
        }
        self.scroll.backgroundColor = [UIColor blackColor];
        self.scroll.contentSize = CGSizeMake(SCREEN_WIDTH * ary.count, 0);
        self.scroll.showsHorizontalScrollIndicator = NO;
        self.scroll.showsVerticalScrollIndicator=NO;
        self.scroll.pagingEnabled = YES;
        self.scroll.contentOffset = CGPointMake(SCREEN_WIDTH * tag, 0);
        self.scroll.delegate = self;
        
        [self addSubview:self.scroll];
        
        UITapGestureRecognizer * PrivateLetterTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(remove)];
        PrivateLetterTap.numberOfTouchesRequired = 1; //手指数
        PrivateLetterTap.numberOfTapsRequired = 1; //tap次数
        
        [self addGestureRecognizer:PrivateLetterTap];
        
    }
    return self;
}

- (instancetype)initWithSpecialDatePicker{
    if (self == [super init]) {
        self.frame = [UIScreen mainScreen].bounds;
        
        self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
        
        UIButton* alphaBtn = [EBUtility btnfrome:[UIScreen mainScreen].bounds andText:@"" andColor:[UIColor clearColor] andimg:nil andView:self];
        [alphaBtn addTarget:self action:@selector(remove) forControlEvents:UIControlEventTouchUpInside];
        self.alertView = [[UIView alloc] init];
        self.alertView.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.alertView];
        
        self.alertView.frame = CGRectMake(0, SCREEN_HEIGHT - 300, SCREEN_WIDTH, 300);
        self.alertView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        UIButton* s = [EBUtility btnfrome:CGRectZero andText:@"完成" andColor:[UIColor blackColor] andimg:nil andView:self.alertView];
        [s addTarget:self action:@selector(aryPick:) forControlEvents:UIControlEventTouchUpInside];
        UIPickerView* picker = [[UIPickerView alloc]initWithFrame:CGRectZero];
        
        picker.backgroundColor = [UIColor groupTableViewBackgroundColor];
        self.pv = picker;
        picker.delegate = self;
        picker.dataSource = self;
        [self.alertView addSubview:picker];
        picker.tag = 1;

        NSCalendar* calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents* component = [calendar components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:[NSDate dateWithTimeIntervalSinceNow:1800]];
        
        [picker selectRow:component.hour inComponent:1 animated:NO];
        [picker selectRow:(component.minute /15) inComponent:2 animated:NO];
        
        [s mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.alertView.mas_right);
            make.top.equalTo(self.alertView.mas_top);
            make.height.equalTo(@30);
            make.width.equalTo(@50);
        }];
        [picker mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.alertView.mas_right);
            make.top.equalTo(s.mas_bottom);
            make.bottom.equalTo(self.alertView.mas_bottom);
            make.left.equalTo(self.alertView.mas_left);
        }];
    }
    return self;
}
- (instancetype)initWithSiftList{
    if (self == [super init]) {
        self.frame = [UIScreen mainScreen].bounds;
        
        self.backgroundColor = [UIColor clearColor];//[UIColor colorWithWhite:0.1 alpha:0.8];
        
        UIButton* alphaBtn = [EBUtility btnfrome:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT ) andText:@"" andColor:[UIColor clearColor] andimg:nil andView:self];
        [alphaBtn addTarget:self action:@selector(remove) forControlEvents:UIControlEventTouchUpInside];
//        alphaBtn.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
        self.alertView = [[UIView alloc] init];
        
        [self addSubview:self.alertView];
        
        self.alertView.frame = CGRectMake(SCREEN_WIDTH - 60, 64, 60, 108);
        self.alertView.backgroundColor = Nav_color;
        self.alertView.alpha = 0.9;
        self.alertView.layer.cornerRadius = 10;
        self.alertView.layer.masksToBounds = 1;
        
        NSArray *title = @[@"全部",@"未完成",@"已结束"];
        for (int i = 0; i < 3; i++ ){
            UIButton* btn = [EBUtility btnfrome:CGRectMake(0, 36 * i, 60, 36) andText:title[i] andColor:[UIColor whiteColor] andimg:nil andView:self.alertView];
            btn.layer.borderColor = [UIColor whiteColor].CGColor;
            btn.layer.borderWidth = 0.2;
            btn.titleLabel.font = [UIFont systemFontOfSize:12];
            btn.tag = i;
            [btn addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return self;
}
- (instancetype)initWithSiftWithHeight:(float)height AndTitleAry:(NSArray*)titleAry{
    if (self == [super init]) {
        self.frame = [UIScreen mainScreen].bounds;
        
        self.backgroundColor = [UIColor clearColor];
        self.dataAry = titleAry;
        
        UIButton* alphaBtn = [EBUtility btnfrome:CGRectMake(0, height, SCREEN_WIDTH, SCREEN_HEIGHT - height) andText:@"" andColor:[UIColor clearColor] andimg:nil andView:self];
        [alphaBtn addTarget:self action:@selector(remove) forControlEvents:UIControlEventTouchUpInside];
        alphaBtn.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
        self.alertView = [[UIView alloc] init];
        self.alertView.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.alertView];
        
        int row = (titleAry.count%3 > 0) ? (titleAry.count/3+1) : titleAry.count/3;
        self.alertView.frame = CGRectMake(0, height, SCREEN_WIDTH, 230 + 45 * row);
        self.alertView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        UIButton* alphaBtn1 = [EBUtility btnfrome:CGRectMake(0, 0, SCREEN_WIDTH, height) andText:@"" andColor:[UIColor clearColor] andimg:nil andView:self];
        [alphaBtn1 addTarget:self action:@selector(remove) forControlEvents:UIControlEventTouchUpInside];
        alphaBtn1.backgroundColor = [UIColor clearColor];
        
        self.requirement = [NSMutableArray arrayWithObjects:@"0",@"0",@"0", nil];
        self.btnAry1 = [NSMutableArray array];
        self.btnAry2 = [NSMutableArray array];
        self.btnAry3 = [NSMutableArray array];
        UILabel* sexLab = [EBUtility labfrome:CGRectMake(10, 10, 30, 18) andText:@"性别" andColor:[UIColor blackColor] andView:self.alertView];
        for (int i = 0; i < 3; i++) {
            UIButton* btn = [EBUtility btnfrome:CGRectMake(10 + ((SCREEN_WIDTH - 70)/3 + 25)*i , 40, (SCREEN_WIDTH - 70)/3, 30) andText:@[@"全部",@"男",@"女"][i] andColor:[UIColor blackColor] andimg:nil andView:self.alertView];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [btn setBackgroundImage:[UIImage imageNamed:@"navi_bg"] forState:UIControlStateSelected];
            [btn setBackgroundImage:[UIImage imageNamed:@"gray_bg"] forState:0];
            [btn addTarget:self action:@selector(selectRequirement:) forControlEvents:UIControlEventTouchUpInside];
            [self.btnAry1 addObject:btn];
            if (i == 0) {
                btn.selected = YES;
            }
        }
        UILabel* ageLab = [EBUtility labfrome:CGRectMake(10, 80, 30, 18) andText:@"年龄" andColor:[UIColor blackColor] andView:self.alertView];
        for (int i = 0; i < 4; i++) {
            UIButton* btn = [EBUtility btnfrome:CGRectMake(10 + ((SCREEN_WIDTH - 50)/4 + 10)*i , 110, (SCREEN_WIDTH - 50)/4, 30) andText:@[@"全部",@"80后",@"90后",@"00后"][i] andColor:[UIColor blackColor] andimg:nil andView:self.alertView];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [btn setBackgroundImage:[UIImage imageNamed:@"navi_bg"] forState:UIControlStateSelected];
            [btn setBackgroundImage:[UIImage imageNamed:@"gray_bg"] forState:0];
            [btn addTarget:self action:@selector(selectRequirement:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = 1;
            [self.btnAry2 addObject:btn];
            if (i == 0) {
                btn.selected = YES;
            }
        }
        UILabel* gameLab = [EBUtility labfrome:CGRectMake(10, 150, 30, 18) andText:@"技能" andColor:[UIColor blackColor] andView:self.alertView];
        

        for (int i = 0; i < row; i++) {
            for (int j = 0; j < 3; j++) {
                if (i*3 + j >= titleAry.count){
                    break;
                }
                UIButton* btn = [EBUtility btnfrome:CGRectMake(10 + ((SCREEN_WIDTH - 70)/3 + 25)*j , 180 + 45 * i, (SCREEN_WIDTH - 70)/3, 30) andText:titleAry[i * 3 + j] andColor:[UIColor blackColor] andimg:nil andView:self.alertView];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
                [btn setBackgroundImage:[UIImage imageNamed:@"navi_bg"] forState:UIControlStateSelected];
                [btn setBackgroundImage:[UIImage imageNamed:@"gray_bg"] forState:0];
                [self.btnAry3 addObject:btn];
                [btn addTarget:self action:@selector(selectRequirement:) forControlEvents:UIControlEventTouchUpInside];
                btn.tag = 2;
                if (i*3 + j == 0) {
                    btn.selected = YES;
                }
            }
        }
        
        UIButton* replace = [EBUtility greenBtnfrome:CGRectMake(10, self.alertView.height - 50, 130, 35) andText:@"重置" andColor:Nav_color andimg:nil andView:self.alertView];
        replace.layer.borderColor = Nav_color.CGColor;
        replace.layer.borderWidth = 1;
        replace.tag = 1;
        [replace addTarget:self action:@selector(replaceAllBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton* confirg = [EBUtility greenBtnfrome:CGRectMake(160, self.alertView.height - 50, 200, 35) andText:@"确定" andColor:[UIColor whiteColor] andimg:nil andView:self.alertView];
        confirg.backgroundColor = Nav_color;
        [confirg addTarget:self action:@selector(replaceAllBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}
- (instancetype)initWithHeight:(float)height AndAry:(NSArray*)ary{
    if (self == [super init]) {
        self.frame = [UIScreen mainScreen].bounds;
        
        self.backgroundColor = [UIColor clearColor];//[UIColor colorWithWhite:0.1 alpha:0.8];
        
        UIButton* alphaBtn = [EBUtility btnfrome:CGRectMake(0, height, SCREEN_WIDTH, SCREEN_HEIGHT - height) andText:@"" andColor:[UIColor clearColor] andimg:nil andView:self];
        [alphaBtn addTarget:self action:@selector(remove) forControlEvents:UIControlEventTouchUpInside];
        alphaBtn.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
        self.alertView = [[UIView alloc] init];
        self.alertView.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.alertView];
        
        self.alertView.frame = CGRectMake(0, height, SCREEN_WIDTH, 300);
        self.alertView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        UIButton* alphaBtn1 = [EBUtility btnfrome:CGRectMake(0, 0, SCREEN_WIDTH, height) andText:@"" andColor:[UIColor clearColor] andimg:nil andView:self];
        [alphaBtn1 addTarget:self action:@selector(remove) forControlEvents:UIControlEventTouchUpInside];
        alphaBtn1.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.alertView];
        float h = ary.count > 6 ? (50*6) : (50*ary.count);
        self.alertView.frame = CGRectMake(0, height, SCREEN_WIDTH, h);
        self.alertView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, h) style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        UIView *v = [[UIView alloc]init];
        v.backgroundColor = [UIColor clearColor];
        self.tableView.tableFooterView = v;
        [self.alertView addSubview:self.tableView];
        
        self.dataAry = ary;
    }
    return self;
}

- (instancetype)initWithPicker:(NSArray *)ary{
    if (self == [super init]) {
        self.frame = [UIScreen mainScreen].bounds;
        
        self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
        
        UIButton* alphaBtn = [EBUtility btnfrome:[UIScreen mainScreen].bounds andText:@"" andColor:[UIColor clearColor] andimg:nil andView:self];
        [alphaBtn addTarget:self action:@selector(remove) forControlEvents:UIControlEventTouchUpInside];
        self.alertView = [[UIView alloc] init];
        self.alertView.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.alertView];
        
        self.alertView.frame = CGRectMake(0, SCREEN_HEIGHT - 300, SCREEN_WIDTH, 300);
        self.alertView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        UIButton* s = [EBUtility btnfrome:CGRectZero andText:@"完成" andColor:[UIColor blackColor] andimg:nil andView:self.alertView];
        [s addTarget:self action:@selector(aryPick:) forControlEvents:UIControlEventTouchUpInside];
        UIPickerView* picker = [[UIPickerView alloc]initWithFrame:CGRectZero];
        
        picker.backgroundColor = [UIColor groupTableViewBackgroundColor];
        self.pv = picker;
        picker.delegate = self;
        picker.dataSource = self;
        self.dataAry = ary;
        [self.alertView addSubview:picker];
        
        [s mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.alertView.mas_right);
            make.top.equalTo(self.alertView.mas_top);
            make.height.equalTo(@30);
            make.width.equalTo(@50);
        }];
        [picker mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.alertView.mas_right);
            make.top.equalTo(s.mas_bottom);
            make.bottom.equalTo(self.alertView.mas_bottom);
            make.left.equalTo(self.alertView.mas_left);
        }];
    }
    return self;
}

- (instancetype)initWithUrl:(NSString *)url{
    if (self == [super init]) {
        self.frame = [UIScreen mainScreen].bounds;
        
        self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
        
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];

        [self addSubview:webView];
        
        UIButton* btn = [EBUtility btnfrome:CGRectZero andText:@"发送" andColor:[UIColor whiteColor] andimg:nil andView:self];
        self.btn = btn;
        [btn addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
        btn.backgroundColor = Nav_color;
        
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.mas_bottom);
            make.left.equalTo(self.mas_left);
            make.right.equalTo(self.mas_right);
            make.height.equalTo(@50);
        }];
        [webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(btn.mas_top);
            make.left.equalTo(self.mas_left);
            make.right.equalTo(self.mas_right);
            make.top.equalTo(self.mas_top);
        }];
    }
    return self;
}

- (instancetype)initWithCustomerDic:(NSDictionary*)dic{
    if (self == [super init]) {
        self.frame = [UIScreen mainScreen].bounds;
        
        self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
        
        UIButton* alphaBtn = [EBUtility btnfrome:[UIScreen mainScreen].bounds andText:@"" andColor:[UIColor clearColor] andimg:nil andView:self];
        [alphaBtn addTarget:self action:@selector(remove) forControlEvents:UIControlEventTouchUpInside];
        self.alertView = [[UIView alloc] init];
        self.alertView.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.alertView];
        
        self.alertView.frame = CGRectMake(0, SCREEN_HEIGHT - 230, SCREEN_WIDTH, 230);
        self.alertView.backgroundColor = [UIColor whiteColor];
        UIImageView* img = [EBUtility imgfrome:CGRectZero andImg:[UIImage imageNamed:@"ico_head"] andView:self.alertView];
        [img sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",dic[@"photo"]]] placeholderImage:[UIImage imageNamed:@"ico_head"]];
        img.layer.cornerRadius = 30;
        img.layer.masksToBounds = YES;
        UILabel* name = [EBUtility labfrome:CGRectZero andText:[NSString stringWithFormat:@"%@",dic[@"nickname"]] andColor:[UIColor blackColor] andView:self.alertView];
        name.font = [UIFont systemFontOfSize:18];
        [name sizeToFit];
        UILabel* grade = [EBUtility labfrome:CGRectZero andText:@"♂0岁" andColor:[UIColor whiteColor] andView:self.alertView];
        if ([NSString stringWithFormat:@"%@",dic[@"sex"]].integerValue == 1){
            grade.text = [NSString stringWithFormat:@" ♂%@岁\t",dic[@"birthday"]];
            grade.backgroundColor = Nav_color;
        }else{
            grade.text = [NSString stringWithFormat:@" ♀%@岁\t",dic[@"birthday"]];
            grade.backgroundColor = Pink_color;
        }
        grade.layer.cornerRadius = 3;
        grade.font = [UIFont systemFontOfSize:11];
        grade.layer.masksToBounds = YES;
        
        UIButton* cancleBtn = [EBUtility btnfrome:CGRectZero andText:@"" andColor:nil andimg:[UIImage imageNamed:@"ico_close"] andView:self.alertView];
        [cancleBtn addTarget:self action:@selector(remove) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel* grayLine = [EBUtility labfrome:CGRectZero andText:@"" andColor:nil andView:self.alertView];
        grayLine.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        UILabel* classLab = [EBUtility labfrome:CGRectZero andText:@"品类" andColor:[UIColor darkGrayColor] andView:self.alertView];
        UILabel* classLabInfo = [EBUtility labfrome:CGRectZero andText:[NSString stringWithFormat:@"%@",dic[@"game_name"]] andColor:[UIColor darkGrayColor] andView:self.alertView];
        [classLabInfo sizeToFit];
        classLab.font = [UIFont systemFontOfSize:15];
        classLabInfo.font = [UIFont systemFontOfSize:15];
        
        UILabel* timeLab = [EBUtility labfrome:CGRectZero andText:@"时间" andColor:[UIColor darkGrayColor] andView:self.alertView];
        UILabel* timeLabInfo = [EBUtility labfrome:CGRectZero andText:[NSString stringWithFormat:@"%@ %@小时",dic[@"stime"],dic[@"num"]] andColor:[UIColor darkGrayColor] andView:self.alertView];
        [timeLabInfo sizeToFit];
        timeLab.font = [UIFont systemFontOfSize:15];
        timeLabInfo.font = [UIFont systemFontOfSize:15];
        
        UILabel* feeLab = [EBUtility labfrome:CGRectZero andText:@"费用" andColor:[UIColor darkGrayColor] andView:self.alertView];
        UILabel* feeLabInfo = [EBUtility labfrome:CGRectZero andText:[NSString stringWithFormat:@"¥%@",dic[@"totalprice"]] andColor:[UIColor darkGrayColor] andView:self.alertView];
        [feeLabInfo sizeToFit];
        feeLab.font = [UIFont systemFontOfSize:15];
        feeLabInfo.font = [UIFont systemFontOfSize:15];
        
        UIButton* commit = [EBUtility btnfrome:CGRectZero andText:@"提交订单" andColor:[UIColor whiteColor] andimg:nil andView:self.alertView];
        commit.backgroundColor = Nav_color;
        [commit addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        [img mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.alertView.mas_top).offset(5);
            make.left.equalTo(self.alertView.mas_left).offset(10);
            make.height.equalTo(@60);
            make.width.equalTo(@60);
        }];
        [cancleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.alertView.mas_top).offset(10);
            make.right.equalTo(self.alertView.mas_right).offset(-10);
            make.height.equalTo(@20);
            make.width.equalTo(@20);
        }];
        [name mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.alertView.mas_top).offset(15);
            make.left.equalTo(img.mas_right).offset(10);
        }];
        [grade mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(name.mas_bottom).offset(5);
            make.left.equalTo(img.mas_right).offset(10);
        }];
        [grayLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(img.mas_bottom).offset(10);
            make.left.equalTo(self.alertView.mas_left);
            make.right.equalTo(self.alertView.mas_right);
            make.height.equalTo(@1);
        }];
        [classLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(grayLine.mas_bottom).offset(10);
            make.left.equalTo(self.alertView.mas_left).offset(10);
        }];
        [classLabInfo mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(grayLine.mas_bottom).offset(10);
            make.right.equalTo(self.alertView.mas_right).offset(-10);
        }];
        [timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(classLab.mas_bottom).offset(15);
            make.left.equalTo(self.alertView.mas_left).offset(10);
        }];
        [timeLabInfo mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(classLab.mas_bottom).offset(15);
            make.right.equalTo(self.alertView.mas_right).offset(-10);
        }];
        [feeLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(timeLab.mas_bottom).offset(15);
            make.left.equalTo(self.alertView.mas_left).offset(10);
        }];
        [feeLabInfo mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(timeLab.mas_bottom).offset(15);
            make.right.equalTo(self.alertView.mas_right).offset(-10);
        }];
        
        [commit mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.alertView.mas_bottom);
            make.left.equalTo(self.alertView.mas_left);
            make.right.equalTo(self.alertView.mas_right);
            make.height.equalTo(@44);
        }];
    }
    return self;
}
- (instancetype)initWithAry:(NSArray*)ary{
    if (self == [super init]) {
        self.frame = [UIScreen mainScreen].bounds;
        
        self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
        
        UIButton* alphaBtn = [EBUtility btnfrome:[UIScreen mainScreen].bounds andText:@"" andColor:[UIColor clearColor] andimg:nil andView:self];
        [alphaBtn addTarget:self action:@selector(remove) forControlEvents:UIControlEventTouchUpInside];
        self.alertView = [[UIView alloc] init];
        self.alertView.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.alertView];
        
        self.alertView.layer.cornerRadius = 10;
        self.alertView.frame = CGRectMake(30, 260, SCREEN_WIDTH - 100,  190);
        self.alertView.layer.position = self.center;
        self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH - 100, 150) style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        UIView *v = [[UIView alloc] init];
        v.backgroundColor = [UIColor clearColor];
        self.tableView.tableFooterView = v;
        [self.alertView addSubview:self.tableView];
        
        self.dataAry = ary;
    }
    return self;
}

- (void)clickImageView:(UITapGestureRecognizer *)tap{
    [self removeFromSuperview];
}
- (void)showAlertView{
    UIWindow *rootWindow = [UIApplication sharedApplication].keyWindow;
    [rootWindow addSubview:self];
    [self creatShowAnimation];
}
- (void)creatShowAnimation
{
    //    self.alertView.layer.position = self.center;
    self.alertView.transform = CGAffineTransformMakeScale(0.90, 0.90);
    [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:1 options:UIViewAnimationOptionCurveLinear animations:^{
        self.alertView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL finished) {
    }];
}
- (void)datepick:(UIButton*)sender{
    if (self.resultDate) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
        self.resultDate([dateFormatter stringFromDate:self.picker.date]);
    }
    [self removeFromSuperview];
}
- (void)dateAndTimePick:(UIButton*)sender{
    if (self.resultDate) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"hh:mm"];
        
        self.resultDate([NSString stringWithFormat:@"%@-%@",[dateFormatter stringFromDate:self.picker.date],[dateFormatter stringFromDate:self.timePicker.date]]);
    }
    [self removeFromSuperview];
}
- (void)aryPick:(UIButton*)sender{
    if (self.resultDate) {
        if ([self.pv selectedRowInComponent:0] >= 0){
            if (self.pv.tag == 1){
                NSString* s1 = @[@"今天",@"明天",@"后天"][[self.pv selectedRowInComponent:0]];
                NSString* s2 = [NSString stringWithFormat:@"%ld点",[self.pv selectedRowInComponent:1]];
                NSString* s3 = @[@"00分",@"15分",@"30分",@"45分"][[self.pv selectedRowInComponent:2]];
                self.resultDate([NSString stringWithFormat:@"%@ %@ %@",s1,s2,s3]);
            }else{
                self.resultDate([NSString stringWithFormat:@"%ld",[self.pv selectedRowInComponent:0]]);
            }
            
        }
    }
    [self removeFromSuperview];
}

- (void)selectRequirement:(UIButton*)sender{
    NSInteger num = 0;
    if (sender.tag == 0){
        for (UIButton* i in self.btnAry1) {
            i.selected = NO;
        }
        num = [self.btnAry1 indexOfObject:sender];
    }else if (sender.tag == 1){
        for (UIButton* i in self.btnAry2) {
            i.selected = NO;
        }
        num = [self.btnAry2 indexOfObject:sender];
    }else if (sender.tag == 2){
        for (UIButton* i in self.btnAry3) {
            i.selected = NO;
        }
        num = [self.btnAry3 indexOfObject:sender];
    }
    sender.selected = YES;
    self.requirement[sender.tag] = [NSString stringWithFormat:@"%ld",num];
}

- (void)replaceAllBtn:(UIButton*)sender{
    if (sender.tag == 0){
        if (self.resultDate) {
            self.resultDate([self.requirement componentsJoinedByString:@","]);
        }
        [self removeFromSuperview];
    }else{
        for (UIButton* i in self.btnAry1) {
            i.selected = NO;
            if (i == [self.btnAry1 firstObject]){
                i.selected = YES;
            }
        }
        for (UIButton* i in self.btnAry2) {
            i.selected = NO;
            if (i == [self.btnAry2 firstObject]){
                i.selected = YES;
            }
        }
        for (UIButton* i in self.btnAry3) {
            i.selected = NO;
            if (i == [self.btnAry3 firstObject]){
                i.selected = YES;
            }
        }
        self.requirement = [NSMutableArray arrayWithObjects:@"0",@"0",@"0", nil];
    }
}
- (void)touchBtn:(UIButton*)sender {
    if (self.resultIndex) {
        self.resultIndex(sender.tag);
    }
    [self removeFromSuperview];
}

- (void)remove{
    if (self.player){
        [self.player pause];
    }
    if (self.resultRemove){
        self.resultRemove(@"");
    }
    [self removeFromSuperview];
}

#pragma mark - scrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    if (scrollView.tag > 0){
        return [scrollView viewWithTag:100];
    }
    return nil;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView.tag == 0){
        for (UIScrollView * i in self.scroll.subviews){
            [UIView animateWithDuration:0.2 animations:^{
                [i setZoomScale:1];
            }];
        }
    }
}
#pragma mark - tableViewDelegate/DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataAry.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
//    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:self.dataAry[indexPath.row][@"logo"]]];
    cell.textLabel.text = self.dataAry[indexPath.row];//[@"title"];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.textAlignment = 0;
    return  cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (self.resultIndex) {
//        self.resultIndex(indexPath.row);
//    }
    if (self.resultDate) {
        self.resultDate([NSString stringWithFormat:@"%ld",(long)indexPath.row]);
    }
     [self removeFromSuperview];
}
#pragma mark - pickerViewDelegate/DataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    if (pickerView.tag == 1){
        return 3;
    }
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (pickerView.tag == 1){
        if (component == 0){
            return 3;
        }else if (component == 1){
            return 24;
        }
        return 4;
    }
    return self.dataAry.count;
}
// 返回每行的标题
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView.tag == 1){
        if (component == 0){
            return @[@"今天",@"明天",@"后天"][row];
        }else if (component == 1){
            return [NSString stringWithFormat:@"%ld点",row];
        }
        return @[@"00",@"15",@"30",@"45"][row];
    }
    return self.dataAry[row];
}
#pragma mark - textField
- (void)textFieldDidChange:(UITextField *)textField{
    for (int i = 0; i < 6; i++){
        UILabel* bot = [self.alertView viewWithTag:1000 + i];
        if (i >= textField.text.length ){
            bot.hidden = YES;
        }else{
            bot.hidden = NO;
        }
    }
    if (textField.text.length == 6){
        [self removeFromSuperview];
        if (self.resultDate) {
            NSLog(@"%@",textField.text);
            self.resultDate(textField.text);
        }
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [textField becomeFirstResponder];
}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//    for (int i = 0; i < 6; i++){
//        UILabel* bot = [self.alertView viewWithTag:1000 + i];
//        if (i > textField.text.length ){
//            bot.hidden = YES;
//        }else{
//            bot.hidden = NO;
//        }
//    }
//    if (textField.text.length == 5){
//        [self removeFromSuperview];
//        if (self.resultDate) {
//            NSLog(@"%@",[NSString stringWithFormat:@"%@%@",textField.text,string]);
//            self.resultDate([NSString stringWithFormat:@"%@%@",textField.text,string]);
//        }
//
//    }
//    return YES;
//}

@end
