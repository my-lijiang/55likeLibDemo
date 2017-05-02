//
//  TopToggletabView.m
//  XinKaiFa55like
//
//  Created by junseek on 2017/3/24.
//  Copyright © 2017年 55like lj. All rights reserved.
//

#import "TopToggletabView.h"

@interface TopToggletabView(){
    NSArray *arrayTempTitles;
    UIView *viewLine;
}

@end

@implementation TopToggletabView
-(instancetype)initWithFrame:(CGRect)frame{
    self= [super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];
        
    }
    return self;
}
-(void)setTiltelArray:(NSArray*)titleArray toggleTab:(TopToggletabBlock)aToggleTab{
    [self setTiltelArray:titleArray toggleTab:aToggleTab selectIndex:0];
}
-(void)setTiltelArray:(NSArray*)titleArray toggleTab:(TopToggletabBlock)aToggleTab selectIndex:(NSInteger)sIndex{
    self.toggleTab=aToggleTab;
    if ([arrayTempTitles isEqualToArray:titleArray]) {
        UIButton *btn;
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:[UIButton class]]) {
                UIButton *btnT=(UIButton *)view;
                if (btnT.tag==sIndex) {
                    btnT.selected=YES;
                    btn=btnT;
                }else{
                    btnT.selected=NO;
                }
                
            }
        }
        if (btn) {
            btn.selected=YES;
            viewLine.hidden=NO;
            [UIView animateWithDuration:0.3 animations:^{
                viewLine.frameX=btn.frameX;
            } completion:^(BOOL finished) {
                
            }];
            self.toggleTab?self.toggleTab(arrayTempTitles[btn.tag]):nil;
        }else  if (sIndex==-1) {
            self.toggleTab?self.toggleTab(@{}):nil;
            viewLine.hidden=YES;
        }
        return;
    }
    arrayTempTitles=titleArray;
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    [self addSubview:[RHMethods lineViewWithFrame:CGRectMake(0, H(self)-0.5, W(self),0.5)]];
    float fw=W(self)/[titleArray count];
    
    viewLine=[RHMethods lineViewWithFrame:CGRectMake(0, H(self)-2, fw, 2)];
    [viewLine setBackgroundColor:rgbpublicColor];
    [self addSubview:viewLine];
    
    for (int i=0; i<titleArray.count; i++) {
        NSDictionary *dicT=titleArray[i];
        UIButton*btn=[[UIButton alloc] initWithFrame:CGRectMake(i*fw, 0, fw, H(self))];
        btn.titleLabel.font=Font(15);
        [btn setTitle:[dicT valueForJSONStrKey:@"title"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(toggleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        btn.tag=i;
        [btn setTitleColor:rgbTitleColor forState:UIControlStateNormal];
        [btn setTitleColor:rgbpublicColor forState:UIControlStateSelected];        
        btn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        if (i==sIndex) {
            [self toggleButtonClicked:btn];
        }
        if (i<[titleArray count]-1){
            [self addSubview:[RHMethods lineViewWithFrame:CGRectMake(XW(btn)-0.5, (H(self)-20)/2, 0.5,20)]];
        }
    }
    if (sIndex==-1) {
        self.toggleTab?self.toggleTab(@{}):nil;
        viewLine.hidden=YES;
    }
    
    
}
#pragma mark button
-(void)toggleButtonClicked:(UIButton *)btn{
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *btnT=(UIButton *)view;
            btnT.selected=NO;
        }
    }
    btn.selected=YES;
    viewLine.hidden=NO;
    [UIView animateWithDuration:0.3 animations:^{
        viewLine.frameX=btn.frameX;
    } completion:^(BOOL finished) {
        
    }];
    self.toggleTab?self.toggleTab(arrayTempTitles[btn.tag]):nil;
    //    self.toggleTab=nil;
    
}


-(void)dealloc{
    self.toggleTab=nil;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
