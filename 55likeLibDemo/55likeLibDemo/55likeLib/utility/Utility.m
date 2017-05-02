
#import "Utility.h"
#import <Reachability.h>
#import "NSObject+JSONCategories.h"
#import "NSDictionary+expanded.h"
#import "NSString+JSONCategories.h"
//#import "DMHessian.h"
#import <arpa/inet.h>
#import "NetEngine.h"
#import "AppDelegate.h"
//#import "LoginView.h"
//#import "RegisterView.h"

#import "LoginViewController.h"
#import "CustomTabBar.h"
#import "NSObject+JSONCategories.h"

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>


#import <CoreLocation/CoreLocation.h>
//#import "HomeView.h"

//振动
#import <AudioToolbox/AudioToolbox.h>
//
///分享
//#import <ShareSDK/ShareSDK.h>
//#import <ShareSDKUI/ShareSDKUI.h>
////支付宝
//#import <AlipaySDK/AlipaySDK.h>
//#import "Order.h"
////微信支付
//#import "WXApi.h"
////极光推送
//#import "JPUSHService.h"

//启动页
#import "StartTransitionView.h"
//相册
#import <Photos/Photos.h>



#define picMidWidth 200
#define picSmallWidth 100
@interface Utility ()<UIAlertViewDelegate,CLLocationManagerDelegate>{//SRWebSocketDelegate
    
    NSString *phoneNum;
    UIAlertView *alertview;
    
    CLLocationManager *locManager;
    
    SystemSoundID sound;//系统声音的id 取值范围为：1000-2000
    
    StartTransitionView *startView;
    
    UIAlertView *alertTempScorket;
    
    
    NSInteger intConnectionNum;//连接socket服务器次数
    
    
    NSDictionary *dicTempDownload;
    float paramProgress_temp;
    BOOL automaticDownload;
    
    
    BOOL aboolOneLogin;
    BOOL aboolAgainLogin_message;
    
    BOOL abool_backPassword_socket;
    
    
    
}
@property (nonatomic,strong) NSURL *phoneNumberURL;
@property (nonatomic,strong) Reachability *reachability;

@end

@implementation Utility


static Utility *_utilityinstance=nil;
static dispatch_once_t utility;

+(id)Share
{
    dispatch_once(&utility, ^ {
        _utilityinstance = [[Utility alloc] init];
        
    });
	return _utilityinstance;
}

- (BOOL)offline
{
    return ![[NetEngine Share] isReachable];
}

#pragma mark -
#pragma mark validateEmail
- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:candidate];
}
#pragma mark validateTel
- (BOOL) validateTel: (NSString *) candidate {
    NSString *telRegex = @"^1[3-9]\\d{9}$";
    NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *telTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", telRegex];
	NSPredicate *PHSP = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PHS];
    if ([telTest evaluateWithObject:candidate] == YES || [PHSP evaluateWithObject:candidate] == YES) {
        return YES;
    }else{
        return NO;
    }
//    if (candidate.length>=5) {
//        NSString *str = [NSString stringWithFormat:@"%.0f",candidate.doubleValue];
//        return [str isEqualToString:candidate];
//    }else{
//        return NO;
//    }
}
///验证字母
-(BOOL)validateLetter:(NSString *)str{
    NSString *regex = @"[a-zA-Z]";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:str];
}
#pragma mark validateEmail
- (BOOL) validateUrl:(NSString *)candidate{
    //((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)
    ///\b(([\w-]+:\/\/?|[\w]?[.])[^\s()<>]+(?:\([\w\d]+\)|([^[:punct:]\s]|\/)))/
    NSString *urlRegex = @"";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegex];
    return [urlTest evaluateWithObject:candidate];
}
#pragma ImagePeSize
-(CGFloat)percentage:(NSString*)per width:(NSInteger)width
{
    if (per) { 
        NSArray *stringArray = [per componentsSeparatedByString:@"*"];
        
        if ([stringArray count]==2) {
            CGFloat w=[[stringArray objectAtIndex:0] floatValue];
            CGFloat h=[[stringArray objectAtIndex:1] floatValue];
            if (w>=width) {
                return h*width/w;
            }else{
                return  h;
            }
        }
    }
    return width;
}

/**
 *	保存obj的array到本地，如果已经存在会替换本地。
 *
 *	@param	obj	待保存的obj
 *	@param	key	保存的key
 */
+ (void)saveToArrayDefaults:(id)obj forKey:(NSString*)key
{
    [self saveToArrayDefaults:obj replace:obj forKey:key];
}
+ (void)saveToArrayDefaults:(id)obj replace:(id)oldobj forKey:(NSString*)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *array = [defaults valueForKey:key];
    
    NSMutableArray *marray = [NSMutableArray array];
    if (!oldobj) {
        oldobj = obj;
    }
    if (array) {
        [marray addObjectsFromArray:array];
        if ([marray containsObject:oldobj]) {
            [marray replaceObjectAtIndex:[marray indexOfObject:oldobj] withObject:obj];
        }else{
            [marray addObject:obj];
        }
    }else{
      [marray addObject:obj];  
    }
    [defaults setValue:marray forKey:key];
    [defaults synchronize];
}

+ (BOOL)removeForArrayObj:(id)obj forKey:(NSString*)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *array = [defaults valueForKey:key];
    
    NSMutableArray *marray = [NSMutableArray array];
    if (array) {
        [marray addObjectsFromArray:array];
        if ([marray containsObject:obj]) {
            [marray removeObject:obj];
        }
    }
    if (marray.count) {
        [defaults setValue:marray forKey:key];
    }else{
        [defaults removeObjectForKey:key];
    }
    [defaults synchronize];
    return marray.count;
}
/**
 *	保存obj到本地
 *
 *	@param	obj	数据
 *	@param	key	键
 */
+ (void)saveToDefaults:(id)obj forKey:(NSString*)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:obj forKey:key];
    [defaults synchronize];
}

+ (id)defaultsForKey:(NSString*)key
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:key];
}
+ (void)removeForKey:(NSString*)key
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
}

+(NSString *)Utuid{
    return [[Utility Share] userId];
}
+(NSString *)Uttoken{
    return [[Utility Share] userToken];
}
+(id)uid
{
    return [[Utility Share] userId];
}
-(void)ShowMessage:(NSString *)title msg:(NSString *)msg
{
    title=title?title:@"";
	UIAlertView *alert=[[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
	[alert show];
}

#pragma mark -
#pragma mark makeCall
- (NSString*) cleanPhoneNumber:(NSString*)phoneNumber
{
    return [[[[phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""]
              stringByReplacingOccurrencesOfString:@"-" withString:@""]
             stringByReplacingOccurrencesOfString:@"(" withString:@""]
            stringByReplacingOccurrencesOfString:@")" withString:@""];
    
    //return number1;
}

- (void) makeCall:(NSString *)phoneNumber
{
    phoneNum=[self cleanPhoneNumber:phoneNumber];
    if ([phoneNum intValue]!=0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"拨打号码?"
                                                        message:phoneNum
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"拨打",nil];
        
        [alert show];
    }else {
        [[[UIAlertView alloc] initWithTitle:nil message:@"无效号码" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"好", nil] show];
        return;
    }
}



#pragma mark TimeTravel
- (NSString*)timeToNow:(NSString*)theDate needYear:(BOOL)needYear
{
    if (!theDate || ![theDate notEmptyOrNull]) {
        return @"";
    }
    if (![self isPureFloat:theDate]) {
        return theDate;
    }
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *d=[NSDate dateWithTimeIntervalSince1970:[theDate integerValue]];
    //NSDate *d=[dateFormatter dateFromString:theDate];
    if (!d) {
        return theDate;
    }
    
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString *timeString=@"";
    
    NSTimeInterval cha=(now-late)>0 ? (now-late) : 0;
    
    if (cha/3600<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/60];
        timeString = [timeString substringToIndex:timeString.length-7];
        
        timeString=[timeString floatValue] <=1?@"刚刚":[NSString stringWithFormat:@"%@ 分前", timeString];
        
    }else if (cha/3600>1 && cha/3600<24) {
        timeString = [NSString stringWithFormat:@"%f", cha/3600];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@小时前", timeString];
    }
    else
    {
        if (needYear) {
            [dateFormatter setDateFormat:@"yy-MM-dd"];
        }
        else
        {
            [dateFormatter setDateFormat:@"MM-dd"];
        }
        timeString=[dateFormatter stringFromDate:d];
        // timeString = [NSString stringWithFormat:@"%.0f 天前",cha/3600/24];
    }
    
    return timeString;
}

