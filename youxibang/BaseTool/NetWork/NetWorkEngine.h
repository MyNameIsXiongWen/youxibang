//
//  NetWorkEngine.h
//  AFN
//
//  Created by laouhn on 15/9/18.
//  Copyright (c) 2015年 laouhn. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^Success)(id response);
typedef void(^Fail)(NSError *error);

@interface NetWorkEngine : NSObject

+ (NetWorkEngine *)shareNetWorkEngine;


//封装了一个网络请求
- (void)getInfoFromServerWithUrlStr:(NSString *)str
                         Paremeters:(id)parameters
                   successOperation:(Success)success
                      failoperation:(Fail)fail;


- (void)postInfoFromServerWithUrlStr:(NSString *)str
                         Paremeters:(id)parameters
                   successOperation:(Success)success
                      failoperation:(Fail)fail;



//封装一个上传图片和文件的网络请求
- (void)postInfoFromServerWithUrlStr:(NSString *)str
                          Paremeters:(id)parameters
                               Image:(UIImage *)image
                           ImageName:(NSString *)imageName
                    successOperation:(Success)success
                       failoperation:(Fail)fail;
//上传多张图片(只上传图片)
- (void)onlyPostImageAryInfoFromServerWithUrlStr:(NSString *)str
                           Paremeters:(id)parameters
                                Image:(NSArray  *)array
                            ImageName:(NSArray  *)nameArray
                     successOperation:(Success)success
                        failoperation:(Fail)fail;
//上传多张图片
- (void)postImageAryInfoFromServerWithUrlStr:(NSString *)str
                                  Paremeters:(id)parameters
                                       Image:(NSArray  *)array
                                   ImageName:(NSArray  *)nameArray
                            successOperation:(Success)success
                               failoperation:(Fail)fail;

//监测网络状态
-(void)reachabilitysuccessOperation:(Success)success
                      failoperation:(Fail)fail;
//上传视频&截图
- (void)postFileFromServerWithUrlStr:(NSString *)str
                          Paremeters:(id)parameters
                               Image:(UIImage *)image
                                File:(NSString *)file
                    successOperation:(Success)success
                       failoperation:(Fail)fail;

@end
