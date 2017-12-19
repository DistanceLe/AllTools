//
//  LJColumnChartView.h
//  LJColumnChart
//
//  Created by LiJie on 2017/2/27.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DisplayColumnBlock)(NSInteger index, BOOL isAnimation);

@interface LJColumnChartView : UIView

/**  每跳柱形图的值 */
@property(nonatomic, strong)NSArray<NSNumber*>* valueArray;

/**  y轴的最大值， 可以不填，自动算出。 */
@property(nonatomic, assign)NSInteger yAxisMax;

/**  当前选中的 位置 */
@property(nonatomic, assign)NSInteger   currentSelectIndex;

/**  移动到当前位置  位置为center 有动画*/
@property(nonatomic, assign)NSInteger   scrollToIndex;

/**  X轴的文字 */
@property(nonatomic, strong)NSArray<NSString*>* XAxisTextsArray;
/**  X轴的文字(只有 首尾的状况) */
@property(nonatomic, strong)NSArray<NSString*>* twoXAxisTextsArray;

/**  每条柱形图的宽度，可以不设置，直接设置 columnWidth*/
@property(nonatomic, strong)NSArray<NSNumber*>* columnWidthsArray;

/**  每条柱形图的颜色，可以不设置，直接设置 columnColor*/
@property(nonatomic, strong)NSArray<UIColor*>* columnColorsArray;

/**  左下方的 其实位置（26， 28） 28固定 */
@property(nonatomic, assign)CGSize  chartOriginSize;

/**  每条柱形图的 间隙， 默认5 */
@property(nonatomic, assign)CGFloat columnSpace;

/**  每条柱形图的宽度 默认23*/
@property(nonatomic, assign)CGFloat columnWidth;

/**  每条柱形图的颜色 默认白色*/
@property(nonatomic, strong)UIColor* columnColor;

/**  每条柱形图被选中后的颜色 默认灰色 */
@property(nonatomic, strong)UIColor* columnSelectColor;

/**  Y轴虚线的 颜色 默认浅白色*/
@property(nonatomic, strong)UIColor* yAxisdashColor;
/**  X Y轴 及其文字的颜色 默认都是白色*/
@property(nonatomic, strong)UIColor* XAndY_TextColor;
@property(nonatomic, strong)UIColor* XAndY_LineColor;

/**  X轴单位 如： 10分钟 或 分钟 */
@property(nonatomic, copy)NSString* XUnit;
/**  比如上面的10 是会变的。 则传该数组， 上面就改为‘分钟’ */
@property(nonatomic, copy)NSArray<NSString*>* XUnitsArray;
/**  Y轴单位 */
@property(nonatomic, copy)NSString* YUnit;


/**  显示的时候 是否有动画  默认有 */
@property(nonatomic, assign)BOOL animation;

/**  添加数据的时候，默认直接移到最末尾 */
@property(nonatomic, assign)BOOL scrollToEnd;

/**  是否显示 Y轴值的虚线 默认不显示*/
@property(nonatomic, assign)BOOL showYAxisDash;

/**  是否显示 每条柱形图顶部的值 默认不显示*/
@property(nonatomic, assign)BOOL showEndValue;

/**  是否显示XY轴的线， 默认显示 */
@property(nonatomic, assign)BOOL showXAxisLine;
@property(nonatomic, assign)BOOL showYAxisLine;

/**  是否显示Y轴文字， 默认显示 */
@property(nonatomic, assign)BOOL showYAxisText;

/**  是否可点击，显示详细值 , 默认打开*/
@property(nonatomic, assign)BOOL canShowDetail;

/**  显示详细值的背景图片 */
@property(nonatomic, strong)UIImage* detailBackImage;



/**  添加数据, 后面相应的 宽度和颜色 可选， 默认移动到最后面 再添加 */
-(void)addData:(NSArray* )addDataArray titleArray:(NSArray*)titleArray widthArray:(NSArray*)widthArray colorArray:(NSArray*)colorArray animation:(BOOL)animation;

/**  滚到到 哪一个柱形条 */
-(void)scrollToIndex:(NSInteger)index position:(UICollectionViewScrollPosition)position animation:(BOOL)animation;

/**  开始显示 图表 */
-(void)showChart;

/**  柱形图显示的回调， YES:停止动画时， NO:手势停止时或停止减速时 */
-(void)displayColumnCallBackHandler:(DisplayColumnBlock)handler;


@end
