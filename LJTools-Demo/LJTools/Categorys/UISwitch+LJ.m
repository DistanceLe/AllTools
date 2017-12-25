//
//  UISwitch+LJ.m
//  timeDemo
//
//  Created by LiJie on 2017/3/10.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import "UISwitch+LJ.h"

@implementation UISwitch (LJ)


-(void)setCustomMask{
    
    CALayer* maskLayer=[CALayer layer];
    maskLayer.contents=(id)[self getImageForColor].CGImage;
    maskLayer.frame = CGRectMake(2, 8, self.lj_width-4, self.lj_height-16);
    maskLayer.cornerRadius = (self.lj_height-16)/2.0;
    maskLayer.masksToBounds=YES;
    
    for (UIView* subView1 in self.subviews) {
        subView1.backgroundColor  = [UIColor whiteColor];
        subView1.layer.mask=maskLayer;
        for (UIView* subView2 in subView1.subviews) {
            if ([subView2 isKindOfClass:[UIImageView class]]) {
                [self addSubview:subView2];
                break;
            }
        }
        UILabel* lineView = [[UILabel alloc]initWithFrame:maskLayer.frame];
        lineView.backgroundColor = [UIColor whiteColor];
        lineView.layer.cornerRadius = lineView.lj_height/2.0;
        lineView.layer.borderWidth = 1;
        lineView.layer.borderColor = self.onTintColor.CGColor;
        [subView1 insertSubview:lineView atIndex:0];
    }
}


#pragma mark - ================ 生成一个蒙版图片 ==================
-(UIImage*)getImageForColor{
    CGRect rect=CGRectMake(0.0f, 0.0f, 5, 5);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor redColor] CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}






@end
