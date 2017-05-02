//
//  BackPasswordViewController.m
//  ZhuiKe55like
//
//  Created by junseek on 15-4-10.
//  Copyright (c) 2015年 五五来客 李江. All rights reserved.
//

#import "BackPasswordViewController.h"
#import "NetEngine.h"
#import "KKNavigationController.h"
#import "MoreBlankTableViewHeaderFooterView.h"
//#import "SelectWebUrlViewController.h"

@interface BackPasswordViewController ()<UITextFieldDelegate,UIAlertViewDelegate>{
    NSMutableArray *dataArrray;
    UITextField *txtTel;
    UITextField *txtYZM;
    UIButton *btnYZM;
    UITextField *txtNewPwd;
    UITextField *txtNewPwd2;
    UIButton *btnSelect;
    
    
    BOOL boolBack;
    
    BOOL boolCode;
}

@property (nonatomic, strong) UITableView *tableView;



@end

@implementation BackPasswordViewController

@synthesize tableView = _tableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBarHidden = YES;
    boolCode=NO;
    [self initComponents];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
   
        
    KKNavigationController *kNav=(KKNavigationController *)self.navigationController;
    kNav.canDragBack=NO;
    
    //注册监听键盘事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
   
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
   
        
    KKNavigationController *kNav=(KKNavigationController *)self.navigationController;
    kNav.canDragBack=YES;
    

}


- (void)initComponents{
    [self.view setBackgroundColor:rgbGray];
    
        
    
    dataArrray =[[NSMutableArray alloc] initWithObjects:@"手机号",@"验证码",@"新密码",@"确认密码",@"", nil];
    // indexType=0;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kVersion7?64:44, kScreenWidth,kContentHeight)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView setBackgroundColor:rgbGray];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:_tableView];
    [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];//08-09修改-热点、电话 页面调整
    [_tableView registerClass:[MoreBlankTableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"MoreBlankTableViewHeaderFooterView"];
    
}
#pragma mark selector
-(void)handleKeyboardDidShow:(NSNotification *)notification{
    NSDictionary *info = [notification userInfo];
    CGRect keyboardFrame;
    [[info objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
    CGFloat distanceToMove = kbSize.height;
    NSLog(@"---->动态键盘高度:%f",distanceToMove);
    
    [UIView animateWithDuration:0.3 animations:^{
        _tableView.frame=CGRectMake(X(_tableView), Y(_tableView), W(_tableView),self.view.frame.size.height- Y(_tableView)-distanceToMove);
        
        
    }];
}
- (void)handleKeyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{        
        _tableView.frame=CGRectMake(0, Y(_tableView), kScreenWidth,kContentHeight);
        
        
    }];
}//

#pragma mark UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    if (textField==txtNewPwd2) {
        [self submintButtonClicked];
    }
    
    return YES;
}

