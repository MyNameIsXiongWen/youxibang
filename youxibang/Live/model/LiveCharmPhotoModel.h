//
//  LiveCharmPhotoModel.h
//  youxibang
//
//  Created by jiazhuo1 on 2018/4/27.
//

#import <Foundation/Foundation.h>

@interface LiveCharmPhotoModel : NSObject

@property (copy, nonatomic) NSString *id;
@property (copy, nonatomic) NSString *fee;
@property (copy, nonatomic) NSString *url;
@property (copy, nonatomic) NSString *is_charge;
@property (assign, nonatomic) NSInteger type;//1是新的。2是旧的

@end
