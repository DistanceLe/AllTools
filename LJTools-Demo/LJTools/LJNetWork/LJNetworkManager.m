//
//  LJNetworkManager.m
//  timeDemo
//
//  Created by LiJie on 2017/3/6.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import "LJNetworkManager.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"


#define NSStringFormat(format,...) [NSString stringWithFormat:format,##__VA_ARGS__]

static BOOL _isOpenLog;   // 是否已开启日志打印
static NSMutableArray *_allSessionTask;
/**  开始请求时就加入，完成后 删除 */
static NSMutableArray *_allLJRequest;
static AFHTTPSessionManager *_sessionManager;

@implementation LJNetworkManager

#pragma mark - ================ 开始监听网络 ==================
+ (void)networkStatusWithBlock:(LJNetworkStatus)networkStatus {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
                case AFNetworkReachabilityStatusUnknown:
                    networkStatus ? networkStatus(LJNetworkStatusUnknown) : nil;
                    LJDLog(@"未知网络");
                    break;
                case AFNetworkReachabilityStatusNotReachable:
                    networkStatus ? networkStatus(LJNetworkStatusNotReachable) : nil;
                    LJDLog(@"无网络");
                    break;
                case AFNetworkReachabilityStatusReachableViaWWAN:
                    networkStatus ? networkStatus(LJNetworkStatusReachableViaWWAN) : nil;
                    LJDLog(@"手机自带网络");
                    break;
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    networkStatus ? networkStatus(LJNetworkStatusReachableViaWiFi) : nil;
                    LJDLog(@"WIFI");
                    break;
            }
        }];
    });
}

+ (BOOL)isNetwork {
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

+ (BOOL)isWWANNetwork {
    return [AFNetworkReachabilityManager sharedManager].reachableViaWWAN;
}

+ (BOOL)isWiFiNetwork {
    return [AFNetworkReachabilityManager sharedManager].reachableViaWiFi;
}

+ (void)openLog {
    _isOpenLog = YES;
}

+ (void)closeLog {
    _isOpenLog = NO;
}

+ (void)cancelAllRequest {
    // 锁操作
    @synchronized(self) {
        [[self allSessionTask] enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            [task cancel];
        }];
        [[self allSessionTask] removeAllObjects];
    }
}

+ (void)cancelRequestWithURL:(NSString *)URL {
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

/**  json转字符串   */
+ (NSString *)jsonToString:(id)data {
    if(!data) { return nil; }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

/** 存储着所有的请求task数组   */
+ (NSMutableArray *)allSessionTask {
    if (!_allSessionTask) {
        _allSessionTask = [[NSMutableArray alloc] init];
    }
    return _allSessionTask;
}
/**  开始请求时就加入，完成后 删除 */
+(NSMutableArray*)allLJRequest{
    if (!_allLJRequest) {
        _allLJRequest = [[NSMutableArray alloc]init];
    }
    return _allLJRequest;
}

#pragma mark - ================ 初始化AFHTTPSessionManager相关属性 ==================
/** 开始监测网络状态   load是只要类所在文件被引用就会被调用*/
+ (void)load {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}
/** initialize是在类或者其子类的第一个方法被调用前调用
    所有的HTTP请求共享一个AFHTTPSessionManager
 *  原理参考地址:http://www.jianshu.com/p/5969bbb4af9f   */
+ (void)initialize {
    _sessionManager = [AFHTTPSessionManager manager];
    // 设置请求的超时时间
    _sessionManager.requestSerializer.timeoutInterval = 30.f;
    // 设置服务器返回结果的类型:JSON (AFJSONResponseSerializer,AFHTTPResponseSerializer)
//    _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json",  @"text/plain", @"text/javascript", @"text/xml", @"image/*", nil];
    _sessionManager.securityPolicy.allowInvalidCertificates = YES;
    // 打开状态栏的等待菊花
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
}
#pragma mark - ================ 请求 与 上传 ==================
/**   GET请求,无缓存
 *
 *  @param URL        请求地址
 *  @param parameters 请求参数
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 *
 *  @return 返回的对象可取消请求,调用cancel方法  */
+ (__kindof NSURLSessionTask *)GET:(NSString *)URL
                        parameters:(NSDictionary *)parameters
                           success:(LJHttpRequestSuccess)success
                           failure:(LJHttpRequestFailed)failure{
    NSURLSessionTask* sessionTask = [_sessionManager GET:URL parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        LJDLog(@"%@",_isOpenLog ? NSStringFormat(@"responseObject = %@",[self jsonToString:responseObject]) : @"已关闭日志打印");
        [[self allSessionTask] removeObject:task];
        
        success ? success(responseObject) : nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        LJDLog(@"%@",_isOpenLog ? NSStringFormat(@"error = %@",error) : @"已关闭日志打印");
        [[self allSessionTask] removeObject:task];
        failure ? failure(error) : nil;
    }];
    sessionTask ? [[self allSessionTask] addObject:sessionTask]:nil;
    return sessionTask;
}

/**   POST请求,无缓存
 *
 *  @param URL        请求地址
 *  @param parameters 请求参数
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 *
 *  @return 返回的对象可取消请求,调用cancel方法  */
+ (__kindof NSURLSessionTask *)POST:(NSString *)URL
                         parameters:(NSDictionary *)parameters
                            success:(LJHttpRequestSuccess)success
                            failure:(LJHttpRequestFailed)failure{
    NSURLSessionTask *sessionTask = [_sessionManager POST:URL parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        LJDLog(@"%@",_isOpenLog ? NSStringFormat(@"responseObject = %@",[self jsonToString:responseObject]) : @"已关闭日志打印");
        
        [[self allSessionTask] removeObject:task];
        success ? success(responseObject) : nil;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        LJDLog(@"%@",_isOpenLog ? NSStringFormat(@"error = %@",error) : @"已关闭日志打印");
        
        [[self allSessionTask] removeObject:task];
        failure ? failure(error) : nil;
    }];
    
    // 添加最新的sessionTask到数组
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil ;
    return sessionTask;
}