///改变时间格式yyyy-MM-dd HH:mm
- (NSString*)time_ChangeTheFormat:(NSString*)theDate{
    DLog(@"________%@",theDate);
    if (!theDate || ![theDate notEmptyOrNull]) {
        return @"";
    }
    if (![self isPureFloat:theDate]) {
        return theDate;
    }
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.0"];
//    NSDate *d=[dateFormatter dateFromString:theDate];
//    DLog(@"_______________%@",d);
//    if (!d) {
//        return @"";
//    }
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSDate *aTime = [NSDate dateWithTimeIntervalSince1970:[theDate integerValue]];
    return [dateFormatter stringFromDate:aTime];
}

-(NSInteger)ACtimeToNow:(NSString*)theDate
{
    /*
     -1过期
     */
    
    
    if (!theDate || ![theDate notEmptyOrNull]) {
        return -1;
    }
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.0"];
    NSDate *d=[dateFormatter dateFromString:theDate];
    if (!d) {
        return -1;
    }
    
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    // NSString *timeString=@"";
    
    NSTimeInterval cha=(now-late);//>0 ? (now-late) : 0
    //    if (cha==0) {
    //        return -1;
    //    }else{
    return -cha/3600/24;
    //}
    
    
    //    if (cha/3600<1) {
    //        timeString = [NSString stringWithFormat:@"%f", cha/60];
    //        timeString = [timeString substringToIndex:timeString.length-7];
    //        timeString=[NSString stringWithFormat:@"%@ 分前", timeString];
    //
    //    }else if (cha/3600>1 && cha/3600<24) {
    //        timeString = [NSString stringWithFormat:@"%f", cha/3600];
    //        timeString = [timeString substringToIndex:timeString.length-7];
    //        timeString=[NSString stringWithFormat:@"%@ 小时前", timeString];
    //    }
    //    else
    //    {
    //        /* if (needYear) {
    //         [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    //         }
    //         else
    //         {
    //         [dateFormatter setDateFormat:@"MM-dd"];
    //         }
    //         timeString=[dateFormatter stringFromDate:d];*/
    //        timeString = [NSString stringWithFormat:@"%.0f 天前",cha/3600/24];
    //    }
    //    
    //    return timeString;
}


- (NSString*)timeToNow_zk:(NSString*)theDate{
    if (!theDate || ![theDate notEmptyOrNull]) {
        return @"";
    }
    if (![self isPureFloat:theDate]) {
        return theDate;
    }
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];//@"yyyy-MM-dd HH:mm:ss"
    NSDate *d=[NSDate dateWithTimeIntervalSince1970:[theDate integerValue]];//[dateFormatter dateFromString:theDate];
    if (!d) {
        return theDate;
    }
    
    NSString *timeString=@"";
    
    NSString *todayString = [dateFormatter stringFromDate:[NSDate date]];
    NSString *dateOfCurrentString = [dateFormatter stringFromDate:d];
    NSString *dateOfYesterdayString = [dateFormatter stringFromDate:[NSDate dateWithTimeInterval:-24*60*60 sinceDate:[NSDate date]]];
 
    if ( [todayString isEqualToString:dateOfCurrentString]) {
        timeString=@"今天";
    }else if ([dateOfCurrentString isEqualToString:dateOfYesterdayString]){
        timeString=@"昨天";
    }
    else
    {
        
        [dateFormatter setDateFormat:@"MM/dd"];
        timeString=[dateFormatter stringFromDate:d];
    }
    
    return timeString;
}

//时间戳
-(NSString *)timeToTimestamp:(NSString *)timestamp{
    if (!timestamp || ![timestamp notEmptyOrNull]) {
        return @"";
    }
    if (![self isPureFloat:timestamp]) {
        return timestamp;
    }
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
     NSDate *aTime = [NSDate dateWithTimeIntervalSince1970:[timestamp integerValue]];
    
    NSString *str=[dateFormatter stringFromDate:aTime];
    return str;
}

//data-固定格式时间yyyy-MM-dd
-(NSString *)timeToFormatConversion:(NSString *)aDate{
    if (!aDate || ![aDate notEmptyOrNull]) {
        return @"";
    }
    if (![self isPureFloat:aDate]) {
        return aDate;
    }
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *aTime = [NSDate dateWithTimeIntervalSince1970:[aDate integerValue]];

    NSString *str=[dateFormatter stringFromDate:aTime];
    return str;
}

///data-固定格式时间 录音使用
-(NSString *)timeToFormatAudio:(NSString *)aDate{
    if (!aDate || ![aDate notEmptyOrNull]) {
        return @"";
    }
    if (![self isPureFloat:aDate]) {
        return aDate;
    }
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *aTime = [NSDate dateWithTimeIntervalSince1970:[aDate integerValue]];
    
    NSString *str=[dateFormatter stringFromDate:aTime];
    return str;
}

#pragma mark login
-(void)isLogin:(validationLoginSuc)aLoginSuc
{
    self.vloginSuc = aLoginSuc;
    if ([_userId notEmptyOrNull] && [_userToken notEmptyOrNull]) {
        //登录过-验证token是否过期
        NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:[[Utility Share] userId],@"uid",[[Utility Share] userToken],@"token",nil];
        [NetEngine createHttpAction:MFuserrelogin withCache:NO withParams:dic withMask:SVProgressHUDMaskTypeNil onCompletion:^(id resData, BOOL isCache) {
            if ([[resData valueForJSONKey:@"status"] isEqualToString:@"200"]) {
                NSDictionary *userDict = [[resData objectForJSONKey:@"data"] objectForJSONKey:@"userinfo"];
                [self setUserData:userDict];
                [self saveUserInfoToDefault];
                
                //没过期
                self.vloginSuc?self.vloginSuc(1):nil;//只用于验证是否过期-没过期
                self.vloginSuc = nil;
            }else{  //过期
                self.vloginSuc?self.vloginSuc(0):nil;
                self.vloginSuc = nil;
                [self showAgainLoginMessage:[resData valueForJSONKey:@"msg"]];
//                [self showwebScoketLogin];
            }
        } onError:^(NSError *error) {
            //请求报错---处理为没过期
            self.vloginSuc?self.vloginSuc(1):nil;
            self.vloginSuc = nil;
        }];
    }
    else{
        self.vloginSuc?self.vloginSuc(0):nil;
        self.vloginSuc = nil;
        
//        [self showwebScoketLogin];
    }
}

-(void)isLoginAccount:(NSString *)account pwd:(NSString *)password code:(NSString *)chkcode aLogin:(LoginSuc)aLoginSuc
{
    self.loginSuc = aLoginSuc;
    [self loginWithAccount:account pwd:password code:chkcode];
    
}

-(void)loginWithAccount:(NSString *)account pwd:(NSString *)password code:(NSString *)chkcode
{
    
    if (![account notEmptyOrNull])
    {
        [SVProgressHUD showImage:nil status:@"请填写账号"];
        return;
    }
    if (![password notEmptyOrNull])
    {
        [SVProgressHUD showImage:nil status:@"密码不能为空"];
        return;
    }
    if (!chkcode || ![chkcode notEmptyOrNull]) {
        chkcode =@"";
    }
    
    
    NSDictionary *dic=@{@"mobile":account,
                        @"passwd":password,
                        @"hairstylist":@"1"};
    
    [NetEngine createHttpAction:MFuserlogin withCache:NO withParams:dic withMask:SVProgressHUDMaskTypeClear onCompletion:^(id resData, BOOL isCache) {
        DLog(@"userLogin__resData:%@",resData);
        if ([[resData valueForJSONKey:@"status"] isEqualToString:@"200"]) {
            NSDictionary *userDict = [[resData objectForJSONKey:@"data"] objectForJSONKey:@"userinfo"];
            [self setUserAccount:account];
            [self setUserPwd:password];
            
            [self setUserId:[userDict valueForJSONStrKey:@"id"]];
            [self setUserToken:[userDict valueForJSONStrKey:@"token"]];
            
            [self setUserData:userDict];
            
            [self saveUserInfoToDefault];
            
            
            [self hiddenLoginAlert];
            
            self.loginSuc?self.loginSuc(1):nil;
            self.loginSuc = nil;
        }else{
            [SVProgressHUD showImage:nil status:[resData valueForJSONKey:@"msg"]];
            self.loginSuc?self.loginSuc(2):nil;
            self.loginSuc = nil;
        }
    } onError:^(NSError *error) {
        [SVProgressHUD showImage:nil status:alertErrorTxt];
        self.loginSuc?self.loginSuc(2):nil;
        self.loginSuc = nil;
    }];
    
}
- (void)showLoginAlert:(BOOL)abool
{
    //againLogin
    if (aboolOneLogin) {
        return;
    }
    aboolOneLogin=YES;
    
    [[Utility Share] setIsUserLogin:NO];
    if (abool) {
       
    }
//    [JPUSHService setAlias:@"zhuike_jpush_null" callbackSelector:nil object:@""];
//    //清除第三方平台授权
//    if ([ShareSDK hasAuthorized:SSDKPlatformTypeSinaWeibo]) {
//        [ShareSDK cancelAuthorize:SSDKPlatformTypeSinaWeibo];
//    }
//    if ([ShareSDK hasAuthorized:SSDKPlatformTypeQQ]) {
//        [ShareSDK cancelAuthorize:SSDKPlatformTypeQQ];
//    }
//    if ([ShareSDK hasAuthorized:SSDKPlatformTypeWechat]) {
//        [ShareSDK cancelAuthorize:SSDKPlatformTypeWechat];
//    }
//
    
//    [[Utility Share] websocketClose];
    [[Utility Share] readUserInfoFromDefault];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"push_showLogin" object:nil userInfo:nil];
    
    UINavigationController *curNav = [[[[Utility Share] CustomTabBar_zk] viewControllers] objectAtIndex:[[[Utility Share] CustomTabBar_zk]selectedIndex]];
    [curNav dismissViewControllerAnimated:NO completion:nil];
    
