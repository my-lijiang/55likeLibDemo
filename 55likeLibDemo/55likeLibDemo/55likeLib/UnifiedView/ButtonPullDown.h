//
//  ButtonPullDown.h
//  SampleCheck55like
//
//  Created by junseek on 2017/2/6.
//  Copyright © 2017年 55like lj. All rights reserved.
//右侧带下来标志的按钮

#import <UIKit/UIKit.h>

@interface ButtonPullDown : UIButton

-(instancetype)initWithFrame:(CGRect)frame withSel:(SEL)sel addTarget:(id)target buttonTitle:(NSString *)strTitle;
-(void)setButtonTitle:(NSString *)strTitle;


@end
