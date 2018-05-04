//
//  UserModel.h
//  youxibang
//
//  Created by jiazhuo1 on 2018/4/18.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject <NSCoding>

@property (copy, nonatomic) NSString *birthday;
@property (copy, nonatomic) NSString *myinterest;
@property (copy, nonatomic) NSString *user_money;
@property (copy, nonatomic) NSString *alipay;
@property (copy, nonatomic) NSString *is_paypwd;
@property (copy, nonatomic) NSString *nickname;
@property (copy, nonatomic) NSString *sex;
@property (copy, nonatomic) NSString *mysign;
@property (copy, nonatomic) NSString *is_vip;
@property (copy, nonatomic) NSString *invitecode;
@property (copy, nonatomic) NSString *is_newmsgsounds;
@property (copy, nonatomic) NSString *is_strangercall;
@property (copy, nonatomic) NSString *is_vipstr;
@property (copy, nonatomic) NSString *arrears;
@property (copy, nonatomic) NSString *is_alipay;
@property (copy, nonatomic) NSString *age;
@property (copy, nonatomic) NSString *is_newmsg;
@property (copy, nonatomic) NSString *photo;
@property (copy, nonatomic) NSString *kefuurl;
@property (copy, nonatomic) NSString *sexstr;
@property (copy, nonatomic) NSString *is_realauthstr;
@property (copy, nonatomic) NSString *is_realauth;
@property (copy, nonatomic) NSString *follow_count;
@property (copy, nonatomic) NSString *laud_count;
@property (copy, nonatomic) NSString *is_anchor;
@property (copy, nonatomic) NSArray *bgimg;
@property (copy, nonatomic) NSArray *interest;
@property (strong, nonatomic) NSDictionary *video;

@property(nonatomic, strong) NSString *city;//城市
@property(nonatomic, strong) NSString *latitude;//纬度
@property(nonatomic, strong) NSString *longitude;//经度

//@property (copy, nonatomic) NSString *userid;
//@property (copy, nonatomic) NSString *mobile;
//@property (copy, nonatomic) NSString *token;
//@property(nonatomic, strong) NSString *yxuser;//云信账号
//@property(nonatomic, strong) NSString *yxpwd;//云信密码

+ (UserModel *)sharedUser ;
+ (void)keyarchiveUserModelWithDict:(NSDictionary *)dict ;
- (void)keyarchiveUserModel ;

@end
