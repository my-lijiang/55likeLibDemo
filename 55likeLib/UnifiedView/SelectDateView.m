//
//  SelectDateView.m
//  ZKwwlk
//
//  Created by junseek on 14-7-24.
//  Copyright (c) 2014年 五五来客. All rights reserved.
//

#import "SelectDateView.h"

@interface SelectDateView (){
    
    UIDatePicker *datePicker;

}


@end
@implementation SelectDateView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor=RGBACOLOR(0, 0, 0, 0.4);
        
        
        

        UIControl *closeC=[[UIControl alloc]initWithFrame:self.bounds];
        [closeC addTarget:self action:@selector(closeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeC];
        closeC.frameHeight=kScreenHeight-(216+64);
        
        
        UIImageView *im=[RHMethods imageviewWithFrame:CGRectMake(0, kScreenHeight-(216+44), kScreenWidth, 44) defaultimage:@""];
        im.backgroundColor=rgbGray;
        [self addSubview:im];
        [self addSubview:[RHMethods imageviewWithFrame:CGRectMake(0, YH(im)-0.5, kScreenHeight, 0.5) defaultimage:@"userLine"]];
        UIButton *closeBtn1=[UIButton buttonWithType:UIButtonTypeCustom];
        closeBtn1.frame=CGRectMake(20,  Y(im), 120, 44);
        [closeBtn1 setTitle:@"取消" forState:UIControlStateNormal];
        [closeBtn1 setTitleColor:rgbpublicColor forState:UIControlStateNormal];
        [closeBtn1 setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [closeBtn1 addTarget:self action:@selector(closeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeBtn1];
        
        UIButton *OKBtn1=[UIButton buttonWithType:UIButtonTypeCustom];
        OKBtn1.frame=CGRectMake(kScreenWidth-140,  Y(im), 120, 44);
        [OKBtn1 setTitle:@"确定" forState:UIControlStateNormal];
        [OKBtn1 setTitleColor:rgbpublicColor forState:UIControlStateNormal];
        [OKBtn1 setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [OKBtn1 addTarget:self action:@selector(OkButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:OKBtn1];
        
        datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0,YH(im),kScreenWidth,216)];
        //设置中文显示
        NSLocale * locale = [[NSLocale alloc] initWithLocaleIdentifier:@"Chinese"];
        [datePicker setLocale:locale];
        datePicker.minimumDate=[NSDate date];
        //            [[UIDatePicker appearance] setTintColor:RGBCOLOR(245, 245, 245)];
        datePicker.backgroundColor = rgbGray;//RGBCOLOR(236, 234, 240);
        datePicker.timeZone = [NSTimeZone timeZoneWithName:@"GMT-8"];
        [self addSubview:datePicker];
        
        
        
    }
    return self;
}
-(void)closeButtonClicked{
    [self hidden];
}
-(void)OkButtonClicked{
    //发
    if ([self.delegate respondsToSelector:@selector(select:object:)]) {
        if ([self.strType isEqualToString:@"xsUpdate"]) {
            
            NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
            [dic setValue:self.strId forKey:@"strId"];
            [dic setValue:[NSString stringWithFormat:@"%f",[datePicker.date timeIntervalSince1970]] forKey:@"date"];
            
            [self.delegate select:self object:dic];

        }else{
            
            [self.delegate select:self object:datePicker.date];
        }
    }

    [self hidden];
}
- (void)show
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hidden) name:@"push_showLogin" object:nil];
    
    
    [[[UIApplication sharedApplication].windows objectAtIndex:0] addSubview:self];
    
    if ([self.strType isEqualToString:@"Birthday"]) {
        //生日
        datePicker.minimumDate=nil;
        datePicker.datePickerMode = UIDatePickerModeDate;
        datePicker.maximumDate=[NSDate date];
    }else if ([self.strType isEqualToString:@"time"]){
        datePicker.minimumDate=nil;
        datePicker.maximumDate=nil;
        datePicker.datePickerMode = UIDatePickerModeTime;
    }else if ([self.strType isEqualToString:@"AfterTodayDate"]) {
        datePicker.minimumDate=[NSDate date];
        datePicker.maximumDate=nil;
        datePicker.datePickerMode = UIDatePickerModeDate;
    }else if ([self.strType isEqualToString:@"date"]){
        datePicker.minimumDate=nil;
        datePicker.maximumDate=nil;
        datePicker.datePickerMode = UIDatePickerModeDate;
    }else{
        datePicker.maximumDate=nil;
        datePicker.minimumDate=nil;
        datePicker.datePickerMode=UIDatePickerModeDateAndTime;
    }
    
    if (self.strTime && [self.strTime notEmptyOrNull]) {
        NSDate *dateT=[NSDate dateWithTimeIntervalSince1970:[self.strTime integerValue]];
        [datePicker setDate:dateT animated:YES];
    }else{
        if ([self.strType isEqualToString:@"Birthday"]) {//3600/24/365/25
            NSInteger time_t=[[NSDate date] timeIntervalSince1970];
             NSDate *dateT=[NSDate dateWithTimeIntervalSince1970:time_t-25*3600*24*365];
            [datePicker setDate:dateT animated:YES];
        }
    }
    
    
    
    self.hidden = NO;
    self.alpha = 0.0f;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hidden
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
