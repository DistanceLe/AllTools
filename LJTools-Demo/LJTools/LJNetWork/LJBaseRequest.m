//
//  LJBaseRequest.m
//  timeDemo
//
//  Created by LiJie on 2017/3/15.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import "LJBaseRequest.h"

#import <objc/message.h>

@interface LJBaseRequest ()

@property(nonatomic, strong)NSDictionary* paramDic;
@property(nonatomic, strong)NSURLSessionTask* requestTask;

@end

@implementation LJBaseRequest

/**  获取参数 */
-(NSDictionary *)paramDic{
    NSMutableDictionary* mutableParamDic = [NSMutableDictionary dictionary];
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);
    
    NSArray *ignoredParameters = nil;
    if ([[self ignoreParams]count] > 0) {
        NSMutableArray *tempArr = [NSMutableArray array];
        [tempArr addObjectsFromArray:[self ignoreParams]];
        ignoredParameters = tempArr;
    }
    
    for (unsigned int i = 0; i < propertyCount; ++i) {
        objc_property_t property = properties[i];
        const char * name = property_getName(property);
        NSString *strName = [NSString stringWithUTF8String:name];
        
        id value = [self valueForKey:strName];
        if (![ignoredParameters containsObject:strName]) {
            
            if ([value isKindOfClass:[NSString class]]) {
                [mutableParamDic setObject:value forKey:strName];
            }
            else if ([value isKindOfClass:[NSNumber class]]) {
                [mutableParamDic setObject:[value stringValue] forKey:strName];
            }
            else if ([value isKindOfClass:[NSArray class]]){
                [mutableParamDic setObject:value forKey:strName];
            }else{
                LJDLog(@"参数类型 有误");
            }
        }
        
    }
    if (properties) free(properties);
    
    NSString *ut = [self userId];
    if (ut.length > 0) {
        [mutableParamDic setObject:ut forKey:@"userId"];
    }
    LJDLog(@"请求参数: %@", mutableParamDic);
    
    return mutableParamDic;
}
-(NSString*)requestUrl{
    NSString* url = [NSString stringWithFormat:@"%@%@", self.baseUrl, self.baseRelativeUrl];
    LJDLog(@"requestURL：%@", url);
    return url;
}
-(NSString *)baseUrl{
    return  kBaseUrl;
}
-(NSString *)baseRelativeUrl{
    return @"";
}
-(NSArray *)ignoreParams{
    return @[];
}

-(NSString *)userId{
    return @"";
}

-(void)dealloc{
    LJDLog(@"=========request dealloc");
}

-(void)requestGetWithHandler:(requestCompletionHandler)handler{
    [self requestWithMethod:@"GET" withHandler:handler];
}

-(void)requestPostWithHandler:(requestCompletionHandler)handler{
    [self requestWithMethod:@"POST" withHandler:handler];
}

-(void)requestWithMethod:(NSString*)method withHandler:(requestCompletionHandler)handler{
    if (!handler) {
        handler = ^(id returnValue, NSString* message, NSError* error) {
        };
    }
    
    NSString* requestUrl = [self requestUrl];
    if (requestUrl.length == 0) {
        if (handler) {
            NSError* error = [NSError errorWithDomain:@"请求路径不对" code:-999 userInfo:nil];
            handler(nil, @"请求路径不对",  error);
        }
    }
    //设置超时 时间
    [LJNetworkManager setRequestTimeoutInterval:10];
    
    __block NSError* requestError = nil;
    //开始请求
    if ([method isEqualToString:@"GET"]) {
        self.requestTask = [LJNetworkManager GET:requestUrl parameters:self.paramDic success:^(id responseObject) {
            if (handler) {

                if ([responseObject isKindOfClass:[NSData class]]) {
                    NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                    DLog(@"result✌️%@", result);
                }else{
                    DLog(@"result✌️%@", responseObject);
//                    if ([[responseObject valueForKey:@"code"]integerValue]!=0) {
//                        requestError = [NSError errorWithDomain:@"网络错误" code:1 userInfo:nil];
//                    }
                    handler([responseObject valueForKey:@"result"], [responseObject valueForKey:@"err"], requestError);
                }
            }
            if ([[LJNetworkManager allLJRequest]containsObject:self]) {
                [[LJNetworkManager allLJRequest]removeObject:self];
            }
        } failure:^(NSError *error) {
            if (handler) {
                handler(nil, @"网络错误", error);
            }
            if ([[LJNetworkManager allLJRequest]containsObject:self]) {
                [[LJNetworkManager allLJRequest]removeObject:self];
            }
        }];
    }else if ([method isEqualToString:@"POST"]){
        self.requestTask = [LJNetworkManager POST:requestUrl parameters:self.paramDic success:^(id responseObject) {
            if (handler) {
                if ([[responseObject valueForKey:@"code"]integerValue]!=0) {
                    requestError = [NSError errorWithDomain:@"网络错误" code:1 userInfo:nil];
                }
                handler([responseObject valueForKey:@"result"], [responseObject valueForKey:@"err"],  requestError);
            }
            if ([[LJNetworkManager allLJRequest]containsObject:self]) {
                [[LJNetworkManager allLJRequest]removeObject:self];
            }
        } failure:^(NSError *error) {
            if (handler) {
                handler(nil, @"网络错误", error);
            }
            if ([[LJNetworkManager allLJRequest]containsObject:self]) {
                [[LJNetworkManager allLJRequest]removeObject:self];
            }
        }];
    }
    [[LJNetworkManager allLJRequest]addObject:self];
}

-(void)cancelRequest{
    if (self.requestTask) {
        [self.requestTask cancel];
    }
}

@end
