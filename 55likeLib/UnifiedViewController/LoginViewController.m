//
//  LoginViewController.m
//  XinKaiFa55like
//
//  Created by junseek on 2017/1/16.
//  Copyright © 2017年 55like lj. All rights reserved.
//

#import "LoginViewController.h"
#import "BackPasswordViewController.h"
#import "SelectWebUrlViewController.h"

@interface LoginViewController ()<UITextFieldDelegate>{
    UIView *viewBG;
    UITextField *txtAccount;
    UITextField *txtPwd;
    
    UIButton *subBtn;
    float viewH;
    
    BOOL boolLogin;
    UIImageView *imageLogo;
}

@end

@implementation LoginViewController


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //注册监听键盘事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    txtAccount.text=[[Utility Share] userAccount];
    txtPwd.text=[[Utility Share] userPwd];
     [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//      
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//            
//        });
//    });
    
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initComponents];
}



- (void)initComponents{
    float fh=300/640.0*kScreenWidth;
//    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:[RHMethods imageviewWithFrame:self.view.bounds defaultimage:@"loginBG"]];
    if (kScreenHeight>600) {
        viewH =550.0;
    }else{
        viewH =480.0;
    }
    //    viewH =480.0 * kScreenWidth / 320.0;
    viewBG=[[UIView alloc]initWithFrame:CGRectMake(0, (kScreenHeight-viewH)/2.0, kScreenWidth, viewH)];//
    viewBG.backgroundColor=[UIColor clearColor];
    [self.view addSubview:viewBG];
    
    UIControl *closeC=[[UIControl alloc]initWithFrame:viewBG.bounds];
    [closeC addTarget:self action:@selector(closeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [viewBG addSubview:closeC];
    
    float ftw=100.0 * kScreenWidth/320.0;
    
    UIImageView *imageAcountBG;
    UIImageView *imagePwdBG;
    imageLogo=[RHMethods imageviewWithFrame:CGRectMake((W(viewBG)-ftw)/2.0, 40, ftw, ftw) defaultimage:@"Loginlogo" contentMode:UIViewContentModeScaleAspectFit];
    [viewBG addSubview:imageLogo];
    
    float fy=viewH-300;
    if (viewH==480) {
        fy=viewH-310;
    }else if(kScreenHeight>570){
        CGRect  viewFramw = [imageLogo convertRect:imageLogo.frame toView:self.view ];
        float fTemp=viewFramw.origin.y+viewFramw.size.height;
//        160
        float f_jg= H(self.view)-fh-fTemp-140;
        fy=YH(imageLogo)+f_jg/2;
    }
    imageAcountBG=[RHMethods imageviewWithFrame:CGRectMake(35,fy, 20, 40) defaultimage:@"LoginTel" contentMode:UIViewContentModeScaleAspectFit];
    [viewBG addSubview:imageAcountBG];   
    
    txtAccount=[RHMethods textFieldlWithFrame:CGRectMake(X(imageAcountBG)+30, Y(imageAcountBG), kScreenWidth-100, 40) font:Font(15) color:RGBACOLOR(50, 50, 50, 1) placeholder:@"请输入手机号" text:@""];
    txtAccount.delegate=self;
//    [txtAccount setKeyboardType:UIKeyboardTypePhonePad];
    [viewBG addSubview:txtAccount];
    
    UIView *lineV = [RHMethods lineViewWithFrame:CGRectMake(35, YH(imageAcountBG), kScreenWidth-70, 0.5) supView:viewBG];
    lineV.backgroundColor=RGBACOLOR(255, 255, 255, 0.5);
    
    imagePwdBG=[RHMethods imageviewWithFrame:CGRectMake(35,YH(imageAcountBG)+10, 20, 40) defaultimage:@"LoginPwd" contentMode:UIViewContentModeScaleAspectFit];
    [viewBG addSubview:imagePwdBG];
    lineV=[RHMethods lineViewWithFrame:CGRectMake(35, YH(imagePwdBG), kScreenWidth-70, 0.5) supView:viewBG];
    lineV.backgroundColor=RGBACOLOR(255, 255, 255, 0.5);
    
    txtPwd=[RHMethods textFieldlWithFrame:CGRectMake(X(imagePwdBG)+30, Y(imagePwdBG), W(txtAccount), 40) font:Font(15) color:RGBACOLOR(50, 50, 50, 1) placeholder:@"请输入密码" text:@""];
    txtPwd.delegate=self;
    [txtPwd setSecureTextEntry:YES];
    [viewBG addSubview:txtPwd];
    
    
    subBtn=[RHMethods buttonWithFrame:CGRectMake(X(imageAcountBG),viewH==480? YH(imagePwdBG)+15: YH(imagePwdBG)+25, kScreenWidth-70, 40) title:@"登录" image:@"" bgimage:@"loginSub"];
    subBtn.titleLabel.font=Font(20);
    [subBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [subBtn addTarget:self action:@selector(submintButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [viewBG addSubview:subBtn];
    
    txtPwd.textColor=[UIColor whiteColor];
    txtAccount.textColor=[UIColor whiteColor];
    
    NSString *holderText = @"请输入手机号";
    NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc]initWithString:holderText];
    [placeholder addAttribute:NSForegroundColorAttributeName
                       value:RGBACOLOR(255, 255, 255, 0.5)
                       range:NSMakeRange(0, holderText.length)];
    [placeholder addAttribute:NSFontAttributeName
                       value:[UIFont boldSystemFontOfSize:15]
                       range:NSMakeRange(0, holderText.length)];
    txtAccount.attributedPlaceholder = placeholder;
    
    NSString *holderPwd = @"请输入密码";
    NSMutableAttributedString *placeholderPwd = [[NSMutableAttributedString alloc]initWithString:holderPwd];
    [placeholderPwd addAttribute:NSForegroundColorAttributeName
                        value:RGBACOLOR(255, 255, 255, 0.5)
                        range:NSMakeRange(0, holderPwd.length)];
    [placeholderPwd addAttribute:NSFontAttributeName
                        value:[UIFont boldSystemFontOfSize:15]
                        range:NSMakeRange(0, holderPwd.length)];
    txtPwd.attributedPlaceholder = placeholderPwd;
    
    
    UIButton *backPwd=[RHMethods buttonWithFrame:CGRectMake(XW(subBtn)-100, YH(subBtn)+5, 100, 30) title:@"忘记密码？" image:nil bgimage:nil];
    backPwd.titleLabel.font=fontTxtContent;
    [backPwd setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [backPwd addTarget:self action:@selector(backPwdButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [backPwd setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [viewBG addSubview:backPwd];
    
    
    [[Utility Share] setIsUserLogin:NO];
    
    
    boolLogin=NO;
    
    UIButton *backXY=[RHMethods buttonWithFrame:CGRectMake(0, kScreenHeight-50, kScreenWidth, 30) title:@"使用Hair Salon APP即表示同意手艺人用户协议" image:nil bgimage:nil];
    backXY.titleLabel.font=fontSmallTitle;
    [backXY addTarget:self action:@selector(xyButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [backXY setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:backXY];
    
   
}

#pragma mark button
-(void)backPwdButtonClicked{
    [self pushController:[BackPasswordViewController class] withInfo:@"" withTitle:@"找回密码"];
}
-(void)xyButtonClicked{
    
    [self pushController:[SelectWebUrlViewController class] withInfo:@"" withTitle:@"用户协议" withOther:@{@"url":[NSString stringWithFormat:@"%@wappage/page_detail?source=app&type=serviceagreement",baseWebPath]}];
}
-(void)submintButtonClicked{
    boolLogin=YES;  
    [self closeButtonClicked];
    
    NSString *strAc=txtAccount.text;
    NSString *strPwd=txtPwd.text;
    
    [[Utility Share] isLoginAccount:strAc pwd:strPwd code:nil aLogin:^(NSInteger NoLogin) {
        if (NoLogin==1) {
            
            
        }
        
    }];
//
    
}
-(void)closeButtonClicked{
    [txtAccount resignFirstResponder];
    [txtPwd resignFirstResponder];
    
}

#pragma mark text
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField==txtAccount) {
        [txtPwd becomeFirstResponder];
    }else{
        [self submintButtonClicked];
    }
    return YES;
}


#pragma mark serlector
-(void)handleKeyboardDidShow:(NSNotification *)notification{
    
    NSDictionary *info = [notification userInfo];
    CGRect keyboardFrame;
    [[info objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
    CGFloat distanceToMove = kbSize.height;
    NSLog(@"---->动态键盘高度:%f",distanceToMove);
    if (distanceToMove<20) {
        return;
    }
    float t_y=(Y(viewBG)+distanceToMove +YH(subBtn)+10)-kScreenHeight;
    
    NSLog(@"---->动态键盘高度:%f:::::<%f",distanceToMove,t_y);
    
    [UIView animateWithDuration:0.3 animations:^{
        viewBG.frame=CGRectMake(X(viewBG), Y(viewBG) - t_y, W(viewBG),H(viewBG));
        
    }];
}
- (void)handleKeyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        viewBG.frame=CGRectMake(X(viewBG), (kScreenHeight-viewH)/2.0, W(viewBG),H(viewBG));
        
        
    }];
}//


-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

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




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