//LoginViewController
    LoginViewController *login=[[LoginViewController alloc] init];
    login.userInfo=@"againLogin";
    login.otherInfo=@{@"animated":(abool?@"yes":@"no")};
    KKNavigationController *loginNav=[[KKNavigationController alloc] initWithRootViewController:login];
    
    [curNav presentViewController:loginNav animated:abool completion:^{
        [curNav popToRootViewControllerAnimated:NO];
        [[[Utility Share] CustomTabBar_zk] selectedTabIndex:@"0"];
        [self hiddenStartTransitionView:YES];
    }];
}
-(void)hiddenLoginAlert:(BOOL)abool{
//    //极光
//    [JPUSHService setAlias:[NSString stringWithFormat:@"%@",self.userId] callbackSelector:nil object:@""];
    

    [self push_loginStatus];
    UINavigationController *curNav = [[[[Utility Share] CustomTabBar_zk] viewControllers] objectAtIndex:[[[Utility Share] CustomTabBar_zk]selectedIndex]];
    if (abool) {
        [curNav dismissViewControllerAnimated:abool completion:^{
            
            aboolOneLogin=NO;
        }];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"againLoadUserData" object:nil];
    }else{
        [curNav dismissViewControllerAnimated:abool completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"againLoadUserData" object:nil];
            aboolOneLogin=NO;
        }];
        
    }
//   refreshLocalNotificationData
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshLocalNotificationData" object:nil];
//    });
    
    
    
    
}
- (void)hiddenLoginAlert
{
    [self hiddenLoginAlert:YES];
}
///登录后推送登录
-(void)push_loginStatus{
    //zk
//    [NetEngine createGetAction_LJ:[NSString stringWithFormat:ZKNewuserpushtoclient,self.userId,self.userToken] onCompletion:^(id resData, BOOL isCache) {
//        DLog(@"_________登录推送：%@",resData);
//    }];
}


#pragma mark 数据更新
-(void)saveUserInfoToDefault
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:self.userPwd forKey:default_userpwd];
    [defaults setValue:self.userAccount forKey:default_userAccount];
    [defaults setValue:self.userId forKey:default_userID];
    [defaults setValue:self.userToken forKey:default_userToken];
    [defaults setObject:self.userAppSetServer forKey:default_userAppSetServer];
    
    [defaults setBool:self.isDefaultNOplaySystemSound forKey:default_setDefaultplaySystemSound];
    [defaults setBool:self.isDefaultNOStartSystemShake forKey:default_setDefaultStartVibrate];
    
    
    [defaults synchronize];
}
-(void)readUserInfoFromDefault
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self setUserPwd:[defaults valueForKey:default_userpwd]];
    [self setUserAccount:[defaults valueForKey:default_userAccount]];
    [self setUserAppSetServer:[defaults objectForKey:default_userAppSetServer]];
    [self setUserId:[defaults valueForKey:default_userID]];
    [self setUserToken:[defaults valueForKey:default_userToken]];
    
    [self setUserAppIp:[self.userAppSetServer valueForJSONStrKey:@"ip"]];
    [self setUserAppsocketport:[self.userAppSetServer valueForJSONStrKey:@"socketport"]];
    [self setUserAppdomain:[self.userAppSetServer valueForJSONStrKey:@"domain"]];
    [self setUserAppwapdomain:[self.userAppSetServer valueForJSONStrKey:@"wapdomain"]];
    [self setUserPrimaryDomain:[self.userAppSetServer valueForJSONStrKey:@"primaryDomain"]];
    
    //v3
    [self setUserAppUseSSL:NO];
    
    if ([[self.userAppSetServer valueForJSONStrKey:@"version"] notEmptyOrNull]) {
        [self setUserInterfaceVersion:[self.userAppSetServer valueForJSONStrKey:@"version"]];
    }else{
        //market
        [self setUserInterfaceVersion:@"market"];
    }
    
    [self setIsDefaultNOplaySystemSound:[defaults boolForKey:default_setDefaultplaySystemSound]];
    [self setIsDefaultNOStartSystemShake:[defaults boolForKey:default_setDefaultStartVibrate]];
    
    
}
-(void)clearUserInfoInDefault
{
    //
    self.userId=@"";
    self.userToken=@"";
    self.userPwd=@"";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //消除用户
    [defaults removeObjectForKey:default_userpwd];
    [defaults removeObjectForKey:default_userID];
    [defaults removeObjectForKey:default_userToken];
    
    [defaults synchronize];
    
    //消除用户资料
//    [self removeSqlData];
    
}
#pragma mark 版本更新
-(NSString *)VersionSelectString{
    //CFBundleShortVersionString
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}
-(NSString *)VersionSelect{
    NSString *v = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    return v;
}

- (void)versionUpdate:(BOOL)abool{
    NSString *version=[self VersionSelect];
    
    NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:[[Utility Share] userId],@"uid",[[Utility Share] userToken],@"token",@"ios",@"type",nil];
    [NetEngine createHttpAction:MFusergetversion withCache:NO withParams:dic withMask:abool?SVProgressHUDMaskTypeClear:SVProgressHUDMaskTypeNil onCompletion:^(id resData, BOOL isCache) {
        DLog(@"resData Version:%@",resData);
        if ([[resData valueForJSONKey:@"status"] isEqualToString:@"200"]) {
            NSDictionary *userDict = [[resData objectForJSONKey:@"data"] objectForJSONKey:@"info"];
            // 更新包路径
            _APPpackPath = [userDict valueForJSONStrKey:@"url"];
            DLog(@"packPath:%@",_APPpackPath);
            
            _APPnewAppVersion = [userDict valueForJSONStrKey:@"number"];
            DLog(@"newVersion:%@",_APPnewAppVersion);
            if ([_APPnewAppVersion floatValue]>[version floatValue]) {
                // 分为强制更新与不强制更新
                NSString *force = [userDict valueForJSONStrKey:@"forces"];
                if ([force isEqualToString:@"1"]) {
                    // 强制更新、、[NSString stringWithFormat:@"发现新版本啦！ %@",_APPnewAppVersion]
                    UIAlertView *forceAlterView = [[UIAlertView alloc] initWithTitle:@"发现新版本啦！" message:[userDict valueForJSONStrKey:@"content"] delegate:self cancelButtonTitle:@"立即更新" otherButtonTitles:nil, nil];
                    forceAlterView.tag=199;
                    [forceAlterView show];
                }else{
                    // 不强制更新
                    UIAlertView *notForceAlterView = [[UIAlertView alloc] initWithTitle:@"发现新版本啦！" message:[userDict valueForJSONStrKey:@"content"] delegate:self cancelButtonTitle:@"稍后再说" otherButtonTitles:@"立即更新", nil];
                    notForceAlterView.tag=198;
                    [notForceAlterView show];
                }
                
            }else{
                if (abool) {
                    [SVProgressHUD showImage:nil status:@"当前是最新版本啦！"];
                }
                
            }
            
        }else{
            if (abool) {
                [SVProgressHUD showImage:nil status:[resData valueForJSONKey:@"msg"]];
            }
        }
    } onError:^(NSError *error) {
        if (abool) {
            [SVProgressHUD showImage:nil status:alertErrorTxt];

        }
    }];
    
    
    
}
#pragma mark UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView==alertTempScorket) {
        if (buttonIndex==1) {
            intConnectionNum=0;
//            [self WebSocketConnectServer];
        }
        
    }else if (alertView.tag == 199) {
        // 强制更新
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_APPpackPath]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             exit(0);
        });
       
    }else if (alertView.tag == 198){
        // 不强制更新
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_APPpackPath]];
        }else{
            DLog(@"不更新");
        }
    }else if (alertView.tag==1010){
        aboolAgainLogin_message=NO;
    }else if ([alertView.title isEqualToString:@"拨打号码?"]) {//phoneCall AlertView
        if (buttonIndex==1)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phoneNum]]];
        }
        phoneNum=nil;
    }else if (alertView.tag==121 && buttonIndex==1){
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if([[UIApplication sharedApplication] canOpenURL:url]) {
            NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url];
            
        }
    }
}



