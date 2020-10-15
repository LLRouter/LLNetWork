//
//  LLCacheManager.h
//  HuYuFeedBack
//
//  Created by Eastday Mac Pro 2 on 2020/6/4.
//  Copyright © 2020 Eastday Mac Pro 2. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LLCacheManager : NSObject

+(LLCacheManager *)sharedInstance;
//MARK: 网络数据缓存

/// 缓存网络数据
+ (void)setNetWorkCache:(id)httpData URL:(NSString *)URL parameters:(id)parameters;

///根据地址取出数据
+ (id)netWorkCacheForURL:(NSString *)URL parameters:(id)parameters;

/// 获取网络缓存的总大小 bytes(字节)
+ (NSInteger)getAllHttpCacheSize;

/// 删除所有网络缓存
+ (void)removeAllHttpCache;

@end