/**   上传文件
 *
 *  @param URL        请求地址
 *  @param parameters 请求参数
 *  @param name       文件对应服务器上的字段
 *  @param filePath   文件本地的沙盒路径
 *  @param progress   上传进度信息
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 *
 *  @return 返回的对象可取消请求,调用cancel方法  */
+ (__kindof NSURLSessionTask *)uploadFileWithURL:(NSString *)URL
                                      parameters:(NSDictionary *)parameters
                                            name:(NSString *)name
                                        fileType:(NSString *)fileType
                                        filePath:(NSString *)filePath
                                        progress:(LJHttpProgress)progress
                                         success:(LJHttpRequestSuccess)success
                                         failure:(LJHttpRequestFailed)failure{
    
    NSURLSessionTask *sessionTask = [_sessionManager POST:URL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
//        NSError *error = nil;
//        [formData appendPartWithFileURL:[NSURL URLWithString:filePath] name:name error:&error];
//        (failure && error) ? failure(error) : nil;
        
        NSData* fileData = [NSData dataWithContentsOfFile:filePath];
        
        [formData appendPartWithFileData:fileData
                                    name:name
                                fileName:NSStringFormat(@"%@.%@",name,fileType)
                                mimeType:NSStringFormat(@"image/%@",fileType ?: @"jpg")];
        
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        //上传进度
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(uploadProgress) : nil;
        });
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        LJDLog(@"%@",_isOpenLog ? NSStringFormat(@"responseObject = %@",[self jsonToString:responseObject]) : @"已关闭日志打印");
        
        [[self allSessionTask] removeObject:task];
        success ? success(responseObject) : nil;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        LJDLog(@"%@",_isOpenLog ? NSStringFormat(@"error = %@",error) : @"已关闭日志打印");
        
        [[self allSessionTask] removeObject:task];
        failure ? failure(error) : nil;
    }];
    
    // 添加sessionTask到数组
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil ;
    
    return sessionTask;
}

/**   上传单/多张图片
 *
 *  @param URL        请求地址
 *  @param parameters 请求参数
 *  @param name       图片对应服务器上的字段
 *  @param images     图片数组
 *  @param fileNames  图片文件名数组, 可以为nil, 数组内的文件名默认为当前日期时间"yyyyMMddHHmmss"
 *  @param imageScale 图片文件压缩比 范围 (0.f ~ 1.f)
 *  @param imageType  图片文件的类型,例:png、jpg(默认类型)....
 *  @param progress   上传进度信息
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 *
 *  @return 返回的对象可取消请求,调用cancel方法  */
