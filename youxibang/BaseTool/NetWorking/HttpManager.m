//
//  HttpManager.m
//  AJCash
//
//  Created by 熊文 on 16/11/9.
//  Copyright © 2016年 熊文. All rights reserved.
//

#import "HttpManager.h"

@implementation HttpManager

static id _instance = nil;

+ (instancetype)sharedInstance {
    static HttpManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [HttpManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/javascript",@"application/json",@"text/json", @"text/html",@"text/plain", nil];
        manager.requestSerializer.timeoutInterval = 30;
    });
    return manager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

- (void)monitorInternet {
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager startMonitoring];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
            {
                // 位置网络
                NSLog(@"未知网络");
            }
                break;
            case AFNetworkReachabilityStatusNotReachable:
            {
                // 无法联网
                NSLog(@"无法联网");
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
            {
                // WIFI
                NSLog(@"当前在WIFI网络下");
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
            {
                // 手机自带网络
                NSLog(@"当前使用的是2G/3G/4G网络");
            }
        }
    }];
}

#pragma mark -- GET请求 --
- (void)getWithURLString:(NSString *)URLString
                  method:(NSString *)method
              parameters:(id)parameters
                 success:(void (^)(id))success
                 failure:(void (^)(NSError *))failure {
    
    [[HttpManager sharedInstance] GET:[NSString stringWithFormat:@"%@/%@",URLString,method] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

#pragma mark -- POST请求 --
- (void)postWithURLString:(NSString *)URLString
                   method:(NSString *)method
               parameters:(id)parameters
                  success:(void (^)(id))success
                  failure:(void (^)(NSError *))failure {
    [[HttpManager sharedInstance] POST:[NSString stringWithFormat:@"%@/%@",URLString,method] parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *statusStr = [NSString stringWithFormat:@"%@",responseObject[@"status"]];
        if ([statusStr isEqualToString:@"600"]) {
            
        }
        else {
            [SVProgressHUD showErrorWithStatus:responseObject[@"msg"]];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error.code == -1001) {
            [SVProgressHUD showErrorWithStatus:@"请求超时"];
        }
        else {
            if (failure) {
                failure(error);
            }
        }
        [[HttpManager sharedInstance] monitorInternet];
    }];
}

-(void)postRequestWithUrl:(NSString *)urlStr parameters:(id)param completeHander:(void (^)(id, NSError *))complete{
    
    [[HttpManager sharedInstance] POST:urlStr parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        complete(responseObject,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        complete(nil,error);
    }];
}

#pragma mark -- POST/GET网络请求 --
- (void)requestWithURLString:(NSString *)URLString
                  parameters:(id)parameters
                        type:(HttpRequestType)type
                     success:(void (^)(id))success
                     failure:(void (^)(NSError *))failure {
    
    switch (type) {
        case HttpRequestTypeGet:
        {
            [[HttpManager sharedInstance] GET:URLString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (success) {
                    success(responseObject);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failure) {
                    failure(error);
                }
            }];
        }
            break;
        case HttpRequestTypePost:
        {
            [[HttpManager sharedInstance] POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (success) {
                    success(responseObject);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failure) {
                    failure(error);
                }
            }];
        }
            break;
    }
}

- (void)uploadWithURLString:(NSString *)URLString parameters:(id)parameters uploadParam:(NSArray<UploadParam *> *)uploadParams success:(void (^)(id responseObject))success failure:(void (^)(NSError *))failure progress:(void (^)(NSProgress *uploadProgress))progress {
    
    [[HttpManager sharedInstance] POST:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
//        for (UploadParam *uploadParam in uploadParams) {
//            [formData appendPartWithFileData:uploadParam.data
//                                        name:uploadParam.name
//                                    fileName:uploadParam.filename
//                                    mimeType:uploadParam.mimeType];
//        }
        NSString *hightImageName =[NSString stringWithFormat:@"uploadFile"];
        NSString *hightImageFileName =[NSString stringWithFormat:@"uploadFile.jpg"];
        [formData appendPartWithFileData:parameters[@"uploadFile"]
                                    name:hightImageName
                                fileName:hightImageFileName
                                mimeType:@"image/jpeg"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"%zd",uploadProgress.fractionCompleted);
        if (progress) {
            progress(uploadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

#pragma mark - 下载数据
- (void)downLoadWithURLString:(NSString *)URLString parameters:(id)parameters progerss:(void (^)())progress success:(void (^)())success failure:(void (^)(NSError *))failure {
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    NSURLSessionDownloadTask *downLoadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progress) {
            progress();
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return targetPath;
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (failure) {
            failure(error);
        }
    }];
    [downLoadTask resume];
}

@end
