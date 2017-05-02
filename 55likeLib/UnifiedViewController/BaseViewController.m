
#import "BaseViewController.h"
#import <Reachability.h>
#include <objc/runtime.h>
//#import <NimbusModels.h>
//#import "MLEmojiLabel.h"

//Category实现：
@implementation UIControl (Additions)
- (void)removeAllTargets {
    for (id target in [self allTargets]) {
        [self removeTarget:target action:NULL forControlEvents:UIControlEventAllEvents];
    }
}
@end



@interface BaseViewController (){
    
    BOOL boolNavTitleAnimate;
    BOOL boolDefaultNavTitleAnimate;
//    MLEmojiLabel *emojiLabel;
    
    UILabel *titleText;
    
}
@property (nonatomic,strong) UILabel *sizeLabel;
@property (nonatomic,strong) UITextView *sizeTextView;
@property (nonatomic,strong) UIView *DefaultNavView;
//@property (nonatomic, readwrite, retain) NITableViewModel* model;
//@property (nonatomic, readwrite, retain) NITableViewActions* actions;
@end
@implementation BaseViewController

- (id)initWithNavStyle:(NSInteger)style
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    if (!_hideAudioPlayButton) {
//         SendNotify(ZKShowAudioPlayBtton, nil)
    }
   
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];

        [[UIApplication sharedApplication]setStatusBarHidden:NO];
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

    /*if (self.hideTabbar) {
     [self hideTabBar];
     }else{
     [self showTabBar];
     }*/
    
    if (boolNavTitleAnimate ) {//&& !kVersion7
        [self performSelector:@selector(startNavTitleAnimate) withObject:nil afterDelay:0.1];
    }
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
//    if (kVersion7) {
//        
        self.automaticallyAdjustsScrollViewInsets=NO;
//        self.navigationController.navigationBarHidden = NO;
        self.edgesForExtendedLayout = UIRectEdgeNone;
//        [self.navigationController.navigationBar setBarTintColor:rgbpublicColor];
//        
//        [[UINavigationBar appearance] setBackIndicatorImage:[UIImage imageNamed:@"back"]];
//        [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"back"]];
//        
//        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
//        backItem.title = @"返回";
//        self.navigationItem.backBarButtonItem = backItem;
//        
//        
//        
//        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];//23/180/235
//        [self.navigationController.view setBackgroundColor:rgbpublicColor];//
//        
//        
//        //  NSForegroundColorAttributeName,NSFontAttributeName,NSShadowAttributeName
//        
//        NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[UIColor whiteColor],[UIFont boldSystemFontOfSize:20.0f], nil] forKeys:[NSArray arrayWithObjects: UITextAttributeTextColor,UITextAttributeFont, nil]];
//        //[UIColor colorWithWhite:0.0 alpha:1]//UITextAttributeTextShadowColor
//        self.navigationController.navigationBar.titleTextAttributes = dict;
//        
//    }else{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ZKapplicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        self.navigationController.navigationBarHidden = YES;
        // self.hidesBottomBarWhenPushed=YES;
        [self.view setClipsToBounds:YES];
//    }
    
    [self.view setBackgroundColor:rgbGray];//RGBCOLOR(198, 198, 203)
    
    
    
   
}


- (UIView*)navbarTitle:(NSString*)title
{
//    if (kVersion7) {
//        self.title=title;
//        return nil;
//    }else{
    
        self.title=title;
        if(!self.navView)
        {
            self.navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 64)];
            [self.navView setBackgroundColor:[UIColor whiteColor]];//rgbpublicColor//[UIColor whiteColor]RGBCOLOR(249, 249, 249)
            //UIImageView *iamgeBG=[RHMethods imageviewWithFrame:self.navView.bounds defaultimage:@"TapNavBig070116"];
            //iamgeBG.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
            //[self.navView addSubview:iamgeBG];
            
            
            UIView *viewLine=[[UIView alloc]initWithFrame:CGRectMake(0, H(self.navView)-0.5, W(self.navView), 0.5)];
            viewLine.backgroundColor=rgbLineColor;
            viewLine.tag=104;
            [self.navView addSubview:viewLine];

