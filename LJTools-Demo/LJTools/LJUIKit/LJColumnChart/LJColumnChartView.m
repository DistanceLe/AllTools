//
//  LJColumnChartView.m
//  LJColumnChart
//
//  Created by LiJie on 2017/2/27.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import "LJColumnChartView.h"
#import "LJColumnCell.h"

#define P_M(x,y) CGPointMake(x, y)
#define XORYLINEMAXSIZE CGSizeMake(CGFLOAT_MAX,30)


@interface LJColumnChartView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property(nonatomic, strong)UICollectionView* collectionView;


@property(nonatomic, assign)CGFloat   maxValue;//Y轴最大值
@property(nonatomic, assign)CGFloat     perHeight;//每个单元的高度
@property(nonatomic, assign)NSInteger   oldCount;//旧的数据 数量
@property(nonatomic, assign)BOOL        newDataAnimation;//新的数据 是否要显示动画

@property(nonatomic, strong)DisplayColumnBlock tempHandler;
@property(nonatomic, strong)NSMutableArray* layersArray;

@end

@implementation LJColumnChartView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.columnSpace = 5;
        self.columnWidth = 23;
        self.animation = YES;
        self.showXAxisLine = YES;
        self.showYAxisLine = YES;
        self.canShowDetail = YES;
        self.showYAxisText = YES;
        self.scrollToEnd = YES;
        
        self.columnColor = [UIColor whiteColor];
        self.columnSelectColor = [UIColor lightGrayColor];
        self.yAxisdashColor = [[UIColor whiteColor]colorWithAlphaComponent:0.6];
        self.XAndY_LineColor = [UIColor whiteColor];
        self.XAndY_TextColor = [UIColor whiteColor];
        
        self.layersArray = [NSMutableArray array];
        self.chartOriginSize = CGSizeMake(26, 28);
        self.currentSelectIndex = -1;
        [self initUI];
    }
    return self;
}

-(void)displayColumnCallBackHandler:(DisplayColumnBlock)handler{
    self.tempHandler =handler;
}

-(void)showChart{
    [self drawChart];
    self.collectionView.frame = CGRectMake(self.chartOriginSize.width,
                                           5,
                                           self.lj_width-self.chartOriginSize.width ,
                                           self.lj_height-5);
    [self.collectionView reloadData];
}

-(void)setChartOriginSize:(CGSize)chartOriginSize{
    chartOriginSize.height = 28;
    _chartOriginSize = chartOriginSize;
}

-(void)setCurrentSelectIndex:(NSInteger)currentSelectIndex{
    _currentSelectIndex = currentSelectIndex;
    if (self.collectionView && _currentSelectIndex>=0 && _currentSelectIndex < self.valueArray.count) {
        [self collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:_currentSelectIndex inSection:0]];
    }else{
        _currentSelectIndex = -1;
        [self.collectionView reloadData];
    }
}

-(void)setScrollToIndex:(NSInteger)scrollToIndex{
    if (scrollToIndex >=0 && scrollToIndex < self.valueArray.count) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:scrollToIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
    _scrollToIndex = scrollToIndex;
}

-(void)scrollToIndex:(NSInteger)index position:(UICollectionViewScrollPosition)position animation:(BOOL)animation{
    if (index >=0 && index < self.valueArray.count) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:position animated:animation];
    }
}

-(void)setYAxisMax:(NSInteger)yAxisMax{
    _yAxisMax = yAxisMax;
    if (_yAxisMax > 0 && _yAxisMax > _maxValue) {
        _maxValue = _yAxisMax;
    }
    _perHeight = (self.lj_height - 30 - _chartOriginSize.height)/_maxValue;
}

-(void)setValueArray:(NSArray *)valueArray{
    _maxValue = 0;
    
    NSMutableArray* tempArray = [NSMutableArray array];
    
    for (NSNumber* value in valueArray) {
        //过滤 小数保留过多位数问题
        float subValue = [value floatValue];
        if (subValue >= (int)subValue + 0.0001) {
            NSString* subStr = [NSString stringWithFormat:@"%.1f",subValue];
            subValue = [subStr floatValue];
            [tempArray addObject:@(subValue)];
        }else{
            [tempArray addObject:value];
        }
        if (_maxValue < subValue) {
            _maxValue = subValue;
        }
    }
    
    if (_maxValue<1) {
        _maxValue = 1;
    }else if(_maxValue<10){
        _maxValue = 10;
    }
    _maxValue *= 1.25;
    if (_yAxisMax > 0 && _yAxisMax > _maxValue) {
        _maxValue = _yAxisMax;
    }
    
    _perHeight = (self.lj_height - 30 - _chartOriginSize.height)/_maxValue;
    _valueArray = tempArray;
}