//判断是否为整形：
- (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

//判断是否为浮点形：
- (BOOL)isPureFloat:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    float val;
    return[scan scanFloat:&val] && [scan isAtEnd];
}


#pragma mark view
//类似qq聊天窗口的抖动效果
-(void)viewAnimations:(UIView *)aV{
    CGFloat t =5.0;
    CGAffineTransform translateRight  =CGAffineTransformTranslate(CGAffineTransformIdentity, t,0.0);
    CGAffineTransform translateLeft =CGAffineTransformTranslate(CGAffineTransformIdentity,-t,0.0);
    CGAffineTransform translateTop =CGAffineTransformTranslate(CGAffineTransformIdentity,0.0,1);
    CGAffineTransform translateBottom =CGAffineTransformTranslate(CGAffineTransformIdentity,0.0,-1);
    
    aV.transform = translateLeft;
    
    [UIView animateWithDuration:0.07 delay:0.0 options:UIViewAnimationOptionAutoreverse animations:^{//UIViewAnimationOptionRepeat
        //[UIView setAnimationRepeatCount:2.0];
        aV.transform = translateRight;
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.07 animations:^{
            aV.transform = translateBottom;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.07 animations:^{
                aV.transform = translateTop;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                    aV.transform =CGAffineTransformIdentity;//回到没有设置transform之前的坐标
                } completion:NULL];
            }];
        }];
//        if(finished){
//            [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
//                aV.transform =CGAffineTransformIdentity;//回到没有设置transform之前的坐标
//            } completion:NULL];
//        }else{
//            aV.transform = translateTop;
//            
//        }
    }];
}

//view 左右抖动
-(void)leftRightAnimations:(UIView *)view{
    
    CGFloat t =5.0;
    CGAffineTransform translateRight  =CGAffineTransformTranslate(CGAffineTransformIdentity, t,0.0);
    CGAffineTransform translateLeft =CGAffineTransformTranslate(CGAffineTransformIdentity,-t,0.0);
    
    view.transform = translateLeft;
    
    [UIView animateWithDuration:0.07 delay:0.0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
        [UIView setAnimationRepeatCount:2.0];
        view.transform = translateRight;
    } completion:^(BOOL finished){
        if(finished){
            [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                view.transform =CGAffineTransformIdentity;
            } completion:NULL];
        }
    }];
    
}

#pragma mark image
-(UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    // End the context
    UIGraphicsEndImageContext();
    // Return the new image.
    return newImage;
}
/////通过颜色来生成一个纯色图片
- (UIImage *)imageFromColor:(UIColor *)color rect:(CGSize )aSize{
    CGRect rect = CGRectMake(0, 0,aSize.width, aSize.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}



#pragma mark -数据格式化
//////////////数据格式化
//格式化电话号码
-(NSString *)ACFormatPhone:(NSString *)str{
    if (str.length<10) {
        return str;
    }else{
        NSString *s1=[str substringToIndex:3];
        NSString *s2=[str substringWithRange:NSMakeRange(3, 4)];
        NSString *s3=[str substringFromIndex:7];
        DLog(@"%@,%@,%@",s1,s2,s3);
        NSString *turntoCarIDString=[NSString stringWithFormat:@"%@ %@ %@",s1,s2,s3];
        return turntoCarIDString;
    }
}
///格式化手机号
-(NSString *)ACFormatMobile:(NSString *)str{
    if (str.length<10) {//含固定电话
        return str;
    }else{
        NSString *s1=[str substringToIndex:3];
        NSString *s2=[str substringWithRange:NSMakeRange(3, 4)];
        NSString *s3=[str substringFromIndex:7];
        DLog(@"%@,%@,%@",s1,s2,s3);
        NSString *turntoCarIDString=[NSString stringWithFormat:@"%@ **** %@",s1,s3];
        return turntoCarIDString;
    }
}
///格式化身份证号
-(NSString *)ACFormatIDC:(NSString *)str{
    if (str.length==18) {
        NSString *s1=[str substringToIndex:3];
        NSString *s2=[str substringWithRange:NSMakeRange(3, 3)];
        NSString *s3=[str substringWithRange:NSMakeRange(6, 4)];
        NSString *s4=[str substringWithRange:NSMakeRange(10, 4)];
        NSString *s5=[str substringFromIndex:14];
        DLog(@"%@,%@,%@,%@,%@",s1,s2,s3,s4,s5);
        NSString *turntoCarIDString=[NSString stringWithFormat:@"%@ %@ %@ %@ %@",s1,s2,s3,s4,s5];
        return turntoCarIDString;
    }else if(str.length>=15){
        NSString *s1=[str substringToIndex:(str.length-8)];
        NSString *s4=[str substringWithRange:NSMakeRange((str.length-8), 4)];
        NSString *s5=[str substringFromIndex:(str.length-4)];
        DLog(@"%@,%@,%@",s1,s4,s5);
        NSString *turntoCarIDString=[NSString stringWithFormat:@"%@ %@ %@",s1,s4,s5];
        return turntoCarIDString;
    }else{
        return str;
    }
}

//// 格式化组织机构代码证
-(NSString *)ACFormatOCC:(NSString *)str{
    if (str.length<9) {
        return str;
    }else{
        NSString *s1=[str substringToIndex:4];
        NSString *s2=[str substringWithRange:NSMakeRange(4, 4)];
        NSString *s3=[str substringFromIndex:8];
        DLog(@"%@,%@,%@",s1,s2,s3);
        NSString *turntoCarIDString=[NSString stringWithFormat:@"%@ %@ %@",s1,s2,s3];
        return turntoCarIDString;
    }
}
////格式化车牌号
-(NSString *)ACFormatPlate:(NSString *)str{
    if (str.length<7) {
        return str;
    }else{
        NSString *s1=[str substringToIndex:(str.length-5)];
        NSString *s2=[str substringWithRange:NSMakeRange((str.length-5), 5)];
        DLog(@"%@,%@",s1,s2);
        NSString *turntoCarIDString=[NSString stringWithFormat:@"%@ %@",s1,s2];
        return turntoCarIDString;
    }
}
//格式化vin
-(NSString *)ACFormatVin:(NSString *)str{
    if (str.length<17) {
        return str;
    }
    else
    {
        NSString *s1=[str substringToIndex:4];
        NSString *s2=[str substringWithRange:NSMakeRange(4, 4)];
        NSString *s3=[str substringWithRange:NSMakeRange(8, 1)];
        NSString *s4=[str substringWithRange:NSMakeRange(9, 4)];
        NSString *s5=[str substringWithRange:NSMakeRange(13, 4)];
        DLog(@"%@,%@,%@,%@,%@",s1,s2,s3,s4,s5);
        NSString *turntoVinString=[NSString stringWithFormat:@"%@ %@ %@ %@ %@",s1,s2,s3,s4,s5];
        return turntoVinString;
    }
}
//------数字格式化----------------
-(NSString*)ACFormatNumStr:(NSString*)nf
{
    float f=[nf floatValue];
//    DLog(@"%f",f);//
//    NSNumberFormatter * formatter=[[NSNumberFormatter alloc]init];
//    formatter.numberStyle=kCFNumberFormatterDecimalStyle;
//    NSString *turnstr=[formatter stringFromNumber:[NSNumber numberWithFloat:f]];
//    NSRange range=[turnstr rangeOfString:@"."];
//    if (range.length==0) {
//        turnstr =[turnstr stringByAppendingString:@".00"];
//    }
//    DLog(@"turnstr=%@_________range.length:%d",turnstr,range.location);
//    if ([[turnstr substringWithRange:NSMakeRange(turnstr.length-2, 1)] isEqualToString:@"."]) {
//        turnstr=[turnstr stringByAppendingString:@"0"];
//    }
//    NSRange range2=[turnstr rangeOfString:@"."];
//    turnstr=[turnstr substringToIndex:range2.location+3];
    
    NSNumberFormatter * formatter=[[NSNumberFormatter alloc]init];
    formatter.numberStyle=kCFNumberFormatterDecimalStyle;//kCFNumberFormatterCurrencyStyle;//kCFNumberFormatterDecimalStyle;//kCFNumberFormatterCurrencyStyle;
    NSString *turnstr=[formatter stringFromNumber:[NSNumber numberWithFloat:f]];
  
    
//    DLog(@"turnstr=%@_______",turnstr);
    
//    turnstr=[turnstr substringFromIndex:1];
//    
//    DLog(@"turnstr=%@___asdfasdfas____",turnstr);
    return turnstr;
}
-(NSString *)ZKFromatNumStr:(NSString *)nf{
    float f=[nf floatValue];
    NSNumberFormatter * formatter=[[NSNumberFormatter alloc]init];
    formatter.numberStyle=kCFNumberFormatterDecimalStyle;
    NSString *turnstr=[formatter stringFromNumber:[NSNumber numberWithFloat:f]];
    
//        DLog(@"turnstr=%@___asdfasdfas____",turnstr);
    return turnstr;
    
}
//格式化身份证号
-(NSString *)ACFormatIDC_DH:(NSString *)str{
    if (str.length==18) {
        NSString *s1=[str substringToIndex:3];
        NSString *s2=[str substringWithRange:NSMakeRange(3, 3)];
        NSString *s3=[str substringWithRange:NSMakeRange(6, 4)];
        NSString *s4=[str substringWithRange:NSMakeRange(10, 4)];
        NSString *s5=[str substringFromIndex:14];
        DLog(@"%@,%@,%@,%@,%@",s1,s2,s3,s4,s5);
        NSString *turntoCarIDString=[NSString stringWithFormat:@"%@ %@ %@ %@ %@",s1,s2,@"****",@"****",@"****"];
        return turntoCarIDString;
    }else if(str.length>=15){
        NSString *s1=[str substringToIndex:(str.length-8)];
        NSString *s4=[str substringWithRange:NSMakeRange((str.length-8), 4)];
        NSString *s5=[str substringFromIndex:(str.length-4)];
        DLog(@"%@,%@,%@",s1,s4,s5);
        NSString *turntoCarIDString=[NSString stringWithFormat:@"%@ %@ %@",s1,@"****",@"****"];
        return turntoCarIDString;
    }else{
        return str;
    }
}
//格式化vin2
-(NSString *)ACFormatVin_DH:(NSString *)str{
    if (str.length<17) {
        return str;
    }
    else
    {
        NSString *s1=[str substringToIndex:4];
        NSString *s2=[str substringWithRange:NSMakeRange(4, 4)];
        NSString *s3=[str substringWithRange:NSMakeRange(8, 1)];
        NSString *s4=[str substringWithRange:NSMakeRange(9, 4)];
        NSString *s5=[str substringWithRange:NSMakeRange(13, 4)];
        DLog(@"%@,%@,%@,%@,%@",s1,s2,s3,s4,s5);
        NSString *turntoVinString=[NSString stringWithFormat:@"%@ %@ %@ %@ %@",s1,@"****",s3,@"****",s5];
        return turntoVinString;
    }
}


#pragma mark CLLocationManagerDelegate

-(void)loadUserLocation:(LocationUserDataBlock)isSuccess{
    self.loactionUserData = isSuccess;
    //初始化位置管理器
    locManager = [[CLLocationManager alloc]init];
    //设置代理
    locManager.delegate = self;
    if (kVersion8) {
        if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined){
            [locManager requestWhenInUseAuthorization];
        }
        [locManager requestAlwaysAuthorization];
    }
    //设置位置经度
    locManager.desiredAccuracy = kCLLocationAccuracyBest;
    //设置每隔-米更新位置
    locManager.distanceFilter = 10;
    //开始定位服务
    [locManager startUpdatingLocation];
    
    if (![CLLocationManager locationServicesEnabled]) {
//        DLog(@"定位服务当前可能尚未打开，请设置打开！");
        [self ShowMessage:nil msg:@"定位服务当前可能尚未打开，请在设置中打开！"];
    }
//    self.userlatitude=@"31.165367";
//    self.userlongitude=@"121.407257";
}

