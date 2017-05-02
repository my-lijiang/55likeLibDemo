//
//  LJImageRollingView.m
//  JiuSheng55like
//
//  Created by junseek on 2016/11/8.
//  Copyright © 2016年 55like lj. All rights reserved.
//

#import "LJImageRollingView.h"

@interface LJImageRollingView ()<UIScrollViewDelegate>
{
    BOOL boolStopAnimation;
    UIScrollView *scrollviewBG;
    NSArray * imageNameList;
    UIPageControl *_pageControl;
    
    UIImageView *imgVLeft;
    UIImageView *imgVCenter;
    UIImageView *imgVRight;
    NSInteger currentImageIndex;
    NSInteger imageCount;
}


@end
@implementation LJImageRollingView

-(void)dealloc{
    RemoveNofify
}
-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        RegisterNotify(UIApplicationDidEnterBackgroundNotification, @selector(enterBackGroundNotication))
        RegisterNotify(UIApplicationWillEnterForegroundNotification, @selector(enterForegroundNotification))
        
        scrollviewBG = [[UIScrollView alloc] initWithFrame:self.bounds];
        scrollviewBG.delegate = self;
        scrollviewBG.contentSize = CGSizeMake(self.bounds.size.width * 3, self.bounds.size.height);
        scrollviewBG.showsHorizontalScrollIndicator = NO;
        scrollviewBG.contentOffset = CGPointMake(self.bounds.size.width, 0);
        scrollviewBG.pagingEnabled = YES;
        [self addSubview:scrollviewBG];