+ (__kindof NSURLSessionTask *)uploadImagesWithURL:(NSString *)URL
                                        parameters:(NSDictionary *)parameters
                                              name:(NSString *)name
                                            images:(NSArray<UIImage *> *)images
                                         fileNames:(NSArray<NSString *> *)fileNames
                                        imageScale:(CGFloat)imageScale
                                         imageType:(NSString *)imageType
                                          progress:(LJHttpProgress)progress
                                           success:(LJHttpRequestSuccess)success
                                           failure:(LJHttpRequestFailed)failure{
    
    NSURLSessionTask *sessionTask = [_sessionManager POST:URL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        for (NSUInteger i = 0; i < images.count; i++) {
            // 图片经过等比压缩后得到的二进制文件
            NSData *imageData = UIImageJPEGRepresentation(images[i], imageScale ?: 1.f);
            // 默认图片的文件名, 若fileNames为nil就使用
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *str = [formatter stringFromDate:[NSDate date]];
            NSString *imageFileName = NSStringFormat(@"%@%ld.%@",str,i,imageType?:@"jpg");
            
            [formData appendPartWithFileData:imageData
                                        name:name
                                    fileName:fileNames ? NSStringFormat(@"%@.%@",fileNames[i],imageType?:@"jpg") : imageFileName
                                    mimeType:NSStringFormat(@"image/%@",imageType ?: @"jpg")];
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        //上传进度
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(uploadProgress) : nil;
        });
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        LJDLog(@"%@",_isOpenLog ? NSStringFormat(@"responseObject = %@",[self jsonToString:responseObject]) : @"已关闭日志打印");
        
        [[self allSessionTask] removeObject:task];
        success ? success(responseObject) : nil;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        LJDLog(@"%@",_isOpenLog ? NSStringFormat(@"error = %@",error) : @"已关闭日志打印");
        
        [[self allSessionTask] removeObject:task];
        failure ? failure(error) : nil;
    }];
    
    // 添加sessionTask到数组
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil ;
    
    return sessionTask;
}

/**   下载文件
 *
 *  @param URL      请求地址
 *  @param fileDir  文件存储目录(默认存储目录为Download)
 *  @param progress 文件下载的进度信息
 *  @param success  下载成功的回调(回调参数filePath:文件的路径)
 *  @param failure  下载失败的回调
 *
 *  @return 返回NSURLSessionDownloadTask实例，可用于暂停继续，暂停调用suspend方法，开始下载调用resume方法  */
+ (__kindof NSURLSessionTask *)downloadWithURL:(NSString *)URL
                                       fileDir:(NSString *)fileDir
                                      progress:(LJHttpProgress)progress
                                       success:(void(^)(NSString *filePath))success
                                       failure:(LJHttpRequestFailed)failure{
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URL]];
    NSURLSessionDownloadTask *downloadTask = [_sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        //下载进度
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(downloadProgress) : nil;
        });
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        //拼接缓存目录
        NSString *downloadDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileDir ? fileDir : @"Download"];
        //打开文件管理器
        NSFileManager *fileManager = [NSFileManager defaultManager];
        //创建Download目录
        [fileManager createDirectoryAtPath:downloadDir withIntermediateDirectories:YES attributes:nil error:nil];
        //拼接文件路径
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


#pragma mark - ================ 重置AFHTTPSessionManager相关属性 ==================
+ (void)setRequestSerializer:(LJRequestSerializer)requestSerializer {
    _sessionManager.requestSerializer = requestSerializer==LJRequestSerializerHTTP ? [AFHTTPRequestSerializer serializer] : [AFJSONRequestSerializer serializer];
//    _sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
}

+ (void)setResponseSerializer:(LJResponseSerializer)responseSerializer {
    _sessionManager.responseSerializer = responseSerializer==LJResponseSerializerHTTP ? [AFHTTPResponseSerializer serializer] : [AFJSONResponseSerializer serializer];
//    _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
}

+ (void)setRequestTimeoutInterval:(NSTimeInterval)time {
    _sessionManager.requestSerializer.timeoutInterval = time;
}

+ (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
    [_sessionManager.requestSerializer setValue:value forHTTPHeaderField:field];
}

+ (void)openNetworkActivityIndicator:(BOOL)open {
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:open];
}

+ (void)setSecurityPolicyWithCerPath:(NSString *)cerPath validatesDomainName:(BOOL)validatesDomainName {
    NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
    // 使用证书验证模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    // 如果需要验证自建证书(无效证书)，需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;
    // 是否需要验证域名，默认为YES;
    securityPolicy.validatesDomainName = validatesDomainName;
    securityPolicy.pinnedCertificates = [[NSSet alloc] initWithObjects:cerData, nil];
    
    [_sessionManager setSecurityPolicy:securityPolicy];
}



@end
