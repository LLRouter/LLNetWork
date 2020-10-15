//
//  Created by Eastday Mac Pro 2 on 2020/6/4.
//  Copyright © 2020 Eastday Mac Pro 2. All rights reserved.
//

#import "LLNetWork.h"
#import <AFNetworking/AFNetworking.h>
#import "AFNetworkActivityIndicatorManager.h"
#import "LLCacheManager.h"

#ifdef DEBUG
#define LLLog(...) printf("[%s] %s [第%d行]: %s\n", __TIME__ ,__PRETTY_FUNCTION__ ,__LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String])
#else
#define LLLog(...)
#endif

@implementation LLNetWork

/// 存储着所有请求的task
static NSMutableArray *_allSessionTask;
/// sessionmanager
static AFHTTPSessionManager *_sessionManager;
/// 是否已开启日志打印
static BOOL _openLog;

+(BOOL)hasNetWork{
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

+(void)cancelAllRequest{
    @synchronized (self) {
        [[self allSessionTask] enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            [task cancel];
        }];
        [[self allSessionTask] removeAllObjects];
    }
}

+ (void)cancelRequestWithURL:(NSString *)URL{
    if (!URL) { return; }
    @synchronized (self) {
        [[self allSessionTask] enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([task.currentRequest.URL.absoluteString hasPrefix:URL]) {
                [task cancel];
                [[self allSessionTask] removeObject:task];
                *stop = YES;
            }
        }];
    }
}
+ (void)enableLog:(BOOL)open{
    _openLog = open;
}
/**
 存储着所有的请求task数组
 */
