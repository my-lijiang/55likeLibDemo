//
//  StartTransitionView.m
//  HanYu55like
//
//  Created by junseek on 15-5-20.
//  Copyright (c) 2015年 五五来客 lj. All rights reserved.
//

#import "StartTransitionView.h"
#import "SelectWebUrlViewController.h"
#import "YLImageView.h"
#import "YLGIFImage.h"

@interface StartTransitionView()<UIScrollViewDelegate>{
    
    UIScrollView *bgView;
    BOOL hidden_self;
    NSArray *arrayImage;
    YLImageView *imageTempV;
    BOOL is_hidden;
    UIPageControl *pagecontroller;
    UILabel *lblsecond;
}

@end


@implementation StartTransitionView
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];//
        
        
        [self loadHeadData];
    }
    return self;
    
}


-(void)loadHeadData{
   
    bgView=[[UIScrollView alloc]initWithFrame:CGRectMake(0,kVersion7? 0:20, kScreenWidth, kVersion7?kScreenHeight:kScreenHeight-20)];
    [bgView setShowsHorizontalScrollIndicator:NO];
    [bgView setBackgroundColor:[UIColor clearColor]];
    [bgView setPagingEnabled:YES];
    [bgView setDelegate:self];
    [self addSubview:bgView];
    arrayImage=@[@"guide01",@"guide02",@"guide03"];
    
    for (int i=0; i<[arrayImage count]; i++) {
        UIImageView *imageV=[RHMethods imageviewWithFrame:CGRectMake(i*W(bgView), 0, W(bgView), H(bgView)) defaultimage:[arrayImage objectAtIndex:i]];
        imageV.contentMode=UIViewContentModeScaleAspectFill;
        imageV.clipsToBounds=YES;
        [bgView addSubview:imageV];
        
        if (i==[arrayImage count]-1) {
            UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenGuide)];
            [imageV setUserInteractionEnabled:YES];
            [imageV addGestureRecognizer:tap];
        }
    }
    bgView.hidden=YES;
    
    pagecontroller = [[UIPageControl alloc]initWithFrame:CGRectMake(0, YH(bgView) - 30, W(bgView), 20)];//(H(bgView)>500?30:20)
    pagecontroller.currentPageIndicatorTintColor =rgbpublicColor;
    pagecontroller.pageIndicatorTintColor =  RGBACOLOR(23, 180,  235, 0.3);
    pagecontroller.currentPage = 0;
    pagecontroller.numberOfPages = arrayImage.count;
    [self addSubview:pagecontroller];
    pagecontroller.hidden=YES;
    
    
    imageTempV=[[YLImageView alloc] initWithFrame:bgView.frame];//[RHMethods imageviewWithFrame:bgView.frame defaultimage:@"Start0117" contentMode:UIViewContentModeScaleAspectFill];
    imageTempV.image=[UIImage imageNamed:@"Start0117"];
    imageTempV.contentMode=UIViewContentModeScaleAspectFill;
    [self addSubview:imageTempV];
    imageTempV.backgroundColor=[UIColor whiteColor];
    imageTempV.hidden=YES;
    //imageFilePath
    NSDictionary *dic=[Utility defaultsForKey:default_APPStartPageAD];
    if ([[dic valueForJSONStrKey:@"imageFile"] notEmptyOrNull]) {
        NSString *strFile=[[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"adImage55like"]stringByAppendingPathComponent:[dic valueForJSONStrKey:@"imageFile"]];
        imageTempV.image=[YLGIFImage imageWithContentsOfFile:strFile];//[UIImage imageWithContentsOfFile:strFile];
    }
    if ([[dic valueForJSONStrKey:@"url"] notEmptyOrNull]) {
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(APPStartPageADClicked)];
        [imageTempV setUserInteractionEnabled:YES];
        [imageTempV addGestureRecognizer:tap];
    }
    

    
}
-(void)Countdown:(NSString *)atime{
    NSInteger second=[atime integerValue];
    DLog(@"广告倒计时：%@",atime);
    if (second>1) {
        second--;
        lblsecond.text=[NSString stringWithFormat:@" 跳过广告 %ld ",(long)second];
        [self performSelector:@selector(Countdown:) withObject:[NSString stringWithFormat:@"%ld",(long)second] afterDelay:1];
    }else{
        _isStopCountdown=YES;
        [self hidden];
    }
    
}
-(void)APPStartPageADClicked{
    ///开器本功能必须测试
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    UINavigationController *curNav = [[[[Utility Share] CustomTabBar_zk] viewControllers] objectAtIndex:0];
    [curNav popToRootViewControllerAnimated:NO];
    BaseViewController *baseV=curNav.viewControllers.firstObject;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{  NSDictionary *dic=[Utility defaultsForKey:default_APPStartPageAD];        
        [baseV pushController:[SelectWebUrlViewController class] withInfo:@"" withTitle:@" " withOther:@{@"url":[dic valueForJSONStrKey:@"url"]} tabBar:YES pushAdimated:NO];
        [self hiddenGuide];
    });
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
     float fx=scrollView.contentOffset.x;
    if (fx>([arrayImage count] -1)*kScreenWidth+50) {
        if (is_hidden) {
            is_hidden=NO;
            [self hiddenGuide];
        }
    }
    float ftw= W(scrollView);
    pagecontroller.currentPage=(fx +ftw/2.0)/ftw;
    
}
///引导页
-(void)showGuide{
    _isStopCountdown=YES;
    _isStopDataInteraction=YES;
    
    imageTempV.hidden=YES;
    pagecontroller.hidden=YES;
    bgView.hidden=NO;
    hidden_self=NO;
    is_hidden=YES;
    
    [bgView setContentSize:CGSizeMake(W(bgView) * [arrayImage count], H(bgView))];
    
    [[[UIApplication sharedApplication].windows objectAtIndex:0] addSubview:self];
    
    self.hidden = NO;
    self.alpha = 1.0f;
    
}

