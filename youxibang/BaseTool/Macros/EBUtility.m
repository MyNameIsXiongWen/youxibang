//
//  EBUtility.m
//  DChang
//
//  Created by 戎博 on 17/7/21.
//  Copyright © 2017年 昆博. All rights reserved.
//

#import "EBUtility.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>
//#import "Base_UITextField.h"
#define LVCOLOR  [EBUtility colorWithHexString:[UIColor whiteColor] alpha:1]

@implementation EBUtility

+ (UIColor *)UIColorFromHexColor:(NSString *)hexColor
{
    
    unsigned int red,green,blue;
    NSRange range;
    range.length = 2;
    
    range.location = 0;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
    
    range.location = 2;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
    
    range.location = 4;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];
    
    return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green / 255.0f) blue:(float)(blue / 255.0f) alpha:1.0f];
}

+ (void)callWithString:(NSString *)phoneString
{
    [self callWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phoneString]]];
}

+ (void)callWithURL:(NSURL *)url
{
    static UIWebView *webView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        webView = [UIWebView new];
    });
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
}

+ (NSString *)md5HexDigest:(NSString*)input
{
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

+ (NSMutableAttributedString *)priceAttrStrWithCutline:(NSString *)priceStr
{
    NSMutableAttributedString *cutPriceString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"¥ %@", priceStr]];
    [cutPriceString addAttribute:NSStrikethroughStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, cutPriceString.length)];
    [cutPriceString addAttribute:NSStrikethroughColorAttributeName value:[UIColor clearColor] range:NSMakeRange(0, 2)];
    return cutPriceString;
}

+ (NSMutableAttributedString *)changePartStringStyleWithString:(NSString *)string WithColor:(UIColor *)color WithSize:(int)size WithRange:(NSRange)range
{
    NSMutableAttributedString *theNewString = [[NSMutableAttributedString alloc] initWithString:string];
    //    [theNewString addAttribute:NSStrikethroughStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, cutPriceString.length)];
    UIFont *font = [UIFont systemFontOfSize:size];
    [theNewString addAttribute:NSFontAttributeName value:font range:range];
    [theNewString addAttribute:NSForegroundColorAttributeName value:color range:range];
    return theNewString;
}

+ (NSMutableAttributedString *)setPriceAttrStr:(NSString *)presentPrice
                                 originalPrice:(NSString *)originalPrice
                                 intervalSpace:(NSString *)intervalSpace
                               presentFontSize:(float)presenFontSize
                              originalFontSize:(float)originalFontSize
{
    NSString *presentPriceStr = [NSString stringWithFormat:@"¥%@", presentPrice];
    NSString *originalPriceStr = @"";
    if (originalPrice && originalPrice.length > 0) {
        originalPriceStr = [NSString stringWithFormat:@"¥%@", originalPrice];
    }
    NSString *priceStr = [NSString stringWithFormat:@"%@%@%@", presentPriceStr, intervalSpace, originalPriceStr];
    NSMutableAttributedString *priceAttrStr = [[NSMutableAttributedString alloc] initWithString:priceStr];
    
    //给现价调整样式
    UIColor *presentPriceColor = [EBUtility UIColorFromHexColor:@"e50a06"];
    NSRange presentPriceRange = NSMakeRange(0, presentPriceStr.length);
    [priceAttrStr removeAttribute:NSFontAttributeName range:presentPriceRange];
    [priceAttrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:presenFontSize] range:presentPriceRange];
    [priceAttrStr addAttribute:NSForegroundColorAttributeName value:presentPriceColor range:presentPriceRange];
    
    //给原价调整样式
    if (originalPriceStr.length > 0) {
        UIColor *originalPriceColor = [EBUtility UIColorFromHexColor:@"949494"];
        NSRange originalPriceRange = NSMakeRange(presentPriceStr.length + intervalSpace.length, originalPriceStr.length);
        [priceAttrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:originalFontSize] range:originalPriceRange];
        [priceAttrStr addAttribute:NSForegroundColorAttributeName value:originalPriceColor range:originalPriceRange];
        [priceAttrStr addAttribute:NSStrikethroughStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, priceStr.length)];
        [priceAttrStr addAttribute:NSStrikethroughColorAttributeName value:[UIColor clearColor] range:NSMakeRange(0, presentPriceStr.length + intervalSpace.length + 1)]; //+1是“¥”的长度
        [priceAttrStr endEditing];
        
    }
    
    return priceAttrStr;
}