-(void)addData:(NSArray *)addDataArray titleArray:(NSArray*)titleArray widthArray:(NSArray*)widthArray colorArray:(NSArray*)colorArray animation:(BOOL)animation{
    
    for (NSNumber* value in addDataArray) {
        if (_maxValue < [value floatValue]) {
            _maxValue = [value floatValue];
        }
    }
    
    if (_maxValue<1) {
        _maxValue = 1;
    }else if(_maxValue<10){
        _maxValue = 10;
    }
    if (_yAxisMax > 0 && _yAxisMax > _maxValue) {
        _maxValue = _yAxisMax;
    }
    _perHeight = (self.lj_height - 30 - _chartOriginSize.height)/_maxValue;
    self.oldCount = self.valueArray.count;
    self.newDataAnimation = animation;
    
    NSMutableArray* array = [NSMutableArray arrayWithArray:self.valueArray];
    [array addObjectsFromArray:addDataArray];
    self.valueArray = array;
    
    NSMutableArray* titles = [NSMutableArray arrayWithArray:self.XAxisTextsArray];
    [titles addObjectsFromArray:titleArray];
    self.XAxisTextsArray = titles;
    
    if (widthArray.count && self.columnWidthsArray) {
        NSMutableArray* widths = [NSMutableArray arrayWithArray:self.columnWidthsArray];
        [widths addObjectsFromArray:widthArray];
        self.columnWidthsArray = widths;
    }
    
    if (colorArray.count && self.columnColorsArray) {
        NSMutableArray* colors = [NSMutableArray arrayWithArray:self.columnColorsArray];
        [colors addObjectsFromArray:colorArray];
        self.columnColorsArray = colors;
    }
    
    
    [self.collectionView reloadData];
    if (self.scrollToEnd) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.valueArray.count-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.oldCount = 0;
    });
}

-(void)initUI{
    
    UICollectionViewFlowLayout* layout=[[UICollectionViewFlowLayout alloc]init];
    
    layout.minimumLineSpacing=0;
    layout.minimumInteritemSpacing=0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView=[[UICollectionView alloc]initWithFrame:
                         CGRectMake(self.chartOriginSize.width,
                                    5,
                                    self.lj_width-self.chartOriginSize.width ,
                                    self.lj_height-5) collectionViewLayout:layout];
    self.collectionView.backgroundColor=[UIColor clearColor];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([LJColumnCell class]) bundle:nil] forCellWithReuseIdentifier:cellIdentify];
    
    self.collectionView.showsHorizontalScrollIndicator=NO;
    
    self.collectionView.delegate=self;
    self.collectionView.dataSource=self;
    [self addSubview:self.collectionView];
}