#pragma mark tableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
            
            return 1;
        }
        case 1:
        {
            return 1;
        }
        case 2:
        {
            return 2;
        }case 3:
        {
            return 1;
        }
        default:
            break;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            return 44;
        }
        case 1:
        {
            return 44;
        }
        case 2:
        {
            return 44;
        }case 3:
        {
            return [self.userInfo isEqualToString:@"register"]?89:120;
        }
        default:
            break;
    }
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            //手机号
            NSString *str= [dataArrray objectAtIndex:indexPath.section];
            
            // DLog(@"_____%@",dic);
            NSString *identifier = str.description.md5;
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
                cell.backgroundColor=[UIColor clearColor];
                
                UIView *BGV=[[UIView alloc]initWithFrame:cell.bounds];
                [BGV setBackgroundColor:RGBCOLOR(255, 255, 255)];
                [cell setBackgroundView: BGV];
                
                
                
                UILabel *lblName=[RHMethods labelWithFrame:CGRectMake(10, 12, 0, 20) font:Font(16) color:rgbTxtGray text:str];
                [cell addSubview:lblName];
                
                txtTel=[RHMethods textFieldlWithFrame:CGRectMake(XW(lblName), 0, kScreenWidth-10-(XW(lblName)), 44) font:fontTitle color:rgbTitleColor placeholder:@"请输入" text:@""];
                [cell addSubview:txtTel];
                [txtTel setTextAlignment:NSTextAlignmentRight];
                [txtTel setDelegate:self];
                
                
                [RHMethods lineViewWithFrame:CGRectMake(0, 43.5, kScreenWidth, 0.5) supView:cell];
                
                
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                
                
            }
            
            return cell;
        }
        case 1:
        {
            //验证码
            NSString *str= [dataArrray objectAtIndex:indexPath.section];
            
            // DLog(@"_____%@",dic);
            NSString *identifier = str.description.md5;
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
                cell.backgroundColor=[UIColor clearColor];
                
                UIView *BGV=[[UIView alloc]initWithFrame:cell.bounds];
                [BGV setBackgroundColor:RGBCOLOR(255, 255, 255)];
                [cell setBackgroundView: BGV];
                
                
                
                UILabel *lblName=[RHMethods labelWithFrame:CGRectMake(10, 12, 0, 20) font:Font(16) color:rgbTxtGray text:str];
                [cell addSubview:lblName];
                
                txtYZM=[RHMethods textFieldlWithFrame:CGRectMake(XW(lblName), 0, kScreenWidth-80-(XW(lblName)), 44) font:fontTitle color:rgbTitleColor placeholder:@"请输入" text:@""];
                [txtYZM setTextAlignment:NSTextAlignmentRight];
                [cell addSubview:txtYZM];
                [txtYZM setDelegate:self];
                
                
                btnYZM=[RHMethods buttonWithFrame:CGRectMake(kScreenWidth-70, 7, 60, 30) title:@"发送" image:@"" bgimage:@""];
                btnYZM.layer.masksToBounds = YES;
                btnYZM.layer.cornerRadius =3.0;
                btnYZM.layer.borderWidth=0.5;
                btnYZM.layer.borderColor =[[UIColor clearColor] CGColor];
                [btnYZM setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [btnYZM setBackgroundColor:rgbpublicColor];
                [btnYZM addTarget:self action:@selector(YZMButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:btnYZM];
                
                [RHMethods lineViewWithFrame:CGRectMake(0, 43.5, kScreenWidth, 0.5) supView:cell];
                
                
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                
                
            }
            
            return cell;
        }
        case 2:
        {
            //新密码、确认密码
            NSString *str= [dataArrray objectAtIndex:(indexPath.row + indexPath.section)];
            
            // DLog(@"_____%@",dic);
            NSString *identifier = str.description.md5;
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
                cell.backgroundColor=[UIColor clearColor];
                
                UIView *BGV=[[UIView alloc]initWithFrame:cell.bounds];
                [BGV setBackgroundColor:RGBCOLOR(255, 255, 255)];
                [cell setBackgroundView: BGV];
                
                
                
                UILabel *lblName=[RHMethods labelWithFrame:CGRectMake(10, 12, 0, 20) font:Font(16) color:rgbTxtGray text:str];
                [cell addSubview:lblName];
                
                if (indexPath.row==0) {
                    
                    txtNewPwd=[RHMethods textFieldlWithFrame:CGRectMake(XW(lblName), 0, kScreenWidth-10-(XW(lblName)), 44) font:fontTitle color:rgbTitleColor placeholder:@"请输入" text:@""];
                    [cell addSubview:txtNewPwd];
                    [txtNewPwd setTextAlignment:NSTextAlignmentRight];
                    [txtNewPwd setSecureTextEntry:YES];
                    [txtNewPwd setDelegate:self];
                }else{
                    
                    txtNewPwd2=[RHMethods textFieldlWithFrame:CGRectMake(XW(lblName), 0, kScreenWidth-10-(XW(lblName)), 44) font:fontTitle color:rgbTitleColor placeholder:@"请输入" text:@""];
                    [cell addSubview:txtNewPwd2];
                    [txtNewPwd2 setTextAlignment:NSTextAlignmentRight];
                    [txtNewPwd2 setSecureTextEntry:YES];
                    [txtNewPwd2 setDelegate:self];
                }
                
                
                [RHMethods lineViewWithFrame:CGRectMake(0, 43.5, kScreenWidth, 0.5) supView:cell];
                
                
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                
                
            }
            
            return cell;
            
            
        }case 3:
        {
            //提交
            static NSString *cellIdentifier = @"userContentSubmint";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                [cell setBackgroundColor:[UIColor clearColor]];
                
                float fy=10;
//                if ([self.userInfo isEqualToString:@"register"]) {
//                    btnSelect=[RHMethods buttonWithFrame:CGRectMake(0, 0, 100, 20) title:@" 我已阅读" image:@"checkBox" bgimage:nil];
//                    [btnSelect setImage:[UIImage imageNamed:@"checkBoxon"] forState:UIControlStateSelected];
//                    [btnSelect setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
//                    [btnSelect setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
//                    [btnSelect setTitleColor:rgbTxtDeepGray forState:UIControlStateNormal];
//                    [cell addSubview:btnSelect];
//                    [btnSelect addTarget:self action:@selector(selectButtonClicked) forControlEvents:UIControlEventTouchUpInside];
//                    
//                    UIButton *btnX=[RHMethods buttonWithFrame:CGRectMake(XW(btnSelect), Y(btnSelect), 200, 20) title:@"《玖晟医疗用户协议》" image:nil bgimage:nil];
//                    [btnX addTarget:self action:@selector(xyButtonClicked) forControlEvents:UIControlEventTouchUpInside];
//                    [btnX setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
//                    [btnX setTitleColor:rgbpublicColor forState:UIControlStateNormal];
//                    [cell addSubview:btnX];
//                    fy=40;
//                }
                
                UIButton *btnSub=[RHMethods buttonWithFrame:CGRectMake(10, fy, kScreenWidth-20, 44) title:@"确定" image:@"" bgimage:@"03buttonBgRed"];
                // [btnSub setTitleEdgeInsets:UIEdgeInsetsMake(0, -280, 0, 0)];
                btnSub.titleLabel.font=Font(20);
                [btnSub setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [btnSub addTarget:self action:@selector(submintButtonClicked) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:btnSub];
                
            }
            
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            return cell;
            
        }
        default:
            break;
    }
    
    return nil;
    
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==1) {
        return 0.0;
    }
    return 20;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    MoreBlankTableViewHeaderFooterView *sectionView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"MoreBlankTableViewHeaderFooterView"];
    return sectionView;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
