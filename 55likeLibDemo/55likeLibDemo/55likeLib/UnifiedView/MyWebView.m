//
//  MyWebView.m
//  ZhuiKe55like
//
//  Created by junseek on 15-4-13.
//  Copyright (c) 2015年 五五来客 李江. All rights reserved.
//

#import "MyWebView.h"
#import "EGORefreshTableHeaderView.h"
#import "MessageInterceptor.h"
#import "WebImagesViewController.h"

@interface MyWebView ()<EGORefreshTableHeaderDelegate,WKNavigationDelegate,UIScrollViewDelegate>{
    //
    EGORefreshTableHeaderView *refreshHeaderView;
    //刷新标识，是否正在刷新过程中
    BOOL reloading;
    NSString *strTempUrl;
    
    NSMutableArray *arrayImages;
    UIProgressView *progressIndicator;
    NSTimer *timeProgress;
}

@property (nonatomic, strong) NSString *strUrl;
@property (nonatomic, strong) MessageInterceptor *delegateInterceptor;
@end


@implementation MyWebView
@synthesize delegateInterceptor=_delegateInterceptor;



-(instancetype)init{
    return [self initWithFrame:[[UIScreen mainScreen] bounds]];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initComponents];
    }
    
    return self;
}

-(void)setNavigationDelegate:(id<WKNavigationDelegate>)navigationDelegate{
    if(_delegateInterceptor) {
        super.navigationDelegate = nil;
        _delegateInterceptor.receiver = navigationDelegate;
        super.navigationDelegate = (id)_delegateInterceptor;
    } else {
        super.navigationDelegate = navigationDelegate;
    }
}

- (void)initComponents
{
    arrayImages=[NSMutableArray new];
    self.backgroundColor=[UIColor whiteColor];
    _delegateInterceptor = [[MessageInterceptor alloc] init];
    _delegateInterceptor.middleMan = self;
    _delegateInterceptor.receiver = self.navigationDelegate;
    //初始化refreshView，添加到webview 的 scrollView子视图中
    if (refreshHeaderView == nil) {
        refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0-self.scrollView.bounds.size.height, self.scrollView.frame.size.width, self.scrollView.bounds.size.height)];
        refreshHeaderView.delegate = self;
        self.scrollView.delegate=self;
        [self.scrollView addSubview:refreshHeaderView];
    }
    if (!progressIndicator) {
        progressIndicator = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, W(self), 1)];
        [progressIndicator setProgressViewStyle:UIProgressViewStyleBar];
        [progressIndicator setProgressTintColor:rgbpublicColor];
        [progressIndicator setTrackTintColor:[UIColor clearColor]];
        progressIndicator.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
        [self addSubview:progressIndicator];
        progressIndicator.hidden=YES;
//        timeProgress=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(function:) userInfo:nil repeats:YES];

    }
   
    [self addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
//    [self addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];

    
    [refreshHeaderView refreshLastUpdatedDate];
}