//协议中的方法，作用是每当位置发生更新时会调用的委托方法
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    //结构体，存储位置坐标
    CLLocationCoordinate2D loc = [newLocation coordinate];
    float longitude = loc.longitude;
    float latitude = loc.latitude;
    DLog(@"longitude:%f,latitude:%f",longitude,latitude);
    self.userlatitude=[NSString stringWithFormat:@"%f",latitude];
    self.userlongitude=[NSString stringWithFormat:@"%f",longitude];
    
    self.loactionUserData?self.loactionUserData(YES):nil;
    self.loactionUserData = nil;
    [locManager stopUpdatingLocation];
    
}

//当位置获取或更新失败会调用的方法
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSString *errorMsg = nil;
    if ([error code] == kCLErrorDenied) {
        errorMsg = @"访问被拒绝";
    }
    if ([error code] == kCLErrorLocationUnknown) {
        errorMsg = @"获取位置信息失败";
    }
    self.loactionUserData?self.loactionUserData(NO):nil;
    self.loactionUserData = nil;
    
//    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Location"
//                                                       message:errorMsg delegate:self cancelButtonTitle:@"Ok"otherButtonTitles:nil, nil];
//    [alertView show];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    switch (status) {
            
        case kCLAuthorizationStatusNotDetermined:
            
            if ([locManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                
                [locManager requestWhenInUseAuthorization];
                
            }
            
            break;
            
        default:
            
            break;
            
    }
    
    
}