+ (BOOL)customServiceWithQQ:(NSString *)qqNum
{
    BOOL bCanCallQQ = NO;
    NSString *urlStr = [NSString stringWithFormat:@"mqq://im/chat?chat_type=wpa&uin=%@&version=1&src_type=web", qqNum];
    NSURL *url = [NSURL URLWithString:urlStr];
    if([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url];
        bCanCallQQ = YES;
    }
    return bCanCallQQ;
}

+ (void)resignKeyBoardInView:(UIView *)view
{
    for (UIView *v in view.subviews) {
        if ([v.subviews count] > 0) {
            [self resignKeyBoardInView:v];
        }
        
        if ([v isKindOfClass:[UITextField class]]) {
            continue;
        }
        
        if ([v isKindOfClass:[UITextView class]] || [v isKindOfClass:[UITextField class]]) {
            [v resignFirstResponder];
        }
    }
}

+ (void)appraiseAppAtAppStote:(NSString *)appID
{
    NSString *appraiseStr = [NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8", appID];
    if([[[UIDevice currentDevice] systemVersion] doubleValue] < 7.0)
    {
        appraiseStr = [NSString stringWithFormat: @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", appID];
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appraiseStr]];
}

+ (void)downLoadAppAtAppStote:(NSString *)appID
{
    NSString *downLoadStr = [NSString stringWithFormat: @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@",  appID];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:downLoadStr]];
}

+ (BOOL)isPriceValid:(NSString *)priceStr
{
    BOOL bValid = NO;
    float priceValue = [priceStr floatValue];
    if (priceValue >= 0.01) {
        bValid = YES;
    }
    return bValid;
}

+ (NSString *)appVersionInfo
{
    NSString *versionInfo = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    return versionInfo;
}
+ (void)changeNavigationBar:(UIViewController*)VC
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];//20变白
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];//item变白
    VC.navigationController.navigationBar.barTintColor = [EBUtility UIColorFromHexColor:@"39AC67"];//背景红
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];//去掉返回的字
    VC.navigationItem.backBarButtonItem = item;
    
    VC.edgesForExtendedLayout = UIRectEdgeNone;//跳过64
    VC.view.backgroundColor = [UIColor groupTableViewBackgroundColor];//背景灰
}
//邮箱
+ (BOOL) validateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}


//手机号码验证
+ (BOOL)isMobileNumber:(NSString *)mobileNum
{
    if (mobileNum.length != 11)
    {
        return NO;
    }
    /**
     * 手机号码:
     * 13[0-9], 14[5,7], 15[0, 1, 2, 3, 5, 6, 7, 8, 9], 17[6, 7, 8], 18[0-9]
     * 移动号段: 134,135,136,137,138,139,150,151,152,157,158,159,182,183,184,187,188,147,178
     * 联通号段: 130,131,132,155,156,185,186,145,176
     * 电信号段: 133,153,180,181,189,177
     */
    
    
    NSString *MOBILE = @"^1(3[0-9]|4[57]|5[0-35-9]|8[0-9])\\d{8}$";
    /**
     * 中国移动：China Mobile
     * 134,135,136,137,138,139,150,151,152,157,158,159,182,183,184,187,188,147,178
     */
    NSString *CM = @"^1(3[4-9]|4[7]|5[0-27-9]|7[8]|8[2-478])\\d{8}$";
    /**
     * 中国联通：China Unicom
     * 130,131,132,155,156,185,186,145,176
     */
    NSString *CU = @"^1(3[0-2]|4[5]|5[56]|7[6]|8[56])\\d{8}$";
    /**
     * 中国电信：China Telecom
     * 133,153,180,181,189,177
     */
    NSString *CT = @"^1(33|53|7[0-9]|8[019])\\d{8}$";
    
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

//车牌号验证
+ (BOOL) validateCarNo:(NSString *)carNo
{
    NSString *carRegex = @"^[\u4e00-\u9fa5]{1}[a-zA-Z]{1}[a-zA-Z_0-9]{4}[a-zA-Z_0-9_\u4e00-\u9fa5]$";
    NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex];
    ////DBLOG(@"carTest is %@",carTest);
    return [carTest evaluateWithObject:carNo];
}