//            if (title.length) {
                UIView *nV=[[UIView alloc]initWithFrame:CGRectMake(80, 20, kScreenWidth-160, 44)];
                nV.backgroundColor=[UIColor clearColor];
                nV.clipsToBounds=YES;
                nV.tag=102;
                
                CAGradientLayer* gradientMask = [CAGradientLayer layer];
                gradientMask.bounds = nV.layer.bounds;
                gradientMask.position = CGPointMake([nV bounds].size.width / 2, [nV bounds].size.height / 2);
                NSObject *transparent = (NSObject*) [[UIColor clearColor] CGColor];
                NSObject *opaque = (NSObject*) [[UIColor blackColor] CGColor];
                gradientMask.startPoint = CGPointMake(0.0, CGRectGetMidY(nV.frame));
                gradientMask.endPoint = CGPointMake(1.0, CGRectGetMidY(nV.frame));
                float fadePoint = (float)10/nV.frame.size.width;
                [gradientMask setColors: [NSArray arrayWithObjects: transparent, opaque, opaque, transparent, nil]];
                [gradientMask setLocations: [NSArray arrayWithObjects:
                                             [NSNumber numberWithFloat: 0.0],
                                             [NSNumber numberWithFloat: fadePoint],
                                             [NSNumber numberWithFloat: 1 - fadePoint],
                                             [NSNumber numberWithFloat: 1.0],
                                             nil]];
                nV.layer.mask = gradientMask;
                
                
                
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, kScreenWidth-140, 44)];
                label.backgroundColor = [UIColor clearColor];
                label.font = BoldFont(19);
                label.textColor  = [UIColor blackColor];
                label.shadowOffset = CGSizeMake(0, 0);
//                label.text = title;
                label.tag = 101;
                label.textAlignment = NSTextAlignmentCenter;
                [nV addSubview:label];
                [self.navView addSubview:nV];
//            }
            
            [self.view addSubview:self.navView];
        }
        
    
        UIView *viewTiltleBG=[self.navView viewWithTag:102];
        
        
        //    [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startNavTitleAnimate) object:nil];
        UILabel *label = (UILabel*)[self.navView viewWithTag:101];
        [label.layer removeAllAnimations];
        CGRect frame=CGRectMake(10, 0, W(viewTiltleBG)-20, 44);
        label.frame=frame;
        label.text = title;
        CGSize size = [label sizeThatFits:CGSizeMake(MAXFLOAT, 20)];
        //  float fAnimateDate=0.0;
        boolNavTitleAnimate=NO;
        if (frame.size.width<size.width) {
            
            CAGradientLayer* gradientMask = [CAGradientLayer layer];
            gradientMask.bounds = viewTiltleBG.layer.bounds;
            gradientMask.position = CGPointMake([viewTiltleBG bounds].size.width / 2, [viewTiltleBG bounds].size.height / 2);
            NSObject *transparent = (NSObject*) [[UIColor clearColor] CGColor];
            NSObject *opaque = (NSObject*) [[UIColor blackColor] CGColor];
            gradientMask.startPoint = CGPointMake(0.0, CGRectGetMidY(viewTiltleBG.frame));
            gradientMask.endPoint = CGPointMake(1.0, CGRectGetMidY(viewTiltleBG.frame));
            float fadePoint = (float)10/viewTiltleBG.frame.size.width;
            [gradientMask setColors: [NSArray arrayWithObjects: transparent, opaque, opaque, transparent, nil]];
            [gradientMask setLocations: [NSArray arrayWithObjects:
                                         [NSNumber numberWithFloat: 0.0],
                                         [NSNumber numberWithFloat: fadePoint],
                                         [NSNumber numberWithFloat: 1 - fadePoint],
                                         [NSNumber numberWithFloat: 1.0],
                                         nil]];
            viewTiltleBG.layer.mask = gradientMask;
            
            frame.size.width=size.width;
            label.frame=frame;
            
            [self performSelector:@selector(startNavTitleAnimate) withObject:nil afterDelay:5.0];
            
            
        }
        
        return self.navView;
//    }
    
}


