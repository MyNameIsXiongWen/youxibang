//
//  NewsReviewModel.h
//  youxibang
//
//  Created by jiazhuo1 on 2018/4/28.
//

#import <Foundation/Foundation.h>

@interface NewsReviewModel : NSObject

@property (copy, nonatomic) NSString *head_pic;
@property (copy, nonatomic) NSString *article_id;
@property (copy, nonatomic) NSString *user_id;
@property (copy, nonatomic) NSString *nickname;
@property (copy, nonatomic) NSString *details;
@property (copy, nonatomic) NSString *comment_id;
@property (copy, nonatomic) NSString *laud_count;
@property (copy, nonatomic) NSString *is_laud;
@property (copy, nonatomic) NSString *time;

@end
