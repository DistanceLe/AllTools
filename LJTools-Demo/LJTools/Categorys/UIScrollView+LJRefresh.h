//
//  UIScrollView+LJRefresh.h
//  LJTools-Demo
//
//  Created by LiJie on 2017/5/24.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (LJRefresh)

/**  添加一个系统的刷新控件，根据偏移量自动进入刷新状态 */
-(void)addSystemHeadRefresh:(NSString*)title handler:(void(^)(void))handler;

/**  可以手动调用开始刷新 */
-(void)beginSystemHeadRefresh;

/**  必须手动调用结束刷新 */
-(void)endSystemHeadRefresh;

@end
