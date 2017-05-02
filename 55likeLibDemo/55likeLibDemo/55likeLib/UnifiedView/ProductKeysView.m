//
//  ProductKeysView.m
//  XinKaiFa55like
//
//  Created by junseek on 2017/2/10.
//  Copyright © 2017年 55like lj. All rights reserved.
//

#import "ProductKeysView.h"
@interface ProductKeysView(){
    UIScrollView *scrollBG;
    
    
}

@end

@implementation ProductKeysView


-(instancetype)init{
    self=[super init];
    if (self) {
        self.backgroundColor=RGBACOLOR(50, 50, 50, 0.4);
        self.frame=CGRectMake(0, 108, kScreenWidth, 100);
        
        UILabel *lblT=[RHMethods labelWithFrame:CGRectMake(0,0, W(self), 40) font:fontTitle color:rgbTitleColor text:@"   历史搜索" supView:self];
        lblT.backgroundColor=rgbGray;
        UIButton *btnDelete=[RHMethods buttonWithFrame:CGRectMake(W(self)-60, 0, 60,40) title:nil image:@"Keyshanchu" bgimage:nil supView:self];
        [btnDelete addTarget:self action:@selector(deleteButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        

        
        scrollBG=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, W(self), H(self)-40)];
        [scrollBG setBackgroundColor:[UIColor clearColor]];
        [self addSubview:scrollBG];
        [scrollBG setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        
        [scrollBG addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidden)]];
        
    }
    return self;
}
-(void)showAllArray:(NSArray *)arrayTitle{
    for (UIView *view in [scrollBG subviews]) {
        [view removeFromSuperview];
    }
    float xt=10.0;
    float yt=10.0;
    float tw=0.0;
    int i=0;
    for (NSString *strKey in arrayTitle) {//NSDictionary *dic//[dic valueForJSONStrKey:@"txts"]
        UIButton *btn=[RHMethods buttonWithFrame:CGRectMake(0, 0, 23, 23) title:strKey image:@"" bgimage:@""];
        btn.titleLabel.font=fontTxtContent;
        [btn setTitleColor:rgbTitleColor forState:UIControlStateNormal];
        CGSize size = [btn.titleLabel sizeThatFits:CGSizeMake(MAXFLOAT, 20)];
        tw=size.width+15;
        if (tw>(kScreenWidth-20)-xt) {
            //大于剩余的宽
            if (xt>0) {
                //换一行
                xt=10.0;
                yt+=28+5;
            }
            tw=tw>(kScreenWidth-20)?(kScreenWidth-20):tw;
        }
        btn.frame=CGRectMake(xt, yt, tw, 28);
        ///////v3更换颜色  ---10-28  更改回去
        [btn setBackgroundImage:[[Utility Share] imageFromColor:RGBCOLOR(230, 230, 230) rect:btn.bounds.size] forState:UIControlStateNormal];//
        //[btn setBackgroundImage:[[Utility Share] imageFromColor:rgbOrange rect:btn.bounds.size] forState:UIControlStateSelected];//rgbOrange
        [btn addTarget:self action:@selector(labelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btn viewLayerRoundBorderWidth:1 cornerRadius:4 borderColor:[UIColor clearColor]];
        [scrollBG addSubview:btn];
        xt+=tw+5;
        i++;
    }
    yt=xt>1?yt+28:yt;
    
    [scrollBG setContentSize:CGSizeMake(kScreenWidth, yt>H(scrollBG)+1?yt:(H(scrollBG)+1))];
    [self show];
}
-(void)show{
    self.hidden=NO;
    self.alpha=0.1;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha=1;
    } completion:^(BOOL finished) {
        
    }];
}
-(void)hidden{
    [[[self supViewController] view] endEditing:YES];
    self.hidden=YES;
}
-(void)labelButtonClicked:(UIButton *)btn{
    [self hidden];
    if ([self.delegate respondsToSelector:@selector(productKeysView:clickeDic:)]) {
        [self.delegate productKeysView:self clickeDic:@{@"txt":btn.titleLabel.text}];
    }
}
#pragma mark button
-(void)deleteButtonClicked{
    //
    [Utility removeForKey:@"searchKey"];
    self.hidden=YES;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
