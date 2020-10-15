//
//  LLCacheManager.m
//  HuYuFeedBack
//
//  Created by Eastday Mac Pro 2 on 2020/6/4.
//  Copyright © 2020 Eastday Mac Pro 2. All rights reserved.
//

#import "LLCacheManager.h"
#import <YYCache/YYCache.h>

static NSString *const kLLNetworkResponseCache = @"kLLNetworkResponseCache";

@implementation LLCacheManager

static YYCache *_dataCache;
/// 暂且不用
+(LLCacheManager *)sharedInstance{
    static LLCacheManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}
+ (void)initialize{
    if (self == [self class]) {
        _dataCache = [YYCache cacheWithName:kLLNetworkResponseCache];
    }
}

//MARK: 类方法缓存
/// 缓存网络数据
+ (void)setNetWorkCache:(id)httpData URL:(NSString *)URL parameters:(id)parameters{
    NSString *cacheKey = [self cacheKeyWithURL:URL parameters:parameters];
       //异步缓存,不会阻塞主线程
    [_dataCache setObject:httpData forKey:cacheKey withBlock:nil];
}

///根据地址取出数据
+ (id)netWorkCacheForURL:(NSString *)URL parameters:(id)parameters{
    NSString *cacheKey = [self cacheKeyWithURL:URL parameters:parameters];
       return [_dataCache objectForKey:cacheKey];
}

/// 获取网络缓存的总大小 bytes(字节)
+ (NSInteger)getAllHttpCacheSize{
    return [_dataCache.diskCache totalCost];
}

/// 删除所有网络缓存
+ (void)removeAllHttpCache{
      [_dataCache.diskCache removeAllObjects];
}
+ (NSString *)cacheKeyWithURL:(NSString *)URL parameters:(NSDictionary *)parameters {
    if(!parameters || parameters.count == 0){return URL;};
    // 将参数字典转换成字符串
    NSData *stringData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    NSString *paraString = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:@"%@%@",URL,paraString];
}

@end
