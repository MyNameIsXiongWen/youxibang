//
//  NewsModel.h
//  youxibang
//
//  Created by jiazhuo1 on 2018/4/26.
//

#import <Foundation/Foundation.h>

@interface NewsModel : NSObject

@property (copy, nonatomic) NSString *article_id;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *thumb;
@property (copy, nonatomic) NSString *publish_time;
@property (copy, nonatomic) NSString *is_top;
@property (copy, nonatomic) NSString *comment_count;
@property (copy, nonatomic) NSString *is_laud;
@property (copy, nonatomic) NSString *laud_count;
@property (copy, nonatomic) NSString *content;

@end
