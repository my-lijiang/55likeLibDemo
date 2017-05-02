

#import <UIKit/UIKit.h>
#import "Utility.h"
//#import "DMHessian.h"
#import "RHMethods.h"
#import "Foundation.h"
#import <SVProgressHUD.h>
#import "NSDictionary+expanded.h"
//#import "RHTableView.h"
//#import <Nimbus/NITableViewActions.h>
//#import <JSONKit.h>

//Category声明：
@interface UIControl (Additions)
- (void)removeAllTargets;
@end

//typedef id (^Block)(NITableViewActions *actions,NSArray *array);
@class RHTableView;
@interface BaseViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) UIView *navView;
@property (nonatomic,strong) id  userInfo;
@property (nonatomic,strong) id  otherInfo;
@property (nonatomic,strong) NSString *strBack;
@property (nonatomic,assign) BOOL  hideAudioPlayButton;///v3隐藏播放按钮

@property (nonatomic,strong) UIButton *navleftButton;
@property (nonatomic,strong) UIButton *navrightButton;
@property (nonatomic,strong) IBOutlet RHTableView *tableView;
- (IBAction)backButtonClicked:(id)sender;
- (IBAction)rootButtonClicked:(id)sender;
- (IBAction)backByButtonTagNavClicked:(UIButton*)sender;

- (BaseViewController*)pushController:(Class)controller withOnlyInfo:(id)info;
- (BaseViewController*)pushController:(Class)controller withInfo:(id)info;
- (BaseViewController*)pushController:(Class)controller withInfo:(id)info withTitle:(NSString*)title;
- (BaseViewController*)pushController:(Class)controller withInfo:(id)info withTitle:(NSString*)title withOther:(id)other;
- (BaseViewController*)pushController:(Class)controller withInfo:(id)info withTitle:(NSString*)title withOther:(id)other tabBar:(BOOL)abool;
- (BaseViewController*)pushController:(Class)controller withInfo:(id)info withTitle:(NSString*)title withOther:(id)other tabBar:(BOOL)tbool pushAdimated:(BOOL)abool;


//- (void)popController:(NSString*)controller withSel:(NSString*)sel withObj:(id)info;
- (void)popController:(NSString*)controller withSel:(SEL)sel withObj:(id)info;
- (CGFloat)heightForLabel:(CGFloat)_width font:(UIFont*)_font text:(NSString*)_text;
- (CGFloat)heightForLabel:(CGFloat)_width font:(UIFont*)_font text:(NSString*)_text floatLine:(CGFloat)_aLine;
- (CGFloat)heightForTextView:(CGFloat)_width font:(UIFont*)_font text:(NSString*)_text floatLine:(CGFloat)_aLine;


///评论表情行高
- (CGFloat)heightForCommentEmojiLabelText:(NSString*)_text;

- (UIButton*)backButton;
/*
 
 主栏目使用
 
 */
- (UIView*)navbarTitle:(NSString*)title;
- (UIButton*)leftButton:(NSString*)title image:(NSString*)image sel:(SEL)sel;
- (UIButton*)rightButton:(NSString*)title image:(NSString*)image sel:(SEL)sel;

/*- (void)UITableViewModel:(Block)block;

- (void)RHTableViewUrl:(NSString*)url;
- (void)RHTableViewBlock:(RHTableDataBlock)block;
- (void)RHTableViewWithRefresh:(BOOL)showRefresh withLoadmore:(BOOL)showLoadmore withMask:(SVProgressHUDMaskType)mask   Url:(NSString*)url withParam:(NSDictionary*)params data:(RHTableDataBlock)data_bk offline:(RHTableDataOfflineBlock)offline_bk loaded:(RHTableLoadedDataBlock)loaded_bk;
- (void)RHTableViewUrl:(NSString*)url withModel:(Block)block;
- (void)RHTableViewBlock:(RHTableDataBlock)datablock withModel:(Block)block;*/
@end
