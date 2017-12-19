//
//  CalendarViewController.m
//  LJTools-Demo
//
//  Created by LiJie on 2017/9/14.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import "CalendarViewController.h"

#import "LJCalendarView.h"

@interface CalendarViewController ()

@end

@implementation CalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    LJCalendarView* calendarView = [LJCalendarView getCalendarWithFrame:CGRectMake(0, 70, IPHONE_WIDTH, 400)];
    calendarView.dateHandler = ^(NSString *dateString, NSDate *date, NSString *selectedDate) {
        
    };
    
//    NSArray* array = @[];
//    DLog(@"%@", array[3]);
    
    [self.view addSubview:calendarView];
    
}



@end
