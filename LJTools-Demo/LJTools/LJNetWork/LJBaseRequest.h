//
//  LJBaseRequest.h
//  timeDemo
//
//  Created by LiJie on 2017/3/15.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LJNetworkManager.h"

#define kBaseUrl @"http://192.168.31.96:8080/WebDemo/"

typedef void(^requestCompletionHandler)(id returnValue, NSString* message,  NSError* error);

@interface LJBaseRequest : NSObject

/**  Get 请求，只要判断error 是否为空，再去提示message */
-(void)requestGetWithHandler:(requestCompletionHandler)handler;
/**  POST 请求，只要判断error 是否为空，再去提示message */
-(void)requestPostWithHandler:(requestCompletionHandler)handler;

/**  取消请求 */
-(void)cancelRequest;

/**  忽略的 参数 子类复写*/
-(NSArray*)ignoreParams;

/**  请求的 地址 子类可重写，默认使用kBaseUrl*/
-(NSString*)baseUrl;

/**  请求的方法名。有就需要子类 重写 */
-(NSString*)baseRelativeUrl;

/**  userId,可以设置一个，参数里面即可以不用每次都写 */
-(NSString*)userId;

@end
