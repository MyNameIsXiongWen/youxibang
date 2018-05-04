//
//  ShareView.h
//  youxibang
//
//  Created by jiazhuo1 on 2018/5/2.
//

#import <UIKit/UIKit.h>
#import <TencentOpenAPI/QQApiInterface.h>

typedef void(^ConfirmShareBlock)(NSString *type);
@interface ShareView : UIView <QQApiInterfaceDelegate> {
    NSString *shareurl;
}

//@property (nonatomic, copy) ConfirmShareBlock confirmShareBlock;
@property (nonatomic, strong) UIView *blackView;
- (void)show;
- (void)dismiss;
- (instancetype)initWithFrame:(CGRect)frame WithShareUrl:(NSString *)url;

@end
