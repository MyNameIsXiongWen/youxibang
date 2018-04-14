//
//  NSObject+Model.m
//  deshanglouyu
//
//  Created by 戎博 on 2017/12/7.
//

#import "NSObject+Model.h"

@implementation NSObject (Model)


+(instancetype)modelWithDict:(NSDictionary *)dict
{
    id obj = [[self alloc] init];
    [obj setValuesForKeysWithDictionary:dict];
    return obj;
}


-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}
@end
