

#import "RHMethods.h"
@implementation RHMethods

+ (UITextField *)textFieldlWithFrame:(CGRect)aframe font:(UIFont*)afont color:(UIColor*)acolor placeholder:(NSString *)aplaceholder text:(NSString*)atext{
    return [self textFieldlWithFrame:aframe font:afont color:acolor placeholder:aplaceholder text:atext supView:nil];
}
+ (UILabel*)labelWithFrame:(CGRect)aframe font:(UIFont*)afont color:(UIColor*)acolor text:(NSString*)atext{
    return [self labelWithFrame:aframe font:afont color:acolor text:atext supView:nil];
}
+ (UILabel*)labelWithFrame:(CGRect)aframe font:(UIFont*)afont color:(UIColor*)acolor text:(NSString*)atext textAlignment:(NSTextAlignment)aalignment{
    return [self labelWithFrame:aframe font:afont color:acolor text:atext textAlignment:aalignment supView:nil];
}
+ (UILabel*)labelWithFrame:(CGRect)aframe font:(UIFont*)afont color:(UIColor*)acolor text:(NSString*)atext textAlignment:(NSTextAlignment)aalignment setLineSpacing:(float)afloat{
    return [self labelWithFrame:aframe font:afont color:acolor text:atext textAlignment:aalignment setLineSpacing:afloat supView:nil];
}
+(UIButton*)buttonWithFrame:(CGRect)_frame title:(NSString*)_title  image:(NSString*)_image bgimage:(NSString*)_bgimage{
    return [self buttonWithFrame:_frame title:_title image:_image bgimage:_bgimage supView:nil];
}
+(UIImageView*)imageviewWithFrame:(CGRect)_frame defaultimage:(NSString*)_image{
    return [self imageviewWithFrame:_frame defaultimage:_image supView:nil];
}
+(UIImageView*)imageviewWithFrame:(CGRect)_frame defaultimage:(NSString*)_image contentMode:(UIViewContentMode )cmode{
    return [self imageviewWithFrame:_frame defaultimage:_image contentMode:cmode supView:nil];
}
+(UIImageView*)imageviewWithFrame:(CGRect)_frame defaultimage:(NSString*)_image stretchW:(NSInteger)_w stretchH:(NSInteger)_h{
    return [self imageviewWithFrame:_frame defaultimage:_image stretchW:_w stretchH:_h supView:nil];
}

///分割线
+(UIView *)lineViewWithFrame:(CGRect)_frame{
    return [self lineViewWithFrame:_frame supView:nil];
}



+ (UITextField *)textFieldlWithFrame:(CGRect)aframe font:(UIFont*)afont color:(UIColor*)acolor placeholder:(NSString *)aplaceholder text:(NSString*)atext supView:(UIView *)sView{
   UITextField *baseTextField=[[UITextField alloc]initWithFrame:aframe];
    [baseTextField setKeyboardType:UIKeyboardTypeDefault];
    [baseTextField setBorderStyle:UITextBorderStyleNone];
    [baseTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [baseTextField setTextColor:acolor];
    baseTextField.placeholder=aplaceholder;
    baseTextField.font=afont;
    [baseTextField setSecureTextEntry:NO];
    [baseTextField setReturnKeyType:UIReturnKeyDone];
    [baseTextField setText:atext];
    baseTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    if (sView) {
        [sView addSubview:baseTextField];
    }
    
    return baseTextField;
}


/**
 *	根据aframe返回相应高度的label（默认透明背景色，白色高亮文字）
 *
 *	@param	aframe	预期框架 若height=0则计算高度  若width=0则计算宽度
 *	@param	afont	字体
 *	@param	acolor	颜色
 *	@param	atext	内容
 *
 *	@return	UILabel
 */
+ (UILabel*)labelWithFrame:(CGRect)aframe font:(UIFont*)afont color:(UIColor*)acolor text:(NSString*)atext supView:(UIView *)sView
{
    return [self labelWithFrame:aframe font:afont color:acolor text:atext textAlignment:NSTextAlignmentLeft supView:sView];// autorelease];
}

/**
 *	根据aframe返回相应高度的label（默认透明背景色，白色高亮文字）
 *
 *	@param	aframe	预期框架 若height=0则计算高度  若width=0则计算宽度
 *	@param	afont	字体
 *	@param	acolor	颜色
 *	@param	atext	内容
 *  @param  aalignment   位置
 *  @param  afloat   行距(文本不能为空)
 *
 *	@return	UILabel
 */
+ (UILabel*)labelWithFrame:(CGRect)aframe font:(UIFont*)afont color:(UIColor*)acolor text:(NSString*)atext textAlignment:(NSTextAlignment)aalignment setLineSpacing:(float)afloat supView:(UIView *)sView
{
    UILabel *lblTemp=[self labelWithFrame:aframe font:afont color:acolor text:atext textAlignment:aalignment supView:sView];
    if (!aframe.size.height && [atext notEmptyOrNull]) {
        lblTemp.numberOfLines=0;
        
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:lblTemp.text];
        NSMutableParagraphStyle *paragraphStyleT = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyleT setLineSpacing:afloat];//调整行间距
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyleT range:NSMakeRange(0, [atext length])];
        lblTemp.attributedText = attributedString;
        
        CGSize size = [lblTemp sizeThatFits:CGSizeMake(aframe.size.width, MAXFLOAT)];
        aframe.size.height = size.height;
        lblTemp.frame=aframe;
        
    }
    return lblTemp;
}

