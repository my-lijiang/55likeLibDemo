//
//  SelectWebUrlViewController.m
//  ZhuiKe55like
//
//  Created by junseek on 15-4-13.
//  Copyright (c) 2015年 五五来客 李江. All rights reserved.
//

#import "SelectWebUrlViewController.h"
#import "MyWebView.h"

@interface SelectWebUrlViewController ()<WKNavigationDelegate>{
    MyWebView *WebView;
    NSString *strTempUrl;
    UIBarButtonItem *LeftItem1;
    UIButton *btnBack;
    NSArray *arrayType;
    
    NSString *strTitle;
    NSString *strDescription;
    NSString *strImageUrl;
 
    BOOL boolBack;
    
    BOOL boolRefresh;
}


@end

@implementation SelectWebUrlViewController

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initComponents];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myWebView_nil:) name:@"myWebView_nil" object:nil];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (boolRefresh) {
        boolRefresh=NO;
        [WebView refreshWeb];
    }
    [SVProgressHUD dismiss];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    [SVProgressHUD dismiss];
}

#pragma mark push_NSNotification
-(void)myWebView_nil:(NSNotification *)note{
    [WebView removeFromSuperview];
    WebView=nil;
}


- (void)initComponents{
    strTempUrl=@"";
    if (!kVersion7) {
        [self navbarTitle:@""];
        [self backButton];
    }
    
    btnBack=[RHMethods buttonWithFrame:CGRectMake(44, 20, 50,44 ) title:@"关闭" image:@"" bgimage:@""];
    [btnBack setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnBack setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [btnBack addTarget:self action:@selector(LeftButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    btnBack.titleLabel.font=Font(17);
    btnBack.hidden=YES;
    [self.navView addSubview:btnBack];
    
    
    
    
    WebView = [[MyWebView alloc] initWithFrame:CGRectMake(0, kTopHeight, kScreenWidth,kContentHeight)];
    WebView.navigationDelegate=self;
    [self.view addSubview:WebView];
//    WebView.scalesPageToFit=YES;
    [WebView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    
   strTempUrl=[self.otherInfo valueForJSONStrKey:@"url"];
    if (strTempUrl.length>4) {
        strTempUrl= [[[strTempUrl lowercaseString] substringToIndex:4] isEqualToString:@"http"]?strTempUrl:[NSString stringWithFormat:@"http://%@",strTempUrl];
    }
    
    [WebView loadMyWeb:strTempUrl];
   
    if ([self.userInfo isEqualToString:@"userProject"] ||
        [self.userInfo isEqualToString:@"userDownload"]) {
        [self rightButton:nil image:@"headfx" sel:@selector(shareBUttonClicked)];
    }
    
}
#pragma mark button
-(void)shareBUttonClicked{
    //分享
}
-(void)backButtonClicked:(id)sender{
//    [SVProgressHUD dismiss];
    if (WebView.canGoBack){
        //返回上一个网页
        [WebView goBack];
    }else{
        if (!boolBack) {
            boolBack=YES;
            [super backButtonClicked:nil];
        }
    }
}
-(void)LeftButtonClicked{
    if (!boolBack) {
        boolBack=YES;
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
//分离URL参数
-(NSMutableDictionary *)dicSeparatedUrl:(NSString *)strurl{
    //获取问号的位置，问号后是参数列表
    NSRange range = [strurl rangeOfString:@"?"];
    NSLog(@"参数列表开始的位置：%d", (int)range.location);
    
    //获取参数列表
    NSString *propertys = [strurl substringFromIndex:(int)(range.location+1)];
    NSLog(@"截取的参数列表：%@", propertys);
    
    //进行字符串的拆分，通过&来拆分，把每个参数分开
    NSArray *subArray = [propertys componentsSeparatedByString:@"&"];
    NSLog(@"把每个参数列表进行拆分，返回为数组：n%@", subArray);
    
    //把subArray转换为字典
    //tempDic中存放一个URL中转换的键值对
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithCapacity:4];
    
    for (int j = 0 ; j < subArray.count; j++)
    {
        if ([subArray[j] notEmptyOrNull]) {
            //在通过=拆分键和值
            NSArray *dicArray = [subArray[j] componentsSeparatedByString:@"="];
            if ([dicArray count]>1) {
                //给字典加入元素
                [tempDic setObject:dicArray[1] forKey:dicArray[0]];
            }else if([dicArray count]){
                [tempDic setObject:@"" forKey:dicArray[0]];
            }
        }
    }
    NSLog(@"打印参数列表生成的字典：n%@", tempDic);
    
    return tempDic;
}

#pragma mark -
#pragma mark WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    strTempUrl= [navigationAction.request.URL absoluteString];
    //hasPrefix 判断创建的字符串内容是否以pic:字符开始
//    if ( [strTempUrl rangeOfString:@"&action=userCard"].length>0 && ![self.userInfo isEqualToString:@"shareCard"]) {
//        //牌照详情-查看个人名片
//        NSDictionary *dicUser = [self dicSeparatedUrl:[strTempUrl stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//        NSMutableDictionary *dicCard=[NSMutableDictionary new];
//        [dicCard setValue:strTempUrl forKey:@"url"];
//        [dicCard setValue:[dicUser valueForJSONStrKey:@"id"] forKey:@"uid"];
//        [dicCard setValue:NSStringFromClass([self class]) forKey:@"controller"];
//        [self pushController:[SelectWebUrlViewController class] withInfo:@"shareCard" withTitle:@" " withOther:dicCard];
//        decisionHandler(WKNavigationActionPolicyCancel);
//        return;
//    }
   
    decisionHandler(WKNavigationActionPolicyAllow);
}

// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
   
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    if (WebView.canGoBack) {
        self.backButton.frameWidth=44;
        btnBack.hidden=NO;
        UIView *viewTemp=[self.navView viewWithTag:102];
        viewTemp.frame=CGRectMake(80, Y(viewTemp), kScreenWidth-160, H(viewTemp));
        
    }else{
        self.backButton.frameWidth=60;
        UIView *viewTemp=[self.navView viewWithTag:102];
        btnBack.hidden=YES;
        viewTemp.frame=CGRectMake(60, Y(viewTemp), kScreenWidth-120, H(viewTemp));
    }
    strTitle=webView.title;
    if ([strTitle notEmptyOrNull]) {
        [self navbarTitle:strTitle];
    }

}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    [SVProgressHUD showImage:nil status:@"加载失败,下拉可以刷新界面"];
}
//#pragma markUIWebViewDelegate
//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
//    strTempUrl= [request.URL absoluteString];
//    DLog(@"request.URL:%@",strTempUrl);
//    return YES;
//}
//- (void)webViewDidStartLoad:(UIWebView *)webView
//{
////    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeNone];
//}
//- (void)webViewDidFinishLoad:(UIWebView *)webView
//{
//    if (WebView.canGoBack) {
//        self.backButton.frameWidth=44;
//        btnBack.hidden=NO;
//        UIView *viewTemp=[self.navView viewWithTag:102];
//        viewTemp.frame=CGRectMake(80, Y(viewTemp), kScreenWidth-160, H(viewTemp));
//        
//    }else{
//        self.backButton.frameWidth=60;
//        UIView *viewTemp=[self.navView viewWithTag:102];
//        btnBack.hidden=YES;
//        viewTemp.frame=CGRectMake(60, Y(viewTemp), kScreenWidth-120, H(viewTemp));
//    }
//
////    strDescription = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByName(\"description\")[0].content"];
////    DLog(@"strDescription______:%@",strDescription);
////    strImageUrl= [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByName(\"picture\")[0].content"];
////    DLog(@"strImageUrl______:%@",strImageUrl);
////    
////    NSString *currentURL = [webView stringByEvaluatingJavaScriptFromString:@"document.location.href"];
////    DLog(@"currentURL:%@",currentURL);
////    strTempUrl=currentURL;
////    
////    
////    NSString *elementsByName = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByName('share')[0].value"];
////    DLog(@"ElementsByName:%@",elementsByName);
////   
//    
//    strTitle=[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
//    if ([strTitle notEmptyOrNull]) {
//        [self navbarTitle:strTitle];
//    }    
//
////    [SVProgressHUD dismiss];
//}
//-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
////    [SVProgressHUD showImage:nil status:@"加载失败,下拉可以刷新界面"];
//    DLog(@"error:%@",error);
//}
#pragma mark pop
-(void)popRefreshData{
    boolRefresh=YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