+ (NSMutableArray *)allSessionTask {
    if (!_allSessionTask) {
        _allSessionTask = [[NSMutableArray alloc] init];
    }
    return _allSessionTask;
}
//MARK: 不带缓存的请求
+ (NSURLSessionTask *)request:(NSString *)URL
                       method:(LLRequestMethod)method
                   parameters:(id)parameters
                      success:(LLRequestSuccess)success
                      failure:(LLRequestFailed)failure{
    return [self request:URL method:method parameters:parameters responseCache:nil success:success failure:failure];
}
//MARK: 自动缓存的请求
+ (NSURLSessionTask *)request:(NSString *)URL
                       method:(LLRequestMethod)method
                   parameters:(id)parameters
                responseCache:(LLRequestCache)responseCache
                      success:(LLRequestSuccess)success
                      failure:(LLRequestFailed)failure{
    if (!URL || URL.length <= 0 || ![NSURL URLWithString:URL]) {
        LLLog(@"请求地址错误");
        return nil;
    }
    switch (method) {
        case LLRequestMethodGET:
            return [self GET:URL parameters:parameters responseCache:responseCache success:success failure:failure];
        case LLRequestMethodPOST:
            return [self POST:URL parameters:parameters responseCache:responseCache success:success failure:failure];
        case LLRequestMethodPUT:
            return [self PUT:URL parameters:parameters responseCache:responseCache success:success failure:failure];
        case LLRequestMethodDELETE:
            return [self DELETE:URL parameters:parameters responseCache:responseCache success:success failure:failure];
    }
}
/// GET请求
+ (NSURLSessionTask *)GET:(NSString *)URL
               parameters:(id)parameters
            responseCache:(LLRequestCache)responseCache
                  success:(LLRequestSuccess)success
                  failure:(LLRequestFailed)failure {
    //读取缓存
    responseCache == nil ? nil: responseCache([LLCacheManager netWorkCacheForURL:URL parameters:parameters]);
    NSURLSessionTask *sessionTask = [_sessionManager GET:URL parameters:parameters headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (_openLog) {LLLog(@"responseObject = %@",responseObject);}
        [[self allSessionTask] removeObject:task];
        success ? success(responseObject) : nil;
        //对数据进行异步缓存
        responseCache!=nil ?[LLCacheManager setNetWorkCache:responseObject URL:URL parameters:parameters] : nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (_openLog) {LLLog(@"error = %@",error);}
        [[self allSessionTask] removeObject:task];
        failure ? failure(error) : nil;
    }];
    // 添加sessionTask到数组
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil ;
    
    return sessionTask;
}
/// POST请求
+ (NSURLSessionTask *)POST:(NSString *)URL
                parameters:(id)parameters
             responseCache:(LLRequestCache)responseCache
                   success:(LLRequestSuccess)success
                   failure:(LLRequestFailed)failure {
    //读取缓存
    responseCache == nil ? nil: responseCache([LLCacheManager netWorkCacheForURL:URL parameters:parameters]);
    NSURLSessionTask *sessionTask = [_sessionManager POST:URL parameters:parameters headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (_openLog) {LLLog(@"responseObject = %@",responseObject);}
        [[self allSessionTask] removeObject:task];
        success ? success(responseObject) : nil;
        //对数据进行异步缓存
        responseCache!=nil ?[LLCacheManager setNetWorkCache:responseObject URL:URL parameters:parameters] : nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (_openLog) {LLLog(@"error = %@",error);}
        [[self allSessionTask] removeObject:task];
        failure ? failure(error) : nil;
    }];
    // 添加sessionTask到数组
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil ;
    
    return sessionTask;
}
/// PUT请求
+ (NSURLSessionTask *)PUT:(NSString *)URL
               parameters:(id)parameters
            responseCache:(LLRequestCache)responseCache
                  success:(LLRequestSuccess)success
                  failure:(LLRequestFailed)failure {
    //读取缓存
    responseCache == nil ? nil: responseCache([LLCacheManager netWorkCacheForURL:URL parameters:parameters]);
    NSURLSessionTask *sessionTask = [_sessionManager PUT:URL parameters:parameters headers:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (_openLog) {LLLog(@"responseObject = %@",responseObject);}
        [[self allSessionTask] removeObject:task];
        success ? success(responseObject) : nil;
        //对数据进行异步缓存
        responseCache!=nil ? [LLCacheManager setNetWorkCache:responseObject URL:URL parameters:parameters]: nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (_openLog) {LLLog(@"error = %@",error);}
        [[self allSessionTask] removeObject:task];
        failure ? failure(error) : nil;
    }];
    // 添加sessionTask到数组
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil ;
    
    return sessionTask;
}
/// DELETE请求
+ (NSURLSessionTask *)DELETE:(NSString *)URL
                  parameters:(id)parameters
               responseCache:(LLRequestCache)responseCache
                     success:(LLRequestSuccess)success
                     failure:(LLRequestFailed)failure {
    //读取缓存
    responseCache == nil ? nil: responseCache([LLCacheManager netWorkCacheForURL:URL parameters:parameters]);
    NSURLSessionTask *sessionTask = [_sessionManager DELETE:URL parameters:parameters headers:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (_openLog) {LLLog(@"responseObject = %@",responseObject);}
        [[self allSessionTask] removeObject:task];
        success ? success(responseObject) : nil;
        //对数据进行异步缓存
        responseCache!=nil ?[LLCacheManager setNetWorkCache:responseObject URL:URL parameters:parameters] : nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (_openLog) {LLLog(@"error = %@",error);}
        [[self allSessionTask] removeObject:task];
        failure ? failure(error) : nil;
    }];
    // 添加sessionTask到数组
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil ;
    
    return sessionTask;
}
/// 文件上传
+ (NSURLSessionTask *)uploadFileWithURL:(NSString *)URL
                                      parameters:(id)parameters
                                            name:(NSString *)name
                                        filePath:(NSString *)filePath
                                        progress:(LLProgress)progress
                                         success:(LLRequestSuccess)success
                                         failure:(LLRequestFailed)failure{
    NSURLSessionTask *sessionTask  = [_sessionManager POST:URL parameters:parameters headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSError *error = nil;
        [formData appendPartWithFileURL:[NSURL URLWithString:filePath] name:name error:&error];
        (failure && error) ? failure(error) : nil;
        // 图片上传
        //        [formData appendPartWithFileData:imageData
        //                                            name:name
        //                                        fileName:fileNames ? NSStringFormat(@"%@.%@",fileNames[i],imageType?:@"jpg") : imageFileName
        //                                        mimeType:NSStringFormat(@"image/%@",imageType ?: @"jpg")];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        //上传进度
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(uploadProgress) : nil;
        });
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (_openLog) {LLLog(@"responseObject = %@",responseObject);}
        [[self allSessionTask] removeObject:task];
        success ? success(responseObject) : nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (_openLog) {LLLog(@"error = %@",error);}
        [[self allSessionTask] removeObject:task];
        failure ? failure(error) : nil;
    }];
    // 添加sessionTask到数组
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil ;
    
    return sessionTask;
}
/// 文件下载
+ (NSURLSessionTask *)downloadWithURL:(NSString *)URL
                              fileDir:(NSString *)fileDir
                             progress:(LLProgress)progress
                              success:(void(^)(NSString *filePath))success
                              failure:(LLRequestFailed)failure{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URL]];
    __block NSURLSessionDownloadTask *downloadTask = [_sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        //下载进度
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(downloadProgress) : nil;
        });
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        //拼接缓存目录
        NSString *downloadDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileDir ? fileDir : @"LLFileDownLoad"];
        //打开文件管理器
        NSFileManager *fileManager = [NSFileManager defaultManager];
        //创建Download目录
        [fileManager createDirectoryAtPath:downloadDir withIntermediateDirectories:YES attributes:nil error:nil];
        //拼接文件路径FileDownLoad
        NSString *filePath = [downloadDir stringByAppendingPathComponent:response.suggestedFilename];
        //返回文件位置的URL路径
        return [NSURL fileURLWithPath:filePath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        [[self allSessionTask] removeObject:downloadTask];
        if(failure && error) {failure(error) ; return ;};
        success ? success(filePath.absoluteString /** NSURL->NSString*/) : nil;
        
    }];
    //开始下载
    [downloadTask resume];
    // 添加sessionTask到数组
    downloadTask ? [[self allSessionTask] addObject:downloadTask] : nil ;
    
    return downloadTask;
}

//MARK: session配置
+ (void)load{
     [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}
+ (void)initialize{
    if (self == [LLNetWork class]) {
        _sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.requestSerializer.timeoutInterval = 30.f;
        _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript", @"text/xml", @"image/*", nil];
        // 打开状态栏的等待菊花
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        // 默认请求类型
        [self setRequestSerializer:LLRequestSerializerJSON];
        [self setResponseSerializer:LLResponseSerializerJSON];
    }
}
+ (void)setAFHTTPSessionManagerProperty:(void(^)(AFHTTPSessionManager *sessionManager))sessionManager{
     sessionManager ? sessionManager(_sessionManager) : nil;
}
+ (void)setRequestSerializer:(LLRequestSerializer)requestSerializer{
    _sessionManager.requestSerializer =
    requestSerializer == LLRequestSerializerHTTP ? [AFHTTPRequestSerializer serializer] : [AFJSONRequestSerializer serializer];
}
+ (void)setResponseSerializer:(LLResponseSerializer)responseSerializer{
    _sessionManager.responseSerializer =
    responseSerializer == LLResponseSerializerHTTP ? [AFHTTPResponseSerializer serializer] : [AFJSONResponseSerializer serializer];
}
+ (void)setRequestTimeoutInterval:(NSTimeInterval)time{
    _sessionManager.requestSerializer.timeoutInterval = time;
}
+ (void)openNetworkActivityIndicator:(BOOL)open{
     [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:open];
}
@end