-(void)hiddenGuide{
    [UIView animateWithDuration:0.4 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.hidden=YES;
    }];
}

- (void)show
{
    _isStopCountdown=NO;
    _isStopDataInteraction=NO;
    is_hidden=NO;
    hidden_self=YES;
    imageTempV.hidden=NO;
    
    NSDictionary *dic=[Utility defaultsForKey:default_APPStartPageAD];
    
    if ([[Utility Share] isPureFloat:[dic valueForJSONStrKey:@"second"]]) {
        lblsecond=[RHMethods labelWithFrame:CGRectMake(kScreenWidth-65, 25, 55, 16) font:Font(12) color:[UIColor whiteColor] text:[NSString stringWithFormat:@" 跳过广告 %@ ",[dic valueForJSONStrKey:@"second"]] textAlignment:NSTextAlignmentCenter supView:self];
        lblsecond.adjustsFontSizeToFitWidth=YES;
        lblsecond.backgroundColor=RGBACOLOR(0, 0, 0, 0.3);
        [lblsecond viewLayerRoundBorderWidth:1 cornerRadius:4 borderColor:[UIColor clearColor]];
        [self performSelector:@selector(Countdown:) withObject:[dic valueForJSONStrKey:@"second"] afterDelay:1];
        UIButton *btnHidden=[RHMethods buttonWithFrame:CGRectMake(kScreenWidth-100, 0, 100, 64) title:nil image:nil bgimage:nil supView:self];
        [btnHidden addTarget:self action:@selector(hiddenButtonClicekd) forControlEvents:UIControlEventTouchUpInside];
    }else{
        _isStopCountdown=YES;
    }

    
    
    
    pagecontroller.hidden=YES;
    bgView.hidden=YES;
//    [bgView setContentSize:CGSizeMake(W(bgView) * arrayImage.count, H(bgView))];
    
    [[[UIApplication sharedApplication].windows objectAtIndex:0] addSubview:self];
    
    self.hidden = NO;
    self.alpha = 1.0f;
    
    
}
-(void)hiddenButtonClicekd{
    _isStopCountdown=YES;
     [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self hidden];
}
- (void)hidden
{
    if (hidden_self && _isStopCountdown && _isStopDataInteraction) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [UIView animateWithDuration:0.4 animations:^{
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.hidden=YES;
        }];

    }
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