-(void)drawChart{
    for (CALayer* layer in self.layersArray) {
        [layer removeAllAnimations];
        [layer removeFromSuperlayer];
    }
    [self.layersArray removeAllObjects];
    
    //画 X Y 轴线
    if (self.showXAxisLine || self.showYAxisLine) {
        CAShapeLayer *layer = [CAShapeLayer layer];
        [self.layersArray addObject:layer];
        
        UIBezierPath *bezier = [UIBezierPath bezierPath];
        
        if (self.showYAxisLine) {
            [bezier moveToPoint:P_M(self.chartOriginSize.width, self.lj_height - self.chartOriginSize.height)];
            [bezier addLineToPoint:P_M(self.chartOriginSize.width, 20)];
        }
        
        if (self.showXAxisLine) {
            [bezier moveToPoint:P_M(self.chartOriginSize.width, self.lj_height - self.chartOriginSize.height)];
            [bezier addLineToPoint:P_M(self.lj_width , self.lj_height - self.chartOriginSize.height)];
        }
        
        layer.path = bezier.CGPath;
        layer.strokeColor = _XAndY_LineColor.CGColor;
        
        //        if (self.animation) {
        //            CABasicAnimation *basic = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        //            basic.duration = self.showYAxisLine?kLineAnimationDuration:kLineAnimationDuration/2.0;
        //            basic.fromValue = @(0);
        //            basic.toValue = @(1);
        //            basic.autoreverses = NO;
        //            basic.fillMode = kCAFillModeForwards;
        //            [layer addAnimation:basic forKey:nil];
        //        }
        [self.layer addSublayer:layer];
    }
    
    //设置 Y轴文字
    UIBezierPath *second = [UIBezierPath bezierPath];
    if (self.showYAxisText || self.showYAxisDash) {
        for (NSInteger i = 0; i<5; i++) {
            float pace = (_maxValue) / 5.0;
            CGFloat height = _perHeight * (i+1)*pace;
            [second moveToPoint:P_M(_chartOriginSize.width, self.lj_height - self.chartOriginSize.height -height)];
            [second addLineToPoint:P_M(self.lj_width, CGRectGetHeight(self.frame) - self.chartOriginSize.height - height)];
            
            if (self.showYAxisText) {
                CATextLayer *textLayer = [CATextLayer layer];
                
                textLayer.contentsScale = [UIScreen mainScreen].scale;
                NSString *text = @"";
                if (pace>1) {
                    text=[NSString stringWithFormat:@"%lld",(int64_t)((i + 1) * pace)];
                }else{
                    text=[NSString stringWithFormat:@"%.1f",(i + 1) * pace];
                }
                
                CGFloat be = [self sizeOfStringWithMaxSize:XORYLINEMAXSIZE textFont:8 aimString:text].width;
                textLayer.frame = CGRectMake(_chartOriginSize.width - be - 3, CGRectGetHeight(self.frame) - self.chartOriginSize.height -height - 5, be, 15);
                
                UIFont *font = [UIFont systemFontOfSize:8];
                CFStringRef fontName = (__bridge CFStringRef)font.fontName;
                CGFontRef fontRef = CGFontCreateWithFontName(fontName);
                textLayer.font = fontRef;
                textLayer.fontSize = font.pointSize;
                CGFontRelease(fontRef);
                
                textLayer.string = text;
                
                textLayer.foregroundColor = _XAndY_TextColor.CGColor;
                [self.layer addSublayer:textLayer];
                [self.layersArray addObject:textLayer];
            }
        }
    }
    
    //画  x轴的 首尾文字：
    if (self.twoXAxisTextsArray.count == 2) {
        NSString *text2 =self.twoXAxisTextsArray[1];
        CGFloat be2 = [self sizeOfStringWithMaxSize:XORYLINEMAXSIZE textFont:8 aimString:text2].width;
        
        for (NSInteger i = 0; i<2; i++) {
            CATextLayer *textLayer = [CATextLayer layer];
            
            textLayer.contentsScale = [UIScreen mainScreen].scale;
            NSString *text =self.twoXAxisTextsArray[i];
            CGSize textSize = [self sizeOfStringWithMaxSize:XORYLINEMAXSIZE textFont:8 aimString:text];
            textLayer.frame = CGRectMake( _chartOriginSize.width + i*(self.lj_width - be2 - _chartOriginSize.width-10), self.lj_height - self.chartOriginSize.height, textSize.width, textSize.height);
            
            UIFont *font = [UIFont systemFontOfSize:8];
            CFStringRef fontName = (__bridge CFStringRef)font.fontName;
            CGFontRef fontRef = CGFontCreateWithFontName(fontName);
            textLayer.font = fontRef;
            textLayer.fontSize = font.pointSize;
            CGFontRelease(fontRef);
            
            textLayer.string = text;
            
            textLayer.foregroundColor = _XAndY_TextColor.CGColor;
            [self.layer addSublayer:textLayer];
            [self.layersArray addObject:textLayer];
        }
    }
    
    //画虚线
    if (self.showYAxisDash) {
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = second.CGPath;
        shapeLayer.strokeColor = _yAxisdashColor.CGColor;
        shapeLayer.lineWidth = 0.5;
        [shapeLayer setLineDashPattern:@[@(3),@(3)]];
        
//        if (_animation) {
//            CABasicAnimation *basic2 = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
//            basic2.duration = kLineAnimationDuration;
//            basic2.fromValue = @(0);
//            basic2.toValue = @(1);
//            basic2.autoreverses = NO;
//            basic2.fillMode = kCAFillModeForwards;
//            [shapeLayer addAnimation:basic2 forKey:nil];
//        }
        
        [self.layer addSublayer:shapeLayer];
        [self.layersArray addObject:shapeLayer];
    }
    [self bringSubviewToFront:self.collectionView];
}