//车型
+ (BOOL) validateCarType:(NSString *)CarType
{
    NSString *CarTypeRegex = @"^[\u4E00-\u9FFF]+$";
    NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",CarTypeRegex];
    return [carTest evaluateWithObject:CarType];
}


//用户名
+ (BOOL) validateUserName:(NSString *)name
{
    NSString *userNameRegex = @"^[A-Za-z0-9]{6,20}+$";
    NSPredicate *userNamePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",userNameRegex];
    BOOL B = [userNamePredicate evaluateWithObject:name];
    return B;
}


//密码
+ (BOOL) validatePassword:(NSString *)passWord
{
    NSString *passWordRegex = @"^[a-zA-Z0-9]{6,15}+$";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passWordRegex];
    return [passWordPredicate evaluateWithObject:passWord];
}


//昵称
+ (BOOL) validateNickname:(NSString *)nickname
{
    NSString *nicknameRegex = @"^[\u4e00-\u9fa5]{4,8}$";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",nicknameRegex];
    return [passWordPredicate evaluateWithObject:nickname];
}


//身份证号
+ (BOOL) validateIdentityCard: (NSString *)identityCard
{
    BOOL flag;
    if (identityCard.length <= 0) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [identityCardPredicate evaluateWithObject:identityCard];
}
// 定义成方法方便多个label调用 增加代码的复用性
+ (CGSize)sizeWithString:(NSString *)string font:(UIFont *)font
{
    CGRect rect = [string boundingRectWithSize:CGSizeMake(SCREEN_HEIGHT-20, 500)//限制最大的宽度和高度
                                       options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading  |NSStringDrawingUsesLineFragmentOrigin//采用换行模式
                                    attributes:@{NSFontAttributeName: font}//传人的字体字典
                                       context:nil];
    
    return rect.size;
}