-(void)startDefaultNavTitleAnimate{
    
    boolDefaultNavTitleAnimate=YES;
    UILabel *label = (UILabel*)[self.DefaultNavView viewWithTag:201];
    CGRect frame=label.frame;
    frame.origin.x=-frame.size.width;
    UIView *nBGv=[self.DefaultNavView viewWithTag:202];
    [UIView animateWithDuration:5.4 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        label.frame = frame;
    } completion:^(BOOL finished) {
        if (boolDefaultNavTitleAnimate) {
            [self EntertainingDiversionsAnimation:10.8 aView:label subView:nBGv];
        }
    }];
}
-(void)startNavTitleAnimate{
    
    boolNavTitleAnimate=YES;
    UILabel *label = (UILabel*)[self.navView viewWithTag:101];
    CGRect frame=label.frame;
    frame.origin.x=-frame.size.width;
    UIView *nBGv=[self.navView viewWithTag:102];
    [UIView animateWithDuration:5.4 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        label.frame = frame;
    } completion:^(BOOL finished) {
        if (boolNavTitleAnimate) {
            [self EntertainingDiversionsAnimation:10.8 aView:label subView:nBGv];
        }
    }];
}
-(void)EntertainingDiversionsAnimation:(NSTimeInterval)interval aView:(UIView *)av subView:(UIView *)sv{
    CGRect frame =av.frame;
    frame.origin.x=sv.frame.size.width;
    av.frame=frame;
    frame.origin.x=-frame.size.width;
    [UIView animateWithDuration:interval
                          delay:0.0
                        options:UIViewAnimationOptionRepeat|UIViewAnimationOptionCurveLinear
                     animations:^{
                         av.frame = frame;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}


- (UIButton*)backButton
{
    return [self backButton:self];
}
- (UIButton*)backButton:(BaseViewController*)target
{
    UIButton *button = (UIButton*)[self.navView viewWithTag:100];
    if (button) {
        return button;
    }
    button = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 100, 44)];
    [button setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    //[button setTitle:@"返回" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = Font(12);
    button.tag = 100;
    [button addTarget:target action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [target.navView addSubview:button];
    return button;
}
- (UIButton*)leftButton:(NSString*)title image:(NSString*)image sel:(SEL)sel
{
    if (!self.navleftButton) {
        self.navleftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 100, 44)];
    }
    if(image){
        [self.navleftButton setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
        [self.navrightButton setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    }
    if(title){
        [self.navleftButton setTitle:title forState:UIControlStateNormal];
        [self.navleftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.navleftButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
        
        self.navleftButton.titleLabel.font = Font(15);
    }
    self.navleftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.navleftButton removeAllTargets];
    if(sel)[self.navleftButton addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    [self.navView addSubview:self.navleftButton];
    return self.navleftButton;
}
- (UIButton*)rightButton:(NSString*)title image:(NSString*)image sel:(SEL)sel
{
    if (!self.navrightButton) {
        self.navrightButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-88,20, 88, 44)];
    }
    if(image){
        [self.navrightButton setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
        [self.navrightButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
    }
    if(title){
        [self.navrightButton setTitle:title forState:UIControlStateNormal];
        [self.navrightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        if (image) {
            [self.navrightButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
            [self.navrightButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 20)];
        }else{
            [self.navrightButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
        }
        self.navrightButton.titleLabel.font = Font(15);
        
    }
    [self.navrightButton removeAllTargets];
    self.navrightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    
    if(sel)[self.navrightButton addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    [self.navView addSubview:self.navrightButton];
    return self.navrightButton;
}

- (void)setTitle:(NSString *)title
{
    for (UIView *view in self.navView.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            ((UILabel*)view).text = title;
            break;
        }
    }
    [super setTitle:title];
}
- (NSString*)title
{
    for (UIView *view in self.navView.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            return ((UILabel*)view).text;
        }
    }
    return [super title];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [SVProgressHUD dismiss];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}
#pragma mark - Methods
- (void)hideTabBar
{
    //[self.navigationController.tabBarController performSelector:@selector(hideTabBar)];
}
- (void)showTabBar
{
    //[self.navigationController.tabBarController performSelector:@selector(showTabBar)];
}

- (BaseViewController*)pushController:(Class)controller withInfo:(id)info
{
    return [self pushController:controller withInfo:info withTitle:nil withOther:nil tabBar:YES];
}
- (BaseViewController*)pushController:(Class)controller withInfo:(id)info withTitle:(NSString*)title
{
    return [self pushController:controller withInfo:info withTitle:title withOther:nil tabBar:YES];
}
/**
 *	自动配置次级controller头部并跳转
 *  次级controller为base的基类的时候，参数生效，否则无效
 *
 *	@param	controller	次级controller
 *	@param	info	主参数
 *	@param	title	次级顶部title（次级设置优先）
 *	@param	other	附加参数
 *
 *	@return	次级controller实体
 */
- (BaseViewController*)pushController:(Class)controller withInfo:(id)info withTitle:(NSString*)title withOther:(id)other
{
    return [self pushController:controller withInfo:info withTitle:title withOther:other tabBar:YES];
    
}

/**
 *	自动配置次级controller头部并跳转
 *  次级controller为base的基类的时候，参数生效，否则无效
 *
 *	@param	controller	次级controller
 *	@param	info	主参数
 *	@param	title	次级顶部title（次级设置优先）
 *	@param	other	附加参数
 *	@param	abool	是否隐藏tabbar
 *
 *	@return	次级controller实体
 */
- (BaseViewController*)pushController:(Class)controller withInfo:(id)info withTitle:(NSString*)title withOther:(id)other tabBar:(BOOL)abool
{
    return  [self pushController:controller withInfo:info withTitle:title withOther:other tabBar:abool pushAdimated:YES];
}
/**
 *	自动配置次级controller头部并跳转
 *  次级controller为base的基类的时候，参数生效，否则无效
 *
 *	@param	controller	次级controller
 *	@param	info	主参数
 *	@param	title	次级顶部title（次级设置优先）
 *	@param	other	附加参数
 *	@param	tbool	是否隐藏tabbar
 *	@param	abool	是否有动画
 *
 *	@return	次级controller实体
 */
- (BaseViewController*)pushController:(Class)controller withInfo:(id)info withTitle:(NSString*)title withOther:(id)other tabBar:(BOOL)tbool pushAdimated:(BOOL)abool
{
    DLog(@"Base UserInfo:%@",info);
    BaseViewController *base = [[controller alloc] init];
    
    if ([(NSObject*)base respondsToSelector:@selector(setUserInfo:)]) {
        base.userInfo = info;
        base.otherInfo = other;
    }
    base.hidesBottomBarWhenPushed=tbool;
    //    if (kVersion7) {
    //        base.title=title;
    //    }
    
    [self.navigationController pushViewController:base animated:abool];
    
    
    //    if (!kVersion7) {
    
    if ([(NSObject*)base respondsToSelector:@selector(setUserInfo:)]) {
        //如果次级controller自定义了title优先展示
        [base navbarTitle:[base.title notEmptyOrNull]?base.title:title];
        if (base.navleftButton) {
            [base.navView addSubview:base.navleftButton];
        }else{
            [base backButton:base];
        }
        if (base.navrightButton) {
            [base.navView addSubview:base.navrightButton];
        }
    }
    //    }
    return base;
    
}

//不需要Base来配置头部
- (BaseViewController*)pushController:(Class)controller withOnlyInfo:(id)info
{
    DLog(@"Base UserInfo:%@",info);
    BaseViewController *base = [[controller alloc] init];
    if ([(NSObject*)base respondsToSelector:@selector(setUserInfo:)]) {
        base.userInfo = info;
    }
    [self.navigationController pushViewController:base animated:YES];
    return base;
}
- (void)lj_popController:(id)controller
{
    //Class cls = NSClassFromString(controller);
    if ([controller isKindOfClass:[UIViewController class]]) {
        [self.navigationController popToViewController:controller animated:YES];
    }else{
        DLog(@"popToController NOT FOUND.");
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)popController:(NSString*)controllerstr withSel:(SEL)sel withObj:(id)info
{
    for (id controller in self.navigationController.viewControllers) {
        if ([NSStringFromClass([controller class]) isEqualToString:controllerstr]) {
            if (sel!=nil && [(NSObject*)controller respondsToSelector:sel]) {
                [controller performSelector:sel withObject:info afterDelay:0.01];
            }
            [self lj_popController:controller];
            break;
        }
    }
}

- (void)popController:(NSString*)controller
{
    Class cls = NSClassFromString(controller);
    if ([cls isSubclassOfClass:[UIViewController class]]) {
        [self.navigationController popToViewController:(UIViewController*)cls animated:YES];
    }else{
        DLog(@"popToController NOT FOUND.");
        [self.navigationController popViewControllerAnimated:YES];
    }
}
/*
 - (void)popController:(NSString*)controllerstr withSel:(NSString*)sel withObj:(id)info
 {
 for (id controller in self.navigationController.viewControllers) {
 if ([NSStringFromClass([controller class]) isEqualToString:controller]) {
 if ([(NSObject*)controller respondsToSelector:@selector(sel)]) {
 [controller performSelector:@selector(sel) withObject:info afterDelay:0.01];
 }
 break;
 }
 }
 [self popController:controllerstr];
 }
 */
/**
 *	根据文字计算Label高度
 *
 *	@param	_width	限制宽度
 *	@param	_font	字体
 *	@param	_text	文字内容
 *
 *	@return	Label高度
 */
- (CGFloat)heightForLabel:(CGFloat)_width font:(UIFont*)_font text:(NSString*)_text
{
   return  [self heightForLabel:_width font:_font text:_text floatLine:0];
    
//    if (!self.sizeLabel) {
//        self.sizeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//        self.sizeLabel.numberOfLines = 0;
//    }
//    // self.sizeLabel.lineBreakMode = UILineBreakModeCharacterWrap;
//    self.sizeLabel.font = _font;
//    if (_text) {
//        self.sizeLabel.text = _text;
//        if (kVersion7) {
//            
//            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
//            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
//            NSDictionary *attributes = @{NSFontAttributeName:_font, NSParagraphStyleAttributeName:paragraphStyle.copy};
//            
//            CGSize labelSize = [_text boundingRectWithSize:CGSizeMake(_width, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
//            
//            
//            return labelSize.height;
//        }else{
//            return [self.sizeLabel sizeThatFits:CGSizeMake(_width, MAXFLOAT)].height;
//        }//
//    }else{
//        return 0;
//    }
}
/**
 *	根据文字计算Label高度
 *
 *	@param	_width	限制宽度
 *	@param	_font	字体
 *	@param	_text	文字内容
 *	@param	_aLine	文字内容换行行间距
 *
 *	@return	Label高度
 */
- (CGFloat)heightForLabel:(CGFloat)_width font:(UIFont*)_font text:(NSString*)_text floatLine:(CGFloat)_aLine
{
    if (!self.sizeLabel) {
        self.sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    }
    self.sizeLabel.numberOfLines = 0;
    self.sizeLabel.baselineAdjustment=UIBaselineAdjustmentAlignCenters;
    
    [self.sizeLabel setLineBreakMode:NSLineBreakByTruncatingTail|NSLineBreakByWordWrapping];
    
    self.sizeLabel.font = _font;
    if (_text) {
        self.sizeLabel.text = _text;
        if (_aLine) {
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:_text];
            NSMutableParagraphStyle *paragraphStyleT = [[NSMutableParagraphStyle alloc] init];
            [paragraphStyleT setLineSpacing:_aLine];//调整行间距
            paragraphStyleT.lineBreakMode = NSLineBreakByWordWrapping;
            [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyleT range:NSMakeRange(0, [_text length])];
            self.sizeLabel.attributedText = attributedString;
           
        }
        return [self.sizeLabel sizeThatFits:CGSizeMake(_width, MAXFLOAT)].height;

    }else{
        return 0;
    }
}

- (CGFloat)heightForTextView:(CGFloat)_width font:(UIFont*)_font text:(NSString*)_text floatLine:(CGFloat)_aLine{
    //sizeTextView
    if (!self.sizeTextView) {
        self.sizeTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        [self.view addSubview:self.sizeTextView];
        self.sizeTextView.alpha=0.0;
    }
    [self.sizeTextView setEditable:NO];
    self.sizeTextView.frame=CGRectMake(X(self.sizeTextView), Y(self.sizeTextView), _width, 20);
    self.sizeTextView.font = _font;
    if (_text) {
        self.sizeTextView.text = _text;
        if (_aLine) {
            
            
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
            paragraphStyle.lineSpacing = _aLine;
            NSDictionary *attributes = @{ NSFontAttributeName:_font, NSParagraphStyleAttributeName:paragraphStyle};
            
            
//            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:_text];
//            NSMutableParagraphStyle *paragraphStyleT = [[NSMutableParagraphStyle alloc] init];
//            [paragraphStyleT setLineSpacing:_aLine];//调整行间距
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
//            [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyleT range:NSMakeRange(0, [_text length])];
            self.sizeTextView.attributedText =[[NSAttributedString alloc]initWithString:_text attributes:attributes];// attributedString;
//            NSDictionary *attributes = @{NSFontAttributeName:_font, NSParagraphStyleAttributeName:paragraphStyleT.copy};
            if (kVersion7) {
              
                CGSize size = [_text boundingRectWithSize:CGSizeMake(_width, 0) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attributes context:nil].size;
                DLog(@"__tSize_____%f",size.height);
                return  size.height;
            }else{

                return self.sizeTextView.contentSize.height-16;

                
            }
        }
        
         return [self.sizeTextView sizeThatFits:CGSizeMake(_width, MAXFLOAT)].height;
       
    }else{
        return 0;
    }
    
    
}

///评论表情行高
- (CGFloat)heightForCommentEmojiLabelText:(NSString*)_text{
    return 0;
//    if (!emojiLabel) {
//        
//        emojiLabel = [[MLEmojiLabel alloc]init];
//        emojiLabel.numberOfLines = 0;
//        emojiLabel.font =fontTxtContent;// [UIFont systemFontOfSize:14.0f];
//        //        NSLog(@"%f",emojiLabel.font.lineHeight);
//               //        _emojiLabel.textAlignment = NSTextAlignmentCenter;
//        emojiLabel.backgroundColor = [UIColor clearColor];
//        emojiLabel.lineBreakMode = NSLineBreakByCharWrapping;
//        emojiLabel.textColor=rgbTitleDeepGray;
//        //        emojiLabel.isNeedAtAndPoundSign = YES;
//        [self.view addSubview:emojiLabel];
//        emojiLabel.disablePhone=YES;
//        emojiLabel.disableEmail=YES;
//        
//        emojiLabel.customEmojiRegex = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
//        emojiLabel.customEmojiPlistName = @"expressionImage_custom.plist";
//        emojiLabel.hidden=YES;
//    }
//    [emojiLabel setEmojiText:_text];
//    emojiLabel.frame = CGRectMake(10,60, kScreenWidth-20, 20);
//    [emojiLabel sizeToFit];    
//    
//    return H(emojiLabel);
}

#pragma mark - Actions
- (IBAction)backByButtonTagNavClicked:(UIButton*)sender
{
    NSArray *controllers = [(UITabBarController*)[(UIWindow*)[[UIApplication sharedApplication] windows][0] rootViewController] viewControllers];
    if (controllers.count>sender.tag) {
        [controllers[sender.tag] popViewControllerAnimated:YES];
    }else{
        DLog(@"Nav Not Found.");
    }
}
- (IBAction)backButtonClicked:(id)sender
{
    [SVProgressHUD dismiss];
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
- (IBAction)rootButtonClicked:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark -Notify
-(void) reachabilityChanged:(NSNotification*) notification
{
    if ([(Reachability*)[notification object] currentReachabilityStatus] == ReachableViaWiFi) {
        NSLog(@"baseview  net changes.");
        //do some refresh
    }
}
-(void) ZKapplicationWillEnterForeground:(NSNotification*) notification
{
    if (boolNavTitleAnimate ) {
        [self performSelector:@selector(startNavTitleAnimate) withObject:nil afterDelay:0.1];
    }

}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - public

/*
 - (void)UITableViewModel:(Block)block
 {
 [self setDelegates];
 _model = [[NITableViewModel alloc] initWithListArray:block(_actions,nil)
 delegate:(id)[NICellFactory class]];
 self.tableView.dataSource = _model;
 }
 - (void)RHTableViewUrl:(NSString*)url withModel:(Block)block
 {
 [self setDelegates];
 self.tableView.dataSource = nil;
 [self RHTableViewWithRefresh:YES withLoadmore:YES withMask:SVProgressHUDMaskTypeClear Url:url withParam:nil data:nil offline:nil loaded:^(NSArray *array, BOOL cache) {
 _model = [[NITableViewModel alloc] initWithListArray:block(_actions,array)
 delegate:(id)[NICellFactory class]];
 self.tableView.dataSource = _model;
 }];
 }
 - (void)RHTableViewBlock:(RHTableDataBlock)datablock withModel:(Block)block
 {
 [self setDelegates];
 self.tableView.dataSource = nil;
 [self RHTableViewWithRefresh:YES withLoadmore:YES withMask:SVProgressHUDMaskTypeClear Url:nil withParam:nil data:datablock offline:nil loaded:^(NSArray *array, BOOL cache) {
 _model = [[NITableViewModel alloc] initWithListArray:block(_actions,array)
 delegate:(id)[NICellFactory class]];
 self.tableView.dataSource = _model;
 }];
 }*/





//是否支持屏幕旋转
-(BOOL)shouldAutorotate
{
    return NO;
}

// 支持的旋转方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;//UIInterfaceOrientationMaskAllButUpsideDown;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    
    return UIInterfaceOrientationPortrait;
}


@end
