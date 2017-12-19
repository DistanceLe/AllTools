//
//  UILabel+LJ.m
//  StarWristSport
//
//  Created by LiJie on 2017/4/25.
//  Copyright © 2017年 celink. All rights reserved.
//

#import "UILabel+LJ.h"
#import <objc/runtime.h>

@implementation UILabel (LJ)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 获取到UILabel中setText对应的method
        Method setText =class_getInstanceMethod([UILabel class], @selector(setText:));
        Method setTextMySelf =class_getInstanceMethod([UILabel class],@selector(setTextHooked:));
        
        IMP setTextImp =method_getImplementation(setText);
        IMP setTextMySelfImp =method_getImplementation(setTextMySelf);
        
        BOOL didAddMethod = class_addMethod([UILabel class], @selector(setText:), setTextMySelfImp, method_getTypeEncoding(setTextMySelf));
        
        if (didAddMethod) {
            class_replaceMethod([UILabel class], @selector(setTextHooked:), setTextImp, method_getTypeEncoding(setText));
        }else{
            method_exchangeImplementations(setText, setTextMySelf);
        }
    });
}

-(void)setTextHooked:(NSString*)text{
    if ([text hasPrefix:@"---"]) {
        self.textAlignment = NSTextAlignmentLeft;
        [self setTextHooked:[text substringFromIndex:3]];
    }else if ([text hasSuffix:@"---"]){
        self.textAlignment = NSTextAlignmentRight;
        [self setTextHooked:[text substringToIndex:text.length-3]];
    }else if ([text hasPrefix:@"|||"]) {
        self.superview.superview.backgroundColor = KSystemColor;
        [self setTextHooked:[text substringFromIndex:3]];
    }else{
        [self setTextHooked:text];
    }
}







@end