//
//#pragma mark websocket
//-(void)WebSocketConnectServer{
//    abool_backPassword_socket=NO;
//    if (!self.srWebSocket.url || ![self.srWebSocket.url isEqual:[NSURL URLWithString:LikeWEBsocket]]) {
//        //启动socket
//        if (self.srWebSocket) {
//            if (self.srWebSocket.readyState==1) {
//                [self.srWebSocket close];
//            }
//        }
//        self.srWebSocket=nil;
//        self.srWebSocket = [[SRWebSocket alloc]initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:LikeWEBsocket]]];
//        self.srWebSocket.delegate = self;
//        
//        [self.srWebSocket open];
//    }
//}
//-(void)WebSocketLogin{
//    if (self.srWebSocket.readyState==1) {
//        NSMutableDictionary *parmna = [NSMutableDictionary dictionary ];
//        [parmna setValue:[NSString stringWithFormat:@"%@",self.userId] forKey:@"uid"];
//        [parmna setValue:@"re_login" forKey:@"type"];
////        [parmna setValue:self.usercompany_id forKey:@"room_id"];
//        [parmna setValue:self.userToken forKey:@"token"];
//        [parmna setValue:@"1" forKey:@"hairstylist"];
//        
//        DLog(@"scoketLogin:%@",parmna);
//        [self.srWebSocket send:[parmna JSONString]];
//        
//    }else{
//        [self alertConnectServer];
//    }
//   
//}
//
//////忘记密码-（发送）
//-(void)WebSocketLoginAndSend:(NSDictionary *)dic{
//    
//    [self WebSocketConnectServer];
//    
//    abool_backPassword_socket=YES;
//    
//}
/////检测连接
//-(void)webSocketDetection{
//    if (self.srWebSocket.readyState==1) {
//        DLog(@"是连接上的");
//    }else{
//        if ([LikeWEBsocket notEmptyOrNull] && [self.userId notEmptyOrNull] && [self.userToken notEmptyOrNull]) {
//            [self WebSocketConnectServer];
//        }
//    }
//    
//}
//-(void)WebSocketsend:(NSString *)strJson{
//    if (self.srWebSocket.readyState==1) {
//        DLog(@"message:______%@",strJson);
//        [self.srWebSocket send:strJson];
//        
//    }else{
//        [self alertConnectServer];
//    }
//}
//-(void)websocketClose{
//    if (self.srWebSocket.readyState==1) {
//        [self.srWebSocket close];
//    }
//    self.srWebSocket=nil;
//}
//
//#pragma mark - SRWebSocketDelegate
//- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
//{
//    NSLog(@"didReceiveMessage___%@",message);
//    NSDictionary *dic =  [message objectFromJSONString];
//    
//    if ([[dic valueForJSONStrKey:@"type"] isEqualToString:@"relogin"] && ![[dic valueForJSONStrKey:@"token"] isEqualToString:self.userToken] ){
//        //token过期
//        [[Utility Share] showAgainLoginMessage:[dic valueForJSONStrKey:@"msg"]];
//        [self performSelector:@selector(showwebScoketLogin) withObject:nil afterDelay:0.1];
//        
//        
//    }else if ([[dic valueForJSONStrKey:@"type"] isEqualToString:@"setclock"]){
//        //、、setclock
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshLocalNotificationData" object:nil];
//    }else if ([[dic valueForJSONStrKey:@"type"] isEqualToString:@"forcedoutline"]){
//        ///（判断是否是自己）
//        NSString *typeC=[dic valueForJSONStrKey:@"typePlatform"];
//       
//        if (abool_backPassword_socket) {
//            ///自己(找回密码)
//            self.userId=@"";
//            ///找回密码--关闭socket
//            [self websocketClose];
//        }else  if (![typeC isEqualToString:[NSString stringWithFormat:@"ios_%@",[[Utility Share] zkUpdatePwdType]]]) {///（判断是否是自己）///不是当前发出的
//            NSString *timeT=[dic valueForJSONStrKey:@"time"];
//             if ([timeT notEmptyOrNull] && ![timeT isEqualToString:@"0"]) {// 判断时间
//                 NSDate *dateA = [NSDate dateWithTimeIntervalSince1970:[timeT integerValue]];
//                 NSDate *dateB = [NSDate dateWithTimeIntervalSince1970:[[[Utility Share] zkLoginDate] integerValue]];//登录时间
//                 NSComparisonResult result = [dateA compare:dateB];
//                 if (result == NSOrderedDescending) {
//                     //NSLog(@"DateA  is in the future");
//                     ///2016-06-21 修改 修改密码前登录
//                     [[Utility Share] showAgainLoginMessage:[dic valueForJSONStrKey:@"msg"]];
//                     [self performSelector:@selector(showwebScoketLogin) withObject:nil afterDelay:0.1];                     
//                 }else if (result == NSOrderedAscending){
//                     //NSLog(@"DateA is in the past");
//                     //修改密码后登录不处理
//                 }
//                 
//                
//            }else{
//                ///强制下线（更改过权限之类造成   2016-06-03）
//                ///2016-06-17 修改 ios_%@
//                [[Utility Share] showAgainLoginMessage:[dic valueForJSONStrKey:@"msg"]];
//                [self performSelector:@selector(showwebScoketLogin) withObject:nil afterDelay:0.1];
//            }
//        }
//        
//    }else if (([[dic valueForJSONStrKey:@"type"] isEqualToString:@"say"] || [[dic valueForJSONStrKey:@"type"] isEqualToString:@"roomsay"])  &&  ![[dic valueForJSONStrKey:@"from_client_id"] isEqualToString:[NSString stringWithFormat:@"%@_%@",self.usercompany_id,self.userId]] ) {
//        if (!self.isDefaultNOStartSystemShake && !self.isNOStartVibrate) {
//            [self StartSystemShake];
//            
//        }
//        if (!self.isDefaultNOplaySystemSound && !self.isNOplaySystemSound) {
//            [self playSystemSound];
//        }
//        UITabBar *bar=[[[Utility Share] CustomTabBar_zk] tabBar];
//       
//        UIView *vt=[bar viewWithTag:204];
//        vt.hidden=NO;
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"webSocketMessage" object:nil userInfo:dic];
//       
//    }else if ([[dic valueForJSONStrKey:@"type"] isEqualToString:@"friendsnotice"]){
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"friendsnotice" object:dic];
//        
//    }else if ([self.userId notEmptyOrNull] && ![[dic objectForJSONKey:@"status"] boolValue]&& [[dic objectForJSONKey:@"msg"] isKindOfClass:[NSString class]] && [[dic objectForJSONKey:@"msg"] isEqualToString:@"login failed"] ) {
//       
//        //登录失败断开连接
//        [self websocketClose];
//        
//    }else  if ([self.userId notEmptyOrNull] && [[dic objectForJSONKey:@"status"] boolValue]&& [[dic objectForJSONKey:@"msg"] isKindOfClass:[NSString class]] && [[dic objectForJSONKey:@"msg"] isEqualToString:@"login success"] ) {
//        //登录成功！
//        if (abool_backPassword_socket) {
//            ///找回密码
//            /*
//             2016-06-17
//             */
//            NSDictionary *dictemp=@{@"type":@"outline",
//                                    @"action":@"findpwd",
//                                    @"time":[[Utility Share] zkUpdatePwdDate],
//                                    @"typePlatform":[NSString stringWithFormat:@"ios_%@",[[Utility Share] zkUpdatePwdType]],//
////                                    @"mobile":[[Utility Share] userMobile],
//                                    @"companyid":[[Utility Share] usercompany_id],
//                                    @"uid":[[Utility Share] userId]};
//            
//            [self.srWebSocket send:[dictemp JSONString]];
//            DLog(@"___忘记密码_________socket成功");
//        }else{
//        
//            intConnectionNum=0;
//            //向自己发送一个消息
//            
//            NSMutableDictionary *parmna = [NSMutableDictionary dictionary ];
//            [parmna setValue:self.userId forKey:@"uid"];
//            [parmna setValue:@"relogintips" forKey:@"type"];
//            [parmna setValue:@"HairStylist" forKey:@"app_type"];
////            [parmna setValue:self.usercompany_id forKey:@"room_id"];
//            [parmna setValue:self.userToken forKey:@"token"];
//            
//            DLog(@"scoketLogin:%@",parmna);
//            [self.srWebSocket send:[parmna JSONString]];
//            
//            DLog(@"____________socket登录成功");
//        }
//        
//        
//    }
//}
//-(void)showwebScoketLogin{
//    [self clearUserInfoInDefault];
//    [[Utility Share] showLoginAlert:YES];
//}
//
//
//- (void)webSocketDidOpen:(SRWebSocket *)webSocket
//{
//    DLog(@"webSocket.readyState：%d",webSocket.readyState);
//    
//    if (webSocket.readyState==1) {
//        DLog(@"____________连接成功");
//        if ([self.userId notEmptyOrNull]) {
//            [self WebSocketLogin];
//        }else{
//            
//            [SVProgressHUD showImage:nil status:@"登录失败，请重新登录"];
//        }
//    }else{
//        if ([self.userId notEmptyOrNull] && webSocket.readyState!=SR_CLOSED) {
//            
//            [self alertConnectServer];
//        }
//    }
//    
//}
//- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
//{
//    DLog(@"失败___%@___",error);
//    if ([self.userId notEmptyOrNull] && [webSocket.url isEqual:[NSURL URLWithString:LikeWEBsocket]]) {
//        self.srWebSocket = nil;
//        [self alertConnectServer];
//    }else{
//        self.srWebSocket = nil;
//    }
//    
//}
//- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClea
//{
//    DLog(@"didCloseWithCode_%@___:%@",self.userId,webSocket.url);
//    if ([self.userId notEmptyOrNull] && [webSocket.url isEqual:[NSURL URLWithString:LikeWEBsocket]]) {
//        self.srWebSocket = nil;
//        [self alertConnectServer];
//    }else{
//        self.srWebSocket = nil;
//    }
//}
//-(void)alertConnectServer{
//    intConnectionNum++;
//    //自动连接5次
////    if (intConnectionNum>10) {
////        //
////        if (!abool_backPassword_socket) {
////            if (alertTempScorket) {
////                [alertTempScorket dismissWithClickedButtonIndex:0 animated:YES];
////                alertTempScorket=nil;
////            }
////            alertTempScorket=[[UIAlertView alloc] initWithTitle:@"哎呀！服务器连接失败！" message:@"请检查网络是否正常，确定重新连接服务器" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"重新连接", nil];
////            [alertTempScorket show];
////        }else{
////            DLog(@"找回密码socket发送失败");
////        }
////       
////    }else{
//        DLog(@"自动连接socket");
//        if (abool_backPassword_socket) {
//            [ self WebSocketConnectServer];
//        }else{
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [ self WebSocketConnectServer];
//            });
//        }
//        
////    }
//}

//
#pragma mark 振动
- (void)StartSystemShake {
    if (!SIMULATOR) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
}