+ (UILabel*)labelWithFrame:(CGRect)aframe font:(UIFont*)afont color:(UIColor*)acolor text:(NSString*)atext textAlignment:(NSTextAlignment)aalignment supView:(UIView *)sView
{
    UILabel *baseLabel=[[UILabel alloc] initWithFrame:aframe];
    if(afont)baseLabel.font=afont;
    if(acolor)baseLabel.textColor=acolor;
//     baseLabel.lineBreakMode=UILineBreakModeCharacterWrap;
    baseLabel.text=atext;
    baseLabel.textAlignment=aalignment;
    baseLabel.baselineAdjustment=UIBaselineAdjustmentAlignCenters;
    [baseLabel setLineBreakMode:NSLineBreakByTruncatingTail|NSLineBreakByWordWrapping];
    
    
    if(aframe.size.height>20){
        baseLabel.numberOfLines=0;
    }
    if (!aframe.size.height) {
        baseLabel.numberOfLines=0;
        CGSize size = [baseLabel sizeThatFits:CGSizeMake(aframe.size.width, MAXFLOAT)];
        aframe.size.height = size.height;
        baseLabel.frame = aframe;
    }else if (!aframe.size.width) {
        CGSize size = [baseLabel sizeThatFits:CGSizeMake(MAXFLOAT, 20)];
        aframe.size.width = size.width;
        baseLabel.frame = aframe;
    }
    //    baseLabel.adjustsFontSizeToFitWidth=YES
    baseLabel.backgroundColor=[UIColor clearColor];
    baseLabel.highlightedTextColor=acolor;//kVersion7?[UIColor whiteColor]:
    if (sView) {
        [sView addSubview:baseLabel];
    }
    
    return baseLabel;// autorelease];
}


+(UIButton*)buttonWithFrame:(CGRect)_frame title:(NSString*)_title image:(NSString*)_image bgimage:(NSString*)_bgimage supView:(UIView *)sView
{
    UIButton *baseButton=[UIButton buttonWithType:UIButtonTypeCustom];//[[UIButton alloc] initWithFrame:_frame];
    baseButton.frame=_frame;
    baseButton.titleLabel.font=fontTitle;
    if (_title) {
        [baseButton setTitle:_title forState:UIControlStateNormal];
        [baseButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    if (_image) {
        [baseButton setImage:[UIImage imageNamed:_image] forState:UIControlStateNormal];
    }
    if (_bgimage) {
        UIImage *bg = [UIImage imageNamed:_bgimage];
        [baseButton setBackgroundImage:bg forState:UIControlStateNormal];
        if (_frame.size.height<0.00001) {
            _frame.size.height = bg.size.height*_frame.size.width/bg.size.width;
            [baseButton setFrame:_frame];
        }else if(_frame.size.width<0.00001) {
            _frame.size.width = bg.size.width*_frame.size.height/bg.size.height;
            _frame.origin.x = (kScreenWidth-_frame.size.width)/2.0;
            [baseButton setFrame:_frame];
        }
    }
    if (sView) {
       [sView addSubview:baseButton];
    }
    
    return baseButton;// autorelease];
}
+(UIImageView*)imageviewWithFrame:(CGRect)_frame defaultimage:(NSString*)_image supView:(UIView *)sView
{
    return [self imageviewWithFrame:_frame defaultimage:_image stretchW:0 stretchH:0 supView:sView];// autorelease];
}
+(UIImageView*)imageviewWithFrame:(CGRect)_frame defaultimage:(NSString*)_image contentMode:(UIViewContentMode )cmode supView:(UIView *)sView{
    UIImageView *imageT=[self imageviewWithFrame:_frame defaultimage:_image stretchW:0 stretchH:0 supView:sView];
    [imageT setContentMode:cmode];
    return imageT;
}
//-1 if want stretch half of image.size
+(UIImageView*)imageviewWithFrame:(CGRect)_frame defaultimage:(NSString*)_image stretchW:(NSInteger)_w stretchH:(NSInteger)_h supView:(UIView *)sView
{
    UIImageView *imageview = nil;
    if(_image){
        if (_w&&_h) {
            UIImage *image = [UIImage imageNamed:_image];
            if (_w==-1) {
                _w = image.size.width/2;
            }
            if(_h==-1){
                _h = image.size.height/2;
            }
            imageview = [[UIImageView alloc] initWithImage:
                         [image stretchableImageWithLeftCapWidth:_w topCapHeight:_h]];
            imageview.contentMode=UIViewContentModeScaleToFill;
        }else{
            imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:_image]];
            imageview.contentMode=UIViewContentModeScaleAspectFill;
        }
    }
    if (CGRectIsEmpty(_frame)) {
        [imageview setFrame:CGRectMake(_frame.origin.x,_frame.origin.y, imageview.image.size.width, imageview.image.size.height)];
    }else{
        [imageview setFrame:_frame];
    }
    imageview.clipsToBounds=YES;
    if (sView) {
        [sView addSubview:imageview];
    }
    
    return  imageview;// autorelease];
}



+(UIView *)lineViewWithFrame:(CGRect)_frame supView:(UIView *)sView
{
    UIView *viewLine=[[UIView alloc] initWithFrame:_frame];
    viewLine.backgroundColor=rgbLineColor;
    if (sView) {
       [sView addSubview:viewLine]; 
    }
    return viewLine;// autorelease];
}

@end
