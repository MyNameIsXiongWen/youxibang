//
//  DataStore.m
//  XianGui
//
//  Created by 洛水寒 on 17/5/11.
//  Copyright © 2017年 洛水寒. All rights reserved.
//

#import "DataStore.h"
static NSString *const kIsFirstLaunch = @"isFirstLaunch";
static DataStore *mInstance;
@implementation DataStore

+ (DataStore *)sharedDataStore {
    static dispatch_once_t once;
    dispatch_once(&once, ^ {
        mInstance = [[DataStore alloc] init];
    });
    return mInstance;
}
+ (void)addDataStore:(NSDictionary*)dic {
    static dispatch_once_t once;
    dispatch_once(&once, ^ {
        mInstance = [DataStore modelWithDict:dic];
    });
    
}

- (void)setIsFirstLaunch:(BOOL)isFirstLaunch {
    [[NSUserDefaults standardUserDefaults] setBool:isFirstLaunch forKey:kIsFirstLaunch];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isFirstLaunch {
    return ![[NSUserDefaults standardUserDefaults] boolForKey:kIsFirstLaunch];
}
@end
