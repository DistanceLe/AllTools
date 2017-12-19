//
//  UITableViewCell+LJ.m
//  StarWristSport
//
//  Created by LiJie on 2017/3/7.
//  Copyright © 2017年 celink. All rights reserved.
//

#import "UITableViewCell+LJ.h"

@implementation UITableViewCell (LJ)

-(void)setSelectedBackgroundColor:(UIColor *)backColor{
    UIView* backView = self.selectedBackgroundView;
    if (!backView || backView.tag != 595 ) {
        backView=[[UIView alloc]initWithFrame:CGRectMake(2, 2, self.lj_width-4, self.lj_height-4)];
        backView.tag = 595;
        backView.layer.cornerRadius = 5;
        backView.layer.masksToBounds = YES;
        backView.backgroundColor = backColor;
        self.selectedBackgroundView=backView;
        [self sendSubviewToBack:backView];
    }
}

@end