+(void)prompt:(NSString *)string with:(UIViewController *)vc
{
    
    //[label  removeFromSuperview];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2-100/2, SCREEN_HEIGHT+50, 100, 30)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = string;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:13];
    
    
    //获取当前文本的属性
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:label.font,NSFontAttributeName, nil];
    //获取文本需要的size
    CGSize actualsize = [label.text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-20, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:dictionary context:nil].size;
    
    //重新设置label的大小
    
    //    [UIView animateWithDuration:0.2 // 动画时长
    //                     animations:^{
    label.frame = CGRectMake(SCREEN_WIDTH/2-(actualsize.width+20)/2, SCREEN_HEIGHT+50, actualsize.width+20, 30);
    //                         label.frame = CGRectMake(SCREEN_WIDTH/2-(actualsize.width)/2, SCREEN_HEIGHT-64-50, actualsize.width+20, 30);
    //
    //                     }];
    //动画回弹效果
    [UIView animateWithDuration:1.0 // 动画时长
                          delay:0.0 // 动画延迟
         usingSpringWithDamping:0.3 // 类似弹簧振动效果 0~1
          initialSpringVelocity:10.0 // 初始速度
                        options:UIViewAnimationOptionCurveEaseInOut // 动画过渡效果
                     animations:^{
                         label.frame = CGRectMake(SCREEN_WIDTH/2-(actualsize.width)/2, SCREEN_HEIGHT-64-150, actualsize.width+20, 30);
                         
                         label.layer.cornerRadius = 5;
                         
                         label.clipsToBounds = YES;
                         
                         label.backgroundColor = [UIColor blackColor];
                         label.alpha = 0.5;
                         UIWindow *window = [UIApplication sharedApplication].keyWindow;
                         [window addSubview:label];
                         
                     } completion:^(BOOL finished) {
                         // 动画完成后执行
                         // code...
                         // [bgImg setAlpha:1];
                         double delayInSeconds = 0.5;
                         dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                         dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                             ////DBLOG(@"timer date 2== %@",[NSDate date]);
                             [label removeFromSuperview];
                         });
                         
                     }];
    
    
    
    
    
}
//-(void)undockView:(UILabel *)label
//{
//
//    [label removeFromSuperview];
//}
+(void)ahahwith:(UIImageView *)customActivityIndicator
{
    customActivityIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-20, 250, 40, 40)];
    
    
    
    customActivityIndicator.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"loading_05"],[UIImage imageNamed:@"loading_04"],[UIImage imageNamed:@"loading_03"],[UIImage imageNamed:@"loading_02"],[UIImage imageNamed:@"loading_01"],nil] ;
    
    customActivityIndicator.animationDuration = 1.0; // in seconds
    
    customActivityIndicator.animationRepeatCount = 0; // sets to loop
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    [window addSubview:customActivityIndicator];
    [customActivityIndicator startAnimating];
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //        ////DBLOG(@"timer date 2== %@",[NSDate date]);
        [customActivityIndicator stopAnimating];
        [customActivityIndicator removeFromSuperview];
    });
    // starts animating
    
    //[customActivityIndicator stopAnimating]; //stops animating
}
+(void)miss:(UIImageView *)customActivityIndicator
{
    [customActivityIndicator stopAnimating];
    [customActivityIndicator removeFromSuperview];
    
}
+(UIColor *)alphaColorWithHexString:(NSString *)colorString
{
    
    //删除字符串中的空格
    NSString *colorStr = [[colorString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    NSString *alphaStr = [NSString string];
    NSString *cString = [NSString string];
    if ([colorStr length] == 9) {
        for (NSInteger i = 0; i < [colorStr length]; i++) {
            if (i==1 || i==2) {
                alphaStr = [NSString stringWithFormat:@"%@%c",alphaStr,[colorStr characterAtIndex:i]];
            }else{
                cString = [NSString stringWithFormat:@"%@%c",cString,[colorStr characterAtIndex:i]];
            }
        }
        
    }
    return [self colorWithHexString:cString alpha:[alphaStr integerValue]];
}
//十六位颜色
+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha
{
    //删除字符串中的空格
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6)
    {
        return [UIColor clearColor];
    }
    // strip 0X if it appears
    //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"])
    {
        cString = [cString substringFromIndex:2];
    }
    //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"])
    {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6)
    {
        return [UIColor clearColor];
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:alpha];
}
/**创建的是view */
+(UIView *) viewfrome:(CGRect)from  andColor:(UIColor *)color  andView:(UIView *)vc
{
    UIView *my_View = [[UIView alloc]initWithFrame:from];
    my_View.backgroundColor = color;
    
    [vc addSubview:my_View];
    return my_View;
    
}
/**创建的是img */
+(UIImageView *)imgfrome:(CGRect)from  andImg:(UIImage *)img  andView:(UIView *)vc;
{
    UIImageView *my_View = [[UIImageView alloc]initWithFrame:from];
    my_View.image = img;
    my_View.userInteractionEnabled = YES;
    
    [vc addSubview:my_View];
    return my_View;
}
/**创建的是textF */
+(UITextField *) textFieldfrome:(CGRect)from andText:(NSString *)text andColor:(UIColor *)color  andView:(UIView *)vc
{
    UITextField *my_TextField = [[UITextField alloc]initWithFrame:from];
    my_TextField.backgroundColor = color;
    my_TextField.placeholder = text;
    my_TextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    my_TextField.font = [UIFont systemFontOfSize:15];
    [vc addSubview:my_TextField];
    
    return my_TextField;
}
/**创建的是Label */
+(UILabel *) labfrome:(CGRect)from andText:(NSString *)text andColor:(UIColor *)color  andView:(UIView *)vc
{
    UILabel *my_Label = [[UILabel alloc]initWithFrame:from];
    my_Label.textColor = color;
    my_Label.text = text;
    my_Label.font = [UIFont systemFontOfSize:14];
    //my_Label.alpha = 0.6;
    
    my_Label.textAlignment = NSTextAlignmentCenter;
    [vc addSubview:my_Label];
    return my_Label;
    
}
///**创建的是lplLabel */
//+(LPLabel *) lplLabfrome:(CGRect)from andText:(NSString *)text andColor:(UIColor *)color  andView:(UIView *)vc
//{
//    LPLabel *my_Label = [[LPLabel alloc]initWithFrame:from];
//    my_Label.textColor = color;
//    my_Label.text = text;
//    my_Label.font = [UIFont systemFontOfSize:14];
//    //my_Label.alpha = 0.6;
//
//    my_Label.textAlignment = NSTextAlignmentCenter;
//    [vc addSubview:my_Label];
//    return my_Label;
//
//}
/**创建的是btn */
+(UIButton *) btnfrome:(CGRect)from andText:(NSString *)text andColor:(UIColor *)color andimg:(UIImage*)img andView:(UIView *)vc
{
    
    UIButton *my_btn = [UIButton buttonWithType:UIButtonTypeCustom];
    my_btn.frame = from;
    [my_btn setTitleColor:color forState:UIControlStateNormal];
    [my_btn setTitle:text forState:UIControlStateNormal];
    [my_btn setImage:img forState:UIControlStateNormal];
    [vc addSubview:my_btn];
    return my_btn;
}

///**创建的是btn */
//+(SectionBtn *) sbtnfrome:(CGRect)from andText:(NSString *)text andColor:(UIColor *)color andimg:(UIImage*)img andView:(UIView *)vc
//{
//    SectionBtn *my_btn = [SectionBtn buttonWithType:UIButtonTypeCustom];
//    my_btn.frame = from;
//    [my_btn setTitleColor:color forState:UIControlStateNormal];
//    [my_btn setTitleColor:color forState:UIControlStateNormal];
//    [my_btn setTitle:text forState:UIControlStateNormal];
//    [my_btn setImage:img forState:UIControlStateNormal];
//    [vc addSubview:my_btn];
//    return my_btn;
//}
///**创建的是btn2 */
+(UIButton *) greenBtnfrome:(CGRect)from andText:(NSString *)text andColor:(UIColor *)color andimg:(UIImage*)img andView:(UIView *)vc
{
    UIButton *my_btn = [UIButton buttonWithType:UIButtonTypeCustom];
    my_btn.frame = from;
    [my_btn setTitleColor:color forState:UIControlStateNormal];
    [my_btn setTitle:text forState:UIControlStateNormal];
    //    [my_btn setBackgroundColor: [EBUtility colorWithHexString:@"#39AC67" alpha:1]];
    my_btn.layer.cornerRadius = 5;
    my_btn.titleLabel.font = [UIFont systemFontOfSize:14];
    my_btn.clipsToBounds = YES;
    
    [my_btn setImage:img forState:UIControlStateNormal];
    [vc addSubview:my_btn];
    return my_btn;
}


//空字符判断
+ (BOOL) isBlankString:(NSString *)string
{
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isEqualToString:@"(null)"]) {
        return YES;
    }
    if ([string isEqualToString:@"<null>"]) {
        return YES;
    }

    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}
