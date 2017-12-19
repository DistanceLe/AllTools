//
//  LJRegisterRequest.h
//  timeDemo
//
//  Created by LiJie on 2017/3/15.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import "LJBaseRequest.h"

@interface LJRegisterRequest : LJBaseRequest

@property(nonatomic, copy)NSString* phone;
@property(nonatomic, copy)NSString* password;
@property(nonatomic, copy)NSString* smsCode;

@end
