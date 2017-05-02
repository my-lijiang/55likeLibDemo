//
//  NavigationBarToggleTabView.h
//  XinKaiFa55like
//
//  Created by junseek on 2017/3/23.
//  Copyright © 2017年 55like lj. All rights reserved.
//导航栏切换选项卡

#import <UIKit/UIKit.h>

typedef void (^NavigationBarToggleTabBlock)(NSDictionary *dicSelect);
@interface NavigationBarToggleTabView : UIView


@property (nonatomic, strong) NavigationBarToggleTabBlock toggleTab;
////titleArray:@[@{@"title":@"xxx",@"id":@"1"}]
-(void)setTiltelArray:(NSArray*)titleArray toggleTab:(NavigationBarToggleTabBlock)aToggleTab;
@property(nonatomic,strong)UIColor *titleColor;//选择颜色

@end