#pragma mark button
-(void)selectButtonClicked{
    btnSelect.selected=!btnSelect.selected;
}
-(void)xyButtonClicked{
    ///wappage/agreement
  //  [self pushController:[SelectWebUrlViewController class] withInfo:@"" withTitle:@"玖晟医疗用户协议" withOther:@{@"url":[NSString stringWithFormat:@"%@wappage/agreement?type=reg",baseWebPath]}];
}
-(void)backButtonClicked:(id)sender{
    if (boolBack) {
         UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"验证码短信可能略有延迟，确定返回并重新开始？" delegate:self cancelButtonTitle:@"等待" otherButtonTitles:@"返回", nil];
        [alert show];
    }else{
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [super backButtonClicked:sender];
    }
}
-(void)submintButtonClicked{
    
    NSString *strTel=txtTel.text;
    if (![[Utility Share] validateTel:strTel]) {
        [SVProgressHUD showImage:nil status:@"哎呀！手机号是不是输错了啊"];
        return;
    }
    if (!boolCode) {
        [SVProgressHUD showImage:nil status:@"请获取验证码！"];
        return;
    }
    NSString *strYZM=txtYZM.text;
    if (![strYZM notEmptyOrNull]) {
        [SVProgressHUD showImage:nil status:@"亲！还没有输入验证码哦"];
        return;
    }
    NSString *strNewPwd=txtNewPwd.text;
    if (![strNewPwd notEmptyOrNull]) {
        [SVProgressHUD showImage:nil status:@"亲！是不是忘了填什么东西啊"];
        return;
    }
    NSString *strNewPwd2=txtNewPwd2.text;
    if (![strNewPwd2 notEmptyOrNull]) {
        [SVProgressHUD showImage:nil status:@"亲！是不是忘了填什么东西啊"];
        return;
    }
    if (![strNewPwd isEqualToString:strNewPwd2]) {
        [SVProgressHUD showImage:nil status:@"哎呀！好像新密码不一样诶..."];
        return;
    }
    
    NSMutableDictionary *dic=[[NSMutableDictionary alloc]initWithCapacity:0];
    [dic setValue:strTel forKey:@"mobile"];
    [dic setValue:strYZM forKey:@"codes"];
    [dic setValue:strNewPwd forKey:@"passwd"];
    [dic setValue:strNewPwd2 forKey:@"re_passwd"];
    [dic setValue:@"1" forKey:@"hairstylist"];
    boolBack=NO;
//    if ([self.userInfo isEqualToString:@"register"]) {
//        if (!btnSelect.selected) {
//            [SVProgressHUD showImage:nil status:@"请阅读用户协议"];
//            return;
//        }
//        
//        [NetEngine createHttpAction:@"" withCache:NO withParams:dic withMask:SVProgressHUDMaskTypeClear onCompletion:^(id resData, BOOL isCache) {
//            DLog(@"__resData____%@",resData);
//            if ([[resData valueForJSONStrKey:@"status"] isEqualToString:@"200"]) {
//                [NSObject cancelPreviousPerformRequestsWithTarget:self];
//                [SVProgressHUD showSuccessWithStatus:[resData valueForJSONStrKey:@"msg"]];
//                [[Utility Share] isLoginAccount:strTel pwd:strNewPwd code:nil aLogin:^(NSInteger NoLogin) {
//                    if (NoLogin!=1) {
//                        [super backButtonClicked:nil];
//                    }
//                } ];
//                
//            }else{
//                [SVProgressHUD showImage:nil status:[resData valueForJSONStrKey:@"msg"]];
//            }
//        } onError:^(NSError *error) {
//            [SVProgressHUD showImage:nil status:alertErrorTxt];
//        }];
//
//    }else{
        [NetEngine createHttpAction:MFuserforgetpwd withCache:NO withParams:dic withMask:SVProgressHUDMaskTypeClear onCompletion:^(id resData, BOOL isCache) {
            DLog(@"__resData____%@",resData);
            if ([[resData valueForJSONStrKey:@"status"] isEqualToString:@"200"]) {
                [NSObject cancelPreviousPerformRequestsWithTarget:self];
                [SVProgressHUD showSuccessWithStatus:[resData valueForJSONStrKey:@"msg"]];
               
                [self performSelector:@selector(backButtonClicked:) withObject:nil afterDelay:0.8];
                
            }else{
                [SVProgressHUD showImage:nil status:[resData valueForJSONStrKey:@"msg"]];
            }
        } onError:^(NSError *error) {
            [SVProgressHUD showImage:nil status:alertErrorTxt];
        }];

//    }
    
}