//播放提示音
-(void)playSystemSound{
//    if (!SIMULATOR) {
    
        if (!sound) {
            /*
             ReceivedMessage.caf--收到信息，仅在短信界面打开时播放。
             sms-received1.caf-------三全音
             sms-received2.caf-------管钟琴
             sms-received3.caf-------玻璃
             sms-received4.caf-------圆号
             sms-received5.caf-------铃声
             sms-received6.caf-------电子乐
             SentMessage.caf--------发送信息
             
             */
            
            NSString *path = [NSString stringWithFormat:@"/System/Library/Audio/UISounds/%@.%@",@"sms-received1",@"caf"];
            //[[NSBundle bundleWithIdentifier:@"com.apple.UIKit" ]pathForResource:soundName ofType:soundType];//得到苹果框架资源UIKit.framework ，从中取出所要播放的系统声音的路径
            //[[NSBundle mainBundle] URLForResource: @"tap" withExtension: @"aif"];  获取自定义的声音
            if (path) {
                OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&sound);
                
                if (error != kAudioServicesNoError) {//获取的声音的时候，出现错误
                    DLog(@"获取的声音的时候，出现错误");
                    //加载资源文件路径
                    NSString *resoursePath=[[NSBundle mainBundle]pathForResource:@"sms-received1_zk.caf" ofType:nil];
                    OSStatus errorT = AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:resoursePath],&sound);
                    if (errorT != kAudioServicesNoError) {//获取的声音的时候，出现错误
                        DLog(@"本地声音出现错误");
                    }
                }
            }
        }
        if (sound) {
            AudioServicesPlaySystemSound(sound);
        }
        
        
        
        
//    }
    
    
}

