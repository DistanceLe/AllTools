//
//  UISwitch+LJ.h
//  timeDemo
//
//  Created by LiJie on 2017/3/10.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UISwitch (LJ)

/**  必须在 设置了所有颜色后调用(onTintColor, thumbTintColor) 否则会出问题*/
-(void)setCustomMask;

@end
