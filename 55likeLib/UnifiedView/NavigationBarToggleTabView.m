//
//  NavigationBarToggleTabView.m
//  XinKaiFa55like
//
//  Created by junseek on 2017/3/23.
//  Copyright © 2017年 55like lj. All rights reserved.
//

#import "NavigationBarToggleTabView.h"

@interface NavigationBarToggleTabView(){
    NSArray *arrayTempTitles;
    
}

@end

@implementation NavigationBarToggleTabView
-(instancetype)initWithFrame:(CGRect)frame{
    self= [super initWithFrame:frame];
    if (self) {
        self.backgroundColor=rgbpublicColor;
        self.layer.borderColor=[rgbpublicColor CGColor];//[UIColor whiteColor]
        self.layer.borderWidth=1;
        
        self.layer.cornerRadius=5;
        self.layer.masksToBounds=YES;
    }
    return self;
}

-(void)setTiltelArray:(NSArray*)titleArray toggleTab:(NavigationBarToggleTabBlock)aToggleTab{
    self.toggleTab=aToggleTab;
    arrayTempTitles=titleArray;
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    float fw=W(self)/[titleArray count];
    for (int i=0; i<titleArray.count; i++) {
        NSDictionary *dicT=titleArray[i];
        UIButton*btn=[[UIButton alloc] initWithFrame:CGRectMake(i*fw, 0, fw, H(self))];
        btn.titleLabel.font=Font(14);
        [btn setTitle:[dicT valueForJSONStrKey:@"title"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(toggleTabButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        btn.tag=i;
        btn.backgroundColor=[UIColor whiteColor];
        [btn setTitleColor:rgbpublicColor forState:UIControlStateNormal];
        
        if (i==0) {
            [self toggleTabButtonClicked:btn];
        }
        if (i<[titleArray count]-1){
            UIView *viewLine=[RHMethods lineViewWithFrame:CGRectMake(XW(btn)-1, 0, 1, H(self)) supView:self];
            viewLine.backgroundColor=rgbpublicColor;
        }
    }
    
}
#pragma mark button
-(void)toggleTabButtonClicked:(UIButton *)btn{
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *btnT=(UIButton *)view;
            btnT.backgroundColor=[UIColor whiteColor];
            [btnT setTitleColor:rgbpublicColor forState:UIControlStateNormal];
        }
    }
    
    if (_titleColor) {
        btn.backgroundColor=[UIColor clearColor];
        [btn setTitleColor:_titleColor forState:UIControlStateNormal];
    }else{
        btn.backgroundColor=[UIColor clearColor];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
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
