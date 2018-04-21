//
//  UserModel.m
//  youxibang
//
//  Created by jiazhuo1 on 2018/4/18.
//

#import "UserModel.h"

static UserModel *shareUser;
static dispatch_once_t onceToken;

@implementation UserModel

- (void)encodeWithCoder:(NSCoder *)aCoder {
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(self.class, &outCount);
    for (i=0; i<outCount; i++) {
        objc_property_t property = properties[i];
        const char *char_f = property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        id propertyValue = [self valueForKey:(NSString *)propertyName];
        if (propertyValue) {
            [aCoder encodeObject:propertyValue forKey:propertyName];
        }
    }
    free(properties);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList(self.class, &outCount);
        for (i=0; i<outCount; i++) {
            objc_property_t property = properties[i];
            const char *char_f = property_getName(property);
            NSString *propertyName = [NSString stringWithUTF8String:char_f];
            id propertyValue = [aDecoder decodeObjectForKey:propertyName];
            if (propertyValue) {
                [self setValue:propertyValue forKey:propertyName];
            }
        }
        free(properties);
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"%@没有被赋值",key);
}

+ (UserModel *)sharedUser {
    dispatch_once(&onceToken, ^{
        shareUser = [self keyUnArchiveUsermodel];
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList([self class], &outCount);
        for (i=0; i<outCount; i++) {
            objc_property_t property = properties[i];
            const char *char_f = property_getName(property);
            NSString *propertyName = [NSString stringWithUTF8String:char_f];
            [shareUser addObserver:shareUser forKeyPath:propertyName options:NSKeyValueObservingOptionNew context:nil];
        }
        free(properties);
    });
    return shareUser;
}

+ (void)keyarchiveUserModelWithDict:(NSDictionary *)dict {
    [UserModel teardown];
    UserModel *model = [UserModel mj_objectWithKeyValues:dict];
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [model encodeWithCoder:archive];
    [archive finishEncoding];
    
    NSArray *cacPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [cacPath objectAtIndex:0];
    NSString *path = [cachePath stringByAppendingPathComponent:@"user.asb"];
    [data writeToFile:path atomically:YES];
    [UserModel teardown];
}

+ (UserModel *)keyUnArchiveUsermodel {
    NSArray *cacPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [cacPath objectAtIndex:0];
    NSString *path = [cachePath stringByAppendingPathComponent:@"user.asb"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    if ([data isKindOfClass:[NSData class]]) {
        NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        UserModel *model = [[UserModel alloc] initWithCoder:unarchive];
        return model;
    }
    else {
        UserModel *model = [[UserModel alloc] init];
        return model;
    }
}

- (void)keyarchiveUserModel {
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [self encodeWithCoder:archive];
    [archive finishEncoding];
    
    NSArray *cacPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [cacPath objectAtIndex:0];
    NSString *path = [cachePath stringByAppendingPathComponent:@"user.asb"];
    [data writeToFile:path atomically:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"keypath:%@,change:%@",keyPath,change);
    [[UserModel sharedUser] keyarchiveUserModel];
}

+ (void)removeUserKeyarchiveData {
    NSArray *cacPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [cacPath objectAtIndex:0];
    NSString *path = [cachePath stringByAppendingPathComponent:@"user.asb"];
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:path error:nil];
}

/**
 *  销毁单例
 */
+ (void)teardown {
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i=0; i<outCount; i++) {
        objc_property_t property = properties[i];
        const char *char_f = property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        [shareUser removeObserver:shareUser forKeyPath:propertyName context:nil];
    }
    free(properties);
    onceToken = 0;
    shareUser = nil;
}

@end
