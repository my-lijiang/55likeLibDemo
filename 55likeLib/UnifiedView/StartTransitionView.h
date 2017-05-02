//
//  StartTransitionView.h
//  HanYu55like
//
//  Created by junseek on 15-5-20.
//  Copyright (c) 2015年 五五来客 lj. All rights reserved.
//
//启动过渡view


#import <UIKit/UIKit.h>

@interface StartTransitionView : UIView

///广告页必须都为Yes 才能Hidden
///是否停止倒计时
@property (nonatomic,assign) BOOL isStopCountdown;
///是否停止数据交互
@property (nonatomic,assign) BOOL isStopDataInteraction;
///引导页
-(void)showGuide;

- (void)show;
- (void)hidden;
@end