-(void)loadMyWeb:(NSString *)url{
    strTempUrl=url;
    self.strUrl=url;
    [self refreshWeb];
}
-(void)refreshWeb{
    DLog("refreshWeb:%@",_strUrl)
    //清除UIWebView的缓存
   [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *encodedString=[self.strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:encodedString]];
        [self loadRequest:request];
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    });

}
#pragma mark controller
- (BaseViewController *)viewBaseController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[BaseViewController class]]) {
            return (BaseViewController *)nextResponder;
        }
    }
    return nil;
}
//#pragma mark -
//#pragma mark UIWebViewDelegate
//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
////    self.strUrl=[request.URL absoluteString];
//    BOOL bool_return=YES;
//    //将url转换为string
//    NSString *requestString = [[request URL] absoluteString];
//    //    NSLog(@"requestString is %@",requestString);
//    
//    //hasPrefix 判断创建的字符串内容是否以pic:字符开始
//    if ([requestString hasPrefix:@"myweb:imageClick:"]) {
//        NSString *imageUrl = [requestString substringFromIndex:@"myweb:imageClick:".length];
//        //        NSLog(@"image url------%@", imageUrl);
//        
////        if (!xhView) {
////            xhView=[[XHImageUrlViewer alloc] init];
////        }
//        NSInteger index_img=0;
//        NSMutableArray *array=[[NSMutableArray alloc] init];
//        for (int i=0 ; i<[arrayImages count];i++) {
//            NSString *strImg =[arrayImages objectAtIndex:i];
//            if ([strImg isEqualToString:imageUrl]) {
//                index_img=i;
//            }
//            NSMutableDictionary *dt=[[NSMutableDictionary alloc] init];
//            [dt setValue:strImg forKey:@"url"];
//            [array addObject:dt];
//        }
//        [[self viewBaseController] pushController:[WebImagesViewController class] withInfo:@"myWebView" withTitle:@"查看" withOther:@{
//                                                                                                                                @"lookImages":array,
//                                                                                                                                @"lookSelectIndex":[NSString stringWithFormat:@"%ld",(long)index_img]}];
//        
////        [xhView showWithImageDatas:array selectedIndex:index_img];
//        return NO;
//    }
//    if (_delegateInterceptor !=nil && [_delegateInterceptor.receiver respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
//        bool_return=[_delegateInterceptor.receiver webView:self shouldStartLoadWithRequest:request navigationType:navigationType];
//    }
//    return bool_return;
//}
//- (void)webViewDidStartLoad:(UIWebView *)webView {
//    [arrayImages removeAllObjects];
//    reloading = YES;
//    progressIndicator.hidden=NO;
//    progressIndicator.progress=0.0;
//    [progressIndicator setProgress:0.9 animated:YES];;
//    
//    if ([_delegateInterceptor.receiver respondsToSelector:@selector(webViewDidStartLoad:)]) {
//        [_delegateInterceptor.receiver webViewDidStartLoad:self];
//    }
//}
//- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    reloading = NO;
//    progressIndicator.progress=1.0;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        progressIndicator.hidden=YES;
//        progressIndicator.progress=0.0;
//    });
//   
////    //调整字号
////    NSString *str = @"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '95%'";
////    [webView stringByEvaluatingJavaScriptFromString:str];
//    
//    //js方法遍历图片添加点击事件 返回图片点击个数
//    static  NSString * const jsGetImages =
//    @"function getImages(){\
//    var image_url=\"\";\
//    var index_click=0;\
//    var objs = document.getElementsByTagName(\"img\");\
//    for(var i=0;i<objs.length;i++){\
//        if(objs[i].getAttribute(\"data-src\")){\
//            if(image_url){\
//                image_url=image_url+\"__zkwap__\"+objs[i].getAttribute(\"data-src\");\
//            }else{\
//                image_url=objs[i].getAttribute(\"data-src\");\
//            };\
//            index_click++;\
//            objs[i].onclick=function(){\
//            document.location=\"myweb:imageClick:\"+this.getAttribute(\"data-src\");;\
//        };\
//    };\
//    };\
//    return image_url;\
//    };";
//   
//    
//    [webView stringByEvaluatingJavaScriptFromString:jsGetImages];//注入js方法
//   
//    //注入自定义的js方法后别忘了调用 否则不会生效（不调用也一样生效了，，，不明白）
//    NSString *resurlt = [webView stringByEvaluatingJavaScriptFromString:@"getImages()"];
//    //调用js方法
//    DLog(@"---调用js方法--%@ jsMehtods_result = %@",self.class,resurlt);
//
//  
//    
//    [arrayImages removeAllObjects];
//    if ([resurlt notEmptyOrNull]) {
//        [arrayImages addObjectsFromArray:[resurlt componentsSeparatedByString:@"__zkwap__"]];
//    }
//    
//    
//    
//    
//    self.strUrl = [webView stringByEvaluatingJavaScriptFromString:@"document.location.href"];
//    if (refreshHeaderView) {
//        [refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.scrollView];
//    }
//    
//    if (_delegateInterceptor !=nil && [_delegateInterceptor.receiver respondsToSelector:@selector(webViewDidFinishLoad:)]) {
//        [_delegateInterceptor.receiver webViewDidFinishLoad:self];
//    }
//}
//- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
//    reloading = NO;
//    progressIndicator.hidden=YES;
//    progressIndicator.progress=0.0;
//    if (refreshHeaderView) {
//        [refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.scrollView];
//    }
//    
//    if (_delegateInterceptor !=nil && [_delegateInterceptor.receiver respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
//        [_delegateInterceptor.receiver webView:self didFailLoadWithError:error];
//    }
//}