//空转0.00
+ (NSString *) isNullString:(NSString *)string
{
    if ([string isEqualToString:@""]||[string isEqualToString:@"0"])
    {
        string = @"0.00";
        
    }
    return string;
}

//null转@""
+ (NSString *) NullString:(NSString *)string
{
    if ([string isEqualToString:@""]||[string isEqualToString:@"<null>"]||string ==NULL||[string isEqualToString:@"(null)"])
    {
        string = @"";
        
    }
    return string;
}

+ (NSString *)md51:(NSString *)str
{
    const char *cStr = [str UTF8String];
    
    unsigned char result[16];
    
    
    NSNumber *num = [NSNumber numberWithUnsignedLong:strlen(cStr)];
    
    CC_MD5( cStr,[num intValue], result );
    return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",result[0], result[1], result[2], result[3],result[4], result[5], result[6], result[7],result[8], result[9], result[10], result[11],result[12], result[13], result[14], result[15]] lowercaseString];
}


+(NSString*)md532BitLower:(NSString *)str


{
    
    
    const char *cStr = [str  UTF8String];
    
    unsigned char result[16];
    
    
    
    NSNumber *num = [NSNumber numberWithUnsignedLong:strlen(cStr)];
    
    CC_MD5( cStr,[num intValue], result );
    
    
    
    return [[NSString stringWithFormat:
             
             @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             
             result[0], result[1], result[2], result[3],
             
             result[4], result[5], result[6], result[7],
             
             result[8], result[9], result[10], result[11],
             
             result[12], result[13], result[14], result[15]
             
             ] lowercaseString];
    
}



