//
//  NetWorkEngine.m
//  AFN
//
//  Created by laouhn on 15/9/18.
//  Copyright (c) 2015年 laouhn. All rights reserved.
//

#import "NetWorkEngine.h"
#import "AFNetworking.h"

@interface NetWorkEngine ()

@property (nonatomic, retain) AFHTTPSessionManager *manager;

@end

@implementation NetWorkEngine

+ (NetWorkEngine *)shareNetWorkEngine
{
    static NetWorkEngine *netWorkEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        netWorkEngine = [[NetWorkEngine alloc] init];
    });
    return netWorkEngine;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // AFN请求操作管理对象
        self.manager = [AFHTTPSessionManager manager];
        [self.manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        self.manager.requestSerializer.timeoutInterval = 15;
        [self.manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    }
    return self;
}

//封装了一个网络请求
- (void)getInfoFromServerWithUrlStr:(NSString *)str
                         Paremeters:(id)parameters
                   successOperation:(Success)success
                      failoperation:(Fail)fail
{
    // GET请求
    //1. urlStr
    //2. 请求地址的参数和值, 一般写成字典的形式, (基本不这样写, 一般写nil)
    
    // 当出现AFN解析错误的时候, (unacceptable to content-type....)
    //1. 不使用它自带的解析工具, 我们自己解析
//    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //2. 增加它解析支持的类型
    
    self.manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"text/xml", @"application/json", @"text/json", @"text/javascript", @"text/plain", nil];
    
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];

    [self.manager GET:str parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"------%@", responseObject);
        if ([responseObject isKindOfClass:[NSDictionary class]]){
            if ([NSString stringWithFormat:@"%@",(NSDictionary*)responseObject[@"errcode"]].intValue < -100){
                [self logout:(NSDictionary*)responseObject];
            }
            success(responseObject);
            return ;
        }
        NSString * str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSString * str1 =  [str stringByReplacingOccurrencesOfString:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>" withString:@""];
        NSString * str2 = [str1 stringByReplacingOccurrencesOfString:@"<string xmlns=\"huaxin.org\">" withString:@""];
        str2 = [str2 stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
        
        str2 = [str2 stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        str2 = [str2 stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        NSString * STR3 = [str2 stringByReplacingOccurrencesOfString:@"</string>" withString:@""];
        NSData *JSONData = [STR3 dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableContainers error:&err];
        if(err) {
            NSLog(@"json解析失败：%@",err);
        }
        if ([NSString stringWithFormat:@"%@",(NSDictionary*)responseJSON[@"errcode"]].intValue < -100){
            [self logout:(NSDictionary*)responseJSON];
        }
        success(responseJSON);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        fail(error);

    }];
}


- (void)postInfoFromServerWithUrlStr:(NSString *)str
                          Paremeters:(id)parameters
                    successOperation:(Success)success
                       failoperation:(Fail)fail
{
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    self.manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"text/xml", @"application/json", @"text/json", @"text/javascript", @"text/plain", nil];
   //  self.manager.requestSerializer =  [AFJSONRequestSerializer serializer];
    [self.manager POST:str parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
                          
                          
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]){
            if ([NSString stringWithFormat:@"%@",(NSDictionary*)responseObject[@"errcode"]].intValue < -100){
                [self logout:(NSDictionary*)responseObject];
            }
            success(responseObject);
            return ;
        }
        NSString * str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSString * str1 =  [str stringByReplacingOccurrencesOfString:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>" withString:@""];
        NSString * str2 = [str1 stringByReplacingOccurrencesOfString:@"<string xmlns=\"huaxin.org\">" withString:@""];
        str2 = [str2 stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
        str2 = [str2 stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        str2 = [str2 stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        NSString * STR3 = [str2 stringByReplacingOccurrencesOfString:@"</string>" withString:@""];
        NSData *JSONData = [STR3 dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
      if (JSONData){
          NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableContainers error:&err];
          if(err) {
              NSLog(@"json解析失败：%@",err);
          }
          if ([NSString stringWithFormat:@"%@",(NSDictionary*)responseJSON[@"errcode"]].intValue < -100){
              if (![str hasSuffix:@"Member/userinfo.html"]){
                  [self logout:(NSDictionary*)responseJSON];
              }
          }
          success(responseJSON);
      }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        fail(error);
    }];
}

//上传图片
- (void)postInfoFromServerWithUrlStr:(NSString *)str
                         Paremeters:(id)parameters
                              Image:(UIImage *)image
                              ImageName:(NSString *)imageName
                   successOperation:(Success)success
                      failoperation:(Fail)fail
{
    self.manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"text/xml", @"application/json", @"text/json", @"text/javascript", @"text/plain", nil];
    [self.manager POST:str parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        if (image){
            
            NSData *imageData = UIImageJPEGRepresentation(image,1);
            NSUInteger size =  [imageData length]/1024;
            if (size > 1000){
                imageData = UIImageJPEGRepresentation(image,0.1);
            }
                
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            
            formatter.dateFormat = @"yyyyMMddHHmmss";
            
            NSString *str = [formatter stringFromDate:[NSDate date]];
            
            NSString *fileName = [NSString stringWithFormat:@"%@%@.png",@"touxiang", str];
            
            [formData appendPartWithFileData:imageData name:imageName  fileName:fileName mimeType:@"image/png"];       // 上传图片的参数key
        }

    } progress:^(NSProgress * _Nonnull uploadProgress) {
    
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]){
            if ([NSString stringWithFormat:@"%@",(NSDictionary*)responseObject[@"errcode"]].intValue < -100){
                [self logout:(NSDictionary*)responseObject];
            }
            success(responseObject);
            return ;
        }
        NSString * str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSString * str1 =  [str stringByReplacingOccurrencesOfString:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>" withString:@""];
        NSString * str2 = [str1 stringByReplacingOccurrencesOfString:@"<string xmlns=\"huaxin.org\">" withString:@""];
        str2 = [str2 stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
        str2 = [str2 stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        str2 = [str2 stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        NSString * STR3 = [str2 stringByReplacingOccurrencesOfString:@"</string>" withString:@""];
        NSData *JSONData = [STR3 dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableContainers error:&err];
        if(err) {
            NSLog(@"json解析失败：%@",err);
        }
        if ([NSString stringWithFormat:@"%@",(NSDictionary*)responseJSON[@"errcode"]].intValue < -100){
            [self logout:(NSDictionary*)responseJSON];
        }
        success(responseJSON);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         fail(error);
    }];
    
}
//上传多张图片(只上传图片)
- (void)onlyPostImageAryInfoFromServerWithUrlStr:(NSString *)str
                                      Paremeters:(id)parameters
                                           Image:(NSArray  *)array
                                       ImageName:(NSArray  *)nameArray
                                successOperation:(Success)success
                                   failoperation:(Fail)fail {
    self.manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"text/xml", @"application/json", @"text/json", @"text/javascript", @"text/plain", nil];
    [self.manager POST:str parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSInteger imgCount = 0;
        for (UIImage* image in array) {
            NSData *imageData = UIImageJPEGRepresentation(image,0.7);
            NSUInteger size =  [imageData length]/1024;
            if (size > 100){
                imageData = UIImageJPEGRepresentation(image,100/size);
            }
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *time = [formatter stringFromDate:[NSDate date]];
            NSString *name = [NSString stringWithFormat:@"%@%@image",time,@(imgCount)];
            NSString *fileName = [NSString stringWithFormat:@"%@%@.png",time,@(imgCount)];
            [formData appendPartWithFileData:imageData name:name fileName:fileName mimeType:@"image/png"];
            imgCount++;
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]){
            if ([NSString stringWithFormat:@"%@",(NSDictionary*)responseObject[@"errcode"]].intValue < -100){
                [self logout:(NSDictionary*)responseObject];
            }
            success(responseObject);
            return ;
        }
        NSString * str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSString * str1 =  [str stringByReplacingOccurrencesOfString:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>" withString:@""];
        NSString * str2 = [str1 stringByReplacingOccurrencesOfString:@"<string xmlns=\"huaxin.org\">" withString:@""];
        str2 = [str2 stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
        str2 = [str2 stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        str2 = [str2 stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        NSString * STR3 = [str2 stringByReplacingOccurrencesOfString:@"</string>" withString:@""];
        NSData *JSONData = [STR3 dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableContainers error:&err];
        if(err) {
            NSLog(@"json解析失败：%@",err);
        }
        success((NSArray*)responseJSON);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        fail(error);
    }];
}

//上传多张图片
- (void)postImageAryInfoFromServerWithUrlStr:(NSString *)str
                          Paremeters:(id)parameters
                               Image:(NSArray  *)array
                               ImageName:(NSArray  *)nameArray
                    successOperation:(Success)success
                       failoperation:(Fail)fail
{
    self.manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"text/xml", @"application/json", @"text/json", @"text/javascript",@"text/plain",nil];
    [self.manager POST:str parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSInteger imgCount = 0;
        
        for (UIImage* image in array) {
            NSData *imageData = UIImagePNGRepresentation(image);
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            
            formatter.dateFormat = @"yyyy-MM-dd-HH:mm:ss:SSS";
            
            NSString *fileName = [NSString stringWithFormat:@"%@%@.png",[formatter stringFromDate:[NSDate date]],@(imgCount)];
            [formData appendPartWithFileData:imageData name:nameArray[imgCount] fileName:fileName mimeType:@"image/png"];
            
            imgCount++;
            
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if ([responseObject isKindOfClass:[NSDictionary class]]){
            if ([NSString stringWithFormat:@"%@",(NSDictionary*)responseObject[@"errcode"]].intValue < -100){
                [self logout:(NSDictionary*)responseObject];
            }
            success(responseObject);
            return ;
        }
        NSString * str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSString * str1 =  [str stringByReplacingOccurrencesOfString:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>" withString:@""];
        NSString * str2 = [str1 stringByReplacingOccurrencesOfString:@"<string xmlns=\"huaxin.org\">" withString:@""];
        str2 = [str2 stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
        str2 = [str2 stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        str2 = [str2 stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        NSString * STR3 = [str2 stringByReplacingOccurrencesOfString:@"</string>" withString:@""];
        NSData *JSONData = [STR3 dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableContainers error:&err];
        if(err) {
            NSLog(@"json解析失败：%@",err);
        }
        if ([NSString stringWithFormat:@"%@",(NSDictionary*)responseJSON[@"errcode"]].intValue < -100){
            [self logout:(NSDictionary*)responseJSON];
        }
        success(responseJSON);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        fail(error);
    }];
    
}

//上传文件&图片
- (void)postFileFromServerWithUrlStr:(NSString *)str
                          Paremeters:(id)parameters
                               Image:(UIImage *)image
                               File:(NSString *)file
                    successOperation:(Success)success
                       failoperation:(Fail)fail {
    self.manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"text/xml", @"application/json", @"text/json", @"text/javascript", @"text/plain", nil];
    [self.manager POST:str parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        if (image){
            NSData *imageData = UIImagePNGRepresentation(image);//UIImageJPEGRepresentation(image);
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            
            formatter.dateFormat = @"yyyyMMddHHmmss";
            
            NSString *str = [formatter stringFromDate:[NSDate date]];
            
            NSString *fileName = [NSString stringWithFormat:@"%@%@.png",@"photo", str];
            
            
            [formData appendPartWithFileData:imageData name:@"skillimg" fileName:fileName mimeType:@"image/png"];       // 上传图片的参数key
        }
        if (file){
            NSError *error;
            NSData *data = [NSData dataWithContentsOfFile:file options:NSDataReadingMappedIfSafe error:&error];
            NSString *name = [NSString stringWithFormat:@"%@%@.mp3",@"audiofile", str];
            
            [formData appendPartWithFileData:data name:@"audiofile" fileName:name mimeType:@"application/octer-stream"];
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
//        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
//        [SVProgressHUD showWithStatus:@"正在发布..."];
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
//            // time-consuming task
//            dispatch_async(dispatch_get_main_queue(),^{
//                [SVProgressHUD dismiss];
//                [SVProgressHUD setDefaultMaskType:1];
//            });
//        });
        if ([responseObject isKindOfClass:[NSDictionary class]]){
            if ([NSString stringWithFormat:@"%@",(NSDictionary*)responseObject[@"errcode"]].intValue < -100){
                [self logout:(NSDictionary*)responseObject];
            }
            success(responseObject);
            return ;
        }
        NSString * str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];

        NSString * str1 =  [str stringByReplacingOccurrencesOfString:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>" withString:@""];
        NSString * str2 = [str1 stringByReplacingOccurrencesOfString:@"<string xmlns=\"huaxin.org\">" withString:@""];
        str2 = [str2 stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
        str2 = [str2 stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        str2 = [str2 stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        NSString * STR3 = [str2 stringByReplacingOccurrencesOfString:@"</string>" withString:@""];
        NSData *JSONData = [STR3 dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableContainers error:&err];
        if(err) {
            NSLog(@"json解析失败：%@",err);
        }
        if ([NSString stringWithFormat:@"%@",(NSDictionary*)responseJSON[@"errcode"]].intValue < -100){
            [self logout:(NSDictionary*)responseJSON];
        }
        success(responseJSON);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        fail(error);
    }];
    
}

//上传视频
- (void)postVideoFromServerWithUrlStr:(NSString *)str
                           Paremeters:(id)parameters
                            VideoPath:(NSString *)videopath
                            VideoName:(NSString *)videoname
                     successOperation:(Success)success
                        failoperation:(Fail)fail {
    self.manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"text/xml", @"application/json", @"text/json", @"text/javascript", @"text/plain", nil];
    [self.manager POST:str parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *time = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@.mp4",time];
//        [formData appendPartWithFileData:videodata name:videoname fileName:fileName mimeType:@"video/mp4"];
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:videopath] name:videoname fileName:fileName mimeType:@"video/mpeg4" error:nil];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"--------------%@",uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]){
            if ([NSString stringWithFormat:@"%@",(NSDictionary*)responseObject[@"errcode"]].intValue < -100){
                [self logout:(NSDictionary*)responseObject];
            }
            success(responseObject);
            return ;
        }
        NSString * str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSString * str1 =  [str stringByReplacingOccurrencesOfString:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>" withString:@""];
        NSString * str2 = [str1 stringByReplacingOccurrencesOfString:@"<string xmlns=\"huaxin.org\">" withString:@""];
        str2 = [str2 stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
        str2 = [str2 stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        str2 = [str2 stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        NSString * STR3 = [str2 stringByReplacingOccurrencesOfString:@"</string>" withString:@""];
        NSData *JSONData = [STR3 dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableContainers error:&err];
        if(err) {
            NSLog(@"json解析失败：%@",err);
        }
        success((NSArray*)responseJSON);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        fail(error);
    }];
}

- (void)logout:(NSDictionary*)dic{
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",dic[@"message"]]];
    NSNotification *notification = [NSNotification notificationWithName:@"Logout" object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

-(void)reachabilitysuccessOperation:(Success)success
                      failoperation:(Fail)fail;
{
    // 检测网络连接状态
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    // 连接状态回调处理
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status)
     {
         switch (status)
         {
             case AFNetworkReachabilityStatusUnknown:
                 // 回调处理
//                 success(@"没有网络供应商");
                 break;
             case AFNetworkReachabilityStatusNotReachable:
                 // 回调处理
//                 success(@"没有网络");
                 break;
             case AFNetworkReachabilityStatusReachableViaWWAN:
                 // 回调处理
//                 success(@"手机流量");
                 break;
             case AFNetworkReachabilityStatusReachableViaWiFi:
                 // 回调处理
//                 success(@"处于wifi状态");
                 break;
             default:
                 break;
         }
     }];
}


@end