#pragma mark ==============代理方法：======================

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.valueArray.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    LJColumnCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentify forIndexPath:indexPath];
    //设置X轴 文字
    if (self.XAxisTextsArray.count > indexPath.item && self.twoXAxisTextsArray.count!=2) {
        cell.xAxisLabel.text = self.XAxisTextsArray[indexPath.item];
    }else{
        cell.xAxisLabel.text = @"";
    }
    cell.xAxisLabel.textColor = self.XAndY_TextColor;
    
    //设置 柱形图颜色 及 详细信息视图
    if (self.columnColorsArray.count > indexPath.item) {
        cell.columnView.backgroundColor = self.columnColorsArray[indexPath.item];
    }else{
        cell.columnView.backgroundColor = self.columnColor;
    }
    cell.backDetailView.hidden = YES;
    cell.endValueLabel.hidden = !self.showEndValue;
    cell.endValueLabel.textColor = cell.columnView.backgroundColor;
    
    if (self.currentSelectIndex == indexPath.item) {
        cell.columnView.backgroundColor = self.columnSelectColor;
        cell.backDetailView.hidden = NO;
        cell.endValueLabel.hidden = YES;
        [self.collectionView bringSubviewToFront:cell];
    }
    
    cell.detailBackImageView.image = self.detailBackImage;
    NSString* detail = [NSString stringWithFormat:@"%@%@\n%@", self.valueArray[indexPath.item], self.YUnit , self.XUnit];
    if (self.XUnitsArray.count>indexPath.item) {
        detail = [NSString stringWithFormat:@"%@%@\n%@%@", self.valueArray[indexPath.item], self.YUnit , self.XUnitsArray[indexPath.item], self.XUnit];
        if (self.YUnit.length<=0) {
            detail = [NSString stringWithFormat:@"%@\n%@", self.XUnitsArray[indexPath.item], self.XUnit];
        }
    }else if (self.XUnit.length<=0){
        detail = [NSString stringWithFormat:@"%@\n%@", self.valueArray[indexPath.item], self.YUnit];
    }
    
    cell.columnDetailLabel.text = detail;
    cell.columnDetailLabel.textColor = self.XAndY_TextColor;
    
    //设置EndValue
    cell.endValueLabel.text = [NSString stringWithFormat:@"%@", self.valueArray[indexPath.item]];
    
    
    //设置高度 及 宽度
    BOOL cellAnimation = NO;
    if (self.oldCount<=0) {
        cellAnimation = self.animation;
    }else if (self.oldCount>0 && self.oldCount-1<indexPath.row) {
        cellAnimation = self.newDataAnimation;
    }
    
    CGFloat height = [self.valueArray[indexPath.item] floatValue]*_perHeight;
    if (self.columnWidthsArray.count > indexPath.row) {
        [cell setColumnHeight:height
                        width:[self.columnWidthsArray[indexPath.item] floatValue]
                    animation:cellAnimation];
    }else{
        [cell setColumnHeight:height
                        width:self.columnWidth
                    animation:cellAnimation];
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_currentSelectIndex >= 0) {
        LJColumnCell* oldCell = (LJColumnCell*)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentSelectIndex inSection:0]];
        oldCell.backDetailView.hidden = YES;
        if (self.columnColorsArray.count == self.valueArray.count) {
            oldCell.columnView.backgroundColor = self.columnColorsArray[self.currentSelectIndex];
        }else{
            oldCell.columnView.backgroundColor = self.columnColor;
        }
        oldCell.endValueLabel.hidden = !self.showEndValue;
    }
    if (_currentSelectIndex != indexPath.item) {
        LJColumnCell* cell = (LJColumnCell*)[collectionView cellForItemAtIndexPath:indexPath];
        cell.columnView.backgroundColor = self.columnSelectColor;
        cell.backDetailView.hidden = NO;
        cell.endValueLabel.hidden = YES;
        [self.collectionView bringSubviewToFront:cell];
        _currentSelectIndex = indexPath.item;
    }else{
        _currentSelectIndex = -1;
    }
}

//-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
//    
//    if (self.tempHandler) {
//        self.tempHandler(indexPath.item, NO);
//    }
//}

//-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
//    if (self.tempHandler) {
//        self.tempHandler(indexPath.item, YES);
//    }
//}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat width = 0;
    
    if (self.columnWidthsArray.count>indexPath.item) {
        width = [self.columnWidthsArray[indexPath.item] floatValue];
    }else{
        width = self.columnWidth;
    }
    width += self.columnSpace;
    return CGSizeMake(width, self.lj_height-5);
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSArray* visibleArray = [self.collectionView indexPathsForVisibleItems];
    if (visibleArray.count>0) {
        NSInteger index = self.valueArray.count;
        for (NSIndexPath* subIndexPath in visibleArray) {
            if (index>subIndexPath.item) {
                index = subIndexPath.item;
            }
        }
        if (self.tempHandler) {
            self.tempHandler(index, NO);
        }
    }
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        NSArray* visibleArray = [self.collectionView indexPathsForVisibleItems];
        if (visibleArray.count>0) {
            NSInteger index = self.valueArray.count;
            for (NSIndexPath* subIndexPath in visibleArray) {
                if (index>subIndexPath.item) {
                    index = subIndexPath.item;
                }
            }
            if (self.tempHandler) {
                self.tempHandler(index, NO);
            }
        }
    }
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    if (self.currentSelectIndex >= 0) {
        LJColumnCell* cell = (LJColumnCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentSelectIndex inSection:0]];
        if ([self.collectionView.visibleCells containsObject:cell]) {
            [self.collectionView bringSubviewToFront:cell];
        }
    }
    if (self.tempHandler) {
        self.tempHandler(-3, YES);
    }
}

#pragma mark - ================ Action ==================
- (CGSize)sizeOfStringWithMaxSize:(CGSize)maxSize textFont:(CGFloat)fontSize aimString:(NSString *)aimString{
    
    return [[NSString stringWithFormat:@"%@",aimString] boundingRectWithSize:maxSize options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} context:nil].size;
    
}
@end