//创建md5签名 加密
+(NSString*)createMd5Sign:(NSMutableDictionary*)dict
{
    NSMutableString *contentString  =[NSMutableString string];
    NSArray *keys = [dict allKeys];
    //按字母顺序排序
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    //拼接字符串
    for (NSString *categoryId in sortedArray) {
        //        if (![[dict objectForKey:categoryId] isEqualToString:@""])
        //        {
        [contentString appendFormat:@"%@=%@&", categoryId, [dict objectForKey:categoryId]];
        //        }
    }
    //添加key字段
    [contentString appendFormat:@"key=%@",md5Key];
    NSString *md5Sign;
    // NSString *md5Sign =[contentString MD5EncodedString];
    //    //DBLOG(@"contentString---->>%@,md5Sign--->>%@",contentString,md5Sign);
    return md5Sign;
}
+(void)keyboardExtension:(UITextField *)textField vc:(UIViewController *)sl btn:(UIButton *)btn
{
    UIToolbar *topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    UIImage *toolBarIMG = [UIImage imageNamed:@"addAddress_Ig"];
    
    if ([topView respondsToSelector:@selector(setBackgroundImage:forToolbarPosition:barMetrics:)]) {
        [topView setBackgroundImage:toolBarIMG forToolbarPosition:0 barMetrics:0];
    }
    [topView setBarStyle:UIBarStyleBlackTranslucent];
    
    UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:sl action:nil];
    
    
    btn.frame = CGRectMake(2, 5, 50, 25);
    
    // [btn setTitleColor:[UIColor colorWithHexString:@"#333333"] forState:UIControlStateNormal];
    [btn setTitle:@"完成" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc]initWithCustomView:btn];
    NSArray * buttonsArray = [NSArray arrayWithObjects:btnSpace,doneBtn,nil];
    [topView setItems:buttonsArray];
    [textField setInputAccessoryView:topView];
}

+(UIView *)viewCircle:(UIView *)myView withRadius:(int)radius
{
    //按钮切圆
    
    myView.layer.cornerRadius = radius;
    
    myView.clipsToBounds = YES;
    
    return myView;
}

//lab 自适应
+(CGRect )fitLabFrom:(UILabel *)lab  withText:(NSString *)str withX:(CGFloat)xf withY:(CGFloat)yF withWidth:(CGFloat)widhtF withHeight:(CGFloat)heightF withL:(CGFloat)lx
{
    //获取当前文本的属性
    lab.numberOfLines = 0;
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:lab.font,NSFontAttributeName, nil];
    
    //获取文本需要的size
    
    CGSize actualsize = [str boundingRectWithSize:CGSizeMake(widhtF, heightF) options:NSStringDrawingUsesLineFragmentOrigin attributes:dictionary context:nil].size;
    
    //重新设置label的大小
    if ([[NSString stringWithFormat:@"%f",lx] intValue] == 0) {
        lab.frame = CGRectMake(xf, yF, actualsize.width+10, 21);
    }else
    {
        lab.frame = CGRectMake(xf, yF, lx, 21);
    }
    
    return lab.frame;
}
//今天-昨天-前天--日期格式修改
+(NSString *)compareDate:(NSDate *)date
{
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    
    //修正8小时之差
    NSDate *date1 = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date1];
    NSDate *localeDate = [date1  dateByAddingTimeInterval: interval];
    
    ////DBLOG(@"nowdate=%@\nolddate = %@",localeDate,date);
    NSDate *today = localeDate;
    NSDate *yesterday,*beforeOfYesterday;
    //今年
    NSString *toYears;
    
    toYears = [[today description] substringToIndex:4];
    
    yesterday = [today dateByAddingTimeInterval: -secondsPerDay];
    beforeOfYesterday = [yesterday dateByAddingTimeInterval: -secondsPerDay];
    
    // 10 first characters of description is the calendar date:
    NSString *todayString = [[today description] substringToIndex:10];
    NSString *yesterdayString = [[yesterday description] substringToIndex:10];
    NSString *beforeOfYesterdayString = [[beforeOfYesterday description] substringToIndex:10];
    
    NSString *dateString = [[date description] substringToIndex:10];
    NSString *dateYears = [[date description] substringToIndex:4];
    
    NSString *dateContent;
    if ([dateYears isEqualToString:toYears]) {//同一年
        //今 昨 前天的时间
        NSString *time = [[date description] substringWithRange:(NSRange){11,5}];
        //其他时间
        NSString *time2 = [[date description] substringWithRange:(NSRange){5,11}];
        if ([dateString isEqualToString:todayString]){
            dateContent = [NSString stringWithFormat:@"今天 %@",time];
            return dateContent;
        } else if ([dateString isEqualToString:yesterdayString]){
            dateContent = [NSString stringWithFormat:@"昨天 %@",time];
            return dateContent;
        }else if ([dateString isEqualToString:beforeOfYesterdayString]){
            dateContent = [NSString stringWithFormat:@"前天 %@",time];
            return dateContent;
        }else{
            return time2;
        }
    }else{
        return dateString;
    }
}


