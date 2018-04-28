//
//  IntelligentModel.h
//  youxibang
//
//  Created by jiazhuo1 on 2018/4/23.
//

#import <Foundation/Foundation.h>

@class IntelligentModel;
@interface ContentModel : NSObject

@property (copy, nonatomic) NSString *id;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *sort;
@property (copy, nonatomic) NSMutableArray <IntelligentModel *>*data;

@end

@interface IntelligentModel : NSObject

@property (copy, nonatomic) NSString *id;
@property (copy, nonatomic) NSString *duanwei;
@property (copy, nonatomic) NSString *price;
@property (copy, nonatomic) NSString *image;
@property (copy, nonatomic) NSString *fontcolor;
@property (copy, nonatomic) NSString *photo;
@property (copy, nonatomic) NSString *nickname;
@property (copy, nonatomic) NSString *last_login;
@property (copy, nonatomic) NSString *juli;
@property (copy, nonatomic) NSString *age;
@property (copy, nonatomic) NSString *sex;

//粉丝列表用
@property (copy, nonatomic) NSString *is_realauth;
@property (copy, nonatomic) NSString *is_follow;
@property (copy, nonatomic) NSString *vip_grade;
@property (copy, nonatomic) NSString *user_id;

@end
