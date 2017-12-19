//
//  LJColumnCell.h
//  LJColumnChart
//
//  Created by LiJie on 2017/2/27.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kLineAnimationDuration 0.8
@interface LJColumnCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *columnView;

@property (weak, nonatomic) IBOutlet UIView *backDetailView;
@property (weak, nonatomic) IBOutlet UILabel *xAxisLabel;
@property (weak, nonatomic) IBOutlet UILabel *endValueLabel;
@property (weak, nonatomic) IBOutlet UIImageView *detailBackImageView;
@property (weak, nonatomic) IBOutlet UILabel *columnDetailLabel;

-(void)setColumnHeight:(CGFloat)height width:(CGFloat)width animation:(BOOL)animation;

@end