+(NSString *)changeDate:(NSString *)dateString
{
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    NSDate* date = [df dateFromString:dateString];
    
    NSString *dateString2  = [df stringFromDate:date];
    
    
    return dateString2;
}
+(CGRect)labAdaptive:(UILabel *)lab withLab:(NSString*)textString withBiggestW:(CGFloat)www  withBiggestH:(CGFloat)hhh withX:(CGFloat)x withY:(CGFloat)y
{
    //获取当前文本的属性
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:lab.font,NSFontAttributeName, nil];
    
    //获取文本需要的size
    
    CGSize actualsize = [textString boundingRectWithSize:CGSizeMake(www, hhh) options:NSStringDrawingUsesLineFragmentOrigin attributes:dictionary context:nil].size;
    
    //重新设置label的大小
    
    CGRect llframe = CGRectMake(x, y, actualsize.width, actualsize.height);
    return  llframe;
}

//删除字符串中的字符
+(NSString *) stringDeleteString:(NSString *)str
{
    NSMutableString *str1 = [NSMutableString stringWithString:str];
    for (int i = 0; i < str1.length; i++) {
        unichar c = [str1 characterAtIndex:i];
        NSRange range = NSMakeRange(i, 1);
        if ( c == '"' || c == 'T' || c == ',' || c == '(' || c == ')') { //可以随意写想删除的，(C后面的那些  随便加)，返回值我写的是全局 还有减号方法，有其他需求自行修改
            [str1 deleteCharactersInRange:range];
            --i;
        }
    }
    NSString *newstr = [NSString stringWithString:str1];
    NSLog(@"%@",newstr);
    return newstr;
}
//设置不同字体颜色

+(void)fuwenbenLabel:(UILabel *)labell FontNumber:(id)font AndRange:(NSRange)range AndColor:(UIColor *)vaColor

{
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:labell.text];
    
    //设置字号
    
    [str addAttribute:NSFontAttributeName value:font range:range];
    
    //设置文字颜色
    
    [str addAttribute:NSForegroundColorAttributeName value:vaColor range:range];
    
    labell.attributedText = str;
    
}

//计算星座
+(NSString *)getAstroWithMonth:(int)m day:(int)d{

    NSString *astroString = @"魔羯水瓶双鱼白羊金牛双子巨蟹狮子处女天秤天蝎射手魔羯";

    NSString *astroFormat = @"102123444543";

    NSString *result;

    if (m<1||m>12||d<1||d>31){

        return @"错误日期格式!";

    }

    if(m==2 && d>29){

        return @"错误日期格式!!";
   
    }else if(m==4 || m==6 || m==9 || m==11) {

        if (d>30) {

            return @"错误日期格式!!!";

        }
 
    }

    result=[NSString stringWithFormat:@"%@",[astroString substringWithRange:NSMakeRange(m*2-(d < [[astroFormat substringWithRange:NSMakeRange((m-1), 1)] intValue] - (-19))*2,2)]];
    
    return result;
 
}
@end

