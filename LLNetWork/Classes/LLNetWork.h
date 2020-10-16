//
//  Created by Eastday Mac Pro 2 on 2020/6/4.
//  Copyright © 2020 Eastday Mac Pro 2. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, LLNetworkStatusType) {
    /// 未知网络
    LLNetworkStatusUnknown,
    /// 无网络
    LLNetworkStatusNotReachable,
    /// 手机网络
    LLNetworkStatusReachableViaWWAN,
    /// WIFI网络
    LLNetworkStatusReachableViaWiFi
};
typedef NS_ENUM(NSUInteger, LLRequestSerializer) {
    /// 设置请求数据为JSON格式
    LLRequestSerializerJSON,
    /// 设置请求数据为二进制格式
    LLRequestSerializerHTTP,
};

typedef NS_ENUM(NSUInteger, LLResponseSerializer) {
    /// 设置响应数据为JSON格式
    LLResponseSerializerJSON,
    /// 设置响应数据为二进制格式
    LLResponseSerializerHTTP,
};

typedef NS_ENUM(NSUInteger, LLRequestMethod) {
    LLRequestMethodGET = 0,
    LLRequestMethodPOST,
    LLRequestMethodPUT,
    LLRequestMethodDELETE
};

/// 请求成功的回调
typedef void (^LLRequestSuccess)(id responseObject);

/// 请求失败的回调
typedef void (^LLRequestFailed)(NSError *error);

/// 缓存的回调
typedef void (^LLRequestCache)(id responseCache);

/// 上传或者下载的进度, Progress.completedUnitCount:当前大小 - Progress.totalUnitCount:总大小
typedef void (^LLProgress)(NSProgress *progress);

/// 网络状态的Block
typedef void(^LLNetworkStatus)(LLNetworkStatusType status);

@class AFHTTPSessionManager;
@interface LLNetWork : NSObject

/// 判断是否有网络
+(BOOL)hasNetWork;

/// 取消所有网络请求
+(void)cancelAllRequest;

/// 取消指定URL的HTTP请求
+ (void)cancelRequestWithURL:(NSString *)URL;

/// 是否开启log打印
+ (void)enableLog:(BOOL)open;

/**
 *  请求,无缓存
 *
 *  @param URL        请求地址
 *  @param parameters 请求参数
 *  @param method     请求方式
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 *
 *  @return 返回的对象可取消请求,调用cancel方法
 */
+ (__kindof NSURLSessionTask *)request:(NSString *)URL
                                method:(LLRequestMethod)method
                            parameters:(id)parameters
                               success:(LLRequestSuccess)success
                               failure:(LLRequestFailed)failure;

/**
 *  请求,自动缓存
 *
 *  @param URL           请求地址
 *  @param method        请求方式
 *  @param parameters    请求参数
 *  @param responseCache 缓存数据的回调
 *  @param success       请求成功的回调
 *  @param failure       请求失败的回调
 *
 *  @return 返回的对象可取消请求,调用cancel方法
 */
+ (__kindof NSURLSessionTask *)request:(NSString *)URL
                                method:(LLRequestMethod)method
                            parameters:(id)parameters
                         responseCache:(LLRequestCache)responseCache
                               success:(LLRequestSuccess)success
                               failure:(LLRequestFailed)failure;

/**
 *  上传文件
 *
 *  @param URL        请求地址
 *  @param parameters 请求参数
 *  @param name       文件对应服务器上的字段
 *  @param filePath   文件本地的沙盒路径
 *  @param progress   上传进度信息
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 *
 *  @return 返回的对象可取消请求,调用cancel方法
 */
+ (__kindof NSURLSessionTask *)uploadFileWithURL:(NSString *)URL
                                      parameters:(id)parameters
                                            name:(NSString *)name
                                        filePath:(NSString *)filePath
                                        progress:(LLProgress)progress
                                         success:(LLRequestSuccess)success
                                         failure:(LLRequestFailed)failure;
/**
 *  下载文件
 *
 *  @param URL      请求地址
 *  @param fileDir  文件存储目录(默认存储目录为Download)
 *  @param progress 文件下载的进度信息
 *  @param success  下载成功的回调(回调参数filePath:文件的路径)
 *  @param failure  下载失败的回调
 *
 *  @return 返回NSURLSessionDownloadTask实例，可用于暂停继续，暂停调用suspend方法，开始下载调用resume方法
 */
+ (__kindof NSURLSessionTask *)downloadWithURL:(NSString *)URL
                                       fileDir:(NSString *)fileDir
                                      progress:(LLProgress)progress
                                       success:(void(^)(NSString *filePath))success
                                       failure:(LLRequestFailed)failure;

//MARK: session配置
+ (void)setAFHTTPSessionManagerProperty:(void(^)(AFHTTPSessionManager *sessionManager))sessionManager;

/**
 *  设置网络请求参数的格式:默认为二进制格式
 *
 *  @param requestSerializer PPRequestSerializerJSON(JSON格式),PPRequestSerializerHTTP(二进制格式),
 */
+ (void)setRequestSerializer:(LLRequestSerializer)requestSerializer;

/**
 *  设置服务器响应数据格式:默认为JSON格式
 *
 *  @param responseSerializer PPResponseSerializerJSON(JSON格式),PPResponseSerializerHTTP(二进制格式)
 */
+ (void)setResponseSerializer:(LLResponseSerializer)responseSerializer;

/**
 *  设置请求超时时间:默认为30S
 *
 *  @param time 时长
 */
+ (void)setRequestTimeoutInterval:(NSTimeInterval)time;

/**
 *  是否打开网络状态转圈菊花:默认打开
 *
 *  @param open YES(打开), NO(关闭)
 */
+ (void)openNetworkActivityIndicator:(BOOL)open;

/**
 *  添加请求头
 *
 *  @param headerDictionary kv请求头json
 */
+ (void)setHeader:(NSDictionary *)headerDictionary;

@end

