//
//  LJColumnCell.m
//  LJColumnChart
//
//  Created by LiJie on 2017/2/27.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import "LJColumnCell.h"

@interface LJColumnCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *columnHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *columnWidth;


@end

@implementation LJColumnCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.masksToBounds = NO;
}

-(void)setColumnHeight:(CGFloat)height width:(CGFloat)width animation:(BOOL)animation{
    
    self.columnWidth.constant = width;
    self.columnHeight.constant = 0;
    if (animation) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:kLineAnimationDuration animations:^{
                self.columnHeight.constant = height;
                [self layoutIfNeeded];
            }];
        });
        
    }else{
        self.columnHeight.constant = height;
        [self.columnView layoutIfNeeded];
    }
}

@end
