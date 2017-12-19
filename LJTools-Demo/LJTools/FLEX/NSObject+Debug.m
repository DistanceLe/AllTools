//
//  NSObject+Debug.m
//  timeDemo
//
//  Created by LiJie on 2017/3/29.
//  Copyright © 2017年 LiJie. All rights reserved.
//
#import <Foundation/Foundation.h>

#if DEBUG
#import <FLEX/FLEX.h>
#import "AppDelegate.h"
#import "KMCGeigerCounter.h"
#endif

@implementation NSObject (Debug)

+(void)load{
#if DEBUG
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.55*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setFlexShowButton];
        [KMCGeigerCounter sharedGeigerCounter].enabled = YES;
    });
#endif
}

+(void)setFlexShowButton{
#if DEBUG
    AppDelegate* dele = (AppDelegate*)[UIApplication sharedApplication].delegate;
    UIButton* showBut = [UIButton buttonWithType:UIButtonTypeSystem];
    [showBut setTitle:@"show" forState:UIControlStateNormal];
    showBut.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.3];
    [showBut setTintColor:[UIColor orangeColor]];
    showBut.frame = CGRectMake(IPHONE_WIDTH-100, IPHONE_HEIGHT-100, 60, 60);
    [dele.window addSubview:showBut];
    [showBut addTargetClickHandler:^(UIButton *but, id obj) {
        but.selected = !but.selected;
        if (but.selected) {
            [[FLEXManager sharedManager] showExplorer];
        }else{
            [[FLEXManager sharedManager] hideExplorer];
        }
    }];
    __weak typeof(UIButton*) tempBut=showBut;
    [showBut addPanGestureHandler:^(UIPanGestureRecognizer *pan, UIView *itself) {
        if (pan.state == UIGestureRecognizerStateChanged) {
            CGPoint point = [pan locationInView:dele.window];
            tempBut.center = point;
        }
    }];
#endif
}
















@end
