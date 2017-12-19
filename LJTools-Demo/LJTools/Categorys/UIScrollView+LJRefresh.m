//
//  UIScrollView+LJRefresh.m
//  LJTools-Demo
//
//  Created by LiJie on 2017/5/24.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import "UIScrollView+LJRefresh.h"
#import <objc/runtime.h>

@interface UIScrollView ()

@property(nonatomic, strong)void(^refreshHandler)(void);

@end

@implementation UIScrollView (LJRefresh)

+(void)load{
    Method originalMethod = class_getInstanceMethod([self class], NSSelectorFromString(@"handlePan:"));
    Method swizzledMethod = class_getInstanceMethod([self class], @selector(customPanGesture:));
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

static char refreshBlockKey;
-(void (^)(void))refreshHandler{
    return objc_getAssociatedObject(self, &refreshBlockKey);
}

-(void)setRefreshHandler:(void (^)(void))refreshHandler{
    objc_setAssociatedObject(self, &refreshBlockKey, refreshHandler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)addSystemHeadRefresh:(NSString *)title handler:(void (^)(void))handler{
    
    UIRefreshControl* refresh = [[UIRefreshControl alloc]init];
    NSAttributedString* attributeStr = [[NSAttributedString alloc]initWithString:title];
    refresh.attributedTitle = attributeStr;
    refresh.tintColor = [UIColor redColor];
    self.refreshControl = refresh;
    self.refreshHandler = handler;
}

-(void)customPanGesture:(UIPanGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (self.refreshControl.isRefreshing && self.refreshHandler) {
            self.refreshHandler();
        }
    }
    [self customPanGesture:gestureRecognizer];
}


-(void)beginSystemHeadRefresh{
    [self.refreshControl beginRefreshing];
}

-(void)endSystemHeadRefresh{
    [self.refreshControl endRefreshing];
}


@end
