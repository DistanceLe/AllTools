//
//  Common.h
//  StarWristSport
//
//  Created by celink on 17/1/5.
//  Copyright © 2017年 celink. All rights reserved.
//

#ifndef Common_h
#define Common_h

#define DIR_DOC            [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

// system
#define IOS_SystemVersion [[UIDevice currentDevice].systemVersion doubleValue]
#define MAINVIEWHEIGHT [[UIScreen mainScreen] bounds].size.height
#define MAINVIEWWIDTH [[UIScreen mainScreen] bounds].size.width

#define IPHONE_HEIGHT MAINVIEWHEIGHT
#define IPHONE_WIDTH  MAINVIEWWIDTH

#define DIFF_7              ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0 ? 20.0 : 0.0)//从ios6到ios7 y值的变化
#define progressFrame CGRectMake(0, 0, MAINVIEWWIDTH, MAINVIEWHEIGHT - [commonCode Ios7NavBarHeight])

//适配用的宏
#define S_(v) ((v)*MAINVIEWWIDTH/320.0)

#define X_(x)  (((x) * MAINVIEWWIDTH)/375.0)                    //x方向上比例缩放
#define Y_(y)  (((MAINVIEWHEIGHT - DIFF_7)/(667.0 - DIFF_7)) * y) //y方向上比例缩放，
#define YT_(y) (((MAINVIEWHEIGHT - 64)/(667.0 -64)) * y)          //y方向上比例缩放，只有导航栏
#define YTB_(y) (((MAINVIEWHEIGHT - 64 - 49)/(667.0 - 64 - 49)) * y) //y方向上比例缩放，有导航栏和tabbar



#define IFISNULL(v)             ([v isEqualToString:@""] || v==nil || v==NULL)
#define kRGBColor(r, g, b, a)   [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define HEXCOLOR(rgbValue)      [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define kCellSelectionBackColor kRGBColor(50, 60, 85, 1.0)
#define KSystemColor            kRGBColor(255, 192, 31, 1.0)
#define KBarColor               kRGBColor(255, 255, 255, 1.0)
#define KTitleColor             [UIColor blackColor]

#define CircleColor_SportTime   HEXCOLOR(0x53C1B8)
#define CircleColor_Calorie     HEXCOLOR(0xC9548B)
#define CircleColor_Step        HEXCOLOR(0x60BF50)
#define CircleColor_Sleep       HEXCOLOR(0x4791A7)
#define CircleColor_Distance    HEXCOLOR(0xEEC966)
#define CircleColor_Heart       HEXCOLOR(0xF06564)


/**  Weakify  Strongify */
#ifndef weakify
#if DEBUG       //===========
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else           //===========
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif          //===========
#endif


#ifndef strongify
#if DEBUG       //+++++++++++
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else           //+++++++++++
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif          //+++++++++++
#endif


#endif /* Common_h */