- (IBAction)YZMButtonClicked:(id)sender {
    NSString *strTel=txtTel.text;
    if (![[Utility Share] validateTel:strTel]) {
        [SVProgressHUD showImage:nil status:@"哎呀！手机号是不是输错了啊"];
        return;
    }
    [self loadSendCode:@""];
}
-(void)loadSendCode:(NSString *)strCid{
    NSString *strTel=txtTel.text;
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
    [dict setValue:strTel forKey:@"mobile"];
    [dict setValue:@"1" forKey:@"hairstylist"];
//    if ([self.userInfo isEqualToString:@"register"]) {
//        [dict setValue:@"reg" forKey:@"type"];
//    }else{
        [dict setValue:@"forgetpwd" forKey:@"type"];
//    }
    
    [NetEngine createHttpAction:MFusergetcode withCache:NO withParams:dict withMask:SVProgressHUDMaskTypeNone onCompletion:^(id resData, BOOL isCache) {
        DLog(@"__resData____%@",resData);
        if ([[resData valueForJSONStrKey:@"status"] isEqualToString:@"200"]) {
            boolCode=YES;
            boolBack=YES;
            [SVProgressHUD showSuccessWithStatus:[resData valueForJSONStrKey:@"msg"]];
            [btnYZM setBackgroundColor:RGBACOLOR(150, 150, 150, 1)];
            btnYZM.userInteractionEnabled=NO;
            [self performSelector:@selector(updateButtonTitle:) withObject:[[resData objectForJSONKey:@"data"] valueForJSONStrKey:@"second"] afterDelay:0];
        }else{
            [SVProgressHUD showImage:nil status:[resData valueForJSONStrKey:@"msg"]];
        }
    } onError:^(NSError *error) {
        [SVProgressHUD showImage:nil status:alertErrorTxt];
    }];

}
-(void)updateButtonTitle:(NSString *)str{
    float aflote=[str floatValue];
    DLog(@"________________()()()()()(");
    [btnYZM setTitle:[NSString stringWithFormat:@"%.0f秒",aflote] forState:UIControlStateNormal];
    if (aflote<=1) {
        [self performSelector:@selector(yanZM_date) withObject:nil afterDelay:1.0];
    }else{
        aflote--;
        [self performSelector:@selector(updateButtonTitle:) withObject:[NSString stringWithFormat:@"%f",aflote] afterDelay:1.0];
    }    
}

-(void)yanZM_date{
    DLog(@"延迟——————禁止验证码按钮");
    [btnYZM setTitle:@"发送" forState:UIControlStateNormal];
    // [btnYZM setTitleColor:rgbpublicColor forState:UIControlStateNormal];
    [btnYZM setBackgroundColor:rgbpublicColor];
    btnYZM.userInteractionEnabled=YES;
}
#pragma mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        boolBack=NO;
        [self backButtonClicked:nil];
    }
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
