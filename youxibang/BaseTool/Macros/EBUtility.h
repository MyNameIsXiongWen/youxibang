//
//  EBUtility.h
//  DChang
//
//  Created by 戎博 on 17/7/21.
//  Copyright © 2017年 昆博. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#define md5Key @"jh20151121"
@interface EBUtility : NSObject
//+(void)prompt:(NSString *)string;

@property(nonatomic,strong) UIImageView *customActivityIndicator;
@property(nonatomic ,copy) NSString *userId;

+ (CGSize)sizeWithString:(NSString *)string font:(UIFont *)font ;//label自适应

+ (UIColor *)UIColorFromHexColor:(NSString *)hexColor;//16位颜色

+ (void)callWithString:(NSString *)phoneString;
+ (void)callWithURL:(NSURL *)url;
+ (NSString *)md5HexDigest:(NSString*)input;
+ (NSMutableAttributedString *)priceAttrStrWithCutline:(NSString *)priceStr;
+ (NSMutableAttributedString *)changePartStringStyleWithString:(NSString *)string WithColor:(UIColor *)color WithSize:(int)size WithRange:(NSRange)range;
+ (NSString *)md51:(NSString *)str;
/**
 *  价格样式富文本
 */
+ (NSMutableAttributedString *)setPriceAttrStr:(NSString *)presentPrice
                                 originalPrice:(NSString *)originalPrice
                                 intervalSpace:(NSString *)intervalSpace
                               presentFontSize:(float)presenFontSize
                              originalFontSize:(float)originalFontSize;

/**
 *  调用QQ
 */
+ (BOOL)customServiceWithQQ:(NSString *)qqNum;

/**
 *  让键盘消失
 */
//+ (void)resignKeyBoardInView:(UIView *)view;

/**
 *  去App Store评价app
 */
+ (void)appraiseAppAtAppStote:(NSString *)appID;

/**
 *  去App Store下载app
 */
+ (void)downLoadAppAtAppStote:(NSString *)appID;

/**
 *  判断价格值是否有效。目前先判断促销价，再判断手机价
 */
+ (BOOL)isPriceValid:(NSString *)priceStr;

/**
 *  获取APP版本信息
 */
+ (NSString *)appVersionInfo;

+ (void)changeNavigationBar:(UIViewController*)VC;
//邮箱
+ (BOOL) validateEmail:(NSString *)email;

//手机号码验证
+ (BOOL)isMobileNumber:(NSString *)mobileNum;


//车牌号验证
+ (BOOL) validateCarNo:(NSString *)carNo;


//车型
+ (BOOL) validateCarType:(NSString *)CarType;

//用户名
+ (BOOL) validateUserName:(NSString *)name;

//密码
+ (BOOL) validatePassword:(NSString *)passWord;


//昵称
+ (BOOL) validateNickname:(NSString *)nickname;


//身份证号
+ (BOOL) validateIdentityCard: (NSString *)identityCard;

+ (void)prompt:(NSString *)string with:(UIViewController *)vc;
//菊花体
+ (void)ahahwith:(UIImageView *)customActivityIndicator;
+ (void)miss:(UIImageView *)customActivityIndicator;

+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;
+ (UIColor *)alphaColorWithHexString:(NSString *)colorString;
/**创建的是Label */
+ (UILabel *) labfrome:(CGRect)from andText:(NSString *)text andColor:(UIColor *)color  andView:(UIView *)vc;
/**创建的是btn */
+ (UIButton *) btnfrome:(CGRect)from andText:(NSString *)text andColor:(UIColor *)color andimg:(UIImage*)img andView:(UIView *)vc;
/**创建的是btn2 */
+ (UIButton *) greenBtnfrome:(CGRect)from andText:(NSString *)text andColor:(UIColor *)color andimg:(UIImage*)img andView:(UIView *)vc;
/**创建的是view */
+ (UIView *) viewfrome:(CGRect)from  andColor:(UIColor *)color  andView:(UIView *)vc;
/**创建的是img */
+ (UIImageView *) imgfrome:(CGRect)from  andImg:(UIImage *)img  andView:(UIView *)vc;
/**创建的是textF */
+ (UITextField *) textFieldfrome:(CGRect)from andText:(NSString *)text andColor:(UIColor *)color  andView:(UIView *)vc;
//lp --lab
//+(LPLabel *) lplLabfrome:(CGRect)from andText:(NSString *)text andColor:(UIColor *)color  andView:(UIView *)vc;
//+(SectionBtn *) sbtnfrome:(CGRect)from andText:(NSString *)text andColor:(UIColor *)color andimg:(UIImage*)img andView:(UIView *)vc;
//null转@""
+ (NSString *) NullString:(NSString *)string;
//空字符判断
+ (BOOL) isBlankString:(NSString *)string;
+ (NSString*)md532BitLower:(NSString *)str;

+ (NSString *) isNullString:(NSString *)string;
//MD5加密
+ (NSString*)createMd5Sign:(NSMutableDictionary*)dict;

+ (void)keyboardExtension:(UITextField *)textField vc:(UIViewController *)sl btn:(UIButton *)btn;

//切圆
+ (UIView *)viewCircle:(UIView *)myView withRadius:(int)radius;
//lab自适应
+ (CGRect )fitLabFrom:(UILabel *)lab  withText:(NSString *)str withX:(CGFloat)xf withY:(CGFloat)yF withWidth:(CGFloat)widhtF withHeight:(CGFloat)heightF withL:(CGFloat)lx;
//时间转换
+ (NSString *)changeDate:(NSString *)dateString;

//今天-昨天-前天--日期格式修改
+ (NSString *)compareDate:(NSDate *)date;
//删除字符串中的字符
+ (NSString *) stringDeleteString:(NSString *)str;
//设置不同字体颜色
+ (void)fuwenbenLabel:(UILabel *)labell FontNumber:(id)font AndRange:(NSRange)range AndColor:(UIColor *)vaColor;
+ (NSString *)getAstroWithMonth:(int)m day:(int)d;

@end
