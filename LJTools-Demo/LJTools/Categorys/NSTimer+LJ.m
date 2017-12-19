//
//  NSTimer+LJ.m
//  StarWristSport
//
//  Created by LiJie on 2017/1/9.
//  Copyright © 2017年 celink. All rights reserved.
//

#import "NSTimer+LJ.h"

@implementation NSTimer (LJ)

-(void)pauseTimer{
    
    if (![self isValid]) {
        return ;
    }
    [self setFireDate:[NSDate distantFuture]]; //如果给我一个期限，我希望是4001-01-01 00:00:00 +0000
}
-(void)resumeTimer{
    
    if (![self isValid]) {
        return ;
    }
    
    //[self setFireDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    [self setFireDate:[NSDate date]];
    
}
@end