//        [scrollviewBG setBackgroundColor:[UIColor greenColor]];
        [scrollviewBG setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        
        imgVLeft=[RHMethods imageviewWithFrame:CGRectMake(0, 0, W(scrollviewBG), H(scrollviewBG)) defaultimage:@"loadImageBG"];
        [imgVLeft setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [imgVLeft setUserInteractionEnabled:YES];
        [scrollviewBG addSubview:imgVLeft];
        [imgVLeft addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageClicked:)]];
        
        imgVCenter=[RHMethods imageviewWithFrame:CGRectMake(W(scrollviewBG), 0, W(scrollviewBG), H(scrollviewBG)) defaultimage:@"loadImageBG"];
        [imgVCenter setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [imgVCenter setUserInteractionEnabled:YES];
        [scrollviewBG addSubview:imgVCenter];
        [imgVCenter addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageClicked:)]];
        
        imgVRight=[RHMethods imageviewWithFrame:CGRectMake(W(scrollviewBG)*2, 0, W(scrollviewBG), H(scrollviewBG)) defaultimage:@"loadImageBG"];
        [imgVRight setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [imgVRight setUserInteractionEnabled:YES];
        [scrollviewBG addSubview:imgVRight];
        [imgVRight addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageClicked:)]];
        
        
        [imgVLeft setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [imgVCenter setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [imgVRight setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        
        CGRect rect = self.bounds;
        rect.origin.y = rect.size.height - 20;
        rect.size.height = 10;
        _pageControl = [[UIPageControl alloc] initWithFrame:rect];
        _pageControl.userInteractionEnabled = NO;
        [_pageControl setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth];
        _pageControl.currentPageIndicatorTintColor = rgbpublicColor;
        _pageControl.pageIndicatorTintColor = [UIColor whiteColor];
        
        [self addSubview:_pageControl];
        boolStopAnimation=NO;
        
    }
    return self;
}
/*
    images@[@{
 (UIImage *)DefaultImage   //默认图片（有数据时候优先显示）
 (NSString *)url           //大图路径
    }]
 */
-(void)reloadImageView:(NSArray *)images selectIndex:(NSInteger )sIndex{
    if (!images || [images count]==0) {
        return;
    }
    imageNameList=images;
    imageCount=[images count];
    if (sIndex>=imageCount) {
        sIndex=0;
    }
    currentImageIndex=sIndex;
    [scrollviewBG setContentOffset:CGPointMake(W(scrollviewBG), 0)];
    _pageControl.numberOfPages = imageCount;
//    _pageControl.hidden=YES;
    
    [self setInfoByCurrentImageIndex:currentImageIndex];
    [self startAnimation];
}

- (void)reloadImage {
    CGPoint contentOffset = [scrollviewBG contentOffset];
    if (contentOffset.x > W(scrollviewBG)) { //向左滑动
        currentImageIndex = (currentImageIndex + 1) % imageCount;
    } else if (contentOffset.x < W(scrollviewBG) ) { //向右滑动
        currentImageIndex = (currentImageIndex - 1 + imageCount) % imageCount;
    }
    
    [self setInfoByCurrentImageIndex:currentImageIndex];
}

- (void)setInfoByCurrentImageIndex:(NSInteger)ImageIndex {
    NSDictionary *dicPrevious;
    if (ImageIndex-1>=0) {
        dicPrevious=imageNameList[ImageIndex-1];
    }else{
        dicPrevious=[imageNameList lastObject];
    }
    if ([dicPrevious objectForJSONKey:@"DefaultImage"]) {
        imgVLeft.image = [dicPrevious objectForJSONKey:@"DefaultImage"];
    }else{
        [imgVLeft imageWithURL:[dicPrevious valueForJSONStrKey:@"url"] useProgress:YES useActivity:NO];
    }
    
    NSDictionary *dic=imageNameList[ImageIndex];
    if ([dic objectForJSONKey:@"DefaultImage"]) {
        imgVCenter.image = [dic objectForJSONKey:@"DefaultImage"];
    }else{
        [imgVCenter imageWithURL:[dic valueForJSONStrKey:@"url"] useProgress:YES useActivity:NO];
    }
    
    NSDictionary *dicLatter;
    if (ImageIndex+1>imageCount-1) {
        dicLatter=imageNameList[0];
    }else{
        dicLatter=imageNameList[ImageIndex+1];
    }
    if ([dicLatter objectForJSONKey:@"DefaultImage"]) {
        imgVRight.image = [dicLatter objectForJSONKey:@"DefaultImage"];
    }else{
        [imgVRight imageWithURL:[dicLatter valueForJSONStrKey:@"url"] useProgress:YES useActivity:NO];
    }
    
   
    
    _pageControl.currentPage = currentImageIndex;
}
#pragma mark UIScrollView
- (void) scrollViewWillBeginDragging: (UIScrollView*) scrollview{
    //当用户准备拖曳时停止定时器,以后重启需重新启动,不会自动启动
    [self stopAnimation];
}

- (void) scrollViewDidEndDragging: (UIScrollView*) scrollview willDecelerate:(BOOL)decelerate{
    //当用户停止拖曳时,定时器重启,自动轮播开始
    [self startAnimation];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self reloadImage];
    
    scrollviewBG.contentOffset = CGPointMake(W(scrollviewBG), 0.0);
    
    //    DLog(@"___滚动End__%ld_",(long)currentImageIndex);
}
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [self reloadImage];
    scrollviewBG.contentOffset = CGPointMake(W(scrollviewBG), 0.0);
    
    //    DLog(@"___滚动Animation__%ld_",(long)currentImageIndex);
}

#pragma autoPlay
- (void)switchFocusImageItems
{
    DLog(@"___滚动中__%ld_",(long)currentImageIndex);
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(switchFocusImageItems) object:nil];
    float fx=scrollviewBG.contentOffset.x+W(scrollviewBG);
    [scrollviewBG setContentOffset:CGPointMake(fx, 0) animated:YES] ;
    if ([imageNameList count]>1) {
        [self performSelector:@selector(switchFocusImageItems) withObject:nil afterDelay:6.0];
    }
    
}

#pragma mark notification
-(void)enterBackGroundNotication{
    //后台-停止
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(switchFocusImageItems) object:nil];
}
-(void)enterForegroundNotification{
    //前台-开启
    if (!boolStopAnimation) {
        [self startAnimation];
    }
}
#pragma mark cliked
-(void)tapImageClicked:(UITapGestureRecognizer *)tap{
    NSDictionary *dic=[imageNameList objectAtIndex:currentImageIndex];
    if ([self.delegateDiscount respondsToSelector:@selector(selectView:ad:index:)]) {
        [self.delegateDiscount selectView:self ad:dic index:currentImageIndex];
    }
}



-(void)startAnimation{
    boolStopAnimation=NO;
    [self performSelector:@selector(switchFocusImageItems) withObject:nil afterDelay:6.0];
}
-(void)stopAnimation{
    boolStopAnimation=YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(switchFocusImageItems) object:nil];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