#pragma mark -
#pragma mark WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSString *requestString = [[navigationAction.request URL] absoluteString];
    //hasPrefix 判断创建的字符串内容是否以pic:字符开始
    if ([requestString hasPrefix:@"myweb:imageClick:"]) {
        NSString *imageUrl = [requestString substringFromIndex:@"myweb:imageClick:".length];
        NSInteger index_img=0;
        NSMutableArray *array=[[NSMutableArray alloc] init];
        for (int i=0 ; i<[arrayImages count];i++) {
            NSString *strImg =[arrayImages objectAtIndex:i];
            if ([strImg isEqualToString:imageUrl]) {
                index_img=i;
            }
            NSMutableDictionary *dt=[[NSMutableDictionary alloc] init];
            [dt setValue:strImg forKey:@"url"];
            [array addObject:dt];
        }
        [[self viewBaseController] pushController:[WebImagesViewController class]
                                         withInfo:@"myWebView"
                                        withTitle:@"查看"
                                        withOther:@{@"lookImages":array,
                                                    @"lookSelectIndex":[NSString stringWithFormat:@"%ld",(long)index_img]}];
        
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if (_delegateInterceptor !=nil && [_delegateInterceptor.receiver respondsToSelector:@selector(webView:decidePolicyForNavigationAction:decisionHandler:)]) {
        [_delegateInterceptor.receiver webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    [arrayImages removeAllObjects];
    reloading = YES;
    progressIndicator.hidden=NO;
    progressIndicator.progress=0.0;
//    [progressIndicator setProgress:0.9 animated:YES];;
    
    if ([_delegateInterceptor.receiver respondsToSelector:@selector(webView:didStartProvisionalNavigation:)]) {
        [_delegateInterceptor.receiver webView:webView didStartProvisionalNavigation:navigation];
    }
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{

}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    reloading = NO;
  
    
    //    //调整字号
    //    NSString *str = @"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '95%'";
    //    [webView stringByEvaluatingJavaScriptFromString:str];
    
    //js方法遍历图片添加点击事件 返回图片点击个数
    static  NSString * const jsGetImages =
    @"function getImages(){\
        var image_url=\"\";\
        var index_click=0;\
        var objs = document.getElementsByTagName(\"img\");\
        for(var i=0;i<objs.length;i++){\
            if(objs[i].getAttribute(\"data-src\")){\
                if(image_url){\
                    image_url=image_url+\"__zkwap__\"+objs[i].getAttribute(\"data-src\");\
                }else{\
                    image_url=objs[i].getAttribute(\"data-src\");\
                };\
                index_click++;\
                objs[i].onclick=function(){\
                    document.location=\"myweb:imageClick:\"+this.getAttribute(\"data-src\");;\
                };\
            };\
        };\
        return image_url;\
    };getImages();";
    
   
    //
    /// jsStr为要执行的js代码，字符串形式
    [webView evaluateJavaScript:jsGetImages completionHandler:^(id _Nullable resurlt, NSError * _Nullable error) {
        // 执行结果回调
        DLog(@"执行结果回调:%@",resurlt);
        [arrayImages removeAllObjects];
        if ([resurlt notEmptyOrNull]) {
            [arrayImages addObjectsFromArray:[resurlt componentsSeparatedByString:@"__zkwap__"]];
        }

    }];
    
    
    
    
    self.strUrl =[webView.URL absoluteString];
    DLog(@"self.strUrl:%@",self.strUrl);
    if (refreshHeaderView) {
        [refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.scrollView];
    }
    
    if (_delegateInterceptor !=nil && [_delegateInterceptor.receiver respondsToSelector:@selector(webView:didFinishNavigation:)]) {
        [_delegateInterceptor.receiver webView:webView didFinishNavigation:navigation];
    }
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    reloading = NO;
    progressIndicator.hidden=YES;
    progressIndicator.progress=0.0;
    if (refreshHeaderView) {
        [refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.scrollView];
    }
    
    if (_delegateInterceptor !=nil && [_delegateInterceptor.receiver respondsToSelector:@selector(webView:didFailProvisionalNavigation:)]) {
        [_delegateInterceptor.receiver webView:webView didFailProvisionalNavigation:navigation];
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (refreshHeaderView) {
        [refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (refreshHeaderView) {
        [refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
    

}
#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [self performSelector:@selector(refreshWeb) withObject:nil afterDelay:.1];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
    return reloading; // should return if data source model is reloading
    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
    return [NSDate date]; // should return date data source was last changed
}

-(void)dealloc{
    [self removeObserver:self forKeyPath:@"estimatedProgress"];
//    [self removeObserver:self forKeyPath:@"title"];
    super.navigationDelegate = nil;
    _delegateInterceptor=nil;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        [progressIndicator setProgress:self.estimatedProgress animated:YES];
        if (object == self) {
            if(self.estimatedProgress >= 1.0f) {
                [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    [progressIndicator setAlpha:0.0f];
                } completion:^(BOOL finished) {
                    progressIndicator.hidden=YES;
                    [progressIndicator setProgress:0.0f animated:NO];
                }];
            }else{
                [progressIndicator setAlpha:1.0f];
            }
        }
        else
        {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
        
    }
    else if ([keyPath isEqualToString:@"title"])
    {
        if (object == self) {
            DLog(@"_title:%@",self.title);
        }
        else
        {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
            
        }
    }
    else {
        
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
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