#pragma mark  启动过渡图片
-(void)showStartTransitionView{
    if (!startView) {
        [self updateAPPStartPageADData];
        startView=[[StartTransitionView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    [startView show];
}
///引导页
-(void)showStartGuideTransitionView{
    if (!startView) {
        [self updateAPPStartPageADData];
        startView=[[StartTransitionView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    [startView showGuide];
}
-(void)hiddenStartTransitionView:(BOOL)stopCountDown{
    if (startView) {
        if (stopCountDown) {
            startView.isStopCountdown=YES;
        }
        startView.isStopDataInteraction=YES;
        [startView hidden];
    }
}

-(void)updateAPPStartPageADData{
    [NetEngine createGetAction_LJ:MFuseronpage onCompletion:^(id resData, BOOL isCache) {
        if ([[resData valueForJSONStrKey:@"status"] isEqualToString:@"200"]) {
            [self updateADImageData:[resData objectForJSONKey:@"data"]];
        }
    }];
}
-(void)updateADImageData:(NSDictionary *)dic{
    if ([[dic allKeys] count]) {
        NSString *url=[dic valueForJSONStrKey:@"path"];
        NSString *urlImage =[url hasPrefix:@"http"]?url:[NSString stringWithFormat:@"http://%@%@",basePicPath,url];
        [NetEngine imageAtURL:urlImage onCompletion:^(UIImage *fetchedImage, NSURL *url, BOOL isInCache) {
            __block BOOL isDir = YES;
            NSString *strFile=[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"adImage55like"];
            if (![[NSFileManager defaultManager]fileExistsAtPath:strFile isDirectory:&isDir ]) {// isDir判断是否为文件夹
                [[NSFileManager defaultManager]createDirectoryAtPath:strFile withIntermediateDirectories:YES attributes:nil error:nil];
            }
            DLog(@"[urlImage pathExtension]:%@",[urlImage pathExtension])
            NSString *strFileName=@"startPageAdImage.jpg";
            if([[urlImage pathExtension] isEqualToString:@"gif"]) {
                //gif
                strFileName = @"startPageAdImage.gif";
            }
            
            NSString *strpath=[strFile stringByAppendingPathComponent:strFileName];
            [[NetEngine Share] saveCache];
            [[NSFileManager defaultManager] removeItemAtPath:strpath error:nil];
            if([[NSFileManager defaultManager] fileExistsAtPath:strpath] == NO)
            {
                NSString *strImageKey=[[NSString stringWithFormat:@"%@ %@",@"GET",urlImage] md5];
                NSString *filePath_old = [[[NetEngine Share] cacheDirectoryName] stringByAppendingPathComponent:strImageKey];
                //复制文件(to 不能是已存在的)
                bool abool=[[NSFileManager defaultManager] copyItemAtPath:filePath_old toPath:strpath error:nil];
               
                if (abool) {
                    DLog(@"启动图片成功");
                    NSMutableDictionary *dicTemp=[[NSMutableDictionary alloc] initWithDictionary:dic];
                    [dicTemp setValue:strFileName forKey:@"imageFile"];
                    [Utility saveToDefaults:dicTemp forKey:default_APPStartPageAD];
                    
                }else{
                    DLog(@"文件失败");
                }

            }
            
//            //比例压缩
//            NSData *tData = UIImageJPEGRepresentation(fetchedImage, 1);
//            BOOL abool=[tData writeToFile:strpath atomically:YES];
        }];
    }else{
        [Utility removeForKey:default_APPStartPageAD];
    }
    

}



- (float)freeDiskSpace

{
    
    NSError *error = nil;
    float totalFreeSpace;
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (fattributes) {
        NSNumber *freeFileSystemSizeInBytes = [fattributes objectForKey:NSFileSystemFreeSize];
        totalFreeSpace = [freeFileSystemSizeInBytes floatValue];
        
    } else {
        
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    return totalFreeSpace;
    
}


#pragma mark 提示信息
-(void)showAgainLoginMessage:(NSString *)strMessage{
    if (!aboolAgainLogin_message && !aboolOneLogin) {
        aboolAgainLogin_message=YES;
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"下线提醒" message:strMessage delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        alert.tag=1010;
        [alert show];
    }
}



////用户权限获取
-(void)showAccessPermissionsAlertViewMessage:(NSString *)str{
    UIAlertView *alertV=[[UIAlertView alloc] initWithTitle:nil message:str delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"前往设置", nil];
    alertV.tag=121;
    [alertV show];
}


///生成二维码
-(UIImage *)generatedCode:(NSString *)str withSize:(CGFloat )fw{
    //二维码滤镜
    
    CIFilter *filter=[CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    //恢复滤镜的默认属性
    
    [filter setDefaults];
    
    //将字符串转换成NSData
    
    NSData *data=[str dataUsingEncoding:NSUTF8StringEncoding];
    
    //通过KVO设置滤镜inputmessage数据
    
    [filter setValue:data forKey:@"inputMessage"];
    
    //获得滤镜输出的图像
    
    CIImage *outputImage=[filter outputImage];
    
    //将CIImage转换成UIImage,并放大显示
    
    return  [self createNonInterpolatedUIImageFormCIImage:outputImage withSize:fw];
    

}
//改变二维码大小
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    
    CGRect extent = CGRectIntegral(image.extent);
    
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 创建bitmap;
    
    size_t width = CGRectGetWidth(extent) * scale;
    
    size_t height = CGRectGetHeight(extent) * scale;
    
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    
    CGContextScaleCTM(bitmapRef, scale, scale);
    
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 保存bitmap到图片
    
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    
    CGContextRelease(bitmapRef);
    
    CGImageRelease(bitmapImage);
    
    return [UIImage imageWithCGImage:scaledImage];
    
}

#pragma mark Share
////分享
- (void)showShareData:(NSDictionary *)dic suc:(ShareActionSuc)shareS
{
//    self.shareSuc = shareS;
//    NSString *strTitle=[dic valueForJSONStrKey:@"title"];
//    if (strTitle.length>25) {
//        strTitle=[NSString stringWithFormat:@"%@...",[strTitle substringToIndex:25]];
//    }
//    NSString *strContent=[dic valueForJSONStrKey:@"descr"];
//    if (strContent.length>50) {
//        strContent=[NSString stringWithFormat:@"%@...",[strContent substringToIndex:50]];
//    }
//    
//    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
//    
//    NSArray* imageArray ;
//    if ([[dic valueForJSONStrKey:@"src"] notEmptyOrNull]) {
//        imageArray= @[[NSURL URLWithString:[dic valueForJSONStrKey:@"src"]]];
//    }
//    [shareParams SSDKSetupShareParamsByText:[NSString stringWithFormat:@"%@ %@",strContent,[dic valueForJSONStrKey:@"url"]]
//                                     images:imageArray
//                                        url:[NSURL URLWithString:[dic valueForJSONStrKey:@"url"]]
//                                      title:strTitle
//                                       type:SSDKContentTypeAuto];
//    
//    [ShareSDK showShareActionSheet:nil items:nil shareParams:shareParams onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
//        if (state==SSDKResponseStateSuccess) {
//            DLog(@"____成功");
//            self.shareSuc?self.shareSuc(1):nil;
//            self.shareSuc = nil;
//        }else if (state==SSDKResponseStateFail){
//            DLog(@"\n\nerror:%@\n\n",error);
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
//                                                            message:[NSString stringWithFormat:@"%@",error]
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"OK"
//                                                  otherButtonTitles:nil, nil];
//            [alert show];
//            self.shareSuc?self.shareSuc(0):nil;
//            self.shareSuc = nil;
//        }else{
//            
//        }
//    
//    }];
//    
    
}



#pragma mark - gotopayforAlipay
///支付
/*
 order_id     //订单ID
 member_name  //商品标题
 tostr        //商品描述
 fee_amount   //商品价格
 notify_url   //回调URL
 
 */
-(void)showAlipay:(NSDictionary *)dict{
    DLog(@"showAlipaydict :%@",dict);
//   
//    NSString *signedString = [dict valueForJSONStrKey:@"msg"];
//    
//    // NOTE: 如果加签成功，则继续执行支付
//    if (signedString != nil) {
//        //应用注册scheme,在AliSDKDemo-Info.plist定义URL types
//        NSString *appScheme = @"JiuSheng55likeAlipay";
//        
////        // NOTE: 将签名成功字符串格式化为订单字符串,请严格按照该格式
////        NSString *orderString =@"";// [NSString stringWithFormat:@"%@&sign=%@",                                 orderInfoEncoded, signedString];
//        
//        // NOTE: 调用支付结果开始支付
//        [[AlipaySDK defaultService] payOrder:signedString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
//            NSLog(@"reslut = %@________%@",resultDic,[resultDic valueForJSONStrKey:@"memo"]);
//            if ([[resultDic valueForJSONStrKey:@"resultStatus"]isEqualToString:@"9000"]) {
//                //成功
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"ZFBPay" object:nil];
//            }else if ([[resultDic valueForJSONStrKey:@"resultStatus"]isEqualToString:@"8000"]){
//                //验证
//                [NetEngine createGetAction:[NSString stringWithFormat:JSordersqueryorder,[[Utility Share] userId],[[Utility Share] userToken],[[Utility Share] userPayOrderId]] onCompletion:^(id resData, BOOL isCache) {
//                    if ([[resData valueForJSONStrKey:@"status"] isEqualToString:@"200"]) {
//                        if ([[resData objectForJSONKey:@"data"] valueForJSONStrKey:@"1"]) {
//                            [SVProgressHUD showSuccessWithStatus:@"支付成功！"];
//                            [[NSNotificationCenter defaultCenter] postNotificationName:@"ZFBPay" object:nil];
//                        }else{
//                            [SVProgressHUD showImage:nil status:[resData valueForJSONStrKey:@"msg"]];
//                        }
//                    }else{
//                        [SVProgressHUD showImage:nil status:[resData valueForJSONStrKey:@"msg"]];
//                    }
//                }];
//            }else{
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"支付失败！" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                [alert show];
//            }
//        }];
//    }
  
    
}

///微信支付
-(void)showWeChat:(NSDictionary *)dict{
    DLog(@"orderId:%@",self.userPayOrderId);
    DLog(@"showWeChat :%@",dict);
//    if (![[dict valueForJSONStrKey:@"prepayid"] notEmptyOrNull]) {
//        [SVProgressHUD showImage:nil status:@"参数获取失败！"];
//        return;
//    }
//    NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
//    //调起微信支付
//    PayReq* req             = [[PayReq alloc] init];
//    /** 由用户微信号和AppID组成的唯一标识，发送请求时第三方程序必须填写，用于校验微信用户是否换号登录*/
//    req.openID              = [dict valueForJSONStrKey:@"appid"];
//      /** 商家向财付通申请的商家id */
//    req.partnerId           = [dict valueForJSONStrKey:@"partnerid"];
//        /** 预支付订单 */
//    req.prepayId            = [dict valueForJSONStrKey:@"prepayid"];
//        /** 随机串，防重发 */
//    req.nonceStr            = [dict valueForJSONStrKey:@"noncestr"];
//        /** 时间戳，防重发 */
//    req.timeStamp           = stamp.intValue;
//       /** 商家根据财付通文档填写的数据和签名 */
//    req.package             = [dict valueForJSONStrKey:@"package"];
//        /** 商家根据微信开放平台文档对数据做的签名 */
//    req.sign                = [dict valueForJSONStrKey:@"sign"];
//    BOOL ab=[WXApi sendReq:req];
//    //日志输出
//    NSLog(@"_____wxBool:%d______________appid=%@\npartnerid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%ld\npackage=%@\nsign=%@",ab,req.openID,req.partnerId,req.prepayId,req.nonceStr,(long)req.timeStamp,req.package,req.sign );
//    
    
}

/// Get IP Address  ipv4
- (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}
/// Get IP Address  ipv6
- (NSString *)getIPAddressIpv6
{
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    NSString *wifiAddress = nil;
    NSString *cellAddress = nil;
    
    // retrieve the current interfaces - returns 0 on success
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            sa_family_t sa_type = temp_addr->ifa_addr->sa_family;
            if(sa_type == AF_INET || sa_type == AF_INET6) {
                NSString *name = [NSString stringWithUTF8String:temp_addr->ifa_name];
                NSString *addr = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)]; // pdp_ip0
                NSLog(@"NAME: \"%@\" addr: %@", name, addr); // see for yourself
                
                if([name isEqualToString:@"en0"]) {
                    // Interface is the wifi connection on the iPhone
                    wifiAddress = addr;
                } else
                    if([name isEqualToString:@"pdp_ip0"]) {
                        // Interface is the cell connection on the iPhone
                        cellAddress = addr;
                    }
            }
            temp_addr = temp_addr->ifa_next;
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    NSString *addr = wifiAddress ? wifiAddress : cellAddress;
    return addr ? addr : @"0.0.0.0";
}



/**
 *  返回相册
 */
- (PHAssetCollection *)collection{
    NSString *app_Name = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    // 先获得之前创建过的相册
    PHFetchResult<PHAssetCollection *> *collectionResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in collectionResult) {
        if ([collection.localizedTitle isEqualToString:app_Name]) {
            return collection;
        }
    }
    
    // 如果相册不存在,就创建新的相册(文件夹)
    __block NSString *collectionId = nil; // __block修改block外部的变量的值
    // 这个方法会在相册创建完毕后才会返回
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        // 新建一个PHAssertCollectionChangeRequest对象, 用来创建一个新的相册
        collectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:app_Name].placeholderForCreatedAssetCollection.localIdentifier;
    } error:nil];
    
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[collectionId] options:nil].firstObject;
}


/**
 *  写入本地相册
 */
- (void)saveImageLocalAlbum:(UIImage *)imageS{
    /*
     PHAsset : 一个PHAsset对象就代表一个资源文件,比如一张图片
     PHAssetCollection : 一个PHAssetCollection对象就代表一个相册
     */
    
    __block NSString *assetId = nil;
    // 1. 存储图片到"相机胶卷"
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{ // 这个block里保存一些"修改"性质的代码
        // 新建一个PHAssetCreationRequest对象, 保存图片到"相机胶卷"
        // 返回PHAsset(图片)的字符串标识
        assetId = [PHAssetCreationRequest creationRequestForAssetFromImage:imageS].placeholderForCreatedAsset.localIdentifier;
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (error) {
            DLog(@"保存图片到相机胶卷中失败");
            [SVProgressHUD showImage:nil status:@"保存图片到相机胶卷中失败"];
            return;
        }
        DLog(@"成功保存图片到相机胶卷中");
        
        // 2. 获得相册对象
        PHAssetCollection *collection = [self collection];
        
        // 3. 将“相机胶卷”中的图片添加到新的相册
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
            
            // 根据唯一标示获得相片对象
            PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil].firstObject;
            // 添加图片到相册中
            [request addAssets:@[asset]];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (error) {
                DLog(@"添加图片到相册中失败");
                [SVProgressHUD showImage:nil status:@"添加图片到相册中失败"];
                return;
            }
            DLog(@"成功添加图片到相册中");
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [SVProgressHUD showSuccessWithStatus:@"保存成功"];
            }];
        }];
    }];
}



@end
